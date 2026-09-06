---
name: wordpress-mcp
description: "Use when the user wants to manage WordPress sites via MCP (Model Context Protocol). Covers two official paths \u2014 (A) the WordPress/mcp-adapter plugin (Abilities API, 3 meta-tools) and (B) the AI Engine plugin (43 admin tools: posts, users, media, plugins, options, SEO, social). Includes plugin install via WP-CLI, Application Password / Bearer Token setup, per-platform MCP config (Claude Code, Devin, OpenCode, Gemini, Codex, AGY, OpenClaw), endpoint verification, and troubleshooting. Trigger when the user says \"WordPress MCP\", \"mcp-adapter\", \"AI Engine MCP\", \"configure WordPress for agents\", or wants to expose WordPress to AI agents over MCP. Part of the afonsoft/skills collection."
license: MIT
compatibility: WordPress 6.9+ (mcp-adapter) or 6.0+ (AI Engine). PHP 7.4+ (mcp-adapter) or 8.1+ (AI Engine). WP-CLI recommended for automated install. MCP clients need HTTP/streamable-HTTP support. Works on any hosting (aaPanel, cPanel, Docker, bare LEMP).
metadata:
  version: "1.1.0"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
  homepage: https://github.com/wordpress/mcp-adapter
  sources: https://github.com/wordpress/mcp-adapter, https://wordpress.org/plugins/ai-engine/, https://lobehub.com/skills/openclaw-skills-wordpress-mcp
---

> **v1.1.0 changelog:** Added complete AI Engine tool reference (109+ tools), `wp_write_blocks` block schema, real-world workflows (theme switch, media upload with permission fix, menu creation, Gutenberg rewrite), Cloudflare cache-busting, SVG-to-PNG conversion, WP-CLI menu command corrections.

# WordPress MCP — mcp-adapter (official) + AI Engine (skill)

Expose WordPress to AI agents over MCP. This skill covers **two complementary paths**:

| Path | Plugin | Endpoint | Auth | Tools | When to use |
|------|--------|----------|------|-------|-------------|
| **A. mcp-adapter** (official) | `wordpress/mcp-adapter` (GitHub) | `/wp-json/mcp/mcp-adapter-default-server` | Basic Auth (Application Password) | 3 meta-tools (discover/get-info/execute abilities) | Extensible, official, abilities-API driven. Use when you want to expose custom abilities or follow the WordPress core direction. |
| **B. AI Engine** (community) | `ai-engine` (WP.org) | `/wp-json/mcp/v1/http` | Bearer Token (static) | 43 admin tools (posts, users, comments, plugins, options, media, SEO, social, Polylang, WooCommerce) | Ready-to-use admin tools. Use when you want immediate WordPress management without writing PHP. |

Both paths can coexist on the same site (different endpoints, different auth). The LobeHub skill `openclaw-skills-wordpress-mcp` targets path B (AI Engine).

## When to use

- The user says "configure WordPress MCP", "expose my WordPress to agents", "mcp-adapter", "AI Engine MCP".
- An agent needs to create/edit posts, manage users, install plugins, or run WP admin tasks via MCP tool calls.
- `devin mcp list` / `claude mcp list` shows a `wordpress-*` server failing to list tools (auth or endpoint issue).
- The user wants to install the LobeHub skill `openclaw-skills-wordpress-mcp` (which requires AI Engine).

## When NOT to use

- The user only wants the WordPress REST API directly (no MCP) → use WP REST API docs.
- The user is building a custom MCP server unrelated to WordPress → use the `building-mcp-servers` skill.
- The user wants to manage WordPress via WP-CLI only (no MCP) → use WP-CLI directly.

---

# Prerequisites

| Requirement | Path A (mcp-adapter) | Path B (AI Engine) |
|-------------|----------------------|---------------------|
| WordPress | 6.9+ | 6.0+ |
| PHP | 7.4+ | 8.1+ |
| Plugin | `mcp-adapter` from GitHub | `ai-engine` from WP.org |
| Composer | Required on server (for mcp-adapter vendor/) | Not needed |
| WP-CLI | Recommended | Recommended |
| Application Passwords | Required (Basic Auth) | Not used |
| Bearer Token | Not used | Required (generated in AI Engine settings) |

---

# PATH A — mcp-adapter (official WordPress)

## A.1 Install the plugin

The plugin is not yet on the WordPress.org directory. Install from GitHub:

```bash
# Via the bundled helper (recommended — handles composer install too):
bash skills/wordpress-mcp/scripts/install_wp_plugin.sh mcp-adapter --wp-path=/var/www/html

# Manual:
cd /tmp
curl -L -o mcp-adapter.zip "https://github.com/WordPress/mcp-adapter/archive/refs/heads/trunk.zip"
unzip -q mcp-adapter.zip -d /tmp/mcp-adapter-extract
mv /tmp/mcp-adapter-extract/mcp-adapter-trunk /var/www/html/wp-content/plugins/mcp-adapter
cd /var/www/html/wp-content/plugins/mcp-adapter
composer install --no-dev --no-interaction --optimize-autoloader
wp plugin activate mcp-adapter --allow-root --path=/var/www/html
wp rewrite flush --allow-root --path=/var/www/html
```

> **Composer required**: the plugin ships without `vendor/`. Without `composer install`, the autoloader is missing and the endpoint returns 404 with no error. If the server's Composer is < 2.2, update first: `composer self-update --2`.

### aaPanel / BT-Panel notes

- PHP path: `/www/server/php/<version>/` (e.g. `/www/server/php/85/`)
- Site root: `/www/wwwroot/<domain>/`
- Web user: `www:www`
- WP-CLI may need `--allow-root` and the right PHP binary

```bash
# aaPanel example
WP_PATH=/www/wwwroot/yourdomain.com
sudo cp -r /tmp/mcp-adapter-pkg $WP_PATH/wp-content/plugins/mcp-adapter
sudo chown -R www:www $WP_PATH/wp-content/plugins/mcp-adapter
cd $WP_PATH/wp-content/plugins/mcp-adapter && sudo composer install --no-dev --optimize-autoloader
wp plugin activate mcp-adapter --path=$WP_PATH --allow-root
```

## A.2 Enable Application Passwords

Application Passwords must be enabled for Basic Auth. On most WP installs they are on by default, but some hosts disable them.

```bash
# Check
wp eval 'echo wp_is_application_passwords_available() ? "enabled" : "disabled";' --allow-root --path=/var/www/html

# If disabled, create a mu-plugin to force-enable:
sudo tee /var/www/html/wp-content/mu-plugins/enable-app-passwords.php > /dev/null <<'EOF'
<?php
add_filter('wp_is_application_passwords_available', '__return_true');
add_filter('wp_is_application_passwords_api_available', '__return_true');
EOF
```

## A.3 Create an Application Password

```bash
# List admin users
wp user list --role=administrator --fields=ID,user_login --allow-root --path=/var/www/html

# Create application password for user ID 1 (or any admin)
wp user application-password create 1 "mcp-clients" --allow-root --path=/var/www/html
# Output: Success: Created application password.
# Password: XXXXXXXXXXXXXXXXXXXXXXXX
```

> **Store the password securely.** It is shown only once. The full credential for Basic Auth is `base64("username:password")`.

## A.4 The MCP endpoint

```
POST https://yourdomain.com/wp-json/mcp/mcp-adapter-default-server
Authorization: Basic <base64(user:app_password)>
Content-Type: application/json
```

The server uses **Streamable HTTP** with session management. The flow is:

1. `initialize` → captures `Mcp-Session-Id` from response headers
2. `notifications/initialized` → HTTP 202 (must send before tools/list)
3. `tools/list` → returns 3 meta-tools

### Quick test

```bash
USER="admin"
PASS="xxxx xxxx xxxx xxxx xxxx xxxx"
AUTH=$(echo -n "$USER:$PASS" | base64)
URL="https://yourdomain.com/wp-json/mcp/mcp-adapter-default-server"

# 1. Initialize
SESSION=$(curl -s -i -X POST "$URL" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' \
  | grep -i "mcp-session-id" | awk '{print $2}' | tr -d '\r\n')

# 2. Initialized notification
curl -s -X POST "$URL" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' -o /dev/null

# 3. List tools
curl -s -X POST "$URL" \
  -H "Authorization: Basic $AUTH" \
  -H "Content-Type: application/json" \
  -H "Mcp-Session-Id: $SESSION" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
```

### Available tools (3 meta-tools)

| Tool | Description |
|------|-------------|
| `mcp-adapter-discover-abilities` | Lists all publicly available WordPress abilities |
| `mcp-adapter-get-ability-info` | Gets detailed info about a specific ability |
| `mcp-adapter-execute-ability` | Executes a WordPress ability with provided parameters |

> The mcp-adapter exposes a **meta-API**: you discover and execute abilities dynamically. This is more flexible but requires the agent to call `discover-abilities` first to know what's available.

---

# PATH B — AI Engine (community, 43 tools)

## B.1 Install the plugin

```bash
# Via the bundled helper:
bash skills/wordpress-mcp/scripts/install_wp_plugin.sh ai-engine --wp-path=/var/www/html

# Manual:
wp plugin install ai-engine --activate --allow-root --path=/var/www/html
# If wp plugin install fails (some hosts block it):
cd /tmp && curl -L -o ai-engine.zip "https://downloads.wordpress.org/plugin/ai-engine.zip"
unzip -q ai-engine.zip -d /tmp/ae-extract
sudo cp -r /tmp/ae-extract/ai-engine /var/www/html/wp-content/plugins/ai-engine
wp plugin activate ai-engine --allow-root --path=/var/www/html
```

## B.2 Enable MCP Server and generate Bearer Token

The MCP module is **off by default**. Enable it and set a bearer token:

```bash
WP_PATH=/var/www/html
TOKEN=$(openssl rand -hex 24)
echo "Bearer Token: $TOKEN"

wp eval '
$o = get_option("mwai_options");
$o["module_mcp"] = true;
$o["mcp_bearer_token"] = "'"$TOKEN"'";
update_option("mwai_options", $o);
echo "module_mcp: " . var_export($o["module_mcp"], true) . "\n";
' --allow-root --path=$WP_PATH

wp rewrite flush --allow-root --path=$WP_PATH
```

> **Store the token securely.** It is the only credential needed for the AI Engine MCP endpoint.

### Optional: enable additional features

By default only WordPress core tools are enabled. Enable more via `mwai_options`:

```bash
wp eval '
$o = get_option("mwai_options");
// Feature flags (all default to false except core):
// $o["mcp_feature_plugins"] = true;     // Install/activate/update plugins
// $o["mcp_feature_themes"] = true;      // Install/activate/switch themes
// $o["mcp_feature_database"] = true;    // Execute SQL queries (DANGEROUS)
// $o["mcp_feature_polylang"] = true;    // Multilingual (requires Polylang)
// $o["mcp_feature_woocommerce"] = true; // Products/orders (requires WooCommerce)
// $o["mcp_feature_seo_engine"] = true;  // SEO (requires SEO Engine)
// $o["mcp_feature_social_engine"] = true; // Social scheduling (requires Social Engine)
update_option("mwai_options", $o);
' --allow-root --path=$WP_PATH
```

## B.3 The MCP endpoint

```
POST https://yourdomain.com/wp-json/mcp/v1/http
Authorization: Bearer <token>
Content-Type: application/json
```

AI Engine uses **Streamable HTTP** but does **not** require session management — each request is independent.

### Quick test

```bash
TOKEN="your_bearer_token"
URL="https://yourdomain.com/wp-json/mcp/v1/http"

# Initialize
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}'

# List tools (no session needed)
curl -s -X POST "$URL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
```

### Available tools (43 core, 109+ with all features)

The AI Engine MCP exposes **43 core tools** by default, expanding to **109+** when all feature flags are enabled (plugins, themes, WooCommerce, SEO, social, Polylang, database, dynamic REST).

| Category | Tools |
|----------|-------|
| **System** | `mcp_ping` |
| **Posts/Pages** | `wp_get_posts`, `wp_get_post`, `wp_get_post_snapshot`, `wp_create_post`, `wp_update_post`, `wp_alter_post`, `wp_delete_post`, **`wp_write_blocks`** |
| **Users** | `wp_get_users`, `wp_create_user`, `wp_update_user`, `wp_delete_user` |
| **Comments** | `wp_get_comments`, `wp_create_comment`, `wp_update_comment`, `wp_delete_comment` |
| **Taxonomy** | `wp_get_terms`, `wp_create_term`, `wp_add_post_terms`, `wp_count_terms` |
| **Media** | `wp_list_media`, `wp_get_media`, `wp_upload_media`, `wp_set_featured_image`, `wp_count_media` |
| **AI** | **`mwai_image`** (image generation), **`mwai_vision`** (image analysis) |
| **Options** | `wp_get_option`, `wp_update_option` |
| **Settings** | `wp_get_settings`, `wp_update_settings` |
| **Plugins** | `wp_list_plugins`, `wp_activate_plugin`, `wp_deactivate_plugin` |
| **Post types** | `wp_list_post_types`, `wp_count_posts` |
| **Feature-gated** | plugins, themes, database, polylang, woocommerce, seo_engine, social_engine, dynamic_rest |

> **Key tools added since v1.0:**
> - `wp_write_blocks` — replace or append Gutenberg blocks (structured input, no raw HTML needed)
> - `wp_get_post_snapshot` — get post content + meta + terms at a point in time
> - `wp_alter_post` — status changes (publish, draft, trash, restore)
> - `mwai_image` / `mwai_vision` — AI image generation and vision analysis (requires API key in AI Engine settings)
> - `wp_set_featured_image` — set post thumbnail
> - `wp_count_posts`, `wp_count_terms`, `wp_count_media` — count operations

> **See `references/ai-engine-tools.md`** for the complete tool reference with arguments, block schema for `wp_write_blocks`, and feature flag enabling instructions.

> Run `tools/list` on the live endpoint to discover the exact tools available on your site (varies by enabled features).

---

# Configure MCP clients

Once the WordPress endpoints are live, configure each MCP client to connect.

## Automated setup (all platforms)

```bash
# Configure both mcp-adapter and AI Engine across all installed CLIs:
bash skills/wordpress-mcp/scripts/setup_wordpress_mcp.sh \
  --url https://yourdomain.com \
  --wp-user admin \
  --wp-app-password "xxxx xxxx xxxx xxxx xxxx xxxx" \
  --ai-engine-token "your_bearer_token"

# Configure only one path:
bash skills/wordpress-mcp/scripts/setup_wordpress_mcp.sh --url https://yourdomain.com --only mcp-adapter --wp-user admin --wp-app-password "..."
bash skills/wordpress-mcp/scripts/setup_wordpress_mcp.sh --url https://yourdomain.com --only ai-engine --ai-engine-token "..."

# Dry-run (show what would change):
bash skills/wordpress-mcp/scripts/setup_wordpress_mcp.sh --url https://yourdomain.com ... --dry-run

# Remove:
bash skills/wordpress-mcp/scripts/setup_wordpress_mcp.sh --remove

# Target one platform:
bash skills/wordpress-mcp/scripts/setup_wordpress_mcp.sh ... --platform claude-code
```

## Manual per-platform config

See **`references/mcp-config.md`** for the exact JSON block per platform. Key gotchas:

| Platform | Config file | Root key | URL field | Gotcha |
|----------|-------------|----------|-----------|--------|
| Claude Code | `~/.claude.json` | `mcpServers` | `url` | `type: "http"` |
| Devin CLI | `~/.config/devin/mcp_config.json` | `mcpServers` | `url` | `devin mcp add` CLI |
| OpenCode | `~/.config/opencode/opencode.json` | `mcp` | `url` | `type: "remote"`, `environment` not `env` |
| Gemini CLI | `~/.gemini/settings.json` | `mcpServers` | `httpUrl` | NOT `url`! |
| AGY | `~/.gemini/antigravity-cli/settings.json` | `mcpServers` | `httpUrl` | NOT `url`! |
| Codex | `~/.codex/config.toml` | `[mcp_servers.<name>]` | `url` | Headers in sub-table |
| OpenClaw | `~/.openclaw/openclaw.json` | `mcp.servers` | `url` | `openclaw mcp add` CLI |

> **Top 3 silent-failure traps:**
> 1. **Gemini CLI / AGY** use `httpUrl` (not `url`) for HTTP servers — using `url` = silently ignored.
> 2. **OpenCode** uses `mcp` (not `mcpServers`), `environment` (not `env`).
> 3. **Codex** stores headers in a TOML sub-table `[mcp_servers.<name>.headers]`, not inline.

---

# Verify

```bash
bash skills/wordpress-mcp/scripts/verify_wordpress_mcp.sh \
  --url https://yourdomain.com \
  --wp-user admin --wp-app-password "..." \
  --ai-engine-token "..."
```

Checks: mcp-adapter endpoint (initialize + tools/list), AI Engine endpoint (initialize + tools/list), and reports tool counts.

---

# LobeHub skill: `openclaw-skills-wordpress-mcp`

The LobeHub marketplace distributes a skill (`openclaw-skills-wordpress-mcp`) that provides **agent instructions** for the AI Engine MCP path (B). It is not an MCP server itself.

```bash
# Register in the marketplace (one-time per device)
npx -y @lobehub/market-cli register \
  --name "your-device-name" \
  --description "description" \
  --source open-claw

# Install for supported agents
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --agent open-claw
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --agent claude-code --global
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --agent codex --global

# Install for other CLIs (use --dir to target the platform's skills folder)
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --dir ~/.config/devin/skills
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --dir ~/.config/opencode/skills
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --dir ~/.gemini/skills
npx -y @lobehub/market-cli skills install openclaw-skills-wordpress-mcp --dir ~/.gemini/antigravity-cli/skills
```

> **Note:** The LobeHub skill targets AI Engine, NOT the official mcp-adapter. If you only installed mcp-adapter (path A), the skill's instructions won't match your tools. Both paths can coexist.

---

# Authentication reference

| Credential | Path | Where it lives | What it authenticates |
|-----------|------|----------------|----------------------|
| Application Password | A (mcp-adapter) | WP database (hashed) | Basic Auth for REST API / MCP endpoint |
| Bearer Token | B (AI Engine) | `mwai_options` option | Bearer Auth for AI Engine MCP endpoint |
| WP admin login | Both | WP database | Used to create/manage the above credentials |

## Auth flow diagram

```
┌─────────────────────────────────────────────────────────────┐
│  Path A — mcp-adapter (Basic Auth)                          │
│  wp user application-password create <id> "mcp-clients"     │
│  → base64("user:app_password") → Authorization: Basic ...   │
│  POST /wp-json/mcp/mcp-adapter-default-server               │
│  → initialize → notifications/initialized → tools/list (3)  │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│  Path B — AI Engine (Bearer Token)                          │
│  mwai_options.module_mcp = true                             │
│  mwai_options.mcp_bearer_token = <random hex>               │
│  → Authorization: Bearer <token>                            │
│  POST /wp-json/mcp/v1/http                                  │
│  → initialize → tools/list (43) — no session needed         │
└─────────────────────────────────────────────────────────────┘
```

---

# Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| mcp-adapter endpoint 404 | Plugin not active OR `vendor/` missing | `wp plugin activate mcp-adapter`; `composer install` in plugin dir |
| mcp-adapter 401 Unauthorized | Application Passwords disabled | Create mu-plugin `enable-app-passwords.php` (see A.2) |
| mcp-adapter tools/list empty | Missing `notifications/initialized` step | Send `notifications/initialized` (HTTP 202) before `tools/list` |
| mcp-adapter tools/list empty | Missing `Mcp-Session-Id` header | Capture from `initialize` response headers, send in subsequent requests |
| AI Engine endpoint 404 | `module_mcp` is `false` | `wp eval '$o=get_option("mwai_options"); $o["module_mcp"]=true; update_option("mwai_options",$o);'` |
| AI Engine 401 Unauthorized | Wrong or missing Bearer Token | Check `mwai_options.mcp_bearer_token`; re-generate if needed |
| `composer install` fails | Composer < 2.2 (jetpack-autoloader requires ^2.2) | `composer self-update --2` |
| `wp plugin install ai-engine` fails | Host blocks WP.org downloads | Download zip manually, extract, copy to `wp-content/plugins/` |
| MCP config silently ignored (no tools) | Wrong field name for platform | See `references/platform-quirks.md` (httpUrl vs url, mcp vs mcpServers) |
| Gemini CLI MCP not loading | Used `url` instead of `httpUrl` | Gemini uses `httpUrl` for HTTP servers, not `url` |
| Codex MCP not loading | Headers not in sub-table | Use `[mcp_servers.<name>.headers]` TOML sub-table |
| Admin notice: "Another version of MCP Adapter is already loaded" | False positive in `Autoloader::is_loaded_elsewhere()` — recheck finds class loaded by our own plugin | Patch `includes/Autoloader.php` with `ReflectionClass` path check (see `references/troubleshooting.md`) |

See **`references/troubleshooting.md`** for extended troubleshooting.

---

# Common workflows

### Publish a post (AI Engine)

```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"wp_create_post","arguments":{"post_title":"Hello World","post_content":"<p>My first MCP post.</p>","post_status":"draft"}}}
```

Then publish:
```json
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"wp_update_post","arguments":{"ID":123,"post_status":"publish"}}}
```

### List all plugins (AI Engine)

```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"wp_list_plugins","arguments":{}}}
```

### Discover abilities (mcp-adapter)

```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"mcp-adapter-discover-abilities","arguments":{}}}
```

Then execute a specific ability:
```json
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"mcp-adapter-execute-ability","arguments":{"ability_id":"...","parameters":{}}}}
```

---

# Real-world workflows

These are end-to-end recipes from managing a live WordPress site via MCP + WP-CLI. See **`references/real-world-workflows.md`** for full details.

## Convert posts homepage to static front page

```bash
wp option update show_on_front page --path=$WP_PATH
wp option update page_on_front <home_id> --path=$WP_PATH
wp option update page_for_posts <blog_id> --path=$WP_PATH
```

## Rewrite homepage with Gutenberg blocks

**Option A — `wp_write_blocks` (structured, < 20 blocks):**
```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"wp_write_blocks","arguments":{
  "ID": 10, "mode": "replace",
  "blocks": [{"type":"heading","level":1,"content":"Title"},{"type":"paragraph","content":"Content"}]
}}}
```

**Option B — `wp_update_post` with raw HTML (robust, 30+ blocks):**
```json
{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"wp_update_post","arguments":{
  "ID": 10,
  "fields": {"post_content": "<!-- wp:heading --><h1>Title</h1><!-- /wp:heading -->\n<!-- wp:paragraph --><p>Content</p><!-- /wp:paragraph -->"}
}}}
```

> **When to use which:** `wp_write_blocks` is clean but can drop the MCP connection on large payloads. `wp_update_post` with raw Gutenberg HTML is more robust for large rewrites and handles `wp:html` blocks with inline styles.

## Switch to a professional theme

```bash
# If wp theme install fails (permission denied on upgrade dir):
cd /tmp && curl -sL "https://downloads.wordpress.org/theme/blocksy.2.1.56.zip" -o blocksy.zip
unzip -q blocksy.zip -d /tmp/blocksy-extract
sudo cp -r /tmp/blocksy-extract/blocksy $WP_PATH/wp-content/themes/blocksy
sudo chown -R www:www $WP_PATH/wp-content/themes/blocksy
wp theme activate blocksy --path=$WP_PATH
```

> **Rollback:** `wp theme activate twentytwentyfive --path=$WP_PATH` — old themes are never deleted.

## Create navigation menu

```bash
MENU_ID=$(wp menu create "Principal" --porcelain --path=$WP_PATH 2>/dev/null | tail -1)
wp menu item add-post $MENU_ID 10 --title="Início" --path=$WP_PATH    # NOT add-post-type!
wp menu item add-custom $MENU_ID "GitHub" "https://github.com/user" --path=$WP_PATH
wp menu location assign $MENU_ID menu_1 --path=$WP_PATH
```

> **Gotcha:** The WP-CLI subcommand is `wp menu item add-post` (not `add-post-type`).

## Upload media when wp_upload_media fails (permission denied)

```bash
sudo cp /tmp/image.png $WP_PATH/wp-content/uploads/2026/09/image.png
sudo chown www:www $WP_PATH/wp-content/uploads/2026/09/image.png
ATTACHMENT_ID=$(wp post create --post_type=attachment --post_status=inherit \
  --post_title="Image" --post_mime_type="image/png" \
  --guid="https://yourdomain.com/wp-content/uploads/2026/09/image.png" \
  --porcelain --path=$WP_PATH 2>/dev/null | tail -1)
wp post meta update $ATTACHMENT_ID _wp_attached_file "2026/09/image.png" --path=$WP_PATH
```

## Verify changes bypassing Cloudflare cache

```bash
curl -s "https://yourdomain.com/?nocache=1" | grep "new content"
# Increment: ?nocache=2, ?nocache=3, ...
```

> `wp cache flush` does NOT purge Cloudflare. Use cache-busting query strings or the Cloudflare API.

---

# References

- **`references/ai-engine-tools.md`** — Complete AI Engine tool reference (109+ tools with arguments, `wp_write_blocks` block schema, feature flags).
- **`references/real-world-workflows.md`** — End-to-end workflows from a live site (static front page, Gutenberg rewrite, theme switch, menu creation, media upload with permission fix, custom CSS, blog posts with categories, Cloudflare cache-busting, SVG-to-PNG conversion).
- **`references/mcp-config.md`** — Full per-platform JSON/TOML config blocks (Claude Code, Devin CLI, OpenCode, Gemini CLI, AGY, Codex, OpenClaw).
- **`references/platform-quirks.md`** — Cross-platform MCP config quirks matrix (httpUrl vs url, mcp vs mcpServers, TOML sub-tables).
- **`references/troubleshooting.md`** — Extended troubleshooting (composer, app passwords, session flow, feature flags, media upload permissions, Cloudflare cache, WP-CLI menu commands, theme install without upgrade dir).
- **`scripts/setup_wordpress_mcp.sh`** — Detects all installed MCP clients and patches each with the correct format.
- **`scripts/verify_wordpress_mcp.sh`** — End-to-end connectivity check for both endpoints.
- **`scripts/install_wp_plugin.sh`** — Installs mcp-adapter or ai-engine plugin via WP-CLI (handles composer, downloads, activation).
- [WordPress MCP Adapter (GitHub)](https://github.com/wordpress/mcp-adapter)
- [AI Engine (WP.org)](https://wordpress.org/plugins/ai-engine/)
- [LobeHub skill](https://lobehub.com/skills/openclaw-skills-wordpress-mcp)
- [Application Passwords docs](https://developer.wordpress.org/rest-api/using-the-rest-api/authentication/)
- [Devin CLI MCP configuration](https://docs.devin.ai/cli/extensibility/mcp/configuration)
- [OpenCode MCP servers](https://opencode.ai/docs/mcp-servers/)
- [OpenClaw MCP tools](https://docs.openclaw.ai/tools/mcp)
