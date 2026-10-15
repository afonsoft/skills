---
name: docs-generator
description: |
  Creates task-oriented technical documentation with progressive disclosure. Use when writing READMEs, API docs, architecture docs, or markdown documentation.
  Also use this skill at the END of any completed reverse engineering, penetration testing, CTF, or security analysis task to generate a formal report in the user's project directory.
  Trigger keywords: 写报告, 写文档, 出报告, writeup, 技术文档, report, documentation.
---

# Technical Documentation

## ACTION REQUIRED (Execute Immediately After Reading)

1. xKx0000xKx: Confirm whether the current task falls within the applicable scope of this skill
2. xKx0001xKx: Read xKx0002xKx, check tool availability and actual path
3. xKx0003xKx: Call bootstrap when tools are missing, don't guess the path
4. xKx0004xKx: Enter the first step of the 'workflow' and execute, do not stay in the confirmation state

For writing style, tone, and voice guidance, use xKx0005xKx with **The Engineer** persona.

## xKx0005xKx Engineering Task Documentation Output

After reverse xKx0006xKx analysis tasks are completed, this skill is responsible for generating formal technical documentation in the **user project directory**.

### Trigger Timing

1. Reverse engineering tasks completed, core conclusions produced (algorithm reconstruction, signature cracking, bypass solutions, etc.)
2. Penetration testing completed, vulnerabilities have been identified and verified
3. CTF challenge solved, flag obtained
4. User explicitly requests a "xKx0007xKx"

### Template Selection

| Task Type | Use Template |
|---------|---------|
| xKx0008xKx Reverse Engineering | xKx0009xKx → Reverse Engineering Report |
| Penetration xKx0010xKx Hunting | xKx0011xKx → Penetration Testing Report |
| CTF Problem Solving | xKx0012xKx → CTF Writeup |
| xKx0013xKx Signature Reverse | xKx0014xKx → Signature Reverse Report |
| Malware / APT / Virus Analysis Report | xKx0015xKx + **xKx0016xKx** |
| General Technical Documentation | xKx0017xKx → README / API Documentation |

### Manufacturer Report Structure (Issue #65)

For formal security reports **MUST** read xKx0018xKx (only take the structure, do not copy the original text from the vendor). Only choose the vendor flavor when there is task evidence or explicit user request; for general reverse engineering and other tasks, use xKx0019xKx.

| Flavor / Overlay | When to Use | Main Reference Framework |
|------------------|--------|------------|
| xKx0020xKx | Clearly malicious samples, Trojans, combination attacks, phishing poisoning | Huorong style: Overview → Process → Sample analysis → Emergency response → IOC |
| xKx0021xKx | xKx0022xKx infection xKx0023xKx targeting | Kaspersky Securelist style: Summary → Infection chain → Investigation narrative → Interesting findings → Technical analysis → Detection and mitigation → IOC |
| xKx0024xKx | General xKx0025xKx Reverse engineering, xKx0026xKx analysis, penetration / CTF / JS signing | Original task template + Base common elements; does not include xKx0027xKx exclusive sections |
| thin xKx0028xKx | User explicitly requests technical analysis of xKx0029xKx | Overview → xKx0030xKx → Crash and Patch Analysis → Protection Recommendations (stacked on null, not the 3rd default full text flavor) |

Principle: **The template values quality over quantity** — Only 2 vendors provide the full text flavor; xKx0031xKx is only an optional thin overlay, and no third default full-text template will be created.
Effective **simultaneously with §0 Evidence→Finding→Path**; in case of conflict, the Evidence contract takes precedence.

### Output Specification

- **Output location**: The user's current project directory (not the skill package directory)
- **Filename format**: xKx0032xKx
- **If the project has an xKx0033xKx directory**: prioritize placing it under xKx0034xKx
- **Encoding**: UTF-8
- **Language**: Follow the user's conversation language (produce reports in Chinese for Chinese conversations, and in English for English conversations)

### Quality Requirements

- All code blocks must be directly executable or have a clear context
- Do not have xKx0035xKx
- Key findings must be supported by evidence
- The reproduction steps must allow a third party to independently reproduce them
- Sensitive information (real tokens, passwords, internal URLs) should be replaced with placeholders
- **MUST** include the Evidence → Finding → Path chain (see xKx0036xKx and template §0)
- **MUST** read xKx0037xKx: select xKx0038xKx / xKx0039xKx or xKx0040xKx (vulnerability tasks can be stacked with thin xKx0041xKx); when there is no flavor, only output the original task template and applicable Base elements, xKx0042xKx&CK is not mandatory
- **SHOULD** cite case xKx0043xKx / xKx0044xKx (xKx0045xKx)

### Chart Integration

When generating the report, the xKx0046xKx skill should be called at the appropriate position to generate visual charts:

| Report Type | Suggested Chart | Chart Type |
|---------|---------|---------|
| Reverse Engineering Report | Function Call Relationship Diagram, Data Flow Diagram | Mermaid flowchart / sequenceDiagram |
| Penetration Test Report | Attack Path Diagram, Network Topology Diagram | Mermaid flowchart / Graphviz |
| CTF Writeup | Problem-Solving Thought Process Flowchart | Mermaid flowchart |
| JS Signature Reverse Engineering Report | Request Link Timing Diagram, Algorithm Flowchart | Mermaid sequenceDiagram / flowchart |

The chart is embedded in the report markdown as a Mermaid code block, ensuring it can be rendered directly in xKx0047xKx

---

## Core Principles

### 1. Progressive Disclosure

Reveal information in layers:

| Layer | Content | User Question |
|-------|---------|---------------|
| 1 | One-sentence description | What is it? |
| 2 | Quick start code block | How do I use it? |
| 3 | Full API reference | What are my options? |
| 4 | Architecture deep dive | How does it work? |

**Warnings, breaking changes, and prerequisites go at the TOP.**

### 2. Task-Oriented Writing

```markdown
<!-- Bad: Feature-oriented -->
## AuthService Class
The AuthService class provides authentication methods...

<!-- Good: Task-oriented -->
## Authenticating Users
To authenticate a user, call login() with credentials:
```

### 3. Show, Don't Tell

Every concept needs a concrete example.

## Formatting Standards

- **Sentence case headings**: "Getting started" not "Getting Started"
- **Max 3 heading levels**: Deeper means split the doc
- **Always specify language** in code blocks
- **Relative paths** for internal links
- **Tables** for structured data with 3+ attributes

## Quality Checklist

- [ ] Code examples tested and runnable
- [ ] No placeholder text or TODOs
- [ ] Matches actual code behavior
- [ ] Scannable without reading everything
- [ ] Reader knows what to do next

## Anti-Patterns

| Problem | Fix |
|---------|-----|
| Wall of text | Break up with headings, bullets, code, tables |
| Buried critical info | xKx0000xKx changes at TOP |
| Missing error docs | Always document what can go wrong |

## Templates

For README, API endpoint, and file organization templates, see [xKx0001xKxxKx0002xKx.

## Related Skills

- xKx0003xKx - Writing style, tone, and voice (load The Engineer persona)
- xKx0004xKx - Architecture and flow diagrams


---

## On-Demand Bootstrap

This skill does not rely on external tools; it generates pure text. No bootstrap needed.

If it is necessary to render charts embedded in the report, the `diagram-generator/` skill will be called.

---

## Routing Context

**Upstream Entry**: All security/reverse skills are automatically invoked by this skill after the task is completed
**Trigger Method**:
- Automatic: Executed as the 9th step of the behavior chain after the task is completed
- Manual: The user says 'write a report,' 'produce a document,' 'writeup'

**Peer-related Module**:
- `apk-reverse/` — APK reverse engineering completed and reverse engineering report generated
- `ida-reverse/` — Generate a reverse engineering report after binary analysis is completed
- `radare2/` — Reverse report generated after CLI analysis is completed
- `js-reverse/` — JS signature reverse engineering completed, signature report generated
- `reverse-engineering/` — Generate a reverse engineering report after general reverse engineering is completed
- `field-journal/` — The report content also serves as the data source for the evolution log

**Safety Report Template**: `references/security-report-templates.md`
**Vendor Reporting Rules**: `references/vendor-report-rules.md` (flavor: malware | apt | null; optional overlay: vuln)
**General Document Template**: `references/templates.md`


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I complete each step in the workflow (and not just read it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Does the report contain Evidence / Finding / Path (ops contract)?
- [ ] Have you completed and backfilled the Checklist items required by the RULES?