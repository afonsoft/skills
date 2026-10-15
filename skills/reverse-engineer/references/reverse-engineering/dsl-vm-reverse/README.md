---
name: dsl-vm-reverse
description: Reverse JavaScript-based custom DSL/VM interpreters, non-standard WASM-like runtimes, and risk-control engines. Use when analyzing IIFE or switch-based opcode dispatchers, extracting instruction tables, recovering bytecode semantics, capturing VM state at runtime, or reconstructing execution flow.
---

# 🔄 DSL Custom Virtual Machine Reverse Engineering (DSL VM Reverse Engineering)

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Confirm that the current task is a custom JS opcode VM / risk control engine, not standard WASM or regular webpack
2. `NOW`: `case-init` until `scope.md` is ready; offline samples use `offline` / `lab`
3. `ACT`: Do file classification from '3. General Reverse Workflow' Phase 1, do not stop at the directories

> Used for reverse engineering custom WASM virtual machines / risk control engines implemented based on JavaScript

---

## Table of Contents

- [1. Scope of Application ](#1-适用范围)
- [2. DSL VM Recognition Feature ](#2-dsl-vm-识别特征)
- [3. General Reverse Engineering Workflow ](#3-通用逆向工作流)
- [4. Opcode Extraction and Classification ](#4-opcode-提取与分类)
- [5. Runtime capture scheme ](#5-运行时捕获方案)
- [6. Common Status Codes ](#6-常见状态码)
- [7. Skill Self-Check List ](#7-skill-自检清单)

---

## 1. Scope of Application

Use this skill when the target file meets any of the following **features**:

| # | Feature | Description |
|---|------|------|
| 1 | IIFE beginning + a large number of single-letter variable names | `!function(){var U=void 0,y=parseInt,E0=Function,...}` |
| 2 | Contains `DG()` or similar functions with switch-case loops | Interpreter main loop, `d[7]&31` decodes opcode |
| 3 | Large file (500KB+) but zero-byte proportion < 1% | Non-standard WASM, pure JS |
| 4 | Includes `C[number]` constant table reference | `C[9][xxx]` function table/string table |
| 5 | Single-line compressed code | 583KB single line, obfuscated variable names |

### Exclusion Rules

| Condition | Non-this skill | Transfer to |
|------|-----------|------|
| The file starts with `\x00asm` | Standard WASM binary | `reverse-engineering/languages.md` |
| File contains WASM magic number with `Uint8Array([0,97,115,109])` | WASM embedded | After extracting .wasm, convert to IDA/Ghidra |
| Standard Webpack Packaging (`function(e,t,n){...}`) | Regular JS | `js-reverse/` |
| Zero byte ratio > 20% | WASM binary | `reverse-engineering/languages.md` |

---

## 2. DSL VM Identification Features

### Code Features

```javascript
// Feature 1: IIFE entry, single-letter variables mapping to numeric constants
!function(){
    var U=void 0, y=parseInt, E0=Function, AN=Uint8Array;
    var E=15, l=10, m=12, x=16, S=13, $=11;
// Map numeric constants to variable names, replacing original numbers
    ...
}

// Feature 2: Interpreter Main Loop DG()
function DG(C, d, ...) {
    var d = [];  // 数组模拟 WASM stack/locals
    for (d[7] = x; d[7] !== U;) {
        var aE = d[7] & 31;         // 低 5 位 = opcode
        var O = d[7] >> 5 & 31;      // 高 5 位 = sub-operation
        switch (aE) {
            case 0: /* ... */ d[7] = 612; break;
            case 1: /* ... */
// ... N cases
        }
    }
}

// Feature 3: The constant table C[9] stores function indices and strings
// C[9][0] = ["pc"]      → Function parameter description
// C[9][667] = "string"  → string constant
// C[9][x] = number      → Function index

// Feature 4: W(C[index], null, ...) call pattern
// W = Function.prototype.call.bind(call)
// All built-in functions are called via C[index]

// Feature 5: Instruction Encoding Format
// d[7] = opcode(bit 0-4) | subop(bit 5-9) | operand(bit 10+)
```

### Opcode Encoding Format

Each instruction is encoded as a 32-bit integer:

```
bit 0-4:   opcode (0-N)
bit 5-9:   sub-operation (0-31)
bit 10-31: operand/immediate value

Decoding:
  aE = d[7] & 31        → opcode
  O  = d[7] >> 5 & 31   → sub-operation
  d[other] = d[7] >> 10  → operand
```

---

## 3. General Reverse Engineering Workflow

### Phase 1: Document Classification (5 minutes)

```bash
# Check if it is a DSL VM
python3 << 'EOF'
with open('target.js', 'rb') as f:
    head = f.read(100)

# 1. Check the WASM magic number
if head[:4] == b'\x00asm':
    print("标准 WASM 二进制")
    exit()

# 2. Check the proportion of zero bytes
data = open('target.js', 'rb').read()
zero_pct = data.count(b'\x00') / len(data) * 100
print(f"零字节占比: {zero_pct:.1f}%")

if zero_pct > 20:
    print("WASM 二进制")
elif head[:2] == b'!f':
# Check single-letter variable pattern
    if b'var U=void 0' in head or b'U=void 0,y=parseInt' in head:
        print("→ DSL VM!")
    else:
        print("普通 JS IIFE")
EOF
```

### Phase 2: Variable Mapping Table Extraction (10 minutes)

```python
import re

with open('target.js', 'r', errors='replace') as f:
    s = f.read()

# Extract the first 2000 characters of var X=numeric mapping
mappings = re.findall(r'var\s+(\w+)\s*=\s*(\d+)', s[:2000])
print('常量映射:')
for name, val in mappings:
    print(f"  {name:4s} = {val:3d} (0x{int(val):02x})")
```

### Phase 3: Opcode Extraction and Classification (15 minutes)

```python
# 1. Extract all cases
all_cases = re.findall(r'case\s+(\d+):', s)
unique = sorted(set(int(c) for c in all_cases))

print(f"总 case: {len(all_cases)} 个")
print(f"唯一 opcode: {len(unique)} 个: {unique}")

# 2. Categorize each opcode
for op in unique:
    idx = s.find(f'case {op}:')
    snippet = s[idx:idx+200]
    if 'd[7]=' in snippet:
        op_type = 'BRANCH'
    elif 'return' in snippet:
        op_type = 'RETURN'
    elif 'W(C[' in snippet:
        op_type = 'CALL'
    elif 'new' in snippet:
        op_type = 'ALLOC'
    elif 'try' in snippet or 'catch' in snippet:
        op_type = 'EXCEPTION'
    else:
        op_type = 'ARITH/STORE'
    print(f"  opcode {op:2d}: {op_type}")
```

### Phase 4: Constant Table Analysis (30 minutes)

```python
const_refs = re.findall(r'C\[9\]\[(\d+)\]', s)
unique_refs = sorted(set(int(x) for x in const_refs))

print(f"C[9] 引用: {len(unique_refs)} 个索引")
print(f"范围: {min(unique_refs)} - {max(unique_refs)}")

# Analyze the context for each citation
for ref in unique_refs[:20]:
    idx = s.find(f'C[9][{ref}]')
    ctx = s[max(0,idx-50):idx+80]
    clean = ''.join(c if c.isprintable() else ' ' for c in ctx)
    print(f"  C[9][{ref}] → {clean}")
```

### Phase 5: Export Function Tracing (1-2 hours)

Exported functions (such as `getToken`) are located through the following path:

```
1. Find AWSCInner.register() or a similar registration call
2. Determine the modules and factory functions to register
3. Find the object returned by the factory function → Export the function definition location
4. If the function name is not in JS → store it as bytecode in the C[9] constant table
5. Track the call chain:
   AWSCInner._modules['fy'].getToken()
→ W(C[function index], null, ...)
→ DG() Interpreter executes the encoded instruction sequence
```

### Phase 6: Runtime Injection (if pure static analysis is insufficient)

```javascript
// Inject the minimal AWSC compatible environment
const fakeEnv = {
    AWSCInner: {
        _modules: {},
        register(name, moduleName, factory) {
            this._modules[moduleName] = factory();
        }
    }
};

// Execute DSL VM code
dslVmCode();

// Get export
const token = fakeEnv.AWSCInner._modules['fy'].getToken({});
```

---

## 4. Opcode Extraction and Classification

### Reference opcode comparison table (based on existing cases)

| Opcode | Operation Type | Feature |
|--------|---------|------|
| 0 | **BRANCH** | `d[7]=xxx` Unconditional jump |
| 1 | **CALL** | `W(C[Y],null,function(){...})` Embedded Function Call |
| 2 | **ARITH** | `d[4]=0`, `d[7]=72` variable assignment |
| 3 | **ARITH** | `d[0]=d[1][C[x]]`, `d[5]=d[0]<d[3]` Comparison Operations |
| 4 | **STORE** | `d[8]=d[5]in d[4]` Property Access/Existence Check |
| 5 | **ARITH** | `d[8]=d[4]-d[8]` Arithmetic Operations |
| 6 | **RETURN** | `return gV`, `throw` return/throw exception |
| 7 | **ALLOC** | `d[6]=[]`, `d[6][C[8]](...)` push operation |
| 8 | **BRANCH** | `d[7]=d[k]?512:425` Conditional Jump |
| 9 | **STRING** | `d[6][C[t]]=d[m]`, `new fh(...)` regex |
| 10 | **ALLOC** | Function parameter preparation, call stack creation |
| 11 | **STRING** | `new fh("\\s",d[5])` Regular Expression Match |
| 12 | **STORE** | `P[d[9]]=d[4][C[H]](d[3])` Data Transfer |
| 13 | **CALL** | `C[9][113]=d[9]` Module Initialization |
| 14 | **STRING** | `d[8]=d[9]+d[m]` String Concatenation |
| 15 | **RETURN** | `return EL;` function return |
| 16 | **ALLOC** | `var r,P,Z,B...` Local Variable Declaration |
| 17 | **ALLOC** | `(Z=[])[C[8]](69,T,445)` Static Array Initialization |
| 18 | **TABLE** | Function Table/Type Table Initialization |
| 19 | **EXCEPTION** | `try{for(var RK=x;...` try-catch loop |
| 20 | **DOM** | `Is[d[o]]` DOM Operations |
| 21 | **STORE** | Safely access global/object properties |
| 22 | **STRING** | `new fh(r,v)` String/Regex Processing |
| 23 | **BRANCH** | `try...catch` Secure Fetch + Conditional Jump |
| 24 | **CALL** | `W(C[2],null,8,z,FL)` Multi-parameter Function Call |
| 25 | **EXCEPTION** | `try{...}catch(C){...}` Exception Catch + Jump |

---

## 5. Runtime Capture Scheme

### Plan A: Selenium + CDP Native Events (Recommended, Highest Success Rate)

```python
from selenium import webdriver

driver = webdriver.Chrome()

# Injection Anti-Detection
driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
    "source": r"""
        Object.defineProperty(navigator, 'webdriver', {get: () => false});
        Object.defineProperty(navigator, 'plugins', {get: () => [1,2,3,4,5]});
        Object.defineProperty(navigator, 'languages', {get: () => ['zh-CN','zh','en']});
    """
})

# Send CDP native mouse events
driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
    "type": "mousePressed",
    "x": 549.5, "y": 441.2,
    "button": "left", "buttons": 1,
    "clickCount": 1, "pointerType": "mouse"
})
```

### Plan B: Playwright Headless Browser

```javascript
const { chromium } = require('playwright');

async function run() {
    const browser = await chromium.launch();
    const page = await browser.newPage();

// Intercept network requests
    await page.route('**/api/**', async route => {
        await route.continue_();
    });

    await page.goto('https://target-page.com');

// Wait for DSL VM initialization
    await page.waitForFunction(() => {
        return window.AWSCInner &&
               window.AWSCInner._modules &&
               window.AWSCInner._modules['fy'];
    });

// Execute operation
    await page.mouse.move(500, 400);
    await page.mouse.down();
// ... operation sequence
    await page.mouse.up();
}
```

### Plan C: Pure Protocol Verification (Very Low Success Rate)

> Tokens generated by DSL VMs are usually tightly bound to the browser context (TLS JA3 fingerprint, IP, cookies, request headers, etc.). When detached from the browser, the server can detect the context mismatch. **Using a pure protocol solution is not recommended**.

---

## 6. Common Status Codes

| Code | Meaning | Handling |
|------|------|------|
| 0 | **Verification Passed** ✅ | Retrieve sessionId + sig |
| 300 | **Risk Control Interception** | Blocked, unable to pass |
| 8778 | **Verification failed, please retry** | Retry operation |
| 8776 | **Operation too fast, please retry** | Retry after increasing the delay |
| 69634 | **General Failure** | Check if the parameters are correct |

---

## 7. Skill Self-Check List

- [ ] Have I completed the DSL VM recognition (IIFE + single-letter variables + DG() interpreter)?
- [ ] Have I extracted the variable mapping table (`var X=数字`)?
- [ ] Have I extracted and categorized the opcode list?
- [ ] Have I analyzed the scope of references to the constant table C[9]?
- [ ] Have I located the export function registration point?
- [ ] When pure static analysis is not enough, have I tried a runtime injection solution?
- [ ] After completing the task, was the field journal updated?
- [ ] Have you discovered new tools/new scenarios → update routing.md?

---

## Route Registration

| Type | Route |
|------|------|
| **Target Type**: WASM / DSL VM / Custom Instruction Set | `reverse-engineering/dsl-vm-reverse/README.md` |
| **User Intent**: "DSL VM / Risk Control Engine Reverse Engineering" | This skill |
| **Toolchain**: Playwright / Selenium CDP | Browser Injection Solution |

### Path Intersection

```
DSL VM reverse path:
reverse-engineering/dsl-vm-reverse/ → Phase 1-6 Workflow
↓ If you need to capture runtime data
  browser-automation/ → Playwright/Selenium CDP
↓ If you need to analyze the API protocol layer
  js-reverse/ → Observe→Capture→Rebuild
```
