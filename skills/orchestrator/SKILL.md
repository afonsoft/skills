---
name: orchestrator
license: MIT
description: "Govern agent-driven projects, audit preconditions, create documentation, turn gaps into GitHub Issues, and coordinate execution, tests, and QA in a continuous loop. Use when starting or running a software project with the afonsoft agent harness. User-facing questions and confirmations must be in Portuguese (pt-BR). Part of the afonsoft/skills collection."
metadata:
  version: "2.0.0"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
---

# Orchestrator

The central control skill for agent-driven projects. It plans, governs, audits, delegates, and re-validates. It never executes complex work directly when a specialized skill exists.

All questions and confirmations directed at the user must be in **Portuguese (pt-BR)**. Internal reasoning and documentation are in English.

## When to Use

- Starting a new project or repository.
- Resuming an existing project with unclear state.
- Planning a feature, Epic, or release.
- Coordinating implementation of a SPEC SDD.
- Preparing a PR after implementation.

## When NOT to Use

- Do not use when the task is a single, well-scoped code change — use `/tdd-spec` directly.
- Do not use when only a code review is needed — use `/code-review-and-quality`.
- Do not use when only a bug fix is needed — use `/diagnose`.

## State File

The Orchestrator must read `references/ESTADO_ORQUESTRATOR.md` at the start of every session and write to it after every phase. This state file persists the DAG, task status, and decisions across sessions. See [references/ESTADO_ORQUESTRATOR.md](references/ESTADO_ORQUESTRATOR.md).

## Phase -1 — Framework Update

Run this at the start of every Orchestrator session, before project preconditions.

1. Find where the skills were installed from. For each loaded skill, resolve the real path of the link and locate the catalog clone that contains `README.md` and `SKILL.md`.
2. In the found clone, read `origin` remote, current branch, and local installed commit.
3. Check the framework remote with `git fetch origin --quiet`. Never pull, merge, or reset the framework clone.
4. Compare local commit with `origin/<branch>` or the equivalent remote reference.
5. If there are new commits, report immediately:

```text
Framework update available
- Framework: afonsoft/skills
- Installed: <commit or date>
- Available: <commit or date>
- Changes: <summary of commits or files>
- Action: reinstall the catalog with `npx skills add afonsoft/skills`
```

6. If new commits are available, guide the user to reinstall skills with `npx skills add afonsoft/skills`.
7. After reinstall, confirm `orchestrator` and `create-agent-harness` point to the new revision and report the result.
8. If no changes, log `Framework up-to-date (<commit>)` without stopping the flow.
9. If the clone, remote, or network cannot be located, log `Unable to check framework updates` and continue only if local skills are available. Do not reinstall without confirming a new revision.

When a new revision is confirmed, the user must reinstall the skills. That is part of the Orchestrator contract.

## Phase 0 — Governance Preconditions

Before creating files or delegating work:

1. Verify Git is initialized.
2. Verify a valid GitHub remote exists, preferably `origin`.
3. Verify repository access with `gh repo view` or equivalent.

If the environment is empty, has no Git, or has no GitHub remote, stop the flow and guide the user to:

1. Create the repository on GitHub;
2. Initialize the local repository;
3. Configure the `origin` remote;
4. Make the first commit and push;
5. Return to the Orchestrator.

Never silently replace GitHub with a local tracker. GitHub is the source of traceability, Issues, review, and history for this framework.

## Phase 1 — Documentation Provisioning

1. Invoke `/create-agent-harness` to generate `CLAUDE.md`, `AGENTS.md` (thin reference), `.claude/` (settings, rules, agents, memory, context), `docs/` (technologies, architecture, decisions), and `.specs/`.
2. Invoke `/grill-me-with-spec` to consolidate domain language and architectural decisions, producing the SPEC SDD in `.specs/SPEC-{YYYYMMDD}-{feature}.md` before any implementation.
3. In an empty repository, invoke `/scaffold-mvp` after domain alignment.
4. Review and persist documentation and the approved SPEC before starting implementation.

Documentation is not optional: the Orchestrator must leave a state another agent can continue.

### Special Case — New Project with Only a PRD in the Folder

When the repository starts from a folder containing only a PRD (no code):

1. Ensure GitHub repository is initialized with `origin` configured (Phase 0).
2. Create and check out a `develop` branch from the default branch.
3. Invoke `/grill-me-with-spec` to turn the PRD into one or more SPEC SDDs in `.specs/SPEC-{YYYYMMDD}-{slug}.md`, one per Epic or well-delimited area.
4. Review and approve the SPECs; update `Status` to `Approved` on each one.
5. Based on approved SPECs, open Issues on GitHub using `/create-issues` (one per Epic, or a master Issue with Epics listed).
6. Use `/create-issues` to slice each Epic into atomic Issues (vertical, traceable, with acceptance criteria), recording the mapping `.specs/SPEC-*.md` → Issue.
7. Proceed to Phase 4 using the sequential queue described below.

## Phase 2 — Audit

Audit the structure produced by `create-agent-harness`:

```text
[ ] Git initialized
[ ] GitHub remote configured and accessible
[ ] CLAUDE.md (single source of truth) and AGENTS.md (thin reference)
[ ] .claude/settings.json (permissions, hooks, env)
[ ] .claude/rules/global-rules.md and stack-scoped rules/
[ ] .claude/agents/ (review.md, plan.md, test.md)
[ ] .claude/memory/ and .claude/MEMORY.md
[ ] .claude/CONTEXT.md, .claude/RULES.md, .claude/TOOLS.md, .claude/WORKFLOWS.md
[ ] .claude/README.md (harness infrastructure)
[ ] .specs/ for SPEC SDD when features are in flight
[ ] docs/agents/ when domain tracker and labels exist
[ ] docs/adr/ when relevant architectural decisions exist
[ ] Skills installed in the chosen environment
```

Classify gaps as P1 (security/types), P2 (architecture), P3 (performance), or P4 (hygiene/documentation). To analyze and address gaps, invoke `/improve-codebase-architecture`.

## Phase 3 — GitHub Fragmentation

Approved gaps must be turned into Issues by `/create-issues`. GitHub is the persistent source of scope, acceptance criteria, dependencies, and status; `references/ESTADO_ORQUESTRATOR.md` is only the operational view of the DAG.

1. Pass the gaps, roadmap, and approved documentation to `/create-issues`.
2. Present the decomposition for approval when HITL decision is needed.
3. Publish Issues in dependency order, using real IDs in `Blocked by`.
4. Record the mapping `Task -> GitHub Issue -> branch/worktree`.
5. Never create a DAG only in memory or only in a local file when the task can be tracked on GitHub.

## Phase 4 — Execution Loop

The Orchestrator runs sliced Issues in a continuous loop until all SPEC implementations are complete. The focus is small vertical slices, one at a time, with constant re-validation.

### General Rules

- Independent slices may run in parallel in isolated worktrees; slices that change schema, authentication, public APIs, or data require human confirmation.
- Before each slice, the agent must read the approved `.specs/SPEC-{YYYYMMDD}-{slug}.md` and the corresponding Issue.
- After each slice, re-validate: build, tests, lint, type check.
- Do not move to the next slice while the current one is not green.

### Per-Slice Cycle

```text
1. READ         → Approved SPEC + GitHub Issue
2. TDD          → /tdd-spec (red-green-refactor) using acceptance criteria
3. CODE REVIEW  → /code-review-and-quality on the slice diff
4. ARCH         → /improve-codebase-architecture if architecture degrades
5. DIAGNOSE     → /diagnose if a bug or mysterious failure appears
6. CLARIFY      → /grill-me-with-spec if the SPEC is ambiguous
7. VERIFY       → build, tests, lint pass
8. COMMIT       → Conventional commit, reference the Issue
9. LOOP         → Next slice in the queue
```

### Skill Delegation by Situation

| Situation | Skill |
| --- | --- |
| Implement from SPEC | `/tdd-spec` |
| Review diff before continuing | `/code-review-and-quality` |
| Bug, regression, or mysterious build failure | `/diagnose` |
| Degraded architecture / too much coupling | `/improve-codebase-architecture` |
| Ambiguity in the SPEC | `/grill-me-with-spec` |
| Create/update Epic Issues | `/create-issues` |
| Need knowledge of a third-party API/library | manual / research subagent |

### Sequential Queue for Epics Sliced from a PRD

When Issues come from the special case "new project with only a PRD" (Phase 1), execution is **not** parallel: dispatch **one agent at a time**, in Issue dependency order.

1. For the current Epic, process its sliced Issues one by one:
   - develop with `/tdd-spec`;
   - QA (Phase 5);
   - commit;
   - next Issue in the queue.
   Repeat until all Issues of the Epic are exhausted.
2. When the Epic is complete, invoke `/qa-analyst` and then `/code-review-and-quality` for the accumulated diff, then `/create-readme` to reflect what was delivered.
3. Epic exhausted → open a PR from the working branch to `develop`.
   * Green PR (CI/tests pass) → merge into `develop`.
   * Failed PR → fix with `/diagnose`, re-run verification, then merge.
4. After the merge, return to the `develop` branch and advance to the next Epic in the queue, repeating the loop until all PRD Epics are finished.
5. When all Epics are complete, open the final merge from `develop` to `main`.

## Phase 5 — Verification and QA

After each slice and at the end of each Epic/DAG:

1. Run proportional verifications: tests, lint, type check, build.
2. If it fails, invoke `/diagnose` before continuing.
3. When the DAG is complete, invoke `/qa-analyst` without exception of tier. QA must confront requirements, Issues, implementation, tests, error scenarios, and out-of-scope changes. Failures reopen Issues or create new tasks.
4. After QA approval, invoke `/code-review-and-quality` for a final review of the accumulated Epic diff (or set of slices). Quality failures reopen Issues or create new tasks.
5. After review approval, invoke `/create-readme` to update `README.md` with the delivered features, stack, and instructions.
6. Only after that can delivery by PR occur. If no Git/PR flow skill is installed, describe the steps and ask for human confirmation; never invoke a nonexistent skill.

At the end of the project or release, ensure `README.md` reflects the current system state.

## References

- [`references/orchestrator-delegation-protocol.md`](references/orchestrator-delegation-protocol.md) — autonomy matrix, risk tiers, and delegation protocols.
- [`references/ESTADO_ORQUESTRATOR.md`](references/ESTADO_ORQUESTRATOR.md) — operational state file for the session DAG.
- `/create-agent-harness` — for generating the project harness
- `/grill-me-with-spec` — for authoring the SPEC SDD
- `/scaffold-mvp` — for bootstrapping a new project
- `/create-issues` — for turning work into GitHub Issues
- `/improve-codebase-architecture` — for analyzing and fixing architecture gaps
- `/tdd-spec` — for test-driven implementation from the SPEC
- `/code-review-and-quality` — for reviewing diffs
- `/diagnose` — for debugging regressions and bugs
- `/qa-analyst` — for the mandatory QA gate
- `/create-readme` — for keeping README in sync
