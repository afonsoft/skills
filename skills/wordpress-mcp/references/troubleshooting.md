# WordPress MCP — extended troubleshooting

## mcp-adapter (Path A)

### Endpoint returns 404

**Cause:** Plugin not active, or `vendor/` directory missing (composer dependencies not installed).

**Fix:**
```bash
wp plugin status mcp-adapter --path=$WP_PATH --allow-root
# If not active:
wp plugin activate mcp-adapter --path=$WP_PATH --allow-root

# If vendor/ is missing:
cd $WP_PATH/wp-content/plugins/mcp-adapter
composer install --no-dev --no-interaction --optimize-autoloader
wp rewrite flush --path=$WP_PATH --allow-root
```

### `composer install` fails with jetpack-autoloader error

**Cause:** Composer < 2.2. The `automattic/jetpack-autoloader` package requires `composer-plugin-api ^2.2`.

**Fix:**
```bash
composer --version  # check version
sudo composer self-update --2  # update to latest 2.x
composer install --no-dev --no-interaction --optimize-autoloader
```

### Endpoint returns 401 Unauthorized

**Cause:** Application Passwords are disabled on the WordPress install.

**Fix:** Create a mu-plugin to force-enable:
```bash
sudo tee $WP_PATH/wp-content/mu-plugins/enable-app-passwords.php > /dev/null <<'EOF'
<?php
add_filter('wp_is_application_passwords_available', '__return_true');
add_filter('wp_is_application_passwords_api_available', '__return_true');
EOF
```

### `tools/list` returns empty array

**Cause:** The `notifications/initialized` step was skipped, or the `Mcp-Session-Id` header is missing.

**Fix:** The mcp-adapter requires a proper MCP handshake:
1. Send `initialize` → capture `Mcp-Session-Id` from response headers
2. Send `notifications/initialized` with the session header (returns HTTP 202)
3. Send `tools/list` with the session header

```bash
# Correct flow:
SESSION=$(curl -s -i -X POST "$URL" -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}' \
  | grep -i "mcp-session-id" | awk '{print $2}' | tr -d '\r\n')

curl -s -X POST "$URL" -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" -H "Mcp-Session-Id: $SESSION" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' -o /dev/null

curl -s -X POST "$URL" -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" -H "Mcp-Session-Id: $SESSION" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
```

> MCP clients (Claude Code, Devin, etc.) handle this automatically. This is only an issue when testing with curl.

### Application Password creation fails

**Cause:** `wp_is_application_passwords_available()` returns false despite WP 5.6+.

**Fix:** Some hosts (and local environments) disable Application Passwords. Use the mu-plugin from A.2 to force-enable.

### Admin notice: "Another version of MCP Adapter is already loaded"

**Cause:** Bug (false positive) in `Autoloader::is_loaded_elsewhere()`. The method rechecks `class_exists('WP\MCP\Core\McpAdapter')` on `plugins_loaded`, but by then our own plugin has already loaded the class via `McpAdapter::instance()`. The recheck finds the class and incorrectly concludes it was loaded by another plugin.

This is **not** caused by another plugin bundling MCP Adapter — it's a self-detection bug. It affects any standalone install of mcp-adapter v0.6.1 (and likely earlier).

**Fix:** Patch `includes/Autoloader.php` in the plugin to check if the class was loaded from our own directory:

```bash
WP_PATH=/www/wwwroot/yourdomain.com
FILE=$WP_PATH/wp-content/plugins/mcp-adapter/includes/Autoloader.php

# Backup
sudo cp "$FILE" "$FILE.bak"

# Apply patch: add ReflectionClass check before loaded_elsewhere_notice()
sudo python3 <<'PY'
path = "/www/wwwroot/yourdomain.com/wp-content/plugins/mcp-adapter/includes/Autoloader.php"
# Replace WP_PATH above with your actual path
with open(path) as f:
    content = f.read()

old = """		self::loaded_elsewhere_notice();
		return true;
	}"""

new = """		// Check if the class was loaded from our own plugin directory.
		// Without this check, the plugins_loaded recheck finds the class
		// that was loaded by our own autoloader (false positive).
		$ref = new \\ReflectionClass( Core\\McpAdapter::class );
		$expected_dir = plugin_dir_path( __DIR__ );
		$actual_file  = $ref->getFileName();
		if ( is_string( $actual_file ) && strpos( $actual_file, $expected_dir ) === 0 ) {
			return false;
		}

		self::loaded_elsewhere_notice();
		return true;
	}"""

content = content.replace(old, new, 1)
with open(path, "w") as f:
    f.write(content)
print("Patched Autoloader.php")
PY

# Verify syntax
php -l "$FILE"
```

> **Warning:** This patch will be overwritten on plugin update. Check if the upstream fix has been merged before re-applying after an update.

---

## AI Engine (Path B)

### Endpoint returns 404

**Cause:** `module_mcp` option is `false` (MCP module not enabled).

**Fix:**
```bash
wp eval '
$o = get_option("mwai_options");
$o["module_mcp"] = true;
update_option("mwai_options", $o);
' --path=$WP_PATH --allow-root
wp rewrite flush --path=$WP_PATH --allow-root
```

### Endpoint returns 401 Unauthorized

**Cause:** Wrong or missing Bearer Token.

**Fix:** Check the stored token and regenerate if needed:
```bash
wp eval 'echo get_option("mwai_options")["mcp_bearer_token"];' --path=$WP_PATH --allow-root
# If empty or wrong, regenerate:
TOKEN=$(openssl rand -hex 24)
wp eval '
$o = get_option("mwai_options");
$o["mcp_bearer_token"] = "'"$TOKEN"'";
update_option("mwai_options", $o);
' --path=$WP_PATH --allow-root
echo "New token: $TOKEN"
```

### `wp plugin install ai-engine` fails

**Cause:** Some hosts block outbound downloads from WordPress.org.

**Fix:** Download manually and copy:
```bash
cd /tmp
curl -L -o ai-engine.zip "https://downloads.wordpress.org/plugin/ai-engine.zip"
unzip -q ai-engine.zip
sudo cp -r ai-engine $WP_PATH/wp-content/plugins/
sudo chown -R www:www $WP_PATH/wp-content/plugins/ai-engine
wp plugin activate ai-engine --path=$WP_PATH --allow-root
```

### Tools missing (e.g., no WooCommerce tools)

**Cause:** Feature flags are off. Only WordPress core tools are enabled by default.

**Fix:** Enable the feature in `mwai_options`:
```bash
wp eval '
$o = get_option("mwai_options");
$o["mcp_feature_woocommerce"] = true;  // requires WooCommerce plugin
update_option("mwai_options", $o);
' --path=$WP_PATH --allow-root
```

Available features: `mcp_feature_plugins`, `mcp_feature_themes`, `mcp_feature_database`, `mcp_feature_polylang`, `mcp_feature_woocommerce`, `mcp_feature_seo_engine`, `mcp_feature_social_engine`, `mcp_feature_dynamic_rest`.

---

## MCP client config issues

### Server silently ignored (no tools, no error)

**Cause:** Wrong field name for the platform. See `references/platform-quirks.md`.

**Common mistakes:**
- Gemini CLI / AGY: used `url` instead of `httpUrl`
- OpenCode: used `mcpServers` instead of `mcp`
- Codex: headers not in TOML sub-table
- Claude Code: missing `type: "http"`

**Fix:** Use the automated setup script or consult `references/mcp-config.md` for the exact format per platform.

### Devin CLI: server only works in one project

**Cause:** Added without `-s user` (project-scoped instead of global).

**Fix:**
```bash
devin mcp remove wordpress-mcp
devin mcp add -s user wordpress-mcp "..." --header "..."
```

### OpenCode: `opencode mcp add` writes to wrong file

**Cause:** OpenCode may write to `~/.config/opencode/opencode.json` (not `config.json`).

**Fix:** Check both files:
```bash
cat ~/.config/opencode/opencode.json
cat ~/.config/opencode/config.json
```

The MCP config lives in `opencode.json`, while `config.json` holds other settings.

---

## aaPanel / BT-Panel specific

### WP-CLI uses wrong PHP version

aaPanel manages multiple PHP versions. WP-CLI may pick the wrong one.

**Fix:**
```bash
# Check which PHP WP-CLI uses
wp --info --path=$WP_PATH --allow-root | grep "PHP version"

# If wrong, set the path:
WP_PHP=/www/server/php/85/bin/php
$WP_PHP /usr/local/bin/wp plugin list --path=$WP_PATH --allow-root
```

### File permissions after plugin install

aaPanel uses `www:www` as the web user. Files copied as `root` or `ubuntu` won't be readable by PHP-FPM.

**Fix:**
```bash
sudo chown -R www:www $WP_PATH/wp-content/plugins/mcp-adapter
sudo chown -R www:www $WP_PATH/wp-content/plugins/ai-engine
sudo chown -R www:www $WP_PATH/wp-content/mu-plugins/
```

### PHP-FPM needs restart after mu-plugin changes

Sometimes PHP-FPM caches the plugin list. Restart it:
```bash
# aaPanel: via the panel UI, or:
sudo /etc/init.d/php-fpm-85 restart
# or
sudo systemctl restart php8.5-fpm
```

---

## Media & uploads

### Media upload fails with permission error

**Symptom:** `wp_upload_media` (MCP) or `wp media import` (WP-CLI) returns:
```
Warning: Unable to import file 'image.png'. Reason: O arquivo enviado não pode ser movido para wp-content/uploads/YYYY/MM.
```

**Cause:** The uploads directory is owned by the web user (`www:www` on aaPanel). WP-CLI runs as `ubuntu` or `root`, which cannot write to that directory.

**Fix — manual copy + register as attachment:**
```bash
WP_PATH=/www/wwwroot/yourdomain.com
UPLOAD_DIR=$WP_PATH/wp-content/uploads/2026/09

# 1. Copy with sudo
sudo cp /tmp/image.png $UPLOAD_DIR/image.png
sudo chown www:www $UPLOAD_DIR/image.png
sudo chmod 644 $UPLOAD_DIR/image.png

# 2. Register as WordPress attachment
ATTACHMENT_ID=$(wp post create \
  --post_type=attachment \
  --post_status=inherit \
  --post_title="My Image" \
  --post_mime_type="image/png" \
  --guid="https://yourdomain.com/wp-content/uploads/2026/09/image.png" \
  --porcelain --path=$WP_PATH 2>/dev/null | tail -1)

# 3. Set _wp_attached_file meta (critical!)
wp post meta update $ATTACHMENT_ID _wp_attached_file "2026/09/image.png" --path=$WP_PATH
```

> **Why `wp media import` fails but `wp post create` works:** `wp media import` tries to move the file into the uploads directory (needs write permission). `wp post create` only creates the database record (no file move). The file is already in place from the `sudo cp` step.

### `mwai_image` returns "No API Key provided"

**Symptom:**
```
The tool "mwai_image" failed: No API Key provided. Please visit the Settings. (ChatML Engine)
```

**Cause:** AI Engine's image generation module has no API key configured.

**Fix:** Configure an API key in WordPress Admin → AI Engine → Settings → API Keys. Add a key for an image provider (OpenAI DALL-E, Stability AI, etc.). There is no WP-CLI shortcut for this — it must be done in the admin UI.

> **Alternative:** If you only need technology logos or icons (not AI-generated art), download them from SimpleIcons CDN and upload manually (see `references/real-world-workflows.md` → "Convert SVG icons to PNG and upload").

---

## Cloudflare cache

### Changes not visible on the live site

**Symptom:** Content updated via MCP, but `curl https://yourdomain.com/` still shows old content.

**Cause:** Cloudflare caches full pages and assets. `wp cache flush` only clears the WordPress object cache, NOT Cloudflare.

**Fix — cache-busting query strings:**
```bash
# Bypass Cloudflare cache for verification
curl -s "https://yourdomain.com/?nocache=1" | grep "new content"
curl -s "https://yourdomain.com/?nocache=2"
# Increment the number each time

# For specific assets:
curl -sI "https://yourdomain.com/wp-content/uploads/2026/09/image.png?nocache=1"
```

**Fix — purge via Cloudflare API (requires API token + zone ID):**
```bash
# Get zone ID
ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=yourdomain.com" \
  -H "Authorization: Bearer $CF_API_TOKEN" | python3 -c "import sys,json; print(json.load(sys.stdin)['result'][0]['id'])")

# Purge everything (use sparingly)
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"purge_everything": true}'

# Or purge specific URLs
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
  -H "Authorization: Bearer $CF_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"files": ["https://yourdomain.com/", "https://yourdomain.com/wp-content/uploads/2026/09/image.png"]}'
```

> **Cloudflare Tunnel note:** If using Cloudflare Tunnel (`cloudflared`), the tunnel config is at `~/.cloudflared/config.yml`. The tunnel itself doesn't control cache — cache rules are in the Cloudflare dashboard.

---

## WP-CLI command issues

### `wp menu item add-post-type` is not a valid subcommand

**Symptom:**
```
Error: 'add-post-type' is not a registered subcommand of 'menu item'.
```

**Cause:** The correct subcommand is `add-post` (for a specific post), not `add-post-type`.

**Fix:**
```bash
# ✅ Correct — adds a specific page/post to the menu
wp menu item add-post <menu_id_or_slug> <post_id> --title="Title" --path=$WP_PATH

# ❌ Wrong — this subcommand does not exist
wp menu item add-post-type <menu> <post_id>
```

Available `wp menu item` subcommands:
- `add-custom` — add a custom (external) link
- `add-post` — add a WordPress post/page by ID
- `add-term` — add a taxonomy term
- `delete` — delete a menu item
- `list` — list menu items
- `update` — update a menu item

### `wp theme install` fails with "Não foi possível criar o diretório"

**Symptom:**
```
Warning: Não foi possível criar o diretório. "/wp-content/upgrade/theme.slug"
Error: No themes installed.
```

**Cause:** The `wp-content/upgrade/` directory is not writable by the WP-CLI user.

**Fix — download and copy manually:**
```bash
cd /tmp
curl -sL "https://downloads.wordpress.org/theme/<slug>.<version>.zip" -o theme.zip
unzip -q theme.zip -d /tmp/theme-extract
sudo cp -r /tmp/theme-extract/<slug> $WP_PATH/wp-content/themes/<slug>
sudo chown -R www:www $WP_PATH/wp-content/themes/<slug>
wp theme activate <slug> --path=$WP_PATH
```

### WP-CLI output includes PHP deprecation warnings

**Symptom:**
```
Deprecated: Case statements followed by a semicolon (;) are deprecated...
```

**Cause:** PHP 8.x deprecation notices from WordPress core or plugins. These are warnings, not errors.

**Fix:** Filter them out in scripts:
```bash
wp theme list --path=$WP_PATH 2>/dev/null | grep -v Deprecated | grep -v "PHP Warning"
```

Or suppress in wp-cli.yml:
```yaml
# wp-cli.yml
php: /www/server/php/85/bin/php
```

---

## SVG to PNG conversion

### ImageMagick produces empty PNG from SVG

**Symptom:** `convert -background none icon.svg -resize 256x256 icon.png` produces a 332-byte (empty) PNG.

**Cause:** The SVG has no `fill` attribute on the root `<svg>` element, and ImageMagick doesn't apply a default fill to `<path>` elements.

**Fix — use cairosvg:**
```bash
pip3 install cairosvg --break-system-packages
python3 -c "import cairosvg; cairosvg.svg2png(url='icon.svg', write_to='icon.png', output_width=256, output_height=256)"
```

**Fix — add fill to the SVG root:**
```bash
# If the SVG has no fill on the root <svg> element:
sed -i 's|<svg |<svg fill="#2496ED" |' icon.svg
convert -background none -density 300 icon.svg -resize 256x256 icon.png
```

> **SimpleIcons CDN tip:** `https://cdn.simpleicons.org/<slug>/<hex-color>` returns SVG with the fill on the root `<svg>` element (converts reliably). `https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/<slug>.svg` returns SVG with fill on `<path>` or no fill at all (may need cairosvg).
