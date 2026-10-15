# Evidence → Finding → Path Evidence Chain

> Inspired by Z3r0 Evidence Plane, implemented as a **Markdown field contract**.
> reverse-skill Features: Reporting templates with `docs-generator`, desensitized write-back with `field-journal`, reproducible command binding.

## 1. Evidence (Immutable Observation)

Each piece of evidence should be presented in a separate paragraph or table:

```markdown
### E-{nnn}
- title:
- observed_at:
- source_type: command | screenshot | file | log | memory | network | manual
- source_ref: {path or command id}
- content_hash: {sha256 of artifact if file, else n/a}
- artifact_path: {relative path under case root when content_hash is recorded, else n/a}
- repro_command: |
    {exact command}
- raw_excerpt: |
{Desensitized excerpt}
- linked_workitem: WI-{nnn} | n/a
- supersedes: E-{nnn} | none
```

**MUST**: Find at least 1 piece of cited evidence; `repro_command` third-party can run or indicate offline restrictions.

**CLI helper** (write to `work/<case>/evidence/E-*.md`):

```powershell
powershell -File references/scripts/append-evidence.ps1 -CaseRoot work/<case> `
  -Id E-001 -Title "..." -ReproCommand "..." -Severity info -Status observed
```

When the evidence is a case-local file, pass `-ArtifactPath` to record a SHA-256 fixity value and a relative artifact path. Review the complete case graph before handoff:

```bash
python3 references/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

The review is read-only and checks scope fields, Evidence records, work item and timeline references, structured Findings, Paths, and artifact hash matches.

## 2. Finding (Security/Reverse Engineering Conclusion)

```markdown
### F-{nnn}
- title:
- severity: critical | high | medium | low | info | n/a_re
- category: vuln | misconfig | design | reverse_algo | bypass | other
- status: candidate | validated | false_positive | accepted_risk
- evidence_ids: [E-001, E-002]
- location: {file:line | addr | url | class.method}
- impact:
- confidence: high | medium | low
- repro_steps:
  1.
  2.
- remediation: {or n/a for pure RE}
- optional_attack: {ATT&CK ID or empty}
```

**MUST**: `evidence_ids` must not be empty; when `status=validated`, confidence must not be low (unless marked as residual risk).

## 3. Path (Attack Path / Call Path / Solution Path)

Unified called **Path**, explained by task type:

| Task | Path Meaning |
|------|-----------|
| Penetration / Attack Chain | Attack Path Steps |
| Reverse | Key Call/Data Flow Steps |
| CTF | Problem Solving Steps |

```markdown
### P-{nnn}
- title:
- path_type: attack | callflow | solve
- start:
- goal:
- steps:
  1. action: — evidence: E-xxx — finding: F-xxx | none
  2. action: — evidence: E-xxx — finding: F-yyy | none
- residual_risks:
```

**MUST**: Each step can be associated with evidence; if the endpoint finding of an attack path declares 'permissions/data obtained', there must be validated evidence.

## 4. Position in the Report

`docs-generator` Security Report **MUST** include:

1. Scope Summary (linked to case `scope.md`)
2. Evidence table or section
3. Findings list (including evidence_ids)
4. At least 1 Path (attack/call/solve)
5. Timeline Summary (full text link optional to `timeline.md`)

For details, see the **Evidence Chain** section in `docs-generator/references/security-report-templates.md`.

## 5. field-journal Hook

When writing back to the journal, **SHOULD** excerpt:

- 3 key Evidence IDs + commands
- 1 core Finding
- Reusable Path pattern in one sentence

The full sensitive content is only in the user's project report; the journal **MUST** be anonymized (`anonymization.md`).

## 6. Differences (Features) with Z3r0

| Z3r0 | reverse-skill |
|------|----------------|
| PG immutable row + API | Markdown file + hash field |
| UI Review Queue | Report + next-step menu + journal |
| ATT&CK Deep Binding | Optional Tag, Not Mandatory in UI |


## Validated sufficiency (Issue #77 / R4*)

Global bind rule remains: every Finding references **>=1** Evidence.

Promotion to status=validated is stricter (decision cookbook):

| status | Evidence bar |
|--------|----------------|
| preliminary / candidate | >=1 (unchanged) |
| **validated** | **SHOULD >=2 independent** Evidence (best: 1 static + 1 dynamic). A single Evidence item alone MUST NOT silently promote to validated — keep xKx0005xKx, or record residual_risk + human confirm. |
| blocked promotion | record Evidence E-insufficient-evidence |

Full recipes: [nalysis-decision-framework.mdxKx0006xKx (R4*, R1, R41, R44).
