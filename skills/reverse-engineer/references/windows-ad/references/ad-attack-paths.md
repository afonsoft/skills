# AD Attack Path Quick Reference

| Path | Prerequisite | Tool Clues |
|------|------|----------|
| Kerberoast | SPN Account | GetUserSPNs / Rubeus |
| AS-REP Roast | No Pre-Authentication Required | GetNPUsers |
| ESC1 | Registerable templates + Forgable SAN | Certipy |
| ESC8 | HTTP enrollment + relay | ntlmrelayx |
| ACL → DA | GenericAll on user/group | BloodHound |
| NTLM Relay | Signature Not Enforced | Responder + Relay |

Always: Authorization → Enumeration → Path Scoring → Minimal Verification → Cleanup.