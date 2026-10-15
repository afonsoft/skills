# [Seed] JS signature reverse engineering (Webpack + AES + timestamp)

## Scene classification
JS signature

## Goal Overview
Restore the `sign` parameter generation algorithm of a certain web application interface to achieve local reproduction.

## Complete execution link

1. Browser packet capture → Found that the POST request carries `sign` and `timestamp` parameters
2. Search for "sign" in the JS source code → locate the chunk file packaged by webpack
3. Set a breakpoint at the sign assignment → hit and view the call stack
4. Call stack traceback → find signature function (in a certain webpack module)
5. Analyze signature logic: `sign = HmacSHA256(sorted_params + timestamp, secret_key)`
6. Key source: hardcoded in another webpack module
7. Node.js local reproduction → the generated sign is consistent with the browser
8. Verification: Use the reproduced sign request interface → return normal data

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| There are too many results for searching "sign" | The variable name is compressed after webpack packaging | Search for `sign=` instead or use initiator to backtrace after finding the request in the network panel | 15min |
| The breakpoint is hit but the code cannot be understood | webpack compression + variable name obfuscation | Formatting with Chrome's Pretty Print, and then using SourceMap (if available) | 10min |
| Local reproduction results are inconsistent | Wrong parameter sorting method | Carefully look at the sort logic in the source code (processed in key alphabetical order + special characters) | 30min |
| The timestamp accuracy is wrong | The server uses seconds, I used milliseconds | `Math.floor(Date.now() / 1000)` | 5min |
| Key not found | Key introduced via require in another chunk file | Console.log prints key variable at breakpoint | 10min |

## Toolchain discovery

- The initiator column of Chrome DevTools locates signed functions faster than searching the source code
- Using Pretty Print + breakpoints for code packaged by webpack is more efficient than hard reading
- If there is a SourceMap (.map file), directly restore the original code
- The `crypto` module of Node.js can directly reproduce most signature algorithms

## Key code/command

```javascript
// Node.js reproduction
const crypto = require('crypto');

function generateSign(params, timestamp, secretKey) {
// 1. Sort parameters by key in alphabetical order
    const sorted = Object.keys(params).sort().map(k => `${k}=${params[k]}`).join('&');
// 2. Concatenate timestamp
    const message = sorted + '&timestamp=' + timestamp;
    // 3. HMAC-SHA256
    return crypto.createHmac('sha256', secretKey).update(message).digest('hex');
}

const params = { user_id: '123', action: 'query' };
const timestamp = Math.floor(Date.now() / 1000);
const secretKey = 'hardcoded_key_from_webpack';
console.log(generateSign(params, timestamp, secretKey));
```

## Suggestions for improving this package

- The env-patching.md of js-reverse should add "How to handle dependencies between webpack chunks"
- It is recommended to join the "Common Signature Algorithm Identification" quick check (HMAC-SHA256 vs MD5 vs custom)

## Reusable patterns/script snippets

**JS signature reverse standard process**:```text
1. Capture the packet and find the signed request
2. Use the initiator/call stack to locate the signature function
3. Analyze signature logic (parameter sorting + splicing + encryption)
4. Find the key source (hard-coded/interface return/time derivation)
5. Node.js recurrence
6. Comparison and verification
```

**Common signature patterns**:```text
- HmacSHA256(sorted_params, key) → most common
- MD5(params + salt + timestamp) → older systems
- AES(JSON.stringify(params), key) → encrypt rather than sign
- RSA sign → rare, usually financial
```

## Evolution action
- [ ] No need to update routing matrix
- [ ] No need to update bootstrap-manifest
- [ ] No need to update child skill documents

## Environment information
- OS: Windows
- Tool version: Chrome DevTools, Node.js 20+
- Target platform: Web (Webpack packaged SPA)

## Desensitization requirements
This article is seed data, written based on public technical models, and does not involve real goals.

---
<!-- [Community Contribution] Seed data, no PR required -->