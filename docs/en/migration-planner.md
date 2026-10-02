# Migration Planner

Produces comprehensive, evidence-based migration plans from legacy systems to **.NET** — preferably **Blazor WebAssembly** for web UIs, **.NET MAUI** for desktop/mobile, and **ASP.NET Core** for backends — using the Strangler Fig pattern, then hands each domain to the spec-driven delivery pipeline.

Adapted from the `legacy-migration-planner` skill (tech-leads-club/agent-skills, CC-BY-4.0), rewired for this catalog and extended with the legacy-migration flow described in the Claudera guide (MCP-connected visibility, logical parity suites, human-in-the-loop governance, security-debt redesign).

## 🎯 Purpose

Big-bang rewrites fail. This skill plans a gradual, reversible migration: it clones (when given a URL) and researches the legacy codebase with `file:line` evidence, maps bounded contexts, designs seams and facades (YARP routes, DI adapters, EF Core dual-write, Blazor/MAUI islands), and writes a per-domain plan plus a consolidated roadmap — all under `migration-plan/` in the target repo.

Then it converts every domain into a Draft SPEC via `write-specs`, waits for explicit approval, publishes a tracked Epic + slice Issues via `create-issues`, and hands execution to `orchestrator`.

## 🛠️ How it Works

1. **RESEARCH** — codebase deep analysis (`.sln`/`.csproj`, `web.config`, `.aspx`, `.xaml` signals), dependency inventory with EOL checks, bounded-context mapping with coupling ratios, .NET target research (verified versions), risk + security-debt scan. Optional MCP sources (DB schema, git index, observability) increase visibility.
2. **PLAN** — migration direction chosen by evidence; seams and facades designed per pattern; one plan file per domain (`migration-plan/domains/`); consolidated `00-roadmap.md` with phases, shared-DB strategy, auth bridge, and observability.
3. **SPECs** — `write-specs` is invoked per domain with the plan as its evidence packet, producing `.specs/SPEC-*.md` in `Draft`.
4. **Approval gate** — pt-BR summary; nothing external happens before an explicit `sim`.
5. **Issues** — `create-issues` creates the `migration-{YYYYMMDD}` Epic and one slice Issue per domain, ordered by roadmap dependencies.
6. **Handoff** — `orchestrator` executes the approved SPECs (`execute-specs`/`tdd-spec`), with parity suites as part of each SPEC's DoD.
7. **State** — `.claude/memory/migration-planner-{YYYYMMDD}.md` enables idempotent re-runs.

## 🚀 Usage

Use this skill when:

- Planning a legacy → .NET migration (or to a user-chosen stack): WebForms/MVC/WinForms/WPF/Xamarin, AngularJS/jQuery/Angular frontends, or non-.NET backends.
- The user provides a source repo (current directory, local path, or URL — URLs are always cloned to a temp dir and analyzed read-only) and optionally a target repo that receives `migration-plan/`, `.specs/`, and the Issues.
- Decomposing a monolith into ASP.NET Core services, or consolidating into a modular monolith.
- The user asks for a "migration plan", "modernization roadmap", or "strangler fig".
- Invoked explicitly: `/migration-planner` (or "run migration-planner", "planejar migração").

Do **not** use it to write migration code, for a single well-scoped change, or when approved SPECs already cover the work.

## 🧪 Safety Nets

Every step requires a rollback plan plus a safety net: characterization tests, the **logical parity suite** (same xUnit tests against legacy and new implementations), contract tests, golden masters (Verify), parallel-run shadow traffic, data-consistency validation, and Playwright visual regression for UI.

## 🔗 Correlation

- **Downstream**: `write-specs` authors each domain's SPEC; `create-issues` publishes Epic + slices; `orchestrator` + `execute-specs`/`tdd-spec` implement them.
- **Siblings**: `architecture`/`mermaid-architecture` own TO-BE diagrams and ADRs; `gap-analysis` complements with evidence audits; `qa-analyst` deepens test planning; `observability-and-instrumentation` guides `migration_path` telemetry.
- **Companion (when installed)**: `aspnet-core-api`, `abp-*`, `fluentui-blazor`, `ef-core`, `testing-xunit`, `security-jwt`, `modern-csharp-coding-standards`, `migrate-aspnetboilerplate-to-abp` — used only when already installed, never installed at runtime.
