# 2026-08-08 Platform-independent structured routing PR integration

## Scene classification

Code audit/tool chain maintenance/multi-platform routing

## Goal Overview

Conduct incremental value reviews on multiple sets of high-conflict PRs, and refactor the valuable parts into platform-independent cores before integration.

## Scope Summary (Desensitization)

- auth_basis: repository_owner_authorized
- network_profile: authorized_upstream_only
- asset_types: [source_repository, pull_request_refs, local_tests]

## Role

- lead_role: lead
- specialists: [cae, doc]

## Complete execution link

1. Grab PR refs from the remote end and compare each PR with the current mainline in the isolated worktree.
2. First judge based on incremental value, then use merge parent to retain the source relationship, and resolve conflicts based on semantics.
3. Decouple structured routing from client access and use JSON as the PowerShell/Bash common source of truth.
4. Only use authorized access control and Bash parity for large PRs, excluding client-specific and generated assets.
5. Run full routing, structural access control, language unit test, grammar and manifest verification.

## Evidence chain summary (desensitization)

| E-id | source_type | Reusable command pattern | Association Finding |
|------|-------------|----------------|--------------|
| E-001 | git diff | `git diff <main>...<pr-ref>` | F-001 |
| E-002 | regression | `test-routing.ps1` + coherence + smoke | F-001 |
| E-003 | unit tests | Python unittest + Node test + Bash parity | F-002 |

## Finding / Path Summary

- top_finding: Client integration is not the core value of structured routing, single source of truth and automatic access control are.
- path_type: callflow
- path_one_liner: any host → optional adapter → routing.json → cross-platform router → unified return access control

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Large PR mixed with client manifests, GIFs, scripts and documentation | Concerns not split | Only minimal cross-platform subset merged | Medium |
| Bash router and PowerShell are each hard-coded | Two sources of truth are bound to drift | Bash reads the same JSON through Python | Medium |
| New pin gate fails first time | Kali manifest keeps floating source | pin manifest and lets actual install command use pin | Medium |
| Gradle wrapper download TLS broken | External network handshake exception | Log and retry on final verification | Low |
| Bash CaseName can write the work root | Missing the existing path constraints of PowerShell during selective merging | Complementing cross-platform equivalence verification and negative CI | Medium |
| Authorization URL marked offline | Bash defaults not aligned with PowerShell | Network target default authorized_target_only; offline local sample only | Low |
| INDEX passed on the development machine, clean clone failed | The generator scanned local private modules that were ignored | Only enumerate Git tracked README.md | Medium |

## Toolchain discovery

Git merge parent can preserve the PR source relationship while allowing semantic deletions within the merge commit. The supply chain gate only works if the manifest metadata is co-fixed with the actual installation command.

## Key code/command

```text
git merge --no-ff --no-commit <pr-ref>
powershell -File references/scripts/test-routing.ps1
powershell -File references/scripts/verify-routing-coherence.ps1
bash references/scripts/master-route.sh --hint "case review evidence graph"
```

## Suggestions for improving this package

All client adapters are placed on separate boundaries; writing client configuration into core routing PRs is prohibited. Large PRs must be split by core, adapters, demo assets, and documentation.

## Reusable patterns/script snippets

The structured routing parity test covers at least ordinary routing, conflict priority routing and the latest new routing to prevent a certain platform entry from lagging behind.

Old/new A/B for the same 163 benchmarks: old hardcoded implementation 137/163 (84.05%), structured implementation 163/163 (100%). Only this quantitative comparison with the input can prove that reconstruction is a substantial improvement rather than an increase in the number of files.

## Evolution action

- [x] Updated routing matrix
- [ ] updated tool-index
- [x] Updated bootstrap-manifest
- [x] Updated sub-skill documentation
- [x] Added pitfalls record
- [ ] No update required

## Environment information

- OS: Windows (master verification) + Linux CI definition
- Tool version: Git / PowerShell / Python 3 / Node.js / Bash
- Target platform/version: client-neutral repository core

## Desensitization requirements

This entry does not contain real targets, credentials, internal addresses, or personally identifiable information.

---
<!-- [Community Contribution] Prepared to push the mainline as instructed by the repository owner. -->