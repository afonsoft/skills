---
name: create-issues
license: MIT
description: Use when turning plans, specs, PRDs, and Epics into trackable GitHub Issues. Creates stable Epic IDs, direct links, vertical slices, dependencies, and verifiable acceptance criteria using the GitHub CLI (gh). Part of the afonsoft/skills collection.
metadata:
  version: "1.1.0"
  visibility: public
  author: afonsoft
  url: https://github.com/afonsoft/skills
---

# Create Issues

Use GitHub as the single source of truth for work tracking. This skill turns roadmaps, PRDs, and SPEC files into stable, linked, verifiable GitHub Issues.

If the repository is not on GitHub or `gh` is not authenticated, stop and invoke `/create-agent-harness` first.

## When to Use

- Converting `ORCHESTRATOR-ROADMAP.md` or `.specs/SPEC-*.md` into GitHub Issues.
- Slicing an Epic into small, vertical, trackable Issues.
- Creating a new batch of Issues from a release plan or PRD.
- Keeping roadmap, Epics, and GitHub Issues in sync.

## When NOT to Use

- Do not use when the only task is to close or modify existing Issues — use GitHub directly.
- Do not use when GitHub access is not confirmed.

## Prerequisites

- `gh` CLI installed and authenticated.
- Remote `origin` pointing to the correct GitHub repository.
- `ORCHESTRATOR-ROADMAP.md` or `.specs/SPEC-*.md` with the work to track.

Check access with:

```bash
gh auth status
gh repo view
```

## Epic Traceability Contract

Every Epic must have:

1. A stable identifier in the format `E10`, `E11`, `E12`.
2. A matching GitHub Issue.
3. A direct link to that Issue in the roadmap or spec.
4. Description, state, and success criteria kept in sync with the Issue.

Required roadmap format:

```markdown
## Epics

- [**[E10] Product foundation**](https://github.com/OWNER/REPO/issues/101) - `in_progress`
- [**[E11] Notification flow**](https://github.com/OWNER/REPO/issues/102) - `todo`
```

`E##` IDs are never reused, even after an Epic is done. The GitHub Issue number does not replace the Epic ID: `E10` stays stable even if the Issue is edited.

## Process

1. Read `ORCHESTRATOR-ROADMAP.md`, `.specs/SPEC-*.md`, `docs/architecture/`, requirements, and any parent Issue comments.
2. List existing Epics and extract their IDs, states, and links.
3. Assign the next available `E##` ID to each Epic that does not have one. Do not renumber existing Epics.
4. For each Epic without a link, find the matching GitHub Issue by title, labels, and body. If none exists, create one with `gh`.
5. Update the roadmap with the direct link `[**[E10] Title**](URL)`.
6. Validate that no Epic is missing an ID, Issue, or link.
7. Split each approved Epic into complete, small, vertical slices.
8. Mark each slice as HITL (human-in-the-loop) or AFK (autonomous) and define dependencies.
9. Present the proposal to the user when there are decisions about granularity, risk, or architecture.
10. Publish slices in dependency order, using real issue numbers in `Blocked by`.
11. Update the Epic Issue with links to child slices and keep the roadmap in sync.
12. Never close or edit a parent Issue without explicit user approval.

## Using the GitHub CLI

### Check the repository

```bash
gh repo view
```

### Create an Epic Issue

```bash
gh issue create \
  --title "E10 - Product foundation" \
  --label "epic" \
  --body-file /path/to/epic-body.md
```

Save the returned issue number. Add the link back to the roadmap.

### Create a slice Issue

```bash
gh issue create \
  --title "[E10] Set up project harness" \
  --label "slice" \
  --body-file /path/to/slice-body.md
```

### Add dependencies (`Blocked by`)

```bash
gh issue edit 124 --add-linked-issue 123 --link-type blocked_by
```

### Add labels

```bash
gh label create epic --color "FF0000" --description "High-level deliverable"
gh label create slice --color "00FF00" --description "Vertical work item"
```

### Add issues to a milestone or project

```bash
gh issue edit 101 --milestone "v1.0"
gh project item-add 23 --content-id "<node_id_of_issue>" --owner "@me"
```

To get an issue node id:

```bash
gh issue view 101 --json id
```

### Bulk creation from a file

When creating many Issues, generate a `issues.json` list and loop over it:

```bash
while IFS= read -r title; do
  gh issue create --title "$title" --label slice --body-file "slices/${title}.md"
done < slices.txt
```

Always capture the returned issue numbers and update the Epic Issue body with the child links.

## Mandatory Validation

Before finishing, confirm:

```text
[ ] Every Epic has an E## identifier
[ ] Every Epic has a GitHub Issue
[ ] Every Epic has a direct link in the roadmap/spec
[ ] Every link points to /issues/<number>
[ ] No Epic ID is duplicated
[ ] Epic Issue references its child slices
[ ] Roadmap and GitHub states are consistent
```

If the roadmap is missing, report that there are no local Epics to map and do not invent Epics. If GitHub is unavailable, stop before publishing or declaring any Epic as tracked.

## Epic Issue Template

```markdown
## Epic

E10 - Product foundation

## Goal

The business or technical result expected.

## Success criteria

- [ ] Verifiable criterion 1
- [ ] Verifiable criterion 2

## Slices

- [ ] #123 - Vertical slice 1
- [ ] #124 - Vertical slice 2

## State

todo | in_progress | done
```

## Slice Issue Template

```markdown
## Parent

Epic: E10 - [link to Epic issue]

## What to build

Concise description of the complete behavior of this slice.

## Acceptance criteria

- [ ] Verifiable criterion 1
- [ ] Verifiable criterion 2

## Blocked by

- #123

## Verification

Commands, tests, or expected evidence.
```

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Reusing an `E##` ID | Always assign the next unused number. |
| Creating slices before the Epic Issue | Create the Epic first, then reference its number in child Issues. |
| Missing `Blocked by` links | Link dependencies explicitly with `gh issue edit --add-linked-issue`. |
| Inventing Epics without a roadmap/spec | Stop and ask the user or the owning skill for the source of truth. |

## References

- `gh` CLI docs: https://cli.github.com/manual/
- `orchestrator` skill for the full agentic workflow
- `grill-me-with-spec` for producing the `.specs/SPEC-*.md` files
