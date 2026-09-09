#!/usr/bin/env bash
# install_wp_plugin.sh — Install and activate a WordPress MCP plugin via WP-CLI.
#
# Supports:
#   mcp-adapter  — official WordPress MCP Adapter (from pinned GitHub release)
#   ai-engine    — AI Engine plugin (from WordPress.org)
#
# Hardened:
#   - Downloads to a private temp directory (mktemp -d)
#   - Pins mcp-adapter to the latest stable GitHub release tag
#   - Never prints the generated Bearer Token to stdout
#   - Writes tokens to a file with 0600 permissions
#   - Avoids composer as root when possible
#   - Quoted paths and args throughout
#
# Usage:
#   bash install_wp_plugin.sh mcp-adapter --wp-path=/var/www/html
#   bash install_wp_plugin.sh ai-engine --wp-path=/var/www/html
#   bash install_wp_plugin.sh mcp-adapter --wp-path=/var/www/html --dry-run
#
# Exit codes: 0 ok / 1 invalid args / 2 wp-cli missing / 3 download failed / 4 activate failed
set -euo pipefail

PLUGIN=""
WP_PATH=""
WEB_USER=""
DRY_RUN=0

while [ $# -gt 0 ]; do
  case "$1" in
    mcp-adapter|ai-engine) PLUGIN="$1"; shift ;;
    --wp-path=*)   WP_PATH="${1#*=}"; shift ;;
    --web-user=*)  WEB_USER="${1#*=}"; shift ;;
    --dry-run)     DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,22p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 64 ;;
  esac
done

if [ -z "$PLUGIN" ]; then
  echo "Error: specify plugin name (mcp-adapter or ai-engine)" >&2
  exit 1
fi
if [ -z "$WP_PATH" ]; then
  echo "Error: --wp-path= is required (e.g. --wp-path=/var/www/html)" >&2
  exit 1
fi
if [ ! -d "$WP_PATH" ]; then
  echo "Error: WordPress path does not exist: $WP_PATH" >&2
  exit 1
fi

# Detect web user if not specified
if [ -z "$WEB_USER" ]; then
  WEB_USER=$(stat -c '%U' "$WP_PATH/wp-content/plugins/" 2>/dev/null || echo "www-data")
fi

WP="wp --path=$WP_PATH --allow-root"

if ! command -v wp >/dev/null 2>&1; then
  echo "Error: wp-cli not found." >&2
  exit 2
fi

PLUGINS_DIR="$WP_PATH/wp-content/plugins"
TMPDIR=""

cleanup() {
  if [ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[dry-run] Would install $PLUGIN into $WP_PATH (web user: $WEB_USER)"
  [ "$PLUGIN" = "mcp-adapter" ] && echo "[dry-run] Would download and install the latest pinned mcp-adapter release"
  echo "[dry-run] Would activate plugin and flush rewrites"
  exit 0
fi

TMPDIR=$(mktemp -d -t "wp-mcp-XXXXXX")

# ── mcp-adapter ──────────────────────────────────────────────────────
if [ "$PLUGIN" = "mcp-adapter" ]; then
  echo "=== Installing mcp-adapter (official WordPress) ==="

  if [ -d "$PLUGINS_DIR/mcp-adapter" ] && $WP plugin is-active mcp-adapter 2>/dev/null; then
    echo "mcp-adapter is already installed and active."
    exit 0
  fi

  # Resolve the latest stable release tag from GitHub
  echo "→ Resolving latest mcp-adapter release..."
  RELEASE_TAG=$(curl -fsSL "https://api.github.com/repos/WordPress/mcp-adapter/releases/latest" 2>/dev/null \
    | grep -oP '"tag_name":\s*"\K[^"]+' || true)
  if [ -z "$RELEASE_TAG" ]; then
    echo "Error: could not resolve latest mcp-adapter release from GitHub" >&2
    exit 3
  fi

  echo "→ Downloading mcp-adapter ${RELEASE_TAG}..."
  curl -fsSL -o "$TMPDIR/mcp-adapter.zip" "https://github.com/WordPress/mcp-adapter/archive/refs/tags/${RELEASE_TAG}.zip" || {
    echo "Error: failed to download mcp-adapter ${RELEASE_TAG}" >&2
    exit 3
  }

  unzip -q "$TMPDIR/mcp-adapter.zip" -d "$TMPDIR/extract"
  SRC=$(find "$TMPDIR/extract" -maxdepth 1 -type d -name 'mcp-adapter-*' | head -n 1)
  if [ -z "$SRC" ]; then
    echo "Error: extracted folder not found" >&2
    exit 3
  fi

  # Check whether we need elevated privileges
  if [ ! -w "$PLUGINS_DIR" ]; then
    echo "⚠ Plugins dir is not writable by the current user."
    echo "  This script will use sudo to copy files into $PLUGINS_DIR."
    echo "  Make sure the site is one you control and the backup is up to date."
    SUDO="sudo"
  else
    SUDO=""
  fi

  $SUDO rm -rf "$PLUGINS_DIR/mcp-adapter"
  $SUDO cp -r "$SRC" "$PLUGINS_DIR/mcp-adapter"
  $SUDO chown -R "${WEB_USER}:${WEB_USER}" "$PLUGINS_DIR/mcp-adapter"

  # Composer install (vendor/ is not shipped) — avoid running as root
  if [ -f "$PLUGINS_DIR/mcp-adapter/composer.json" ] && [ ! -d "$PLUGINS_DIR/mcp-adapter/vendor" ]; then
    if ! command -v composer >/dev/null 2>&1; then
      echo "Warning: composer not found. The plugin needs 'composer install' in its directory." >&2
      echo "  Install composer: https://getcomposer.org/download/" >&2
    else
      cd "$PLUGINS_DIR/mcp-adapter"
      # Run composer as the web user when possible so vendor is not owned by root
      if [ "$(id -u)" -eq 0 ] && ! id -u "$WEB_USER" >/dev/null 2>&1; then
        echo "Error: composer must not run as root. Re-run with --web-user=<user> or as a non-root user." >&2
        exit 1
      fi
      if [ "$(id -u)" -eq 0 ]; then
        sudo -u "$WEB_USER" composer install --no-dev --no-interaction --optimize-autoloader 2>&1 | tail -5
      else
        composer install --no-dev --no-interaction --optimize-autoloader 2>&1 | tail -5
      fi
      $SUDO chown -R "${WEB_USER}:${WEB_USER}" "$PLUGINS_DIR/mcp-adapter/vendor" 2>/dev/null || true
    fi
  fi

  # Enable Application Passwords (required for Basic Auth)
  MU_DIR="$WP_PATH/wp-content/mu-plugins"
  if [ ! -f "$MU_DIR/enable-app-passwords.php" ]; then
    echo "→ Enabling Application Passwords..."
    $SUDO mkdir -p "$MU_DIR"
    $SUDO tee "$MU_DIR/enable-app-passwords.php" >/dev/null <<'EOF'
<?php
add_filter('wp_is_application_passwords_available', '__return_true');
add_filter('wp_is_application_passwords_api_available', '__return_true');
EOF
    $SUDO chown "${WEB_USER}:${WEB_USER}" "$MU_DIR/enable-app-passwords.php"
    $SUDO chmod 0644 "$MU_DIR/enable-app-passwords.php"
  fi

  # Patch false-positive "Another version already loaded" notice
  AUTOLOADER="$PLUGINS_DIR/mcp-adapter/includes/Autoloader.php"
  if [ -f "$AUTOLOADER" ] && ! grep -q "ReflectionClass" "$AUTOLOADER" 2>/dev/null; then
    echo "→ Patching Autoloader false-positive (is_loaded_elsewhere)..."
    $SUDO cp "$AUTOLOADER" "$AUTOLOADER.bak"
    $SUDO python3 - "$AUTOLOADER" <<'PY'
import sys
path = sys.argv[1]
with open(path) as f:
    content = f.read()
old = "\t\tself::loaded_elsewhere_notice();\n\t\treturn true;\n\t}"
new = """\t\t// Check if the class was loaded from our own plugin directory.
\t\t// Without this check, the plugins_loaded recheck finds the class
\t\t// that was loaded by our own autoloader (false positive).
\t\t$ref = new \\ReflectionClass( Core\\McpAdapter::class );
\t\t$expected_dir = plugin_dir_path( __DIR__ );
\t\t$actual_file  = $ref->getFileName();
\t\tif ( is_string( $actual_file ) && strpos( $actual_file, $expected_dir ) === 0 ) {
\t\t\treturn false;
\t\t}

\t\tself::loaded_elsewhere_notice();
\t\treturn true;
\t}"""
if old in content:
    content = content.replace(old, new, 1)
    with open(path, "w") as f:
        f.write(content)
    print("  patched")
else:
    print("  (pattern not found — may already be patched or code changed)")
PY
    $SUDO chown "${WEB_USER}:${WEB_USER}" "$AUTOLOADER"
  fi

  # Activate
  echo "→ Activating plugin..."
  $WP plugin activate mcp-adapter || { echo "Error: activation failed" >&2; exit 4; }
  $WP rewrite flush
  echo "✓ mcp-adapter installed and active."
  echo ""
  echo "Next steps:"
  echo "  1. Create an Application Password:"
  echo "     $WP user application-password create <user_id> \"mcp-clients\""
  echo "  2. Endpoint: ${WP_URL:-https://yourdomain.com}/wp-json/mcp/mcp-adapter-default-server"

# ── ai-engine ────────────────────────────────────────────────────────
elif [ "$PLUGIN" = "ai-engine" ]; then
  echo "=== Installing AI Engine ==="

  if [ -d "$PLUGINS_DIR/ai-engine" ] && $WP plugin is-active ai-engine 2>/dev/null; then
    echo "ai-engine is already installed and active."
  else
    echo "→ Attempting wp plugin install..."
    if $WP plugin install ai-engine --activate 2>/dev/null; then
      echo "✓ Installed via wp plugin install."
    else
      echo "→ wp plugin install failed, downloading manually..."
      curl -fsSL -o "$TMPDIR/ai-engine.zip" "https://downloads.wordpress.org/plugin/ai-engine.zip" || {
        echo "Error: failed to download ai-engine" >&2
        exit 3
      }
      unzip -q "$TMPDIR/ai-engine.zip" -d "$TMPDIR/extract"
      $SUDO cp -r "$TMPDIR/extract/ai-engine" "$PLUGINS_DIR/ai-engine"
      $SUDO chown -R "${WEB_USER}:${WEB_USER}" "$PLUGINS_DIR/ai-engine"
      $WP plugin activate ai-engine || { echo "Error: activation failed" >&2; exit 4; }
    fi
    $WP rewrite flush
  fi

  # Enable MCP module
  echo "→ Enabling MCP module..."
  $WP eval '
$o = get_option("mwai_options");
$o["module_mcp"] = true;
update_option("mwai_options", $o);
echo "module_mcp: " . var_export($o["module_mcp"], true) . "\n";
'

  # Generate Bearer Token if not set
  CURRENT_TOKEN=$($WP eval 'echo get_option("mwai_options")["mcp_bearer_token"] ?? "";' 2>/dev/null || echo "")
  if [ -z "$CURRENT_TOKEN" ] || [ "$CURRENT_TOKEN" = "null" ]; then
    echo "→ Generating Bearer Token..."
    TOKEN=$(openssl rand -hex 24)
    $WP eval '
$o = get_option("mwai_options");
$o["mcp_bearer_token"] = "'"$TOKEN"'";
update_option("mwai_options", $o);
'
    TOKEN_FILE="$HOME/.wp-mcp-ai-engine-token"
    printf '%s\n' "$TOKEN" > "$TOKEN_FILE"
    chmod 0600 "$TOKEN_FILE"
    echo "✓ Bearer Token generated and saved to: $TOKEN_FILE (permissions 0600)"
    echo "  Read it securely when needed. Never commit, share, log, or print this token."
  else
    echo "  Bearer Token already set (hidden for security)."
  fi

  $WP rewrite flush
  echo "✓ AI Engine installed, MCP enabled."
  echo ""
  echo "Endpoint: ${WP_URL:-https://yourdomain.com}/wp-json/mcp/v1/http"
  echo "Auth: Authorization: Bearer <token>"
fi
