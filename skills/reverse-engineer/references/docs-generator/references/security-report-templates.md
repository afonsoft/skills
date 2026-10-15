# Security/Reverse Engineering/Penetration Testing Technical Document Template

This document provides template documentation for security projects such as reverse engineering, penetration testing, and vulnerability analysis. After the task is completed, the AI should create a document in the user's project directory and output it according to the corresponding template.

---

## 0. Evidence Chain (All security reports MUST include)

> Full Contract: `references/ops/evidence-finding-path.md`
> Case Directory: `work/<case>/` (`case-init.ps1`)

The main body of the report **MUST** contain the following sections (they can be included in the 'Key Findings' but no fields should be omitted):

### 0.1 Scope Summary
- Link to `scope.md`: `auth` / `in_scope` / `network_profile`
- No scope → Must not claim task completion

### 0.2 Evidence
At least 1, fields: `E-id` / `source_ref` / `repro_command` / `content_hash|n/a`

### 0.3 Findings
Each: `F-id` / `severity|n/a_re` / `evidence_ids` / `confidence` / `location` / `status`

### 0.4 Path
At least 1 item `P-id`: `path_type=attack|callflow|solve`, steps can be hung E/F

### 0.5 Timeline Summary
Link to `timeline.md` or embed key 3–10 additional records

---

---

## 0.6 Vendor structure overlay (Professional vendor report structure)

> Full text rules: `references/vendor-report-rules.md` (Issue #65)
> **MUST** Read and select when generating formal security reports; **only extract structure, copying vendor original text/IOC examples is prohibited**.

| Flavor / Overlay | Scene | Skeleton Sentence |
|------------------|------|------------|
| `malware` | Clearly malicious samples / common trojans / white and black | Huorong style: overview → process → sample analysis → emergency response → IOC |
| `apt` | APT/Campaign/Multi-stage chain | Kaspersky: Summary → Infection chain → Investigation → Interesting findings → Technical analysis → Detection and mitigation → IOC |
| `flavor = null` | General Reverse Engineering/Penetration/CTF/JS Signature | Task Template for This Section + Applicable Base Common Elements |
| thin `vuln` | Vulnerability/Patch/CVE Technical Analysis (Explicit) | Overview → Impact/Reproduction → Crash and Patch Analysis → Protection Recommendations |

**General Elements (G1–G7) Summary**: G1 Executive Summary MUST · G2 Scope MUST · G3 E/F/P MUST · G4 IOC only `malware`/`apt` MUST · G5 Recommended in `malware`/`apt`/`vuln` MUST · G6 Appendix SHOULD · G7 ATT&CK in `apt` MUST

The selection of models and the order of chapters are based on `vendor-report-rules.md`; in case of conflicts with §0.1–0.5, the **Evidence contract takes precedence**.

## 1. Reverse Engineering Report Template

```markdown
# [Target Name] Reverse Analysis Report

> Analysis Date: YYYY-MM-DD
> Analyst: [AI / Human]
> Toolchain: [jadx / IDA / radare2 / Frida / ...]

## 1. Overview of Objectives

| Attribute | Value |
|------|---|
| File Name | |
| File Type | APK / ELF / PE / Mach-O / ... |
| Size | |
| MD5 | |
| SHA256 | |
| Package Name/Entry | |

## 2. Analysis Objectives

<!-- The core question this reverse engineering aims to answer -->

## 3. Static Analysis

### 3.1 Basic Information
<!-- Architecture, compiler, protection mechanisms, string characteristics -->

### 3.1.1 Import Table / Dependencies (Binary MUST)
<!-- Write summary for E-imports / E-triage-imports; even if it fails, record Evidence, do not skip -->

### 3.2 Key Functions/Classes
<!-- List the located key logic, with code snippets -->

### 3.3 Encryption/Signature Algorithms
<!-- If encryption is involved, explain the algorithm, key source, and parameter construction -->

## 4. Dynamic Analysis

### 4.1 Hook Record
<!-- Frida / xposed / other hook targets and results -->

### 4.2 Runtime Behavior
<!-- Network requests, file operations, process behavior -->

## 5. Key Findings

<!-- List key conclusions by number -->

1. ...
2. ...
3. ...

## 6. Reproduction Steps

<!-- Allow others to reproduce your analysis results -->

```bash# Key Commands```

## 7. Outstanding Issues

<!-- Unresolved points -->

## 8. Appendix

<!-- hook script, decryption code, screenshots, etc. -->
```

---

---

## 1b. Malware / APT Report (Vendor Flavor)

When the task involves malware analysis, virus reporting, or APT/campaign analysis, **do not** rely solely on the above 'reverse engineering' skeleton; regular reverse engineering tasks should follow the original template, without automatically selecting the vendor flavor:

1. Read `vendor-report-rules.md` and select `malware` or `apt`
2. Output according to the corresponding chapter order
3. Still **MUST** include §0 Evidence chain; `malware` / `apt` flavor also **MUST** include IOC table
4. Static analysis of binary samples **MUST** include the import table evidence (consistent with radare2/ida/malware hardware gate)

## 1c. Vulnerability Technical Analysis Report (thin `vuln` overlay)

When the task is **OS/component vulnerabilities, patch comparison, CVE technical analysis**, or the user explicitly requests a 'vulnerability technical analysis report':

1. Read `vendor-report-rules.md` §3b, using the thin `vuln` chapter sequence (**not** the malware/apt full text flavor)
2. **MUST** include: scope of impact, reproduction within authorization or explicit n/a, crash/root cause or patch difference evidence, protection/patch recommendations
3. **MUST** include §0 Evidence→Finding→Path
4. **MUST NOT** extend the PoC to unauthorized targets, or copy external exploitation weaponization details

## 2. Penetration Testing Report Template

```markdown
# [Objective] Penetration Test Report

> Test Date: YYYY-MM-DD
> Test Scope: [URL / IP / Application Name]
> Authorization status: [Authorized / CTF / Learning environment]

## 1. Executive Summary

<!-- A paragraph summary: what was tested, what was discovered, risk level -->

## 2. Test Scope

| Project | Details |
|------|------|
| Goal | |
| Test Type | Black Box / Gray Box / White Box |
| Test Time | |
| Tools | |

## 3. Summary of Findings

| # | Vulnerability Name | Risk Level | Status |
|---|---------|---------|------|
| 1 | | High/Medium/Low/Information | Verified/To be confirmed |

## 4. Vulnerability Details

### 4.1 [Vulnerability Name]

**Risk Level**: High / Medium / Low

**Description**:

**Impact**:

**Reproduction Steps**:

1. ...
2. ...
3. ...

**Evidence**:

```<!-- Request/Response/Screenshot/Payload -->```

**Repair Suggestions**:

## 5. Attack Path

<!-- If there is a complete attack chain, draw the path -->

```Entry → Information Gathering → Exploit Vulnerability → Privilege Escalation → Goal Achievement```

## 6. Tools and Environment

| Tool | Version | Purpose |
|------|------|------|
| | | |

## 7. Summary of Repair Recommendations

| Priority | Recommendation |
|--------|------|
| P0 | |
| P1 | |
| P2 | |

## 8. Appendix

<!-- Complete payload, scripts, configuration files, etc. -->
```

---

## 3. CTF Writeup Template

```markdown
# [Competition Name] - [Problem Name] Writeup

> Categories: Web / Reverse / Pwn / Crypto / Misc / Forensics
> Difficulty: Easy / Medium / Hard
> Score: N pts
> Time to solve the problem:

## Problem Description

<!-- Original Problem Description -->

## Problem-Solving Approach

### Step 1: Information Collection
<!-- What was observed -->

### Step 2: Vulnerability/Breakthrough Point
<!-- What key points were found -->

### Step Three: Utilize
<!-- How to use it -->

## Key Code/Payload

```python
# exploit code
```

## Flag

```
flag{...}
```

## Pitfall Record

<!-- The winding roads traveled -->

## Knowledge Points

<!-- The knowledge points involved in this question, convenient for future review -->
```

---

## 4. JS/Web Signature Reverse Engineering Report Template

```markdown
# [Site/App] Signature Parameter Reverse Engineering Report

> Analysis Date: YYYY-MM-DD
> Target interface: [URL]
> Signature Field: [Field Name]

## 1. Target Request

```http
POST /xKx0000xKx xKx0001xKx
Host: example.com

param1=xxx&sign=<target field>```

## 2. Positioning Process

### 2.1 Breakpoint/Hook Method
<!-- How to find the location for generating a signature -->

### 2.2 Call Stack
<!-- Key call chain -->

## 3. Algorithm Restoration

### 3.1 Algorithm Types
<!-- HMAC-SHA256 / AES / Custom / ... -->

### 3.2 Parameter Construction
<!-- Which fields participate in signature, sorting rules, delimiter -->

### 3.3 Key Sources
<!-- Hardcoded / API response / Timestamp derived / ... -->

## 4. Local Reproduction Code

```javascript// Node.js reproduction```

## 5. Verification Results

<!-- Compare the signature generated with the reproduction code to the actual request -->

## 6. Anti-scraping / Risk Control Precautions

<!-- Frequency limits, device fingerprinting, environment detection, etc. -->
```

---

## 5. Document Output Standards

### Output Location

- The document is by default output to the **user's current project directory** (not the skill package directory)
- File name format: `YYYY-MM-DD_[类型]-[目标简称]-report.md`
- If the user's project has a `docs/` directory, it should be placed under `docs/` preferentially

### Output Timing

AI automatically invokes this skill to generate documents in the following situations:

1. Reverse task completed, core conclusions have been produced
2. Penetration testing completed, vulnerabilities have been identified and verified
3. CTF challenge solved, flag obtained
4. User explicitly requests to "write a report/document"

### Quality Requirements

- All code blocks must be directly executable or have a clear context
- Do not have placeholder/TODO (if some parts are indeed unfinished, mark as 'To be added' and explain the reason)
- Key findings must be supported by evidence (command output, screenshots, code snippets)
- The reproduction steps must allow a third party to independently reproduce it