# WordPress MCP
This skill exposes WordPress sites to AI agents over the Model Context Protocol (MCP), covering plugin selection, authentication, transport, and per-platform client configuration.

## 🎯 Purpose
Give agents safe, authenticated control of WordPress (posts, users, media, plugins, SEO, Gutenberg blocks) without guessing at endpoints or auth schemes. It consolidates three complementary integration paths into one decision guide.

## 🛠️ How it Works
The skill compares three paths and picks the one that fits the target site:
- **Path A — `wordpress/mcp-adapter` (official)**: Abilities API with 3 meta-tools, Application Password auth, HTTP + STDIO transport. No composer needed on v0.6.1+.
- **Path B — AI Engine (community)**: 43–109+ ready-to-use admin tools behind a static Bearer Token, HTTP only. Fastest path to full WP admin.
- **Path C — wp-mcp-ultimate (community)**: 58 pre-built abilities with OAuth 2.1, self-contained, works on WordPress 6.7+.

It then walks through plugin install via WP-CLI, auth setup (Application Password / Bearer Token / OAuth), MCP client config across Claude Code, Devin, OpenCode, Gemini, Codex, AGY, and OpenClaw, and endpoint verification.

## 🚀 Usage
Use this skill when the user wants to "configure WordPress MCP", expose a WordPress site to agents, fix a `wordpress-*` server that fails to list tools, or register custom WordPress abilities. Do NOT use it for building a custom MCP server unrelated to WordPress (use `building-mcp-servers`).

## 🔗 Correlation
- **MCP Integrations**: Sits alongside `composio-mcp` and `notebooklm-mcp` as the third external-service MCP integration in the collection.
- **Extensibility**: For building a brand-new MCP server (not WordPress), pair with `building-mcp-servers`.
- **Migration**: The deprecated `Automattic/wordpress-mcp` plugin should be migrated to Path A (`wordpress/mcp-adapter`).
