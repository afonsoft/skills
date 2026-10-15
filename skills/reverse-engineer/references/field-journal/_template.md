# [Date] [Project Abbreviation]

## Scene Classification
<!-- APK reverse engineering / JS signing / binary analysis / penetration testing / CTF / packet capture analysis / others -->

## Overview of Goals
<!-- A sentence explaining what is being done -->

## Scope Summary (Desensitized)
<!-- auth.basis / network_profile.mode / in_scope type (do not write real xKx0000xKx) -->
- auth_basis:
- network_profile:
- asset_types: []

## Characters
<!-- lead / cie / cpe / cre / … see xKx0001xKx -->
- lead_role: lead
- specialists: []

## Complete Execution Chain
<!-- Complete steps from obtaining the goal to producing the result, including the detours taken -->

1. ...
2. ...
3. ...

## Evidence Chain Summary (De-identified)
<!-- Up to 3 items: E-id + command mode + conclusion type; full evidence in the user project -->
<!-- Field alignment xKx0002xKx Contract (see explanation below) -->
| E-id | severity | status | source_type | reusable command pattern | related Finding |
|------|----------|--------|-------------|----------------|--------------|
| E-001 | info | observed | command | xKx0003xKx | F-001 |
| E-002 | high | validated | command | xKx0004xKx | F-001 |

> **Contract Alignment (review_case.py)**: If this case generates an independent evidence directory (`evidence/E-xxx.md`),
> Each piece of evidence must satisfy the field contract `references/case-review/scripts/review_case.py`, otherwise the `--strict` validation will FAIL:
>
> - Title: `### E-xxx` (must match the file name, e.g., `E-001.md` → `### E-001`)
> - `- severity:` ∈ critical / high / medium / low / info / n/a
> - `- status:` ∈ observed / candidate / validated / false_positive / accepted_risk
> - `- repro_command:` Required (for offline scenarios, note 'offline/离线' in notes to be exempted)
> - `- content_hash:` sha256 or n/a; when filling in sha256, match with `- artifact_path:` (relative path inside case)
> - `- linked_workitem:` is optional, WI-xxx must actually exist
>
> Self-check: `python references/case-review/scripts/review_case.py <case_root> --verify-hashes --strict`

## Finding / Path Summary
- top_finding:
- path_type: attack | callflow | solve
- path_one_liner:

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| ... | ... | ... | ... |

## Toolchain Discovery
<!-- Which tools were used, which ones are useful, which ones have pitfalls, version compatibility issues -->

## Key xKx0020xKx

```
<!-- Paste the actual key commands, hook scripts, decryption logic used -->
```

## Suggestions for Improvement of This Package
<!-- Is the routing accurate? Is Bootstrap missing? Does the documentation need to be supplemented? Does the new tool need to be added to the manifest? -->

## Reusable Patterns/Scripts Snippets
<!-- If you have produced reusable hook scripts, decryption logic, or bypass solutions, paste them here -->

## Evolution Actions
<!-- What updates were actually executed after this write-back -->
- [ ] Updated the routing matrix
- [ ] Updated tool-index
- [ ] Updated bootstrap-manifest
- [ ] Updated the sub-skill documentation
- [ ] Added pitfalls record
- [ ] No update needed

## Environmental Information
<!-- Record the key environment at that time -->
- OS:
- Tool version:
- Target platform/version:

## Desensitization Requirements

> **This document may be synchronized to the remote along with the repository and must be sanitized. For the complete specification, see [`anonymization.md`](anonymization.md) (Placeholder Master List + Automatic Detection Script).**

- Target domain name/IP: Replace with `{target_domain}` / `{target_ip}` (see `anonymization.md` for details)
- Real URL path: keep the structure, replace the domain name
- Token/Cookie/ password/JWT/API key: use `{token}` / `{password}` / `{api_key}` as placeholders
- Username/Phone Number/Email: Use `{username}` / `{phone}` / `{user_email}` as placeholders
- Internal IP/Port: For internal network IP segments, retain the first two segments (`10.0.x.x`)
- Vulnerability payload: technical content can be retained, but target characteristic parameters (such as `?id={user_id}`) should be replaced

Before submission, run a regex scan against the **Field-Journal mandatory checklist item** at the end of `anonymization.md`.

If it is a private repository and it is confirmed that it will not be made public, the above restrictions can be relaxed, but it is still recommended to anonymize sensitive information.

## Index Synchronization (Final Step Before Submission)

After finishing this log, `_index.md` must be updated simultaneously:

1. Add a new row (including date and keywords) in the corresponding subsection of 'Classified by Scene'
2. Append this file name under the corresponding technology in 'High-Frequency Success Mode (by Technology)'
3. Append this file name under the corresponding entity in 'Entity Inversion (by Target Feature)'
4. Update the total number in 'Cumulative Statistics' and the 'Last Updated' date

---
<!-- [Evolution Statistics] Total projects completed in this package: N | New modes this time: X | Toolchain issues fixed this time: Y -->
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. See CONTRIBUTE-BACK.md for the process -->