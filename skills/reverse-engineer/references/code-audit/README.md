---
name: code-audit
description: Use for authorized source-code security review and SAST workflows including Semgrep, CodeQL patterns, dangerous API hunting, and fix verification.
---

# Source Code Security Audit

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` or code audit authorization
2. `NOW`: Confirm access to **source code/repository** (no source code binary → switch to RE skill)
3. `NOW`: Clarify the language stack and scope (directory/service/PR diff)
4. `NEXT`: tool-index; semgrep, etc.
5. `ACT`: Threat modeling sketch → Automated scanning → Manual verification

## Applicable Scenarios

- White-box auditing, PR/differential security review
- Semgrep / CodeQL / Bandit / gosec and other SAST
- Dangerous APIs, injection points, missing authentication, encryption misuse
- Division of work with `supply-chain-security/`: This skill leans towards **proprietary code logic**, while the supply chain relies more on pipelines

## Workflow

### 1. Scope and Threat Model

```text
□ Trust boundaries: user input, files, deserialization, SSRF, authentication middleware
□ High-value assets: authentication, payment, management terminal, key processing
```

### 2. Automatic Scanning

```bash
semgrep --config auto .
# Or Project Rules Package
semgrep --config p/owasp-top-ten .
```

### 3. Manual Verification (MUST)

```text
□ Each SAST hit: accessibility? exploitability? false positive?
□ Authentication: IDOR/Privilege Escalation, Missing Validation, Incorrect Multi-Tenant Isolation
□ Injection: SQL/Command/Template/LDAP
□ Encryption: Hardcoded keys, ECB, custom crypto
```

### 4. Output

```text
Finding: Location + Data Flow + PoC + Fix Recommendation
Optional ATT&CK / CWE Number
```

## Toolchain

| Tool | Language/Scenario |
|------|-----------|
| Semgrep | Multi-language Fast Rules |
| CodeQL | Deep Data Flow (GitHub) |
| Bandit | Python |
| gosec / staticcheck | Go |
| SpotBugs / FindSecBugs | Java |

## References

- `references/sast-review-checklist.md`
- `../supply-chain-security/` `../api-security/` `../llm-security/` (Agent code)

## Routing Context

**Upstream**: MASTER R26
**Character**: `ops/role-map.md` cae
**Downstream**: Dependency vulnerabilities → supply-chain; Runtime verification → pentest-tools

## Task Completion Self-Check

- [ ] Has it been manually verified rather than just pasting the scanner output?
- [ ] Does it include repair suggestions?
- [ ] Is it limited to the scope of authorized repositories?
- [ ] Checklist?