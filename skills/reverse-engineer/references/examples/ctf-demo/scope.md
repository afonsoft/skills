# Case Scope

## meta
- case_id: ctf-demo
- created: 2026-08-02T00:00:00.0000000+08:00
- operator: local
- primary_skill: pwn-chain/README.md
- primary_id: R17
- lead_role: lead
- specialist_roles: [pwn-specialist]
- hint: CTF pwn stack overflow gets

## auth
- status: granted
- basis: ctf_lab (CTF target range authorization)
- evidence_of_auth: Platform authorization terms (authorization included with the target range challenge)
- MUST NOT proceed if status != granted

## in_scope
- assets:
  - xKx0001xKx
- surfaces: [binary download, remote service]
- activities: [static analysis, exploit development, remote verification]

## out_of_scope
- assets: [Other challenges, platform infrastructure]
- activities: [dos, phishing_real_users, unrestricted_exfil]

## network_profile
- mode: authorized_target_only
- notes: |
    offline | lab_only | authorized_target_only | unrestricted_lab
    Change mode only after auth.status = granted.

## deliverables
- report: true
- field_journal: true
- diagrams: true
- timeline: true

## constraints
- timebox: {2h}
- stealth: low
- data_handling: anonymize

## signoff
- ready_for_act: true
- checklist:
  - [x] auth.status = granted
  - [x] in_scope.assets non-empty OR offline sample path set
  - [x] network_profile.mode chosen
  - [x] out_of_scope reviewed
  - [x] roles assigned (see xKx0002xKx)

## ops_refs
- xKx0003xKx
- xKx0004xKx
- xKx0005xKx
- xKx0006xKx
- xKx0007xKx
