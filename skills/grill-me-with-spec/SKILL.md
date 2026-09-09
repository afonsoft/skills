---
name: grill-me-with-spec
license: MIT
description: Use when the user needs to create or refine a feature SPEC SDD before implementation. Interviews the user, builds a design tree, and writes `.specs/SPEC-{YYYYMMDD}-{feature}.md` following the SDD template. Do NOT use for writing implementation code or after the SPEC is approved. Part of the afonsoft/skills collection.
metadata:
  version: "1.0.0"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
---

# Grill me with SPEC

## Overview

Interview the user relentlessly until a shared understanding is reached, then write a complete SPEC SDD (Spec-Driven Development document) in `.specs/SPEC-{YYYYMMDD}-{feature}.md`. The SPEC becomes the single source of truth before any implementation.

## When to Use

- The user asks for a new feature, change, bugfix, or refactor.
- A request is ambiguous and needs clarification.
- Before any implementation begins.

## When NOT to Use

- Do not use for implementation — that is the job of the implementation skill (`/tdd`, `/surgical-patch`, etc.).
- Do not use when a SPEC already exists and is approved.

## Process

### 1. Build the design tree

Map the request as a **design tree**: every decision branches into the decisions that depend on it. Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled: the questions you can ask now without guessing at answers you have not heard yet.

Ask the whole frontier in one round:

- Number each question and give your recommended answer.
- Wait for the user's answers before the next round.

Format a round like so:

```text
❓ **Q1** - **<question title>**: <question body, including multiple choices if useful>

➡️ <your recommended answer>

---

❓ **Q2** - ...
```

After each round, recompute the frontier. A question whose answer depends on another still-open question belongs to a later round, not this one. The session is done when the frontier is empty.

Finding facts is the agent's job, never the user's. When a frontier question needs a fact from the environment (file system, tools, docs), dispatch a sub-agent to find it; do not ask the user for anything you could look up yourself. Do not block: questions downstream of the fact can wait; ask the rest of the frontier now.

### 2. Write the SPEC SDD

Once the design tree is settled, create `.specs/SPEC-{YYYYMMDD}-{feature}.md` by filling the template in `references/spec-sdd-template.md`. The parent agent must read the SPEC and wait for user approval before implementation.

The SPEC must include all sections 0-9:

0. **Metadata** — feature, type, stack, repository, branch, ticket, status.
1. **User Story** — As a / I want / So that, plus problem context.
2. **Scope** — in scope and out of scope.
3. **Technical Context** — where the change happens, files to read, files to create/modify.
4. **Requirements** — numbered, verifiable requirements with input/output.
5. **API Contract** — only if the feature exposes/consumes an API.
6. **Acceptance Criteria** — BDD scenarios and edge cases.
7. **Task Plan** — ordered, small tasks with validation strategy.
8. **Organization Guardrails** — branch policy, security, scope, architecture.
9. **Definition of Done** — checklist to complete during implementation.

Use `[A DEFINIR]` only when the user explicitly declines to answer.

### 3. Wait for approval

Set `Status` to `Draft` initially. Ask the user to approve or revise. Only after `Status = Approved` may implementation begin. Do not write implementation code.

## Verification

- [ ] The design tree is complete (empty frontier).
- [ ] The SPEC file is written in `.specs/SPEC-{YYYYMMDD}-{feature}.md`.
- [ ] All sections 0-9 are filled.
- [ ] Requirements are numbered and verifiable.
- [ ] Acceptance criteria use BDD "Given...when...then" format.
- [ ] User explicitly approved the SPEC.

## References

- `references/spec-sdd-template.md` — full SDD template
