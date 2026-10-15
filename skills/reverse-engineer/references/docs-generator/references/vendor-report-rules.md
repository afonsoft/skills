# Vendor Report Rules (Professional Vendor Report Structure Overlay)

> Issue #65 Question 2.
> **Only extract the structure and writing rules; copying any vendor report text, charts, real IOC examples, or large sections of exposition is prohibited.** 
> This document is an **overlay layer**: it does not replace the `security-report-templates.md` task template, nor does it weaken §0 Evidence→Finding→Path.

Structure reference (public example, skeleton only):

| Flavor | Main Reference | Scenario |
|--------|--------|------|
| `malware` | Huorong Security Virus/Technical Analysis Report | Clear common trojan, White+Black, phishing poisoning, malicious samples |
| `apt` | Kaspersky Securelist / APT Campaign Report (e.g., MATA) | APT, group campaigns, multi-stage infection chains, industry targeting |

Principle: **Focus on quality, not quantity of templates** — only 2 full-text flavors from vendors (`malware` / `apt`) + Base common elements + **optional thin overlay** (such as `vuln` vulnerability technical analysis). Regular reverse engineering, penetration testing, CTF, and JS reports maintain task templates and are not by default disguised as malware reports; `vuln` is **not** a third default full-text flavor.

---

## 0. When to Enable

When generating **security-related** reports in `docs-generator` (reverse engineering / malware / penetration closure / user explicitly requests 'professional report' or 'vendor style'), you **MUST** read this file. Choose the vendor flavor only when task evidence or user explicit request supports it; otherwise, use `flavor = null`, only overlaying general professional elements and the original task template.

| Signal | Flavor / Overlay |
|------|------------------|
| APT / Group / Campaign / Multi-stage C2 / Industry-targeted / ICS / Spear-phishing Campaign | `apt` |
| Clearly define malicious samples, trojans, data theft, white plus black, counterfeit sites | `malware` |
| User explicitly requests vulnerability/patch/CVE technical analysis, or task evidence is OS/component vulnerability research | `flavor = null` + **thin overlay `vuln`** (see §3b) |
| General APK/ELF/PE/Mach-O Reverse engineering, algorithm analysis, firmware analysis, penetration testing, CTF, JS signing | `flavor = null`; using the original task template and the minimal set of common professional elements |

When the user explicitly specifies 'by Kaspersky/APT', 'by Huorong/virus report', or 'by vulnerability technical analysis', it overrides the automatic selection.
**Prohibited** to put the normal malware/APT/ reverse default into the `vuln` directory.

---

## 1. General Professional Elements (Base)

The following Base elements are applied according to report type. Elements marked **MUST** are mandatory; elements related to a specific flavor must not appear in unrelated tasks just to fill the template. If no applicable content exists, use `n/a` and explain the reason.

| # | Element | Requirement |
|---|------|------|
| G1 | Executive Summary / Overview | **MUST**: 3–8 sentences: what was analyzed, most severe conclusions, scope of impact, recommended actions |
| G2 | Scope and Authorization | **MUST**: Link to case `scope.md` (see template §0.1) |
| G3 | Evidence→Finding→Path | **MUST**: See `security-report-templates.md` §0 and `references/ops/evidence-finding-path.md` |
| G4 | IOC Table | `malware` / `apt` **MUST**; other tasks only appear when relevant indicators exist |
| G5 | Recommendation / Disposal | `malware` / `apt` **MUST**: At least 1 actionable recommendation; other tasks according to the original task template |
| G6 | Appendix Metadata | **SHOULD**: Tools and versions, sample hash, full reproduction commands |
| G7 | ATT&CK Mapping | **MUST** (under `apt`; if no applicable technique, `n/a` + reason); other tasks **SHOULD** |

### 1.1 IOC Table Minimum Column

```markdown
| Type | Value | Context | First/Last Found | Source Evidence | Confidence |
|------|----|--------|---------------|----------|--------|
| file_sha256 / file_md5 / domain / ip:port / url / mutex / path / registry | … | Where found | YYYY-MM-DD / n/a | E-id | high/med/low |
```

### 1.2 Copyright and Safety Boundaries

- Do not paste paragraphs or figure captions from vendor PDFs/webpages as your own analysis.
- Use placeholders for real tokens, intranet URLs, and customer identifiers.
- Unauthorized targets may not output attack step details that can be directly exploited (follow case scope / RULES).

---

## 2. Flavor: `malware` (Huorong Style · Explicit Choice)

**Narrative Goal**: Let the reader understand within 5 minutes 'What it is → How it came about → How the sample was handled → How it was disposed of → What IOCs are present'.

### 2.1 Recommended Chapter Order

```markdown
# [Title: One-Sentence Threat Definition]

> Analysis Date / Analyst / Sample Identifier (Hash)

## 1. Overview
(G1: Discovery channels, camouflage methods, core technical points, whether it can be detected or removed on the product side—if unknown, write n/a)

## 2. Attack / Infection Process
(Flowchart: Mermaid or step-by-step list; corresponding to Path `path_type=attack`)

## 3. Sample Analysis
### 3.1 Sample Traceability
### 3.2 Static Analysis
(**MUST** include in the import table / basic identity Evidence: E-imports or equivalent; see radare2/ida/malware hard door)
### 3.3 Dynamic Analysis / Behavior
(If there are no dynamic conditions, then n/a + reason)
### 3.4 Core Findings (Table of Findings or Numbered List, attach evidence_ids)

## 4. Emergency Handling Methods
(Only perform within the authorized scope: first confirm the scope and preserve evidence such as samples, memory, process tree, network connections, and logs, then isolate the host; after obtaining approval from the responsible person, terminate processes, isolate/clear files, check hosts/startup items, perform a full-disk scan and review. Files must not be deleted directly before preserving evidence.)

## 5. Summary Explanation
(Risk reminders and prevention for regular users/operations and maintenance)

## 6. IOC Information
(G4 Table)

## 7. Evidence Chain Summary
(§0: E / F / P / Timeline; can be merged with §3.4 but fields are not omitted)

## 8. Appendix
(Tool version, reproduction command, script path)
```

### 2.2 Writing Style

- Chinese users default to Chinese; conclusions first, details later.
- Static analysis is layered according to 'components/stages' to avoid unstructured long log pasting.
- Disposal steps must be executable independently; empty talk like 'enhance safety awareness' is forbidden.

---

## 3. Flavor: `apt` (Kaspersky Securelist style)

**Narrative Objective**: To clearly tell the story of the battle-level conflict—who attacked whom with what chain at what time, how the investigation progressed, how the components were divided, and what the defending side used to verify.

### 3.1 Recommended Chapter Order

```markdown
# [Campaign/Cluster Name]: [One-sentence Impact]

> Date / Team / Industry and Regional Scope (if known)

## 1. Executive summary
(G1: Time window, victim profile, entry point, family/cluster affiliation, duration, most important conclusions)

## 2. The infection chain
(Phased: Delivery → exploit/loader → Main host → Post-infiltration/data exfiltration; unknown stages explicitly 'limited visibility')
Corresponding Path; recommended to include a chain diagram

## 3. Incident investigation
(Investigation narrative: key turning points, intranet proxy/C2 characteristics, how to expand scope; attach Timeline)

## 4. Interesting findings
(3–7 non-obvious points, try to attach E-id / F-id to each)

## 5. Technical analysis
### 5.1 Component Overview Table (loader / trojan / stealer / …)
### 5.2 Component Behavior and Configuration
### 5.3 Static Highlights (Including Import Tables/Packers/Persistent Evidence)
### 5.4 Network and C2
(Can attach ATT&CK Table G7)

## 6. Detection and mitigation
(Detection ideas / Hunting clues / Mitigation priorities; not empty slogans)

## 7. IOC
(G4; grouped by type)

## 8. Evidence Chain Summary
(§0 Field)

## 9. Appendix
(Sample list with hashes, tool versions, reference public numbers; do not copy the main text from external reports)
```

### 3.2 Writing Style

- The timeline and 'visibility restrictions' should be written honestly.
- Interesting findings ≠ repeating summaries; write the truly key anomalies found in the investigation.
- Component analysis table: role / persistence / C2 / dependencies, then expand.

---


## 3b. Thin overlay: `vuln` (Vulnerability Technical Analysis · Optional)

> Issue #65 Supplement. Structure refers to publicly available "Operating System/Component Vulnerability Technical Analysis" type report directories, **only extracting the chapter skeleton**, copying screenshots/the full text PoC packets, exploitation details, or unauthorized attack steps is prohibited.
> **Not** the full flavor of the third default vendor; only layered during vulnerability research tasks or when explicitly requested by the user.

**Narrative Goal**: Readers can quickly see 'Who is affected → How to verify/reproduce (within authorization) → Root cause and patch differences → How to mitigate'.

### Suggested Chapter Order

```markdown
## 1. Vulnerability Overview
### 1.1 Scope of Impact (Version/Component/Configuration Prerequisites)
### 1.2 Vulnerability Reproduction (Authorized Environment; Steps Can Be Reproduced by Third Parties; No Weaponization Tutorial Tone)

## 2. Vulnerability Analysis
### 2.1 Crash / Exception Analysis (Evidence: crash logs, triggering conditions)
### 2.2 Patch Analysis (diff/guard conditions/fix points — mark E-*)
### 2.3 PoC or Trigger Analysis (only materials already within the authorized scope; protocol/input construction levels can be explained)

## 3. Protection Recommendations
### 3.1 Mitigation Measures (Configuration/Mitigation Switches, etc.)
### 3.2 Official Patches and Verification

## 4. Evidence → Finding → Path (can be integrated into each section or presented as a separate table)
```

### Hard Constraint

- **MUST** scope/authorization: Unauthorized targets are prohibited from reproduction and PoC extension
- **MUST** E/F/P: Reproduction, crash, and patch conclusions all hang on evidence_ids
- **MUST NOT** treat `vuln` as the default shell for malware/APT
- **MUST NOT** copy exploitation code or complete attack weaponization steps from external reports/screenshots
- IOC table: Appears only when network/file indicators are present; otherwise n/a or omitted

---
## 4. Integration with Existing Task Templates

| Task Template (`security-report-templates.md`) | Stacking Method |
|------------------------------------------|----------|
| 1. Reverse Engineering Report | Default `flavor = null`, retaining the original “static/dynamic/reproduction” skeleton and import table and other hard evidence; only clearly malicious samples are applied to §2 |
| 2. Penetration Test Report | `flavor = null`; supplement applicable G1–G3 in Base, align attack path with §0 Path, IOC not mandatory |
| 3. CTF Writeup | `flavor = null`; retain the original title, solution ideas, and reproduction structure, not mandatory IOC/ATT&CK |
| 4. JS/Web Signature Reverse Engineering | `flavor = null`; Use the original overview → Locate → Algorithm → Reproduce the skeleton, without using malware |
| Malware / APT Special | Explicitly select `malware` or `apt` full text skeleton |

**Conflict Resolution**: §0 Evidence chain fields and scope access control are **always prioritized**; flavor only changes narrative order and professional shell, E/F/P must not be deleted.

---

## 5. Selection Pseudocode

```
if user_requests_kaspersky or apt or threat_campaign:
    flavor = apt
elif user_requests_huorong or vir_report or explicit_malware:
    flavor = malware
else:
flavor = null  # Elements applicable in original task template + Base
overlay = null
if user_requests_vuln_tech_report or cve_patch_analysis:
    overlay = vuln  # thin only; never a third default full flavor
emit(base_report)
if flavor in (malware, apt):
    emit(report with flavor outline)
elif overlay == vuln:
    emit(report with vuln thin outline)
```

---

## 6. Complete the checklist (self-check at the end of the report)

- [ ] Flavor selected or explicitly 'task template + minimal set'
- [ ] G1 Overview exists and is not empty
- [ ] §0 E/F/P field complete
- [ ] `malware` / `apt` report contains IOC table (or n/a + reason)
- [ ] `malware` / `apt` report has actionable recommendations/actions
- [ ] Tasks without flavor have not been included in the malware/APT exclusive chapter
- [ ] uln is only enabled for vulnerability tasks; includes overview/analysis/protection framework and E/F/P; no unauthorized PoC weaponization
- [ ] No copying of original manufacturer text, no placeholder/TODO
- [ ] Import tables and other hard door evidence have entered static/technical analysis (if binary analysis has been done for this task)

---

## 7. Source Registration

- Kaspersky Securelist, “Updated MATA attacks industrial companies in Eastern Europe”: <https://securelist.com/updated-mata-attacks-industrial-companies-in-eastern-europe/110829> (structure reference; accessed on: 2026-08-11)
- Huorong Security public technical article entry: <https://www.huorong.cn/> (site entry; date accessed: 2026-08-11. The specific article URL, title, and date accessed should be recorded when citing in practice)
- ATT&CK technique numbers are only for standardized mapping and must be supported by the current evidence; IOCs from external reports must not be automatically included in the current report.

---

## 8. Non-target

- Do not maintain extra full-text templates such as Mandiant/CrowdStrike/ Qi An Xin (the structure has already been covered by dual flavor + optional thin overlay to meet common needs).
- Do not upgrade `vuln` to the default full-text flavor on par with malware/apt.
- Do not automatically crawl vendor sites to fill out the report.
- Do not reduce the scope of Evidence contracts or authorizations because of flavor.