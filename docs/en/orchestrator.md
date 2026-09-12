# Orchestrator

Central control skill for agent-driven projects. It audits preconditions, creates documentation, reconciles open GitHub Issues, turns gaps into Issues, and coordinates execution, tests, QA, and PR in a continuous loop.

## 🎯 Purpose

Govern the full lifecycle of agent-driven software delivery by delegating complex work to specialized skills. Persists state in `.claude/memory/orchestrator_stats.md`, reconciles open GitHub Issues, and auto-continues to the next Epic/Slice in the queue.

## 🛠️ How it Works

1. **Phase -1 — Framework Update**: Check for updates to the skills collection.
2. **Phase 0 — Governance Preconditions**: Verify clean working tree (`git status`), `gh auth`, remote, and runtimes.
3. **Phase 1 — Discovery**: Align domain with prior ADRs, produce SPEC SDDs, and scaffold when needed.
4. **Phase 2 — Audit**: Identify architectural gaps and security vulnerabilities (`sonarqube-autofix`).
5. **Phase 3 — GitHub Fragmentation**: Turn approved gaps into GitHub Issues.
6. **Phase 4 — Implementation Loop**: Run sliced Issues one by one with `design` (UI), DB migrations, and `execute-tdd-spec`, handling review rejections with corrective refactoring.
7. **Phase 5 — Verification and QA**: Run QA, code review, resilient architecture diagrams (`drawio` / `mermaid`), README & CHANGELOG updates, and SPEC archiving.
8. **Phase 6 — Unapproved SPEC Review**: Scan leftover SPECs; approved SPECs enter the full queue through Phase 4 and 5.
9. **Phase 7 — Final Verification & Gap Check**: Confirm all SPECs, Issues, and gaps are closed; if a next item exists, continue automatically.

## 🚀 Usage

Use this skill when starting or resuming a project, planning an Epic, or coordinating the implementation of an approved SPEC SDD.

## 🔗 Correlation

- **Upstream**: `write-specs` produces approved SPECs.
- **Parallel**: `create-issues` turns SPECs into Issues.
- **Execution**: `execute-tdd-spec` implements each slice; `diagnose` handles regressions; `code-review-and-quality` reviews diffs.
- **Downstream**: `qa-analyst` performs the mandatory pre-PR review; `drawio-architecture` and `mermaid-architecture` update architecture diagrams in `docs/architecture/`.
