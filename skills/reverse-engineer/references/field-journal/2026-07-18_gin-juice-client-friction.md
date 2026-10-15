# Modern Web Range Friction → Skill Reinforcement

> Date: 2026-07-18
> Scenario: Legal public shooting range (PortSwigger class scanner-eval / OWASP Juice Shop demo)
> Desensitization: No real business domain name usage details

## Conclusion (for next time Agent)

**Not penetrated ≠ The package is invalid. ** Must deliver: surface map, sink list, latch reason, Evidence(observed|validated).
Failures should be written into the timeline and fed back into the playbook.

## Step on the pit

| Pit | Phenomenon | Repair/Discipline |
|----|------|-----------|
| Case-init authorization is polluted | status becomes a strange string after `-AuthGranted` | Only pending/granted/denied/unknown; `PSBoundParameters` is allowed to judge AuthStatus |
| lab_only not ready | ready_for_act false when network=lab_only | lab_only + granted + assets → ready |
| Windows curl `[]` | `bad range in position` | **must** `curl.exe --globoff` |
| append-evidence special characters | RawExcerpt contains quotes/XML error | block indent + remove control characters |
| Public network demo 503 | Juice Shop Heroku hangs | Change to local Docker or other legal targets; don’t fight to the death |

| agent-browser ref expired | click failed | Re-snapshot after page changes |

## Reusable mode

1. Surface → Sink → Chain (see `pentest-tools/references/client-side-lab-playbook.md`)
2. Inventory class `innerHTML = fetchBody`: first prove the sink, then find 200 non-digits
3. Static rg sink + agent-browser eval dual certificate

## Toolchain

- case-init / case-guard / append-evidence / smoke  
- agent-browser（CDP）  
- curl --globoff  

## environment

- Windows + PowerShell 5.1
- Docker Desktop daemon may not be ready