# Penetration/attack chain life cycle checklist

> Compare community pentest skill packages (such as Orizon claude-code-pentest six stages) and integrate this package `attack-chain` + `ops`.
> Source inspiration: Public Claude pentest lifecycle skills (retrieved in 2026-07); **Commands and authorizations are subject to the scope of this package**.
> Date: 2026-07-17

## Before use

- [ ] `case-init` done, `auth.status=granted`
- [ ] `network_profile` ≠ Misuse unrestricted for production
- [ ] `lead` specialist_roles specified (`ops/role-map.md`)

## stage latch

| Stage | Role | This package skill | Completion criteria |
|------|------|------------|----------|
| 0 Scope | lead | ops/scope-contract | ready_for_act |
| 1 Recon | cie | pentest-tools | assets list + timeline |
| 2 Enum/Vuln | cpe | pentest-tools/api-security | candidate F-* draft |
| 3 Validate | cpe | pentest-tools | E-* + validated Finding |
| 4 Post-ex (if authorized) | cpe/lead | attack-chain second half | not beyond out_of_scope |
| 5 RE Auxiliary | cre | ida/apk/js/… | Only if client/binary is required |
| 6 Report | doc | docs-generator | Evidence→Finding→Path |
| 7 Journal | lead | field-journal | desensitization |

## Differences from the "automatically penetrate a domain name" skill (features)

| Common external automation packages | reverse-skill |
|------------------|---------------|
| Domain names are scanned by default | Required scope asset list |
| Write a report directly with weak evidence | Force E/F/P chain |
| Single session without role | role-map handover |
| tool-index + bootstrap | tool-index + bootstrap |

## Each stage has at least one timeline

See `ops/timeline-workitem.md` for format.