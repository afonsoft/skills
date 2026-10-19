---
name: attack-chain
description: Use for authorized multi-stage security-assessment planning and orchestration when a task spans reconnaissance, validation, and reporting phases under a written authorization and an approved scope contract. Route single-stage tasks directly to their specialist skill.
---

# Attack Chain Orchestration Skill

## Authorization gate (mandatory before any ACT step)

1. `NOW`: Confirm written authorization for this engagement exists (SoW /
   rules of engagement / SRC or bug-bounty scope). A prior precedent file or
   earlier conversation is **not** authorization.
2. `NOW`: **Create/Update case** (`../scripts/case-init.ps1`) and complete `scope.md` (`../ops/scope-contract.md`); `auth.status!=granted` prohibits ACT
3. `NOW`: Plan the phase with the **lead** role (`../ops/role-map.md`), and write into specialist_roles
4. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
5. `NEXT`: Call bootstrap when tools are missing, don't guess the path
6. `ACT`: Pass the stage latch according to `references/lifecycle-checklist.md`; update `timeline.md` + `workitems.md` (`../ops/timeline-workitem.md`) at each stage; upon discovery, promote to Evidence/Finding
7. Conclusion: `docs-generator` The report must contain an Evidence chain

> Overall coordinator for multi-stage security-assessment planning. When an
> authorized engagement requires a complete path "from A to B," this Skill
> arranges each assessment phase, coordinates sub-Skills, and plans the path
> inside the approved scope. Not exclusive to red-team work — any scoped
> assessment that crosses stage boundaries starts here.

---

## Authorization boundary (hard gate)

This skill plans **assessment phases only**. It contains no exploit commands
by design: every active step is delegated to a specialist module and runs
under the engagement's written authorization plus the `scope.md` contract.

- Written authorization (SoW / rules of engagement / SRC or bug-bounty scope)
  is required before any ACT step. `auth.status!=granted` → plan only, never
  act.
- Every phase must map to an in-scope asset list. Assets not named in
  `scope.md` are out of scope.
- Credential material is handled only for in-scope demonstration of impact;
  recovered secrets are never exfiltrated, reused outside scope, or retained
  in reports un-anonymized.
- DoS, destructive actions, persistence beyond the engagement window, and
  data exfiltration are prohibited regardless of scope.
- All findings are reported with an Evidence chain; high-severity findings
  are escalated to the client immediately instead of being exploited further.

---

## When to route to this Skill

The following scenarios **must** first go through this Skill for full-chain planning before being distributed to specific sub-Skills for execution:

| Scene | Why orchestration is needed |
|------|--------------|
| "Help me conduct a full authorized penetration test" | Plan the entire process from information gathering to reporting |
| "Assess the attack surface of this in-scope target" | Multi-dimensional information gathering + path planning |
| "Attack-path planning exercise" | Requires sequencing of assessment phases |
| "Purple-team / adversary-emulation exercise" | Complete chain mapped to detection coverage |
| "Bug Bounty continuous monitoring" | Multi-stage but bounded process |
| "Assess how far this in-scope vulnerability chains" | Evaluate the chain value of a validated finding |

**Single-stage tasks do not need to go through this Skill**:
- Only do port scanning → Go directly to `pentest-tools/`
- Only do SQL injection → go directly to `pentest-tools/`
- Only do APK reverse engineering → go directly to `apk-reverse/`
- Only do domain assessment → go directly to `windows-ad/README.md`

---

## Arrangement Principles

### The Role of This Skill

```
The user proposed a multi-stage authorized task
    ↓
attack-chain/README.md (this document)
↓ Plan assessment phases and determine their sequence
↓ Assess the evidence and tooling required at each stage
    ↓
Distribute to specific sub-skills for execution:
├── pentest-tools/     → Tool invocation, in-scope validation
├── apk-reverse/       → Mobile analysis
├── js-reverse/        → Web frontend analysis
├── reverse-engineering/ → Binary analysis
├── ida-reverse/       → Deep reverse engineering
└── browser-automation/ → Automated operations
    ↓
After completing each stage, return to this Skill to assess the next step
    ↓
All done → docs-generator generates report
```

### Path Planning Decision Tree

```
Inside the approved scope:
1. What is the target surface? (Web/Internal lab/Cloud/Mobile/IoT)
2. What currently exists? (External perspective / existing evidence / in-scope footholds)
3. What is the engagement goal? (Validated findings / demonstrated impact / detection coverage)
4. Constraints? (Time / approved windows / fragile systems to avoid)
    ↓
Plan the shortest evidence-producing route based on the above
    ↓
A path doesn't work → Go back to this skill and replan alternative paths
```

---

## Assessment phases (lifecycle overview)

Detailed stage gates live in `references/lifecycle-checklist.md`. Each phase
below lists its **objective**, the **specialist module** that executes it, and
the **evidence** it must produce. Operational commands belong to the
specialist modules and are executed only inside an approved scope.

### Phase 0 — Scope confirmation

- Objective: written authorization + `scope.md` complete
  (`auth.status=granted`, legal `network_profile`, asset list,
  `out_of_scope` boundaries).
- Evidence: scope contract, approval record.

### Phase 1 — Reconnaissance and surface mapping

- Objective: enumerate the **in-scope** external surface — approved domains,
  IP ranges, application inventory, technology fingerprint.
- Specialist module: `pentest-tools/` (asset enumeration),
  `threat-intelligence/` (public-source exposure review such as leaked
  credentials in code hosting, for in-scope organizations only).
- Evidence: asset inventory + `timeline.md` entries.

### Phase 2 — Vulnerability identification

- Objective: candidate findings on in-scope assets — known-vulnerable
  components, misconfigurations, injection-class issues, exposed services.
- Specialist modules: `pentest-tools/`, `api-security/`, `cloud-k8s/`,
  `windows-ad/`, `wifi-wireless/`, `firmware-pentest/` per target class.
- Evidence: draft `F-*` candidates with reproduction notes.

### Phase 3 — Validation (proof of exploitability)

- Objective: confirm each candidate is real, on an in-scope host, with the
  minimum action that proves impact. Prefer non-destructive proofs.
- Specialist module: `pentest-tools/` plus the target-class module.
- Evidence: `E-*` records + validated Finding.

### Phase 4 — Impact demonstration (post-exploitation, only if authorized)

- Objective: demonstrate the business impact an attacker could achieve —
  e.g. which data or systems a validated weakness can reach — **strictly**
  inside scope. This phase plans and documents; it does not run covert
  tradecraft. Prohibited: persistence beyond the window, defense
  impairment/tampering, log deletion, exfiltration of real user data,
  lateral spread to out-of-scope assets.
- Specialist module: this skill coordinates; execution via `pentest-tools/`,
  `windows-ad/`, `cloud-k8s/` with lead approval per step.
- Evidence: impact narrative tied to `E-*` records; remediation mapping.

### Phase 5 — Reporting and handoff

- Objective: findings + evidence chain + remediation guidance.
- Specialist module: `docs-generator/` for the report,
  `diagram-generator/` for the attack-path diagram, `field-journal/` for the
  anonymized lesson learned.
- Evidence: report containing the Evidence→Finding→Path chain.

---

## Defensive mapping (for reports)

Map each demonstrated phase to defensive controls so the report is
actionable for the blue side:

| Phase | Primary detection surface | ATT&CK anchor examples |
|------|------------|------------|
| Recon | External monitoring, CT log watch | T1595 Active Scanning |
| Validation | WAF/IDS, app logs, auth telemetry | T1190 Exploit Public-Facing App |
| Impact | EDR, identity telemetry, DLP | T1078 Valid Accounts |

Use `references/lifecycle-checklist.md` for stage latches and
`ops/role-map.md` for the role that owns each gate.

---

## Engagement discipline

### Three bottom lines

1. **All operations must be authorized in writing**
2. **Client data shown in deliverables must be anonymized**
3. **Return the environment to its original state; remove assessment artifacts before closing the engagement**

### Action discipline

- Assess the risk level of each action before executing it
- Notify the engagement manager before high-risk actions
- Keep an operation log (time, action, result) in `timeline.md`
- Immediately report high-risk vulnerabilities once discovered; do not exploit them further
- Never affect business availability (DoS is prohibited)
- Never copy, move, or retain real user data

---

## Relationship with Other Skills in This Package

| Requirement | Route to |
|------|--------|
| In-depth web vulnerability validation | `pentest-tools/` |
| Domain/identity assessment detail | `windows-ad/` |
| Malicious-sample reverse analysis | `malware-analysis/` |
| APK reverse engineering (mobile) | `apk-reverse/` |
| JS frontend signature analysis | `js-reverse/` |
| Report generation | `docs-generator/` |
| Attack path diagram | `diagram-generator/` |

## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each applicable step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index.md`?
- [ ] Have I produced reproducible evidence (records, findings, reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?
