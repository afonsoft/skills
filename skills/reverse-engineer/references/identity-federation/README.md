---
name: identity-federation
description: Use for authorized assessment of federated identity systems including SAML, OIDC, OAuth2 flows, SSO misconfiguration, and token confusion issues.
---

# Identity Federation (SAML / OIDC / OAuth)

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read precedent-pentest; SSO test account and IdP/SP range are in scope
2. `NOW`: Prohibited brute-force attempts to lock real user accounts
3. `NEXT`: Packet capture tools and documentation (metadata URL)
4. `ACT`: Protocol Flow Mapping → Common Mismatches → Verification

## Applicable Scenarios

- SAML Response signature/assertion tampering aspect (classic vulnerability pattern)
- OIDC Implicit/Authorization Code + PKCE missing
- redirect_uri / state / nonce issues
- Confusion between IdP and SP metadata, multi-tenant issuer
- Complementary to `api-security` JWT attacks (this skill is more focused on federated and SSO flows)

## Workflow

```text
□ Clear Diagram: User → SP → IdP → Token → SP
□ Collection: /.well-known/openid-configuration, SAML metadata
□ Check: precise matching of redirect_uri, state binding, PKCE
□ Check: SAML signature coverage, algorithm downgrade
□ Session Fixation and Logout Failure
```

## Toolchain

| Tool | Purpose |
|------|------|
| Burp + SAML Raider, etc. | Assertion Editing (Authorization) |
| jwt_tool | JWT section |
| Browser DevTools | Redirect Chain |
| IdP Management Logs | Audit |

## References

- `references/sso-flow-checklist.md`
- `../api-security/` `../windows-ad/` (Enterprise IdP)

## Routing Context

**Upstream**: MASTER R37
**Downstream**: Pure API JWT → api-security; Cloud IdP → cloud-k8s

## Task Completion Self-Check

- [ ] Whether to map the complete SSO flow?
- [ ] Does each finding have reproduction and impact?
- [ ] Checklist?