---
name: obsidian
license: MIT
description: Use when working with Obsidian vaults — running the Obsidian CLI (read/create/search/manage
  notes, tasks, properties), building Bases (.base views/filters/formulas), writing
  Obsidian Flavored Markdown (wikilinks, embeds, callouts, properties), or developing/debugging
  plugins and themes. Do NOT use for generic Markdown editors or non-Obsidian note
  tools; this skill is Obsidian-specific. Part of the afonsoft/skills collection.
metadata:
  version: 1.0.1
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
  openclaw: '{"requires":{"bins":["obsidian"]}}'
---

# Obsidian

A single skill for everything Obsidian: the **CLI**, **Bases** (`.base` files), and **Obsidian Flavored Markdown**. Consolidates the former `obsidian-cli`, `obsidian-bases`, and `obsidian-markdown` skills.

> **Origin:** derived from `kepano/obsidian-skills` (MIT). Obsidian must be running for any CLI or MCP command to work.

## When to Use

- Interact with a vault from the command line (create/read/search/manage notes, tasks, properties).
- Build or edit a **Base** (database-like view over notes) with filters and formulas.
- Author **Obsidian Flavored Markdown** (wikilinks, embeds, callouts, properties).
- Develop or debug an Obsidian **plugin or theme**.

- User asks or mentions this skill in English (e.g., "use /obsidian", "run obsidian").
- O usuário pede ou menciona esta skill em português (ex.: "use /obsidian", "execute obsidian").

## When NOT to Use

- Do not use for generic Markdown files or note-taking tools that are not Obsidian.
- Do not target a vault the user has not explicitly named.
- Do not auto-install the `mcp-obsidian-cli` package or run the `obsidian` binary without user confirmation.

## Security & Guardrails

- **Human confirmation first**: confirm the target vault and any `obsidian` command with the user before execution.
- **No auto-execution**: only run commands that read or modify the named vault; do not run system-wide commands or execute arbitrary plugins/themes without explicit consent.
- **MCP fallback is opt-in**: if the `obsidian` CLI is missing, present `mcp-obsidian-cli` as an optional fallback and wait for the user to approve its installation.
- **Stay inside the vault**: do not use Obsidian CLI to access files outside the vault root.

## Three areas

### 1. CLI
Run `obsidian` against a running Obsidian instance — vault operations, plugin/theme dev, DOM/screenshot inspection.
See the full command reference and quick-start examples in [`references/obsidian-cli.md`](references/obsidian-cli.md).

> Before running any `obsidian` command, verify which vault the user wants to target and confirm the command. Do not auto-install `mcp-obsidian-cli` or any Obsidian plugin without explicit user consent.

### 2. Bases
`.base` files are valid YAML defining filters, formulas, and views (table/cards/list/map) over notes.
See [`references/obsidian-bases.md`](references/obsidian-bases.md) and the full function list in [`references/FUNCTIONS_REFERENCE.md`](references/FUNCTIONS_REFERENCE.md).

```yaml
filters:
  and:
    - file.hasTag("task")
    - 'file.ext == "md"'
formulas:
  days_until_due: 'if(due, (date(due) - today()).days, "")'
views:
  - type: table
    name: "Active Tasks"
    order: [file.name, status, formula.days_until_due]
```

### 3. Markdown (Obsidian Flavored)
Wikilinks `[[Note]]`, embeds `![[note.png|300]]`, callouts `> [!warning]`, properties/frontmatter, highlights `==text==`, Mermaid, math.
See [`references/obsidian-markdown.md`](references/obsidian-markdown.md), plus [`references/CALLOUTS.md`](references/CALLOUTS.md), [`references/EMBEDS.md`](references/EMBEDS.md), [`references/PROPERTIES.md`](references/PROPERTIES.md).

## Workflows

### Create an Obsidian note
1. Add frontmatter/properties at the top (see `references/PROPERTIES.md`).
2. Write content with standard Markdown + Obsidian syntax (wikilinks, embeds, callouts).
3. Verify it renders in reading view.

### Build a Base
1. Create a `.base` file with valid YAML.
2. Define `filters` (global/view) and optional `formulas`.
3. Add one or more `views` (`table`/`cards`/`list`/`map`).
4. Validate YAML (watch quoting rules); open in Obsidian to confirm rendering.

### Register CLI / develop a plugin
1. Guide the user to **Settings → General → Command line interface → Register CLI**; restart the terminal.
2. After the user confirms code changes, run `obsidian plugin:reload` and `obsidian dev:screenshot` only for the explicitly named plugin.

## Common Mistakes

| Mistake | Symptom | Fix |
|---|---|---|
| Obsidian not running | CLI/MCP commands fail | Open the Obsidian app first |
| Unquoted special chars in `.base` | YAML error | Quote strings with `:`, `{`, `}`, `[`, `]`, `,`, `&`, `*`, `#`, `?`, `\|`, `-`, `<`, `>`, `=`, `!`, `%`, `@` |
| Double quotes inside double quotes (formula) | Parse error | Wrap formula in single quotes: `'if(done, "Yes", "No")'` |
| Duration without field access | `(now()-file.ctime).round(0)` errors | Access `.days` first: `(now()-file.ctime).days.round(0)` |
| Missing null checks in formulas | Crash on empty property | Guard with `if()`: `if(due, (date(due)-today()).days, "")` |
| Wikilink vs Markdown link | Broken external links | `[[Note]]` for vault notes; `[text](url)` for external only |

## References

- [`references/obsidian-cli.md`](references/obsidian-cli.md) — CLI install, syntax, commands, plugin dev.
- [`references/obsidian-bases.md`](references/obsidian-bases.md) — Bases schema, filters, formulas, views, examples.
- [`references/obsidian-markdown.md`](references/obsidian-markdown.md) — Obsidian Flavored Markdown syntax.
- [`references/FUNCTIONS_REFERENCE.md`](references/FUNCTIONS_REFERENCE.md) — Complete Bases function reference.
- [`references/CALLOUTS.md`](references/CALLOUTS.md) — All callout types.
- [`references/EMBEDS.md`](references/EMBEDS.md) — All embed types.
- [`references/PROPERTIES.md`](references/PROPERTIES.md) — All property types and tag rules.
