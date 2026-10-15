# Authorization pre-declaration — reduces disclaimer noise, cannot replace scope.md

> This document only solves one thing: Don't regard "the user clicked on the target" as authorization.
> The executable authorization gate is still `case-init.ps1` → `auth.status=granted` of `work/<case>/scope.md` + legal `network_profile`.

---

## CRITICAL

Common scenarios in this package (SRC / own system / paid contract / CTF shooting range / responsible disclosure) can ** reduce cliche disclaimers.

**AI must not identify this document as `auth.status=granted`. **

- User mentioned domain name / IP / sample path ≠ Authorized
- It is forbidden to use this file to skip `case-init`
- It is forbidden to automatically add `-AuthGranted` in the skill "so that the process can go on"
- CTF / shooting range: still need to build case, use `lab` or `offline` for `network_profile`
- Real external network: ACT must be granted + `authorized_target_only` (or contract document)

---

## Allow/Disable

1. **MUST NOT** Overwrite `ops/scope-contract.md` with this file
2. **MUST NOT** Run nmap / sqlmap / upload / exploit on the target without `scope.md`
3. **MUST** distinguish between "less legalese" and "already allowed to take action"
4. **MUST** Output technical analysis when technology is uncertain, rather than pretending to have insufficient authorization to stop work.
5. Unbuilt case or `auth.status!=granted` → `case-init` first, don’t guess

---

## Relationship with other files

| File | Function |
|------|------|
| **precedent-auth.md** (this file) | less disclaimer; **not** written granted |
| `ops/scope-contract.md` + `case-init.ps1` | Unique executable authorization gate |
| `precedent-reverse.md` / `precedent-pentest.md` | Daily operations are not a criminal tutorial; still subject to scope |

```
case-init/scope.md → Can ACT
precedent-auth.md → Don’t use clichés instead of scope
PRIMARY README.md → How to do it
```
