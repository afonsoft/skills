---
name: database-security
description: Use for authorized database security assessment covering PostgreSQL/MySQL/MSSQL/Mongo/Redis exposure, authz, UDF/command paths, and misconfiguration review.
---

# Database Security Assessment

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read precedent-pentest for context (not authorization); **destructive statements are prohibited in the production database** unless explicitly allowed
2. `NOW`: scope Clearly state examples, account permissions, and whether writing/deleting is allowed
3. `NEXT`: Client tool path
4. `ACT`: Exposure → Authentication → Authorization → Configuration → Chain of utilization verification (Security)

## Applicable Scenarios

- Database unauthorized/weak password/misconfigured binding 0.0.0.0
- Excessive permissions, dangerous functions (xp_cmdshell, COPY PROGRAM, UDF)
- Horizontal: From application account to DBA
- NoSQL injection and Redis file writing, etc. (authorized environment)

## Workflow

```text
□ Network Exposure and TLS
□ Account Roles and Grantee
□ Sensitive Form Access Control
□ Dangerous configurations: file_priv, xp_cmdshell, load_file
□ Is the audit log enabled
□ Backup and Snapshot Permissions
```

## Toolchain

| Tool | Purpose |
|------|------|
| Official CLI | Connection and Enumeration |
| sqlmap | Injection Verification (Authorized) |
| nuclei | Known Exposure Template |
| Cloud RDS Console Audit | Configuration |

## References

- xKx0000xKx
- xKx0001xKx xKx0002xKx

## Routing Context

**Upstream**: MASTER R35
**Downstream**: Obtain OS command → attack-chain; Cloud hosting → cloud-k8s

## Task Completion Self-Check

- [ ] Whether to prevent unauthorized writing and deleting?
- [ ] Whether to distinguish between configuration issues and available chains?
- [ ] Checklist?