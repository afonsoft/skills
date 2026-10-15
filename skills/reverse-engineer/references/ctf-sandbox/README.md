---
name: ctf-sandbox
description: Thin PRIMARY for CTF / AWD / range multi-type orchestration. Hands off to the sidecar CTF-Sandbox-Orchestrator. Use when the user says CTF, AWD, range, or competition problem and no more specific pwn/APK/IDA route has already won.
---

# CTF sandbox entry (sidecar, not a second router)

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: ACT to the real external network is prohibited before running `../scripts/case-init.ps1`; `auth.status=granted`. For competition/range use `-NetworkProfile lab` or `offline`.
2. `NOW`: Open `../../CTF-Sandbox-Orchestrator/ctf-sandbox-orchestrator/README.md` under the package root and click its sandbox to continue.
3. `MUST NOT` writes 40+ `competition-*` sub-skills into `routing.json`. This entrance is a PRIMARY latch only.
4. `ACT`: The orchestrator selects a downstream `competition-*`. When the specific question type has been clarified (pwn/ROP, APK, IDA), it should have been won by the more advanced rules of `routing.json`, so don’t grab it again.

## Why a separate layer?

`CTF-Sandbox-Orchestrator/` is a **GPL bypass package**, and the license is inside the sandbox by default. The core routing package is still MIT + `scope.md` gated. This skill only provides keyword entry and does not incorporate the competition tree into the core.

## Task completion self-test (MUST pass before claiming completion)

- [ ] Do I go case-init/scope first instead of treating "user said CTF" as an authorized external network?
- [ ] Did I turn on the sidecar orchestrator instead of using the 40 sub-skills as PRIMARY?
- [ ] If the task is actually pwn/APK/IDA, do I let a more specific PRIMARY take over?