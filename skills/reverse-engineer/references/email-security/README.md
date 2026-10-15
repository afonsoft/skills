---
name: email-security
description: Use for authorized email security review including phishing analysis, header authentication (SPF/DKIM/DMARC), BEC patterns, and mailbox token abuse research.
---

# Email Security & Phishing Analysis

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Confirm authorization (analyze sample emails/tenant configuration review)
2. `NOW`: Do not re-deliver malicious samples to real users
3. `ACT`: Header Authentication → Content/URL → Attachment Sandbox → Tenant Control Plane Recommendations

## Applicable scenarios

- Phishing email disassembly and IOC
- SPF/DKIM/DMARC configuration evaluation
- BEC Business Email Fraud Pattern
- OAuth App Phishing/Mailbox Token Abuse (Federated llm/cloud Identity)
- Security awareness drill design (authorized)

## Workflow

```text
□ Complete original header: Received chain, From/Return-Path consistency
□ SPF/DKIM/DMARC alignment result
□ URL sandbox and attachment static (joint malware-analysis)
□ Differences in counterfeit brands and reply addresses
□ Tenant: Anti-phishing policy, external tagging, MFA, OAuth app consent
```

## Toolchain

| Tools | Purpose |
|------|------|
| Email client "View Source" | Header |
| dig/nslookup | SPF/DMARC record |
| urlscan/sandbox | links and attachments |
| Tenant Management Center | Strategy |

## Reference

- `references/email-auth-checklist.md`
- `../malware-analysis/` `../attack-chain/` (phishing stage) `../windows-ad/` (token)

## Routing context

**Upstream**: MASTER R36
**MUST NOT**: Unauthorized mass testing of phishing for third-party domains

## Task completion self-check

- [ ] Is the header authentication conclusion complete?
- [ ] Is the IOC detectable (in conjunction with threat-hunting)?
- [ ] Checklist？