---
name: api-security
description: Use for authorized security assessment of REST, GraphQL, WebSocket, or SOAP APIs, including discovery, authentication, authorization, rate-limit, and CI/CD testing.
---
# API security testing

## ACTION REQUIRED (execute immediately after reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md` - Confirm that the operation of this skill is an authorized normal operation
2. `NOW`: Confirm whether the current task hits the scope of application of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don’t guess the path
5. `ACT`: Enter the first step of the "workflow" and execute it, do not stop in the confirmation state

> Covers REST / GraphQL / WebSocket / SOAP full protocols
> 10-stage methodology, from discovery to CI/CD integration

## Applicable scenarios

- REST API security testing (OpenAPI/Swagger driver or blind testing)
- GraphQL security audit (introspection, batch query, alias overload)
- WebSocket security testing
- JWT / OAuth 2.0 authentication testing
- BOLA/IDOR/BFLA authorization vulnerability detection
- API speed limit bypass and DoS testing

## 10 stage testing process

### Phase 1: API Discovery and Reconnaissance

```text
Proactively discover:
□ Vespasian: Headless browser crawling → Automatically generate OpenAPI 3.0 / GraphQL SDL specifications
□ Entropy --discover: Extract endpoints from robots.txt + JS file
□ Kiterunner/ffuf: Exploiting undocumented endpoint paths
□ Check common paths: /swagger.json, /openapi.json, /graphql, /api-docs

GraphQL introspection (Level 3 attempt):
1. Standard introspection query
2. Streamline query (bypass WAF full ban)
3. Only check __schema { types { name } } (minimum detection)
```

### Phase 2: Certification Testing

```text
JWT analysis (jwt_tool/Burp):
□ alg:none attack: modify the header to "alg":"none" and clear the signature
□ Key obfuscation: RS256 public key → HS256 symmetric key
□ Weak HMAC key blasting: jwt_tool -C -d wordlist.txt
□ Expiration/statement tampering: Modify exp/iat/sub/role statement
□ kid injection: ../../etc/passwd → HMAC signature bypass

OAuth 2.0：
□ redirect_uri control → authorization code leakage
□ CSRF via state parameter is missing
□ Token leaked in Referer header
□ PKCE deletion detection

GraphQL authentication:
□ mutation bypasses authentication (CSRF) via GET request
□ Batch query authentication bypass
```

### Phase 3: Authorization Test (BOLA/IDOR/BFLA)

```text
BOLA (Object Level Authorization Bypass):
□ Traverse digital ID: /user/1 → /user/2 → /user/3
□ Traverse UUID
□ Traverse username/email
□ Burp Autorize: Dual session replay comparison

BFLA (Function Level Authorization Bypass):
□ Ordinary user execution administrator API
□ HTTP method switching: GET → PUT → PATCH → DELETE
□ API version downgrade: /v2/admin → /v1/admin
□ Batch operation injection: {"users": [1,2,3]} → {"users": [1,2,3,admin_id]}

Tools: Burp Autorize, AuthMatrix, Entropy (malicious_insider persona)
```

### Phase 4: GraphQL Specialization

```text
Introspection Leak → Information Exposure Detection
Alias Overload → 100+ Alias DoS
Batch query → 10+ simultaneous query DoS
Field duplication → __typename × 500
Directive overload → recursive @skip/@include
Loop query → deeply nested introspection recursion
Field Suggestions → Error Message Information Leak
GraphiQL/Playground Exposed → IDE Exposed Risk
GET mutation → CSRF risk
Trace/Debug Mode → Metadata Leak

Tools: FireTail, Escape DAST, api.sh (Phases 1-3)
```

### Phase 5: REST input validation

```text
□ HTTP method switching: GET→POST→PUT→DELETE→OPTIONS→PATCH
□ Content-Type tampering: JSON→XML→multipart
□ NoSQL injection: {"username": {"$gt": ""}}
□ SSRF via URL parameters: webhook URL/avatar URL/import URL
□ XXE in XML endpoint
□ Parameter pollution: /api?role=user&role=admin
□ Batch assignment: add is_admin: true to the request body
```

### Phase 6: Business logic and differential testing

```text
□ Entropy compare: diff v1 vs v2 API → status code change/field deletion/delayed regression
□ Multi-role workflow test: admin/user/readonly permission matrix
□ Coupons/Points/Price Control
□ Race condition: Concurrent request test TOCTOU
```

### Phase 7: WebSocket Testing

```text
□ Endpoint discovery
□ Message injection (payload injection, prototype pollution)
□ Extremely large message processing
□ Type confusion
□ Cross-site WebSocket Hijacking (CSWH)
```

### Phase 8: Speed Limiting and DoS

```text
□ Speed limit bypass via header: X-Forwarded-For, X-Real-IP
□ Path variant: /api/ → /api → /Api/ → /API/
□ Slowloris low bandwidth exhaustion
□ GraphQL batch query deeply nested DoS
□ IP rotation test (ProxyCat proxy pool)
```

### Phase 9: Data Exposure

```text
□ Response overexposure: Compare API return vs UI display
□ Paging enumeration: ?page=1&limit=10000
□ Error message information leakage: stack trace/internal path/SQL error
□ GraphQL nested traversal access unauthorized data
□ OpenAPI specification exposes sensitive endpoints
```

### Phase 10: CI/CD integration

```text
□ Entropy --ci --watch: Automatically rerun when spec changes
□ Escape DAST: Automatically block builds based on severity thresholds
□ Discover persistence as a regression test
□ StackHawk (developer priority, ZAP core)
```

## Toolchain

| Tools | Usage | Get |
|------|------|------|
| Vespasian | Traffic → OpenAPI/GraphQL Specification | GitHub: praetorian-inc/vespasian |
| Entropy | LLM generated attack scenario, 5 personas | GitHub: arjinexe/entropy-chaos |
| Escape DAST | Business logic security testing | escape.tech |
| api.sh | 8-stage full-protocol attack pipeline | GitHub: Sharon-Needles/api |
| FireTail | GraphQL 12 special test | firetail.ai |
| jwt_tool | JWT comprehensive testing | GitHub: ticarpi/jwt_tool |
| Burp Autorize | Dual-session licensing comparison | Burp BApp Store |

## Reference

- `references/rest-graphql-testing.md` — REST + GraphQL in-depth testing
- `references/jwt-oauth-testing.md` — JWT + OAuth security testing


## Task completion self-test (MUST pass before claiming completion)

- [ ] Did I execute every step in the workflow (instead of just reading)?
- [ ] Am I using real toolpaths based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and written back the Checklist items required by RULES?