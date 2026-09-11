# Agent Skills Collection

A curated collection of high-performance Agent Skills and hooks designed to enhance AI capabilities across various runtimes (Claude Code, OpenCode, Devin, Cursor, etc.).

[![skills.sh](https://skills.sh/b/afonsoft/skills)](https://skills.sh/afonsoft/skills)
[![Spec Validation](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml/badge.svg?job=validate-spec)](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml)
[![Quality Check](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml/badge.svg?job=validate-quality)](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml)
[![Security Scan](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml/badge.svg?job=security-scan)](https://github.com/afonsoft/skills/actions/workflows/skills-validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Agent Skills Spec](https://img.shields.io/badge/Agent%20Skills-Spec-blue)](https://agentskills.io)
[![DeepWiki](https://img.shields.io/badge/DeepWiki-afonsoft%2Fskills-blue)](https://deepwiki.com/afonsoft/skills)
[![Made in Brazil](https://img.shields.io/badge/Made%20in-Brazil-green)](https://github.com/afonsoft/skills)
[![Last Commit](https://img.shields.io/github/last-commit/afonsoft/skills)](https://github.com/afonsoft/skills/commits/main)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/afonsoft/skills/pulls)
[![Open Source](https://img.shields.io/badge/Open%20Source-%E2%9D%A4-brightgreen)](https://github.com/afonsoft/skills)

## 🚀 Overview

This repository provides specialized guidance and tools following the **Agent Skills Specification** (agentskills.io). Instead of generic prompts, these skills provide structured patterns, constraints, and reference materials that allow agents to perform complex software engineering tasks with production-grade quality.

## 🛠️ Skill Catalog & Correlation

The skills are organized into four main pillars: **Harness Engineering**, **Code Quality**, **Extensibility**, and **MCP Integrations**.

### 🏗️ Harness Engineering
*Foundation for creating and managing AI agents.*
- **[`create-agent-harness`](docs/en/create-agent-harness.md)**: The starting point. Use this to bootstrap a complete agent environment (CLAUDE.md, rules, skills) in any repo.
- **[`create-readme`](docs/en/create-readme.md)**: Professionalizes the repository landing page. Generates evidence-based READMEs and SemVer-compliant CHANGELOGs.
- **[`observability-and-instrumentation`](docs/en/observability-and-instrumentation.md)**: Once the harness is set, use this to ensure the agent's actions and the application's behavior are visible and diagnosable in production.

### 🧭 Orchestration & Delivery
*Planning, execution, verification, and documentation for agent-driven projects.*
- **[`orchestrator`](docs/en/orchestrator.md)**: Central control skill. Audits preconditions, creates documentation, turns gaps into GitHub Issues, and coordinates execution, tests, QA, and PR in a continuous loop. Uses `references/ESTADO_ORQUESTRATOR.md` to persist state.
- **[`grill-me-with-spec`](skills/grill-me-with-spec/SKILL.md)**: Interviews the user in Portuguese to consolidate domain language and produce an approved `.specs/SPEC-{YYYYMMDD}-{feature}.md` before implementation.
- **[`scaffold-mvp`](skills/scaffold-mvp/SKILL.md)**: Bootstraps a new repository after domain/spec alignment. Proposes a stack and generates a lean README, lockfiles, and stubs.
- **[`create-issues`](skills/create-issues/SKILL.md)**: Turns approved gaps, roadmap, and specs into GitHub Issues with vertical slices and dependency links.
- **[`execute-tdd-spec`](docs/en/execute-tdd-spec.md)**: Test-driven development using the approved SPEC SDD as the source of truth. Red-green-refactor one vertical slice at a time.
- **[`qa-analyst`](skills/qa-analyst/SKILL.md)**: Full QA cycle — requirements analysis, test planning, test cases, execution, bug reports, and process improvement.
- **[`diagnose`](skills/diagnose/SKILL.md)**: Disciplined diagnosis and re-validation loop for hard bugs and performance regressions.
- **[`improve-codebase-architecture`](skills/improve-codebase-architecture/SKILL.md)**: Finds architectural deepening opportunities by reading `.claude/CONTEXT.md` and `docs/adr/`, and produces an HTML report.

### 💎 Code Quality & Review
*Ensuring the output meets professional standards.*
- **[`code-review-and-quality`](docs/en/code-review-and-quality.md)**: The primary gatekeeper. Performs multi-axis reviews (correctness, security, performance) before any code is merged.
- **[`quality-test-implementation`](docs/en/quality-test-implementation.md)**: The whole-repo quality intervention. Fixes static-analysis warnings (Roslyn/Sonar, SpotBugs/Checkstyle, Bandit/Ruff), resolves security CVEs, and applies SOLID/DDD/Clean Architecture across .NET, Java, or Python repositories.
- **[`sonarqube-review`](docs/en/sonarqube-review.md)**: The automated auditor. Integrates with SonarQube to identify and fix technical debt and smells systematically.

### 🔌 Extensibility & Integration
*Expanding what the agent can actually do.*
- **[`building-mcp-servers`](docs/en/building-mcp-servers.md)**: The power-user tool. Teaches agents how to build their own Model Context Protocol (MCP) servers to connect to any API or database.
- **[`drawio-architecture`](docs/en/drawio-architecture.md)**: Visual intelligence. Merges architecture diagram authoring with the official draw.io MCP server for automated system design.
- **[`obsidian`](docs/en/obsidian.md)**: Obsidian vault operations. Runs the Obsidian CLI (read/create/search/manage notes, tasks, properties), builds Bases (.base views/filters/formulas), writes Obsidian Flavored Markdown (wikilinks, embeds, callouts), and develops/debugs plugins and themes.

### 🔗 MCP Integrations
*Configuring, authenticating, and using external MCP servers across all supported agent platforms.*
- **[`composio-mcp`](docs/en/composio-mcp.md)**: Connects AI agents to 1000+ external apps (Gmail, GitHub, Slack, Notion, Linear, Jira) via Composio. CLI-first path (`ak_*` project key) with MCP fallback (`ck_*` consumer key via `x-consumer-api-key` header). Includes multi-platform setup script (handles `serverUrl` vs `url`, `mcp` vs `mcpServers`, `environment` vs `env` across Claude Code/Desktop, Cursor, Devin CLI/Desktop, OpenCode, Antigravity IDE/CLI, OpenClaw), verify script, per-platform config reference, and cross-platform quirks matrix.
- **[`notebooklm-mcp`](docs/en/notebooklm-mcp.md)**: Google NotebookLM (Gemini Notebook) integration via the `nlm` CLI and `notebooklm-mcp` server. Cookie-based auth for headless servers with three methods (OpenClaw CDP provider preferred, manual `cookies.txt` file, desktop auto + copy) and multi-platform setup script covering all 8 supported agent platforms. Includes verify, cookie-extraction helper, per-platform config reference, and cross-platform quirks matrix.
- **[`wordpress-mcp`](docs/en/wordpress-mcp.md)**: Expose WordPress to AI agents over MCP. Three paths: (A) `wordpress/mcp-adapter` official plugin (Abilities API, 3 meta-tools, HTTP+STDIO), (B) AI Engine plugin (43–109+ admin tools: posts, users, media, plugins, SEO, social), and (C) wp-mcp-ultimate (58 abilities, OAuth 2.1, WP 6.7+). Includes WP-CLI install scripts, Application Password / Bearer Token / OAuth setup, per-platform MCP config (Claude Code, Devin, OpenCode, Gemini, Codex, AGY, OpenClaw), endpoint verification, and troubleshooting.

> 📚 **Documentation:** each skill has a dedicated doc page in [`docs/en/`](docs/en/) (English) and [`docs/pt-br/`](docs/pt-br/) (Português).

## 🛡️ Security Audits

Latest results from the [skills.sh](https://skills.sh) third-party audit (**Gen Agent Trust Hub**, **Socket**, **Snyk**). Click **View** to see the full report for a skill.


> **Updated:** 2026-09-09

| Skill | Gen Agent Trust Hub | Socket alerts | Snyk | Details |
|-------|---------------------|---------------|------|---------|
| `building-mcp-servers` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/building-mcp-servers) |
| `code-review-and-quality` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/code-review-and-quality) |
| `composio-mcp` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/composio-mcp) |
| `create-agent-harness` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/create-agent-harness) |
| `create-issues` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/create-issues) |
| `create-readme` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/create-readme) |
| `diagnose` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/diagnose) |
| `drawio-architecture` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/drawio-architecture) |
| `grill-me-with-spec` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/grill-me-with-spec) |
| `improve-codebase-architecture` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/improve-codebase-architecture) |
| `notebooklm-mcp` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/notebooklm-mcp) |
| `observability-and-instrumentation` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/observability-and-instrumentation) |
| `obsidian` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/obsidian) |
| `orchestrator` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/orchestrator) |
| `qa-analyst` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/qa-analyst) |
| `quality-test-implementation` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/quality-test-implementation) |
| `scaffold-mvp` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/scaffold-mvp) |
| `sonarqube-review` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/sonarqube-review) |
| `execute-tdd-spec` | ⚪ unknown | - | ⚪ unknown | [View](https://skills.sh/afonsoft/skills/execute-tdd-spec) |
| `wordpress-mcp` | ✅ safe | 0 | 🟢 low | [View](https://skills.sh/afonsoft/skills/wordpress-mcp) |
---

## 📦 Installation

### ⚡ via skills.sh (Recommended)
The fastest way to install and auto-detect your environment.
```bash
npx skills add afonsoft/skills
```

## 📣 Publish on Skill Directories

### SkillsLLM
[SkillsLLM](https://skillsllm.com/) indexes open-source skills for Claude Code, Codex CLI, and ChatGPT. The scraper discovers repos daily via GitHub topics (`claude-code`, `ai-agent`, `mcp-server`, `agent-skills`, `skill-md`) and `SKILL.md` files. To list this collection:

1. Sign in with GitHub at [Submit a Skill](https://skillsllm.com/submit)
2. Submit the repository URL: `https://github.com/afonsoft/skills`
3. The scraper validates, fetches metadata, runs a security scan (Semgrep + npm audit + pip-audit), and adds it to the catalog within 24 hours

> **Note:** SkillsLLM's automated discovery filters for repos with 100+ stars. Manual submission via the form above bypasses that filter — the repo is then scanned and listed regardless of star count. The GitHub topics and description are already set so the scraper can categorize the skills correctly.

### Awesome Skills
[Awesome Skills](https://awesomeskill.ai/) discovers open-source `SKILL.md` skills from GitHub via its **Awesome List Import**. Each `skills/<name>/SKILL.md` directory becomes a separate listing with slug `afonsoft-skills-<name>`. Submit the repository URL through the site's **Submit a Skill** form:

- **Repository URL:** `https://github.com/afonsoft/skills`
- **Branch:** `main`
- **Skills Path:** `/skills`

Each skill's `description` frontmatter includes `afonsoft` so the collection is discoverable at [awesomeskill.ai/search?q=afonsoft](https://awesomeskill.ai/search?q=afonsoft). The Awesome Skills search API matches against skill `name` and `description` only (not owner, repo, or tags), so the `afonsoft` attribution in each description is what makes the search return results.

### SkillHub
[SkillHub](https://www.skill-marketplace.com/) aggregates skills from GitHub sources. Open **Sources** → **Add Source**, then use:

- **Name:** `afonsoft/skills`
- **Repository URL:** `https://github.com/afonsoft/skills`
- **Source Type:** `GitHub Repo`
- **Branch:** `main`
- **Skills Path:** `/skills`

SkillHub imports the collection from this source and lists each valid `SKILL.md` directory in its marketplace.

### LobeHub Skills Marketplace
[LobeHub](https://lobehub.com/skills) is the world's largest skills marketplace (100,000+ skills). Publishing is CLI-driven (no web form). Each skill gets identifier `afonsoft-skills-<name>`.

**One-time setup (per machine, requires Node.js >= 22):**
```bash
npx -y @lobehub/market-cli login           # browser OAuth
npx -y @lobehub/market-cli github connect  # verify GitHub ownership
```

**Publish all skills locally:**
```bash
./publish-lobehub.sh          # publishes all skills
./publish-lobehub.sh --dry-run # preview without publishing
```

**Publish a single skill:**
```bash
npx -y @lobehub/market-cli skill publish --dir skills/<skill-name> --identifier afonsoft-skills-<skill-name>
```

**Automatic publishing via GitHub Actions:**

A workflow (`.github/workflows/lobehub-publish.yml`) publishes all skills on every push to `main`. To enable it, add two repository secrets:

1. **`LOBEHUB_M2M_CREDENTIALS`** — contents of `~/.lobehub-market/credentials.json` (device registration)
2. **`LOBEHUB_USER_CREDENTIALS`** — contents of `~/.lobehub-market/user-credentials.json` (OAuth tokens)

```bash
# After running lhm login + lhm github connect locally:
gh secret set LOBEHUB_M2M_CREDENTIALS < ~/.lobehub-market/credentials.json
gh secret set LOBEHUB_USER_CREDENTIALS < ~/.lobehub-market/user-credentials.json
```

The workflow restores both credential files, verifies auth, then runs `./publish-lobehub.sh`. The refresh token auto-renews the access token, so the workflow stays authenticated across runs.

After publishing, skills appear at `market.lobehub.com/s/skills/afonsoft-skills-<name>` and are searchable at [lobehub.com/skills?q=afonsoft](https://lobehub.com/skills?q=afonsoft).

### ClawHub
[ClawHub](https://clawhub.ai/) is the public skill registry for OpenClaw. Each `skills/<name>/SKILL.md` directory becomes a versioned, installable skill under the `afonsoft` publisher.

**Install from ClawHub:**

```bash
# Search for a skill
clawhub search "afonsoft"

# Install one skill
clawhub install @afonsoft/<skill-name>

# Or install with OpenClaw directly
openclaw skills install @afonsoft/<skill-name>
```

**Publish all skills locally:**

```bash
npm i -g clawhub
clawhub login
./publish-clawhub.sh          # publish new/changed skills
./publish-clawhub.sh --dry-run # preview the publish plan
```

The `clawhub` CLI uses `clawhub sync` to compare local fingerprints against the registry and publishes only new or changed skills, defaulting to the next patch version.

**Automatic publishing via GitHub Actions:**

A workflow (`.github/workflows/clawhub-publish.yml`) publishes all skills on every push to `main`. To enable it, add the repository secret:

1. **`CLAWHUB_TOKEN`** — your ClawHub publisher token (`clawhub token create` or from https://clawhub.ai/settings/tokens)

```bash
gh secret set CLAWHUB_TOKEN
```

## 📖 How to use

1. **Install** the collection using one of the methods above.
2. **Invoke** a skill in your chat by mentioning its name (e.g., *"Use the create-agent-harness skill to setup this repo"*).
3. **Follow** the structured workflow provided by the skill (the agent will automatically load the `SKILL.md` and follow the lapped process).

## ⚖️ License
MIT - See `LICENSE`.

## 🛠️ Skill Development Tools

### skillxp
[skillxp](https://skillxp.dev/) observes skill loading behavior across harnesses (Claude Code, Codex CLI, Antigravity). Stage a skill in a fresh fixture, invoke the harness headlessly, and see what actually reached the model with transcript evidence. Install via `brew install agent-ecosystem/tap/skillxp` or `npm install -g skillxp`. Use `skillxp harnesses` to list supported platforms and `skillxp observe -harness <name> -install ./my-skill ...` to trace skill activation and phrase loading.

## 📊 Skills Catalog
Browse all available skills at [skills.sh](https://www.skills.sh/?q=afonsoft).
