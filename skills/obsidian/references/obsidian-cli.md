# Obsidian CLI

Use the `obsidian` CLI to interact with a running Obsidian instance. Requires Obsidian to be open.

## Installation

1. Install Obsidian 1.12.7+ from <https://obsidian.md/download>.
2. Open Obsidian, then enable the CLI:
   - **Settings → General → Command line interface**
3. Click **Register CLI** and follow the prompt to add `obsidian` to PATH.
   - Linux: `~/.local/bin/obsidian`
   - macOS: `/usr/local/bin/obsidian` or `~/.local/bin/obsidian`
   - Windows: `Obsidian.com` redirector alongside `Obsidian.exe`
4. Restart your terminal.

```bash
which obsidian
obsidian --version
```

### MCP Fallback

If the agent does not have shell access to the `obsidian` binary, ask the user before installing `mcp-obsidian-cli`. Pin a known version:

```bash
# Ask the user first, then install a pinned version
npm install -g mcp-obsidian-cli@<VERSION>
# or
npx mcp-obsidian-cli@<VERSION>
```

Configure as an MCP server in the agent only after the user approves:

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "npx",
      "args": ["mcp-obsidian-cli@<VERSION>"],
      "env": { "OBSIDIAN_VAULT": "<vault-name>" }
    }
  }
}
```

> **Note:** The Obsidian app must be running for any CLI or MCP command to work. Do not install or execute `mcp-obsidian-cli` without user consent.

## Command reference

Run `obsidian help` to see all available commands. This is always up to date. Full docs: https://help.obsidian.md/cli

## Syntax

**Parameters** take a value with `=`. Quote values with spaces:

```bash
obsidian create name="My Note" content="Hello world"
```

**Flags** are boolean switches with no value:

```bash
obsidian create name="My Note" silent overwrite
```

For multiline content use `\n` for newline and `\t` for tab.

## File targeting

Many commands accept `file` or `path` to target a file. Without either, the active file is used.

- `file=<name>` — resolves like a wikilink (name only, no path or extension needed)
- `path=<path>` — exact path from vault root, e.g. `folder/note.md`

## Vault targeting

Commands target the most recently focused vault by default. Use `vault=<name>` as the first parameter to target a specific vault:

```bash
obsidian vault="My Vault" search query="test"
```

## Common patterns

```bash
obsidian read file="My Note"
obsidian create name="New Note" content="# Hello" template="Template" silent
obsidian append file="My Note" content="New line"
obsidian search query="search term" limit=10
obsidian daily:read
obsidian daily:append content="- [ ] New task"
obsidian property:set name="status" value="done" file="My Note"
obsidian tasks daily todo
obsidian tags sort=count counts
obsidian backlinks file="My Note"
```

Use `--copy` on any command to copy output to clipboard. Use `silent` to prevent files from opening. Use `total` on list commands to get a count.

## Plugin development

### Develop/test cycle

After making code changes to a plugin or theme, follow this workflow:

1. **Reload** the plugin to pick up changes:
   ```bash
   obsidian plugin:reload id=my-plugin
   ```
2. **Check for errors** — if errors appear, fix and repeat from step 1:
   ```bash
   obsidian dev:errors
   ```
3. **Verify visually** with a screenshot or DOM inspection:
   ```bash
   obsidian dev:screenshot path=screenshot.png
   obsidian dev:dom selector=".workspace-leaf" text
   ```
4. **Check console output** for warnings or unexpected logs:
   ```bash
   obsidian dev:console level=error
   ```

### Additional developer commands

Run JavaScript in the app context:

```bash
obsidian eval code="app.vault.getFiles().length"
```

Inspect CSS values:

```bash
obsidian dev:css selector=".workspace-leaf" prop=background-color
```

Toggle mobile emulation:

```bash
obsidian dev:mobile on
```

Run `obsidian help` to see additional developer commands including CDP and debugger controls.
