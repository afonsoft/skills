---
name: case-review
description: Reviews a reverse-skill case package for scope readiness, Evidence to Finding to Path traceability, work item coverage, timeline references, and optional artifact hash integrity before report handoff.
---

# Evidence Graph Review

Use this skill when a reverse engineering, forensics, CTF, or authorized security case needs a defensible handoff. It audits the existing `work/<case>/` package without changing the case or touching a target.

## Scope

This skill covers:

- Scope metadata and target-activity readiness
- Evidence record structure and reproducibility fields
- References from work items and timeline entries to Evidence
- Structured Findings and Paths in report Markdown
- Optional SHA-256 verification for case-local artifacts
- A Markdown or JSON review result for a report handoff

It MUST NOT perform reconnaissance, exploitation, dynamic instrumentation, or target changes. Those actions belong to the routed analysis skill and require the case scope gate.

## ACTION REQUIRED

1. `NOW`: read `../field-journal/precedent-reverse.md` and confirm that this is a review of an existing authorized case package.
2. `NOW`: confirm the case path and choose read-only review mode.
3. `NEXT`: read `../tool-index.md`; this skill uses only Python 3 standard library and does not require bootstrap.
4. `NEXT`: run `python3 scripts/review_case.py <case-root> --format markdown`.
5. `ACT`: resolve every error, then rerun the review before claiming a handoff is complete.

## Tool dependencies

| Tool | Required | Purpose | Auto-bootstrap |
|------|----------|---------|---------------|
| Python 3.9+ | Yes | Runs the read-only case review script | No, use the platform Python installation |

No network access or third-party package is required.

## Workflow

### Phase 1: Intake

Run the review against the existing case directory:

```bash
python3 references/case-review/scripts/review_case.py work/<case> --format markdown
```

Confirm that xKx0000xKx, xKx0001xKx, xKx0002xKx, and xKx0003xKx are present. A non-strict review reports scope warnings while a strict review treats warnings as handoff blockers.

## Suggested Next Step (Choose a Number)

1. Fix the authorization, scope, or network_profile fields in scope.md
2. Continue to check the reproducible commands and sources recorded in Evidence
3. Export the current review results and attach them to the interim report
4. Switch to JSON output to integrate with CI or other review tools
5. Pause, first confirm the scope of review

### Phase 2: Traceability

Review the checks for:

- Evidence IDs that do not exist
- Findings without xKx0004xKx
- Paths without an allowed xKx0005xKx or Evidence reference
- Work items and timeline entries pointing to unknown Evidence
- Unlinked Evidence records
- Validated Findings with low confidence

An offline observation may use xKx0006xKx only when its xKx0007xKx field explicitly documents the offline limitation.

Use JSON when another tool needs stable fields:

```bash
python3 references/case-review/scripts/review_case.py work/<case> --format json
```

## Suggested Next Step (Choose a Number)

1. Fill in the missing Evidence and retain the original instructions
2. Re-examine after binding the candidate Finding to the Evidence
3. Add P-id and Path steps to the call chain or attack chain
4. Generate Markdown handoff summary
5. Switch back to PRIMARY skill and continue analyzing

### Phase 3: Fixity verification

When an Evidence record contains both xKx0000xKx and xKx0001xKx, verify the case-local artifact:

```bash
python3 references/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

The script accepts `sha256:<64 hex characters>` and checks that the artifact remains inside the case root. A hash mismatch is a hard failure.

The PowerShell Evidence helper can record a hash while appending a record:

```powershell
powershell -File references/scripts/append-evidence.ps1 -CaseRoot work\<case> -Id E-001 -Title "Sample hash" -ReproCommand "sha256sum evidence/sample.bin" -ArtifactPath "evidence\sample.bin"
```

## Suggested Next Step (Choose a Number)

1. Fix hash mismatch or replace the corrupted working copy
2. Add SHA-256 and artifact_path for non-fixed original files
3. Continue to the report generation stage
4. Export JSON results for CI to save
5. Pause and request manual review

### Phase 4: Handoff

Use strict mode before a final report or specialist handoff:

```bash
python3 references/case-review/scripts/review_case.py work/<case> --strict --format markdown > work/<case>/report/case-review.md
```

The command is read-only with respect to the case unless shell redirection is explicitly used to save its output. The review is not legal advice and does not replace organizational evidence handling procedures.

## Suggested Next Step (Choose a Number)

1. Submit the approved review results to `docs-generator/` to generate the official report
2. Return to PRIMARY skill to complete the new analysis evidence
3. Archive Markdown and JSON review results
4. Pause and request manual review

## Language behavior contract

- Internal reasoning, tool selection, and phase control: English.
- User-visible messages, section labels, reports, and next-step menus: Chinese unless the user requests another language.
- Default bilingual labels place Chinese first and English second, separated by xKx0001xKx.

## Bootstrap boundary

This skill has no third-party dependency. If Python 3 is unavailable, the only allowed recovery action is the repository bootstrap path when a Python capability is registered for the current platform. If no such capability is registered, stop and report the missing runtime. Do not guess executable paths, download packages, or perform a manual install from inside this skill.

## Routing context

**Upstream entry**: any reverse, forensics, CTF, or authorized security skill that has produced a case package.

**Downstream exit**: xKx0002xKx for a formal report, or the original PRIMARY skill when the graph is incomplete.

**Related modules**: xKx0003xKx, xKx0004xKx, xKx0005xKx, xKx0006xKx, and xKx0007xKx.

## References

- [NIST SP 800-86: Guide to Integrating Forensic Techniques into Incident ResponsexKx0008xKx
- [SWGDE Best Practices for Computer Forensic AcquisitionsxKx0009xKx
- [SWGDE Best Practices for Archiving Digital and Multimedia EvidencexKx0010xKx

## Task Completion Self-Check

- [ ] Have I reviewed scope.md, timeline.md, workitems.md, and evidence/?
- [ ] Are all findings cited with existing evidence?
- [ ] Do all Paths contain valid path_type and Evidence references?
- [ ] Was hash verification performed, or was the reason for not performing it recorded?
- [ ] Was the review run again in strict mode and the results saved?