# Scaffold MVP — .NET/Blazor/Angular Bootstrap

Bootstraps a new MVP repository after domain/spec alignment: installs the agent harness, proposes a productive stack, and generates the project skeleton, AD-0001, and local stubs.

## 🎯 Purpose

Get an empty repo to a buildable, documented, agent-ready MVP skeleton — fast, but never sloppy: no pseudo-code, pinned dependencies, incremental build checks, and a recorded architecture decision.

## 🛠️ How it Works

- **Phase 0 — Agent harness** — invokes `/create-agent-harness` first; confirms `CLAUDE.md`/`AGENTS.md`, `.claude/`, `docs/`, and `main` branch exist.
- **Phase 1 — Summary + stack proposal** — reads `.claude/CONTEXT.md` and the approved SPEC, asks for a one-line project summary (pt-BR), proposes the most productive stack.
- **Phase 2 — Stack decision** — decision tree (Blazor vs. Angular vs. API vs. CLI vs. MAUI hybrid) with mandatory UI-kit pairing; **waits for explicit user approval** before scaffolding.
- **Phase 3 — Execution** — solution/projects skeleton, central package management, `global.json`, UI kit + shared libs, `src/`/`tests/` structure, docs folders, lean README — with a build/type check after every structural step.
- **Phase 4 — AD-0001** — records the initial stack decision in `docs/architecture/AD-0001-initial-stack.md`.
- **Phase 5 — External stubs** — Docker Compose or in-memory stubs for every external dependency, `.env.example`, health checks — the app never crashes on first startup.

## 🚫 Golden Rule (non-negotiable)

**Never build base UI components or infrastructure from scratch.** Blazor → MudBlazor/Radzen/Fluent UI; Angular → Material/PrimeNG/NG-ZORRO; backend → ABP/FastEndpoints/minimal APIs. Also forbidden: `// ...` escape comments, unpinned versions, uncommitted lockfiles.

## ✅ Return Criteria

Harness installed, CONTEXT/MEMORY updated, AD-0001 written, `.specs/`/`docs/specs/` exist, README with run commands, clean build, lockfiles committed, no TODOs, external stubs present, initial git history on `main`.

## 🚀 Usage

Use when starting a new .NET/Blazor/Angular MVP in an empty repository — typically right after `/write-specs` approves a SPEC, or when the user asks for a quick MVP bootstrap.

## 🔗 Correlation

- **Upstream**: `write-specs` (domain + approved SPEC) and `create-agent-harness` (Phase 0 prerequisite).
- **Downstream**: `orchestrator` resumes feature work on the scaffolded repo; `create-issues` tracks the Epics; `execute-specs` implements the slices.
