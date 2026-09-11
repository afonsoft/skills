# Orchestrator

Central control skill for agent-driven projects. It audits preconditions, creates documentation, turns gaps into GitHub Issues, and coordinates execution, tests, QA, and PR in a continuous loop.

## 🎯 Purpose

Govern the full lifecycle of agent-driven software delivery by delegating complex work to specialized skills and persisting state in `references/ESTADO_ORQUESTRATOR.md`.

## 🛠️ How it Works

1. **Phase -1 — Framework Update**: Check for updates to the skills collection.
2. **Phase 0 — Governance Preconditions**: Verify Git, remote, harness, and approved SPEC.
3. **Phase 1 — Discovery**: Align domain, produce SPEC SDDs, and scaffold when needed.
4. **Phase 2 — Audit**: Identify gaps and architecture issues.
5. **Phase 3 — GitHub Fragmentation**: Turn approved gaps into GitHub Issues.
6. **Phase 4 — Implementation Loop**: Run sliced Issues one by one using `execute-tdd-spec`, without asking for confirmation between slices.
7. **Phase 5 — Verification and QA**: Run QA, review, architecture diagrams, and README updates.

## 🚀 Usage

Use this skill when starting or resuming a project, planning an Epic, or coordinating the implementation of an approved SPEC SDD.

## 🔗 Correlation

- **Upstream**: `grill-me-with-spec` produces approved SPECs.
- **Parallel**: `create-issues` turns SPECs into Issues.
- **Execution**: `execute-tdd-spec` implements each slice; `diagnose` handles regressions; `code-review-and-quality` reviews diffs.
- **Downstream**: `qa-analyst` performs the mandatory pre-PR review.
