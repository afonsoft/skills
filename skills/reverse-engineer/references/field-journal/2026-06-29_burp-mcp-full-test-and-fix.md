# 2026-06-29 burp-mcp-full full testing and repair

## Scene classification
BurpSuite extension development/testing

## Goal Overview
Conducted full runtime usability testing on burp-mcp-full extension (Burp Suite Professional MCP Full Control, 63 tools), found and fixed 3 bugs + 1 bridge layer race condition.

## Complete execution link

1. Static verification: Check Java dispatch table / getToolList() / bridge buildToolDefinitions three places 63 tool consistency
2. Compile: build.bat automated fat-jar packaging (JDK 21, montoya-api 2025.5, gson 2.11.0, nanohttpd 2.3.1)
3. Loading: Load the extension in Burp Suite Professional 2026.4.2 and confirm [MCP] Server started
4. Runtime test: directly call 127.0.0.1:9876 through node http client in 5 batches:
- First batch: 30 read-only/encoding/query tools (zero side effects)
- The second batch: network sending class (send_request / repeater / intruder, target scanme.nmap.org)
- The third batch: Intruder 7 variants (attack/async/wordlist/pitchfork/cluster_bomb/battering_ram/with_options, small range enumeration)
- The fourth batch: Scope/Configuration/Rules/handler/add_issue/compare
- The fifth batch: crawl + proxy_clear
5. Found and fixed 3 bugs, and passed the regression verification

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| `scan()` request_count is always 0 | AuditConfiguration does not accept the seed URL, the code is missing addRequest | Parse the host/port/ path from the url, construct a GET HttpRequest and feed it to activeAudit.addRequest() | 2h (including verification) |
| `send_to_intruder()` reports HttpRequest must have an HttpService | Use HttpRequest.httpRequest(raw) without service overload | Added buildRequestWithService(): Regularly parse host/port/https from the Host header → HttpService, use httpRequest(HttpService, raw) overload | 20min |
| `set_upstream_proxy()` Missing parameter space pointer NPE | params.get("proxy_host") returns null → .getAsString() NPE | Add null judgment: if (!params.has("proxy_host")) returns clear error | 5min |
| mcp-bridge.js API asynchronous race condition: the 4th of 4 fast requests lost response | process.exit(0) kills unfinished HTTP requests when stdin close | pending counter + stdinClosed flag → exit only after all requests are completed | 1h (including mock test) |
| curl HTTP_CODE=000 cannot detect the port | curl is banned by the sandbox on this machine | Use the node http module for detection instead | 5min |
| Montoya API Audit package path inference error | Based on online javadoc, it is inferred that Audit is under the scanner package | javap decompiles the real montoya-api-2025.5.jar and confirms that it is under the scanner.audit package | 30min |
| File encoding problem causes the Edit tool to fail to match | UTF-8 with BOM Chinese content is displayed in the terminal with mis-encoding | Use Python for replacement, specify utf-8-sig | 10min |

## Toolchain discovery

- montoya-api version 2025.5 Audit in `burp.api.montoya.scanner.audit.Audit` (not scanner.Audit)
- AuditConfiguration factory method does not accept seed URL, the seed must be fed through Audit.addRequest(HttpRequest)
- HttpRequest.httpRequest(raw) without service overload is enough for Repeater, but Intruder requires HttpService
- Intruder.sendToIntruder(HttpRequest) requires that request must be appended with service
- major()/minor()/build() of api.burpSuite().version() has been removed deprecation→removal in 2025.5 and needs to be replaced by buildNumber()/edition()/toString()
- send_request uses http.sendRequest(), but does not enter proxy history.
- The local curl is blocked by the sandbox, so you need to use node http for detection.
- IDA MCP port is not fixed 13337 (incremented between instances), but Burp MCP port is configurable through system properties/env, and the port is fixed

## Key code/command

### Full test script mode```javascript
const http = require('http');
function call(tool, params={}, timeoutMs=30000) {
  return new Promise((resolve) => {
    const body = JSON.stringify({tool, params});
    const req = http.request({hostname:'127.0.0.1',port:9876,path:'/',method:'POST',
      headers:{'Content-Type':'application/json','Content-Length':Buffer.byteLength(body)}}, (res)=>{
      let d=''; res.on('data',c=>d+=c); res.on('end',()=>{ try{resolve(JSON.parse(d));}catch(e){resolve({__raw:d.slice(0,200)});} });
    });
    req.on('error', e => resolve({__err: e.message}));
    req.on('timeout', () => { req.destroy(); resolve({__timeout:true}); });
    req.setTimeout(timeoutMs);
    req.write(body); req.end();
  });
}
```

### buildRequestWithService (core fix)```java
private HttpRequest buildRequestWithService(String rawRequest) {
    java.util.regex.Matcher m = java.util.regex.Pattern.compile(
            "(?im)^Host:\\s*([^:\r\n]+)(?::(\\d+))?\\s*$").matcher(rawRequest);
    if (!m.find()) return HttpRequest.httpRequest(rawRequest);
    String host = m.group(1).trim();
    boolean isHttps = rawRequest.contains("https://") || rawRequest.contains(":443");
    int port = m.group(2) != null ? Integer.parseInt(m.group(2))
              : (isHttps ? 443 : 80);
    HttpService svc = HttpService.httpService(host, port, isHttps);
    return HttpRequest.httpRequest(svc, rawRequest);
}
```

### Bridge layer race condition fix (mcp-bridge.js)```javascript
let pending = 0;
let stdinClosed = false;
rl.on('line', async (line) => { ... pending++; ... finally { pending--; if (stdinClosed && pending === 0) process.exit(0); } });
rl.on('close', () => { stdinClosed = true; if (pending === 0) process.exit(0); });
```

### scan() seed repair```java
// After constructing a GET seed request from the URL, feed it to audit
java.net.URL u = new java.net.URL(url);
String host = u.getHost();
boolean isHttps = "https".equalsIgnoreCase(u.getProtocol());
int port = u.getPort() > 0 ? u.getPort() : (isHttps ? 443 : 80);
String path = (u.getPath() == null || u.getPath().isEmpty()) ? "/" : u.getPath();
String pathQuery = u.getQuery() != null ? path + "?" + u.getQuery() : path;
HttpService svc = HttpService.httpService(host, port, isHttps);
HttpRequest seedReq = HttpRequest.httpRequest(svc,
    "GET " + pathQuery + " HTTP/1.1\r\nHost: " + host + "\r\nConnection: close\r\n\r\n");
activeAudit.addRequest(seedReq);
```

## Suggestions for improving this package

- The routing matrix has covered BurpSuite MCP, no modification is required
- `burpsuite-mcp-guide.md` Update log added (3 fixes + bridge layer + full verification results)
- The tool table has been updated Scanner (scan adds mode parameter) and Intruder (send_to_intruder Host header requirement)
- No need to add new bootstrap entries (the compilation script build.bat is self-contained)
- IDA MCP port is not fixed, it is recommended to indicate it in the MCP service management table

## Reusable patterns/script snippets

- 63 tools full usability testing script mode (see key code above). Suitable for regression testing of any HTTP-based MCP extension.
- buildRequestWithService mode: parse HttpService from Host header. Applicable to all scenarios in Montoya API where HttpRequest + HttpService need to be constructed from the original request.

## Evolution action
- [x] Updated routing matrix (routing has been covered, no need to modify)
- [ ] Updated tool-index (use .template, no modification required)
- [ ] Updated bootstrap-manifest (no new tools)
- [x] Updated sub-skill documentation (burpsuite-mcp-guide.md adds update log)
- [x] Added pitfall record (this entry)
- [ ] No update required

## Environment information
- OS: Windows 11 Pro for Workstations 10.0.26200
- Tool version: JDK 21.0.11+10 / Burp Suite Professional 2026.4.2 (20260402000047704)
- Target platform: montoya-api 2025.5 / gson 2.11.0 / nanohttpd 2.3.1
- Test target: scanme.nmap.org (authorized test site)

## Desensitization requirements
The test target is the public test site scanme.nmap.org, no desensitization is required. Does not include real domain name/IP/Token/ user name.

## Index synchronization (last step before submission)

After writing this log, `_index.md` must be updated simultaneously:

1. Add a new line (including date, keywords) in the corresponding section of "Classification by Scenario"
2. Update the count of "Cumulative Statistics" and the "Last Update" date

---
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. See CONTRIBUTE-BACK.md for the process -->