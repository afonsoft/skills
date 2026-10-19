---
name: reverse-skill-router
description: Routes reverse engineering, exploitation, penetration testing, malware, mobile, firmware, browser automation, documentation, and security tasks to the appropriate specialist skill. Use when a task spans modules or the correct reverse-skill entrypoint is unclear.
---
# Reverse Engineering Skills Master Control

This directory contains a series of skill modules related to reverse engineering. Each subdirectory is an independent module, containing `README.md` that describes its applicable scenarios, toolchains, and workflows.

## CRITICAL: Route Execution Contract (Must Execute Immediately)

After reading this document, replying with only 'Read/Understood' is not allowed. You must follow the steps in order:

1. `NOW`: Run the platform native router (Windows `scripts/master-route.ps1`; Linux/macOS/Kali `scripts/master-route.sh`), set PRIMARY from `config/routing.json`; for troubleshooting, reread the `routing.md` three-axis appendix.
2. `NOW`: Platform-native `case-init` to implement the current analysis project `work/<case>/scope.md`; **auth not granted prohibits operations on the target ACT**. Local offline samples use `offline-sample` preset + explicit sample; Force must not bypass the hard gate.
3. `ACT`: Immediately open PRIMARY `README.md` to execute ACTION REQUIRED.
4. `NEXT`: The tool path only recognizes `tool-index.md`; missing tool → platform-native bootstrap (manifest only).
5. For conclusions, use Evidence → Finding → Path. Reports/journals SHOULD be used, unless the user needs deliverables.

**Identity**: See `ops/IDENTITY.md` (lightweight routing package + tool bootstrap + journal; **not** a Z3r0-style platform).

If the routing cannot be hit, you must first go online to supplement the methodology and propose adding new skills; forcibly inserting them into mismatched modules is prohibited.

## Instruction Semantic Level (RFC 2119)

- `MUST`: Must be executed, failure to comply will result in mission failure.
- `MUST NOT`: Execution prohibited, violation constitutes a safety breach.
- `SHOULD`: In principle, it should be done; if not, the reason must be explained.
- `MAY`: Optional action.
## Current Module

| Module | Directory | Applicable Scenarios |
|------|------|---------|
| **General Reverse Engineering** | `reverse-engineering/` | GDB / Frida / angr / Unicorn / Qiling / Anti-analysis Countermeasures / Cross-language Platform Reverse Engineering / CTF Mode Library |
| **APK Reverse Engineering** | `apk-reverse/` | Android APK unpacking, jadx decompiling, smali modification, Frida hooking, repackaging and signing installation |
| **.NET / C# Reverse Engineering** | `dotnet-reverse/` | Managed PE reverse engineering, dnSpyEx + de4dot deobfuscation (ConfuserEx/SmartAssembly/Babel), IL patch, Sharp* red team tool analysis, dnSpy MCP integration |
| **IDA Pro Reverse Engineering** | `ida-reverse/` | IDA Pro MCP HTTP Server (72 tools): Decompilation, Disassembly, Data Flow Tracking, Cross-References |
| **Frontend JS Reverse Engineering** | `js-reverse/` | Browser-side signature location, encrypted parameter analysis, runtime sampling, Node environment reproduction; preferably use the existing `js-reverse_*`, if stronger browser/CDP/Hook capabilities are needed, integrate jshookmcp, but the prerequisite is to first download/register and enable the MCP server |
| **radare2 Analysis** | `radare2/` | CLI binary reconnaissance, disassembly, patch: r2 / rabin2 / rasm2 / radiff2 |
| **CTF Entry** | `ctf-sandbox/` | Single PRIMARY; downstream still in sidecar `../CTF-Sandbox-Orchestrator/` |
| **Technical Documentation Writing** | `docs-generator/` | Automatically generate reverse engineering reports, penetration reports, CTF writeups, and signed reverse engineering reports after task completion |
| **Evidence Review** | `case-review/` | Verify scope, Evidence→Finding→Path traceability, workitems, timeline, and artifact hash |
| **Browser and Desktop Automation** | `browser-automation/` | Browser Operations (Playwright) + Windows Desktop Application Operations (OpenReverse UIA/CUA) + Network Monitoring |
| **Cross-Version Symbol Migration** | `binary-diff/` | Migrate symbols from old versions to new versions, deduce missing PDBs, batch migrate function names after program updates |
| **N-day patch diff → utilization** | `patch-diff-exploit/` | Locate vulnerability points from vendor patches, write PoCs, N-day weaponization (division of labor with binary-diff: this skill leans towards the attack side) |
| **RE→Exploitation Chain** | `pwn-chain/` | From reversing to usable exploits: stack/heap/kernel pwn, pwntools, libc-database, CTF to real remote stabilization |
| **Firmware Penetration Chain** | `firmware-pentest/` | OWASP FSTM Nine Stages: Extraction → EMBA Automation → Firmadyne/QEMU Simulation → AFL++ Fuzzing → Real Machine Exploitation |
| **EDR Bypass Reverse Engineering** | `edr-bypass-re/` | Red Team Scenario: Reverse engineering EDR hook table / ETW/AMSI → Direct syscall / Hell's Gate / Hardware breakpoints / Call stack spoof |
| **Penetration Testing Toolchain** | `pentest-tools/` | Nmap/Nuclei/SQLMap/FFUF/Hashcat/Pentest Swarm and 20+ penetration tools, exposed to AI through MCP |
| **Chart Generation** | `diagram-generator/` | Generate Mermaid/Graphviz/PlantUML charts from natural language (attack path charts, data flow diagrams, architecture diagrams, state machines) |
| **Attack Chain Orchestration** | `attack-chain/` | The overall commander for planning and executing multi-stage attack paths; complete penetration, HW exercises, cross-stage tasks such as attacking from the external network to domain control start here |
| **LLM/AI Security Testing** | `llm-security/` | OWASP LLM + ASI Top 10: Prompt Injection, Tool Misuse, Memory Poisoning, Agent Hijacking, System Prompt Extraction, **Agent Obedience Engineering** |
| **API Security Testing** | `api-security/` | REST/GraphQL/WebSocket All Protocols: BOLA/IDOR, JWT/OAuth Attacks, 10-Stage Methodology |
| **Supply Chain Security** | `supply-chain-security/` | SBOM/SCA/CI-CD Pipeline: Dependency Scanning, Container Security, Build Integrity, Vulnerability Reachability Verification |
| **Mobile Reverse Engineering** | `mobile-reverse/` | Android + iOS: Frida/Objection dynamic instrumentation, SSL Pinning/Root/ jailbreak detection bypass, OWASP MASTG |
| **Malware Analysis** | `malware-analysis/` | Six Stages of Sample Analysis, YARA/Sigma, Anti-Analysis Detection, Sandbox Orchestration |
| **DSL Virtual Machine Reverse Engineering** | `reverse-engineering/dsl-vm-reverse/` | JS Custom Instruction Set VM (IIFE + switch-case opcode); Risk control/verification code engines, etc. |
| **Operation Contract ops** | `ops/` | Scope / Evidence Chain / Roles / Timeline / Identity / Skill Supply Chain Security |
| **Community Skill Reference** | `references/community-security-skills.md` | External Security Skill Index and Reference Rules (Blind Installation Prohibited) |
| **Skill Supply Chain** | `ops/skill-supply-chain.md` | External skill/MCP Installation Latch (AST10 Simplified) |
| **RE Phase Gate** | `reverse-engineering/references/re-agent-workflow.md` | triage→static→dynamic→synthesis |
| **Authorized Recon Pipeline** | `pentest-tools/references/recon-pipeline.md` | scope door + hit ≠ verification |
| **Protocol Reverse Engineering** | `protocol-reverse/` | Custom Binary Protocol / Protobuf / gRPC / PCAP Frame Layout |
| **Ghidra Reverse Engineering** | `ghidra-reverse/` | Open-source decompilation, headless, Ghidra MCP (main entry point when no IDA) |
| **Binary Ninja Reverse Engineering** | `binary-ninja-reverse/` | HLIL/MLIL/LLIL, Python API, and optional community MCP/localhost HTTP integration |
| **Cloud / Container / K8s** | `cloud-k8s/` | IMDS/IAM, Container Escape Surface, Kubernetes RBAC |
| **Windows / AD** | `windows-ad/` | Kerberos, AD CS, BloodHound, Relay and Domain Paths |
| **Digital Forensics** | `digital-forensics/` | Memory/Disk Timeline, PCAP Traceback, IR Preservation |
| **Code Audit / SAST** | `code-audit/` | Semgrep/CodeQL, White-box, Dangerous API and Authorization Review |
| **Threat Intelligence / OSINT** | `threat-intelligence/` | Public source IOC supplementation, activity correlation, independent verification, and intelligence handover |
| **Threat Hunting** | `threat-hunting/` | Hypothesis-Driven Hunting, Sigma Detection Engineering, Blue Team Validation |
| **OT / ICS Industrial Control** | `ot-ics/` | Purdue zones, PLC/SCADA, passive priority assessment |
| **Wi-Fi / Wireless** | `wifi-wireless/` | Authorized wireless assessment, handshake/PMKID, lab rules |
| **Browser Extension Reverse Engineering** | `browser-extension-reverse/` | Chrome/Firefox Extension, MV3 Worker, Permission Surface |
| **macOS / Mach-O** | `macos-reverse/` | Signature, ObjC/Swift, LaunchAgent, macOS sample |
| **Thick Client** | `thick-client/` | Desktop C/S, Local Storage, IPC, Update Channel || **Go / Rust Reverse Engineering** | `go-rust-reverse/` | Stripping symbols Go/Rust, pclntab, panic strings |
| **Hardware Debug Interface** | `hardware-security/` | UART/JTAG/SWD, Read-only Extraction, Handover Firmware |
| **Database Security** | `database-security/` | MySQL/PG/MSSQL/Mongo/Redis Exposure and Configuration |
| **Email Security** | `email-security/` | Phishing Analysis, SPF/DKIM/DMARC, BEC |
| **Federated Identity** | `identity-federation/` | SAML/OIDC/OAuth SSO Flow and Mismatch |
| **RF / SDR** | `radio-sdr/` | Authorized radio frequency research, default receive only |

## Unified Entry

When encountering tasks such as reverse engineering, CTF, packet capturing, frontend signing, APK repackaging, and binary analysis, follow this order first:

1. Platform native router (Windows `scripts/master-route.ps1`; Linux/macOS/Kali `scripts/master-route.sh`) → PRIMARY (`config/routing.json`)
2. Platform native `case-init` → `scope.md`
3. Open PRIMARY `README.md`
4. Read `routing.md` when encountering difficulties, read `tool-index.md` when the local path is needed

## Work Approach

These modules can be used in combination as needed:

1. **Get a target** → First look at the file type and choose the corresponding analysis tool
2. **Quickly grabbing opportunities** → strings / rabin2 -z / ltrace to see if there are any direct clues
3. **In-depth Analysis** → If decompiling is needed → IDA; if dynamic hooking is needed → Frida; if symbolic execution is needed → angr
4. **If one path doesn't work, try another** → If static analysis doesn't work, then try dynamic analysis; if the Java layer doesn't work, then check the so layer; if observing the page isn't enough, then use breakpoints.

## Next-Step Menu Pattern

Only at a **genuine decision boundary** (where there are two or more materially different, evidence-supported branches, and the user's choice will change the next action) will the sub-skill `MUST` provide 3-6 numbered options. If the next step is uniquely determined by gate / Evidence, `MUST` proceeds directly, and only records `decision_delta` + `carry_forward_refs` according to `ops/timeline-workitem.md`; `MUST NOT` re-outputs unchanged route/scope/auth/context for menu creation.

Format requirements:
- Each option is numbered with digits (range 1-6)
- Each option describes a specific actionable step (not an abstract direction)
- At least include an "Export Report/Write Writeup" option
- Includes at least one option of "Continue to analyze further" or "Try another approach"
- Include a 'stop/pause/ask another question' exit when necessary

Example:```
## Suggested Next Step (Choose a Number)

1. Perform deep reverse engineering on sub_140001000 to restore the algorithm
2. Using Frida to Dynamically Hook and Verify Parameter Hypotheses
3. Export the currently named functions and generate a symbol migration YAML
4. Generate the analysis report for the current stage
5. Switch to radare2 for lightweight reconnaissance comparison
6. Hold on, let me verify the previous evidence first
```

## The table of contents is dynamically expandable

This directory will continue to grow. When a new subdirectory is discovered, reading its `README.md` allows you to quickly understand its purpose.

When adding a new skill, follow the standard process of `CONTRIBUTING.md` to ensure:
- The routing matrix can correctly distribute traffic
- The bootstrap system can automatically complete dependencies
- tool-index can reflect the status of new tools

## Related Resources

- This machine also has an **anything-analyzer** (port 23816) MCP server, providing browser automation, HTTP capture, and AI analysis capabilities
- `tool-index.md` Records whether the local reverse engineering tool is available, its actual path, version, and script references
- The `Readme.md` under the package root provides general installation and access instructions for Claude Code, Codex CLI, and other code AI clients.

## On-Demand Bootstrapping

When the workflow detects a missing tool, do not report an error directly. Always call the platform's native bootstrap:

Windows：
```powershellpowershell -NoProfile -File "<skill-root>\scripts\bootstrap-reverse.ps1" -Capability @('ToolName') -StartServices```

Linux / macOS：
```bashbash <skill-root>/scripts/bootstrap-reverse.sh tool name --start-services```

Kali：
```bashbash <package-root>/kali/scripts/bootstrap-reverse.sh tool name --start-services```

Supported capabilities (based on `scripts/bootstrap-manifest.json`): jadx, apktool, jeb-pro, binaryninja, frida, frida-ps, idalib-mcp, reqable-mcp, jshookmcp, xquik-mcp, anything-analyzer, idapro, r2, rabin2, adb, agent-browser, ghidra-mcp, seclists, proxycat, burpsuite-mcp, nmap, pentestswarm, binwalk, yara, pwntools, bkcrack

> JEB Pro is registered as a **manual license installation** capability: the bootstrap only provides guidance and never downloads or bypasses commercial licenses. Reqable MCP only registers the fixed version of the official runtime, and users still need to install the Reqable desktop client themselves.
>
> Tools not listed in the inventory (such as unblob/EMBA, `MUST`, etc.) should follow the manual installation steps in the skill document; pretending they can be bootstrapped is prohibited.

After the bootstrap is complete, `tool-index` will be automatically refreshed.

## Precedent Files

Before performing any reverse/penetration operations, MUST read in order:

| Read Order | File | When to Read |
|------|------|--------|
| **#1** | `ops/scope-contract.md` + `case-init.ps1` | Executable authorization gate. `precedent-auth.md` does not write granted |
| **#2** | `field-journal/precedent-reverse.md` or `precedent-pentest.md` | On demand — only loads when AI hesitates |

**#1 Preload, #2 Lazy load.**

## Automatic Evolution

After completing each reverse/penetration task, you must write the experience back to the `field-journal/` directory. See the 'Mandatory Checklist After Task Completion' in `RULES.md` for details.

- Template: `field-journal/_template.md`
- Index: `field-journal/_index.md`
- Example: `field-journal/precedent-auth.md` → `precedent-reverse.md` → `precedent-pentest.md`
- Before starting a new task, first check the index and precedents, and reuse existing experience

## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Have I completed the routing three-axis matching (target type + user intent + toolchain)?
- [ ] Did I read the README.md of the target skill after the routing was successful?
- [ ] When the route is not matched, did I suggest adding a new skill instead of forcing a match?
- [ ] Did I use a real tool path based on `tool-index`?