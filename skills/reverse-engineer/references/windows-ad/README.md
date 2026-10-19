---
name: windows-ad
description: Use for authorized Active Directory and Windows identity attacks including Kerberos, AD CS, BloodHound paths, NTLM relay, and domain privilege escalation research.
---

# Windows / Active Directory Security

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` for operator context — precedent is not authorization
2. `NOW`: **Domain/AD testing must have clearly defined authorization scope** (including DC, whether poisoning/relay is allowed)
3. `NOW`: case-init; clearly write the network_profile and prohibited actions
4. `NEXT`: tool-index (impacket/certipy/bloodhound and other common manual operations)
5. `ACT`: Start with identity enumeration and BloodHound mapping, without immediately proceeding to destructive exploitation

## Applicable Scenarios

- Domain penetration, Kerberoasting, AS-REP, delegation
- AD CS (ESC1–ESC8, etc.) Certificate Attacks
- BloodHound / SharpHound attack path
- NTLM Relay / Coercer Forced Authentication
- Local privilege escalation to domain path (using Potato, etc. as a springboard)

## Relationship with attack-chain

- **Multi-stage from external network to domain controller** → PRIMARY can still be `attack-chain/`, this skill is **AD specialist**
- **Already focused on identity within the domain** → PRIMARY = This skill

## Workflow

### 1. Enumeration

```bash
# Example Impacket / Built-in (requires credentials and authorization)
nxc smb <range> -u user -p pass
bloodhound-python -d domain.local -u user -p pass -c All -ns <DC>
```

### 2. Common Routes (First Map, Then Gun)

```text
□ Kerberoast / AS-REP → Offline cracking
□ ACL Abuse (GenericAll/WriteDacl)
□ Delegation (Non-binding / Binding / Resource-based)
□ AD CS Template Error → Certipy
□ Relay: LLMNR/NBT-NS + ntlmrelayx (confirmed authorization)
```

### 3. Vouchers and Horizontal

```text
□ secretsdump / lsassy / mimikatz (strict authorization and cleanup)
□ PtH / PtT / Gold tickets are only within the authorized red team scope
□ Write Evidence for each step; confirmation from high-risk users
```

## Toolchain

| Tool | Purpose |
|------|------|
| BloodHound / SharpHound | Path Map |
| Certipy | AD CS |
| Impacket / NetExec | Lateral Movement and Enumeration |
| Rubeus / Mimikatz | Tickets and Credentials (Authorization) |
| Coercer / Responder | Forced Authentication / Poisoning |

## References

- xKx0000xKx
- xKx0001xKx
- xKx0002xKx
- seeds: xKx0003xKx xKx0004xKx xKx0005xKx

## Routing Context

**Upstream**: MASTER R24
**Downstream**: Report `docs-generator`; EDR study required `edr-bypass-re`
**MUST NOT**: Unauthorized DCSync / Golden Ticket on production

## Task Completion Self-Check

- [ ] Does the image/enumeration come before the utilization?
- [ ] Should reproducible commands be recorded and desensitized?
- [ ] Are the scope prohibitions being followed?
- [ ] Checklist?