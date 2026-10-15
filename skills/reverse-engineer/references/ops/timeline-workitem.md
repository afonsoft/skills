# Timeline + WorkItem / Coverage

> Replayable combat records (Z3r0 timeline idea) + overlay check (WorkItem idea).
> All fall into **`work/<case>/`** (warehouse gitignore) and are not included in the skill package body.

## Directory convention

```text
work/<case>/
scope.md # Contract (ops/scope-contract.md)
timeline.md # Append writing, prohibit changes to historical entries
workitems.md # Work items and coverage
evidence/ # Original product (screenshot, pcap, log)
  notes/
report/ # Final report draft or copy
```

initialization:

```powershell
powershell -File references\scripts\case-init.ps1 -Hint "full pentest" -CaseName "acme-2026"
```

## timeline.md format

**Append only** to each record:

```markdown
## {ISO-8601} | {role} | {phase}
- action:
- command_or_ref:
- result_summary:
- artifacts: []      # relative paths under this case
- evidence_ids: []   # E-xxx when promoted
- decision_delta: [] # only decisions changed since the previous transition
- carry_forward_refs: [scope.md] # unchanged authoritative state is referenced, not re-serialized
- next:
```

**MUST NOT** Delete or overwrite an existing `##` time block (correct with new entry + `corrects: {timestamp}`).

### Decision delta boundary

`scope.md`, `workitems.md` and the existing Evidence are the current authoritative state. `timeline.md` records the transition without copying the full snapshot.

- Each real stage/turn transition **MUST** writes `decision_delta`; only list decisions that actually change from the previous state to the current state and will affect subsequent actions. Write `[]` when there are no changes.
- Unchanged route, auth, scope, network profile, tool capability, existing hypothesis/Evidence **MUST NOT** expanded again for handover; placed in `carry_forward_refs` to reference the authoritative file or entry.
- consumer **MUST** parses `carry_forward_refs` first, and then overwrites `decision_delta` into the working context; delta must not be regarded as a complete state.
- A genuine decision boundary is only when there are two or more materially different, evidence-supported branches, and the user's choice will change the next action; a deterministic transition continues directly without restating the context to create a menu.

Representative transition: `Triage -> Static` If auth/scope/route remains unchanged, only `decision_delta: [phase=triage->static]` is recorded, and `carry_forward_refs: [scope.md, evidence/E-triage.md]` inherits the remaining states.

## workitems.md template

```markdown
# Work Items

| ID | title | role | targets | surface | status | evidence | notes |
|----|-------|------|---------|---------|--------|----------|-------|
| WI-001 | Port scan edge | cie | {ip} | network | done | E-001 | |
| WI-002 | Auth bypass check | cpe | /api/login | web | blocked | | need creds |

status: pending | in_progress | blocked | done | cancelled

## Coverage
- [ ] Recon complete for in_scope assets
- [ ] Critical/High candidates triaged
- [ ] Validated findings have Evidence
- [ ] Path documented (attack/call/solve)
- [ ] Timeline continuous (no silent gaps >1 major phase)
- [ ] Report exported via docs-generator
- [ ] field-journal written (anonymized)
```

## attack-chain/pentest hook

| Skill | MUST |
|-------|------|
| `attack-chain/` | Create case directory for multi-stage tasks; update workitems + timeline at the end of each stage |
| `pentest-tools/` | At least 1 timeline after each tool run batch; Discovery → Evidence Draft |
| Other RE skills | Recommended timeline; at least complete the Evidence chain before issuing a report |

## feature

- Agent friendly plain text, diff/review friendly
- Cross-referenced with tool-index command path
- Does not rely on WebSocket live broadcast; just paste the timeline into the report when needed