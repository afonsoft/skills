# Write SPECs

Interviews the user relentlessly in **Portuguese (pt-BR)** to consolidate domain language and architectural decisions, producing an approved SPEC SDD (`.specs/SPEC-{YYYYMMDD}-{feature}.md`) as the single source of truth before any implementation.

## 🎯 Purpose

Eliminate ambiguity, prevent speculative implementations, and align technical expectations before writing code. The output is a complete, approved SPEC SDD covering requirements, API contracts, acceptance criteria (BDD), and definition of done.

## 🛠️ How it Works

1. **The Design Tree** — Maps decisions from root (user request) to frontier (unblocked decisions). Questions are asked in rounds until the frontier is empty.
2. **Round Format (pt-BR)** — Every question is addressed to the user in Portuguese with a recommended answer to accelerate convergence.
3. **Fact Gathering** — The agent autonomously researches repository code, documentation, and tools using sub-agents. It never asks the user for information already present in the workspace.
4. **Authoring the SPEC SDD** — Fills all sections 0–9 of `references/spec-sdd-template.md` (Metadata, User Story, Scope, Technical Context, Requirements, API Contract, Acceptance Criteria, Task Plan, Guardrails, DoD).
5. **Approval Flow** — Creates the SPEC with `Status: Draft`, presents a concise summary, and requests explicit user approval. Only when `Status: Approved` may implementation begin.

## 🚀 Usage

Use this skill when:
- The user requests a new feature, change, refactor, or bugfix.
- Requirements are ambiguous, missing, or underspecified.
- Invoked explicitly: `/write-specs` (or "write specs", "criar spec").

## 🔗 Correlation

- **Downstream**: `execute-tdd-spec` implements each vertical slice from the approved SPEC.
- **Parallel**: `create-issues` turns approved SPECs into traceable GitHub Issues.
- **Sibling**: `scaffold-mvp` bootstraps a new project once the domain and initial SPEC are established.
- **Orchestration**: `orchestrator` invokes `write-specs` in Phase 1 (Discovery) and whenever ambiguity arises in the SPEC.
