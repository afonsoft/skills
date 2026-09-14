# Gap Analysis

Audits a repository's current state (AS-IS) against its documented desired state (TO-BE) and turns **evidence-backed gaps** into Draft SPECs, a tracked GitHub Epic, and orchestrated execution — with a hard approval gate before any external action.

## 🎯 Purpose

Close the distance between architectural intent, documentation, SPECs, and implementation. Every conclusion cites reproducible evidence (paths, line ranges, commands, test output); missing sources are recorded as evidence, never compensated with invented content.

## 🛠️ How it Works

1. **Source inventory** — `.specs/`, `docs/`, `docs/architecture/`, `.claude/CONTEXT.md`, rules, code, tests, CI, Git history, and GitHub Issues are recorded as present/absent (`scripts/collect-sources.sh` does the mechanical pass).
2. **AS-IS × TO-BE matrix** — maps what exists against what the specs, docs, and rules require, distinguishing fact, interpretation, and `[A DEFINIR]`.
3. **Verdicts** — each candidate is checked against existing coverage (compiler, analyzers, tests, CI, hooks, docs, automation) and receives exactly one verdict: `CONFIRMADO`, `REJEITADO`, `DUPLICADO`, or `INCONCLUSIVO`.
4. **Prioritization & dedup** — confirmed gaps get a qualitative priority card (impact, urgency, risk, scope, effort, confidence) and a stable key `GAP-<category>-<kebab-scope>` for idempotent re-runs.
5. **SPECs** — `write-specs` is invoked per confirmed gap, using the collected evidence as its design-tree starting point; each produces a `.specs/SPEC-*.md` in `Draft`.
6. **Approval gate** — the run stops with a pt-BR summary. No Issue, branch, or execution without explicit approval.
7. **Issues** — `create-issues` publishes one Epic `gap-analysis-{YYYYMMDD}` plus one slice Issue per approved gap.
8. **Handoff** — `orchestrator` validates and executes all approved SPECs through its own Phase 4–5 loop.
9. **Report** — consolidated audit saved to `.claude/memory/gap-analysis-{YYYYMMDD}.md`, which doubles as resume state.

## 🚀 Usage

Use this skill when:

- Auditing a repo before a release or after a review ("what is missing", "what diverges from the spec").
- Converting audit findings into tracked, spec-driven work.
- Invoked explicitly: `/gap-analysis` (or "run gap-analysis", "mapear gaps").
- Called by `orchestrator` as the final evidence-backed audit in Phase 5, before `create-readme`.

## 🔗 Correlation

- **Downstream**: `write-specs` authors each gap's SPEC SDD; `create-issues` publishes the Epic and slices; `orchestrator` executes the approved SPECs.
- **Sibling**: `improve-codebase-architecture` handles P2 deepening opportunities; `sonarqube-autofix` handles P1/P2 static-analysis findings.
- **Contrast**: `orchestrator` Phase 2 runs a structural harness checklist; `gap-analysis` runs the deep evidence-based audit of code vs. docs vs. specs.
