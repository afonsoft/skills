# Reverse Engineering Skill Routing Matrix

> **Advisory only.** PRIMARY comes from xKx0000xKx via xKx0001xKx. This file is a 3-axis disambiguation view. If a row here disagrees with JSON, JSON wins.

Route tasks to the most appropriate skill module by target type, user intent, and toolchain.

## CRITICAL: Routing Execution Protocol

1. **MUST** complete routing BEFORE executing. Do NOT "do first, route later".
2. **MUST** start from xKx0002xKx (JSON). Use this matrix only when PRIMARY is ambiguous.
3. **MUST** match dimensions (target type + user intent + toolchain) before entering a skill.
4. If route not matched → propose new skill, do NOT force-fit.
5. Cross-module tasks → combine skills per "Path Crossing" section.
6. After routing, read the target skill's README.md BEFORE taking action.
7. **Ops contract** (skill-router form): xKx0003xKx before ACT; Evidence→Finding→Path; roles in xKx0004xKx; xKx0005xKx under xKx0006xKx. Identity: xKx0007xKx.
8. **External skills**: do NOT bulk-vendor community packs; map + rules in xKx0008xKx + xKx0009xKx. RE stages: xKx0010xKx. Recon: xKx0011xKx.

## By Target Type

| Target Type | Recommended Entry | Alternative |
|-------------|------------------|-------------|
| APK / Android app | `apk-reverse/` — jadx decompile + apktool unpack | Optional licensed JEB Pro cross-check; if core is in .so → `ida-reverse/` or `radare2/` |
| Binary exe/dll/so/elf | `ida-reverse/` — IDA Pro decompile | `radare2/` — CLI analysis, or `reverse-engineering/tools.md` — GDB/Unicorn |
| JavaScript / Web frontend | `js-reverse/` — 5-stage workflow | anything-analyzer MCP browser tools, or jshookmcp CDP/Hook |
| HTTP capture / browser sampling / request replay | anything-analyzer MCP (23816) | Reqable MCP, `js-reverse/`, jshookmcp, or `competition-web-runtime/` |
| Firmware / IoT | `firmware-pentest/` — extract → EMBA → emulate → fuzz | `reverse-engineering/platforms.md` — static RE only |
| WASM / Python bytecode / .NET / **DSL VM / custom virtual machine** | `reverse-engineering/dsl-vm-reverse/README.md` — IIFE + switch-case opcode JS VM | `reverse-engineering/languages.md` — real WASM binaries |
| Malware / virus sample | `malware-analysis/README.md` — six-stage + YARA/Sigma | `ida-reverse/` deep dive |
| macOS / iOS | `reverse-engineering/platforms.md` — Mach-O/ObjC/Swift | `mobile-reverse/` for iOS-specific |
| Game (Unity) | `reverse-engineering/` — engine reverse, anti-cheat, IL2CPP/Mono (see seed-014) | `ida-reverse/` deep analysis |
| Memory dump / PCAP | `digital-forensics/` — memory/timeline/PCAP IR | `protocol-reverse/` for protocol recovery |
| Existing case package / evidence handoff | `case-review/`: Evidence graph and integrity review | `docs-generator/` for final report writing |
| Custom protocol / Protobuf / gRPC | `protocol-reverse/` | `js-reverse/` if pure browser WS crypto |
| Cloud / Container / K8s | `cloud-k8s/` | CTF: `../CTF-Sandbox-Orchestrator/competition-agent-cloud/` |
| Windows AD / Kerberos / AD CS | `windows-ad/` | multi-stage: `attack-chain/` |
| Source code / SAST | `code-audit/` | deps/CI: `supply-chain-security/` |
| Game client (Unity/UE) | `reverse-engineering/` + seed-014 | `dotnet-reverse/` for Mono assemblies |
| OT / ICS / SCADA | `ot-ics/` | `firmware-pentest/` offline firmware |
| macOS / Mach-O desktop | `macos-reverse/` | iOS → `mobile-reverse/` |
| Thick desktop client | `thick-client/` | Electron → also `js-reverse/` |
| Go / Rust stripped binary | `go-rust-reverse/` | `ida-reverse/` / `ghidra-reverse/` |
| UART / JTAG / debug pads | `hardware-security/` | then `firmware-pentest/` |
| Database instance security | `database-security/` | SQLi web path → `pentest-tools/` |
| Email / phishing / DMARC | `email-security/` | |
| SAML / OIDC / SSO | `identity-federation/` | JWT-only API → `api-security/` |
| RF / SDR (non-Wi-Fi) | `radio-sdr/` | Wi-Fi → `wifi-wireless/` |
| Browser extension (crx/xpi) | `browser-extension-reverse/` | page JS only → `js-reverse/` |
| Wi-Fi / Wireless | `wifi-wireless/` | Close-range chain → `attack-chain/` |
| Public-source threat intelligence / OSINT | `threat-intelligence/` | X/Twitter posts remain leads until independently corroborated |
| Blue team / threat hunt | `threat-hunting/` | sample IOC → `malware-analysis/` |
| Ghidra (no IDA) | `ghidra-reverse/` | `ida-reverse/` if IDA MCP available |
| Binary Ninja / Binja | `binary-ninja-reverse/` — HLIL/MLIL/LLIL + Python API | Community Binary Ninja MCP/localhost HTTP adapter when explicitly enabled |

| OLLVM-obfuscated binary (control flow flattening/opaque control flow/MBA) | `reverse-engineering/references/ollvm-deobfuscation.md` — complete deobfuscation workflow | obpo-plugin / d810-ng (IDA) / ollvm-unflattener (Miasm) / ollvm-breaker (Binary Ninja) / angr / deollvm (ARM64)
| Cryptography / encryption algorithms | `reverse-engineering/patterns*.md` — crypto patterns | `js-reverse/` (if frontend crypto) |
| Protocol reverse / custom protocol | `reverse-engineering/platforms.md` — network protocols | `js-reverse/` (if WebSocket/HTTP) |
| Go / Rust binary | `reverse-engineering/languages-compiled.md` + `go-reverse.md` | `ida-reverse/` or `radare2/` |
| LLM / AI application | `llm-security/` — OWASP LLM Top 10 + ASI Top 10 | Prompt injection, Agent security |
| API / REST / GraphQL | `api-security/` — BOLA/BFLA/JWT/OAuth | `pentest-tools/` for scanning |
| Supply chain / SBOM / CI-CD | `supply-chain-security/` — Trivy/Syft/Gitleaks | — |
| iOS app (IPA) | `mobile-reverse/` — class-dump/Hopper/Frida iOS | `reverse-engineering/platforms.md` |
| **CTF competition (full stack)** | `../CTF-Sandbox-Orchestrator/ctf-sandbox-orchestrator/README.md` — master entry | Route to 40+ sub-skills by evidence |
| **CTF ZIP / PKZIP archive** | `../CTF-Sandbox-Orchestrator/competition-zip-archive/README.md` — legacy ZipCrypto + `bkcrack` known plaintext | Use before password brute force |
| Web runtime / API | `../CTF-Sandbox-Orchestrator/competition-web-runtime/README.md` | — |
| Cloud / Container / K8s | `cloud-k8s/` | CTF-only extra: sidecar orchestrator after PRIMARY `ctf-sandbox/` |
| Windows / AD / Identity | `../CTF-Sandbox-Orchestrator/competition-identity-windows/README.md` | — |
| Forensics / PCAP / Steganography | `../CTF-Sandbox-Orchestrator/competition-forensic-timeline/README.md` | — |
| Prompt injection / Agent | `../CTF-Sandbox-Orchestrator/competition-prompt-injection/README.md` | — |
| Mobile (Android/iOS) | `../CTF-Sandbox-Orchestrator/competition-android-hooking/README.md` | — |
| Firmware / Malware sample | `../CTF-Sandbox-Orchestrator/competition-firmware-layout/README.md` | — |

## By User Intent

| User Says | Route To |
|-----------|----------|
| "DSL VM / 自定义指令集 / 风控引擎逆向" | `reverse-engineering/dsl-vm-reverse/README.md` — IIFE + switch-case opcode |
| "fireye / fireyejs / getToken 逆向" | `reverse-engineering/dsl-vm-reverse/README.md` — runtime capture |
| "582KB JS 文件不是 WASM / 大 JS 文件逆向" | `reverse-engineering/dsl-vm-reverse/README.md` — classify DSL VM first |
| "decompile / IDA analyze" | `ida-reverse/README.md` — IDA MCP workflow |
| "recover source / disassemble" | `reverse-engineering/README.md` + `ida-reverse/` |
| "Frida hook / dynamic inject" | `reverse-engineering/tools-dynamic.md` — Frida section |
| "radare2 / r2 analyze" | `radare2/README.md` — CLI workflow |
| "find frontend signature / encrypted params" | `js-reverse/README.md` — Observe→Capture→Rebuild |
| "jshookmcp / JS hook / CDP debug" | `js-reverse/README.md` — same JS/Web chain |
| "Reqable / Reqable MCP / capture replay" | `pentest-tools/README.md` — authorized local capture and API workflow |
| "JEB / JEB Pro" | `apk-reverse/README.md` — licensed Android / ARM cross-check; verify local install first |
| "APK unpack / repack / modify smali" | `apk-reverse/README.md` — decode→rebuild-sign-install |
| "bypass anti-debug / anti-detection" | `reverse-engineering/anti-analysis.md` |
| "OLLVM deobfuscate / 控制流平坦化去除 / deflat / 脱混淆" | `reverse-engineering/references/ollvm-deobfuscation.md` — 完整工作流 |
| "obpo / obpo-plugin / d810-ng / d810" | `reverse-engineering/references/ollvm-deobfuscation.md` — 现代反混淆工具 |
| "Hikari / Polaris / Pluto / O-MVLL / Arkari / goron 混淆" | `reverse-engineering/references/ollvm-deobfuscation.md` — 现代 OLLVM 变种处理 |
| "Tigress / Hodur / Approov 混淆" | `reverse-engineering/references/ollvm-deobfuscation.md` — d810-ng 专用 unflattener |
| "Trap Angr / angr 路径爆炸" | `reverse-engineering/references/ollvm-deobfuscation.md` — Pluto/Polaris 陷阱处理 |
| "BR 混淆 / 间接分支混淆去除" | `reverse-engineering/references/ollvm-deobfuscation.md` — DeObfBR + 数据段只读 |
| "what obfuscation / VM is this" | `reverse-engineering/patterns*.md` — match by pattern |
| "Go/Rust/Swift reverse" | `reverse-engineering/languages-compiled.md` + `go-reverse.md` |
| "kernel driver / Rootkit / LKM" | `reverse-engineering/kernel-driver-reverse.md` |
| "Python bytecode / pyc" | `reverse-engineering/languages.md` — Python section |
| "symbol execution / angr" | `reverse-engineering/tools-dynamic.md` — angr section |
| "patch environment / Node reproduce" | `js-reverse/references/env-patching.md` |
| "CTF challenge / competition reverse" | `ctf-sandbox/README.md` → sidecar orchestrator |
| "CTF ZIP / PKZIP / bkcrack / 压缩包明文攻击" | `../CTF-Sandbox-Orchestrator/competition-zip-archive/README.md` |
| "write report / documentation" | `docs-generator/` — technical documentation |
| "review case / evidence chain / traceability" | `case-review/`: read-only Evidence Graph Review |
| "write writeup" | `docs-generator/` — CTF writeup template |
| "open webpage / browser automation / fill form" | `browser-automation/README.md` — Playwright |
| "crawl page / screenshot / auto login" | `browser-automation/README.md` |
| "desktop automation / Windows automation" | `browser-automation/README.md` — OpenReverse |
| "game reverse / anti-cheat / hack analysis" | `reverse-engineering/README.md` — game reverse (IL2CPP/Unity/Cheat Engine) |
| "Unity / IL2CPP / Mono" | `reverse-engineering/README.md` — Unity + `seed-014_unity-il2cpp-reverse.md` |
| "Cheat Engine / memory scan" | `reverse-engineering/README.md` — Cheat Engine memory analysis |
| "symbol migration / cross-version compare" | `binary-diff/README.md` — LLM batch migration |
| "missing PDB / old version symbols" | `binary-diff/README.md` — cross-version symbol migration |
| "bindiff / function offset migration" | `binary-diff/README.md` — binary diff |
| "port scan / Nmap" | `pentest-tools/README.md` — information gathering |
| "vulnerability scan / Nuclei" | `pentest-tools/README.md` — vulnerability detection |
| "SQL injection / SQLMap" | `pentest-tools/README.md` — web pentest |
| "directory brute force / FFUF / Gobuster" | `pentest-tools/README.md` — web pentest |
| "password cracking / Hashcat" | `pentest-tools/README.md` — password cracking |
| "penetration testing / active scan" | `pentest-tools/README.md` — pentest toolchain |
| "SRC hunting / Bug Bounty" | `pentest-tools/src-hunter/README.md` — 19 playbooks + H1 cases |
| "WAF bypass" | `pentest-tools/src-hunter/references/payloader/` — 263 bypass steps |
| "draw diagram / flowchart / architecture" | `diagram-generator/README.md` || "attack path diagram / sequence diagram" | `diagram-generator/README.md` — Mermaid/Graphviz/PlantUML |
| "malware / virus analysis / sample analysis" | `reverse-engineering/README.md` + YARA/sandbox |
| "firmware / IoT / binwalk / ARM" | `reverse-engineering/platforms-hardware.md` |
| "cryptography / AES / RSA" | `reverse-engineering/patterns*.md` — crypto pattern recognition |
| "protocol reverse / Protobuf / custom protocol" | `reverse-engineering/platforms.md` |
| "cloud security / container escape / K8s" | `cloud-k8s/README.md` |
| "Prompt injection / AI security" | `llm-security/README.md` — OWASP LLM + ASI Top 10 |
| "internal network / lateral movement" | `pentest-tools/README.md` + `references/network-attack-defense.md` |
| "privilege escalation" | `pentest-tools/references/network-attack-defense.md` — escalation section |
| "Mimikatz / credential extraction / PtH" | `pentest-tools/references/network-attack-defense.md` |
| "Kerberos / domain pentest / AD" | `pentest-tools/references/network-attack-defense.md` |
| "C2 / persistence / remote control" | `pentest-tools/references/network-attack-defense.md` |
| "blue team / detection / defense / IR" | `pentest-tools/references/network-attack-defense.md` |
| "APK security testing / mobile security" | `apk-reverse/references/apk-security-checklist.md` — OWASP MASTG |
| "SSTI / template injection" | `pentest-tools/README.md` — SSTImap |
| "XSS scan / cross-site scripting" | `pentest-tools/README.md` — XSStrike |
| "WordPress pentest / WP enumeration" | `pentest-tools/README.md` — WPProbe |
| "C2 framework / adversary simulation" | `pentest-tools/README.md` — AdaptixC2 |
| "WiFi attack / wireless pentest" | `pentest-tools/README.md` — Fluxion + aircrack-ng |
| "NTLM relay / auth coercion" | `pentest-tools/README.md` — Coercer |
| "NetExec / CrackMapExec / nxc" | `pentest-tools/README.md` — network service enumeration |
| "AI auto pentest / MCP security" | `pentest-tools/README.md` — HexStrike AI / MetasploitMCP |
| "Swarm / swarm pentest / autonomous scan" | `pentest-tools/README.md` — Pentest Swarm AI |
| "red team / HW / attack exercise" | `attack-chain/README.md` — full attack chain orchestration |
| "initial breach / boundary breach" | `attack-chain/README.md` — boundary breach phase |
| "close-range pentest / BadUSB / WiFi phishing" | `attack-chain/README.md` — close-range section |
| "EDR bypass / evasion / AV bypass" | `edr-bypass-re/README.md` |
| "phishing / social engineering" | `email-security/README.md` |
| "supply chain attack" | `attack-chain/README.md` — supply chain section |
| "trace cleanup / anti-forensics" | `attack-chain/README.md` — cleanup section |
| "full pentest / end-to-end" | `attack-chain/README.md` — full chain planning |
| "from external to domain controller" | `attack-chain/README.md` — cross-phase path orchestration |
| "attack surface assessment / path planning" | `attack-chain/README.md` — path planning decision tree |
| "got shell, what next / post-exploitation" | `attack-chain/README.md` — plan from current foothold |
| "BurpSuite / Burp proxy / intercept" | `pentest-tools/README.md` + `references/burpsuite-mcp-guide.md` |
| "Burp MCP / proxy history analysis" | `pentest-tools/references/burpsuite-mcp-guide.md` — 78 tools |
| "Intruder brute force / Repeater replay" | `pentest-tools/references/burpsuite-mcp-guide.md` |
| "Collaborator / OOB testing" | `pentest-tools/references/burpsuite-mcp-guide.md` |
| "API security / GraphQL / JWT attack" | `api-security/README.md` — REST/GraphQL/JWT/OAuth |
| "supply chain security / SBOM / SCA" | `supply-chain-security/README.md` — Trivy/Syft/Gitleaks |
| "iOS reverse / IPA / Mach-O" | `mobile-reverse/README.md` — class-dump/Hopper/Frida iOS |
| "Objection / SSL Pinning bypass" | `mobile-reverse/README.md` — dynamic instrumentation |
| "YARA / malware detection rules" | `malware-analysis/README.md` — YARA/Sigma/IOC |
| "N-day / patch diff / CVE reproduction" | `patch-diff-exploit/README.md` |
| "MBA simplification / mixed boolean-arithmetic / 表达式化简" | `reverse-engineering/references/ollvm-deobfuscation.md` — SiMBA/D-810 |
| "opaque predicate / 不透明谓词去除" | `reverse-engineering/references/ollvm-deobfuscation.md` — 符号执行去除 |
| "Hikari deobfuscate / 字符串加密恢复" | `reverse-engineering/references/ollvm-deobfuscation.md` — Hikari 变种处理 |
| "pwn / stack overflow / ROP / ret2libc" | `pwn-chain/README.md` |
| "Agent not working / AI lazy / skip steps" | `llm-security/references/agent-obedience-engineering.md` |
| "MSF stuck / orphan process / MSF protocol" | `pentest-tools/references/msf-protocol.md` |
| "anonymize / placeholder / writeup desensitize" | `field-journal/anonymization.md` || "Hydra / online brute force" | xKx0232xKx — online password attack |
| "Metasploit / msfconsole / exploit" | xKx0233xKx — exploitation framework |
| "Wireshark / packet analysis / PCAP" | xKx0234xKx or xKx0235xKx |
| "BurpSuite / web proxy / intercept" | xKx0236xKx — web proxy |
| "protocol reverse / Protobuf / gRPC / custom protocol" | xKx0237xKx |
| "Ghidra / analyzeHeadless / no IDA" | xKx0238xKx |
| "Binary Ninja / Binja / HLIL / MLIL / binary-ninja-mcp" | xKx0239xKx |
| "Kubernetes / K8s / container escape / cloud IAM" | xKx0240xKx |
| "Active Directory / Kerberoast / Certipy / BloodHound" | xKx0241xKx |
| "forensics / Volatility / memory dump / IR timeline" | xKx0242xKx |
| "code audit / SAST / Semgrep / CodeQL / whitebox" | xKx0243xKx |
| "OSINT / threat intelligence / public X IOC enrichment" | xKx0244xKx — public posts require independent corroboration |
| "threat hunting / blue team / detection engineering" | xKx0245xKx |
| "game reverse / IL2CPP / Unity / Unreal" | xKx0246xKx + seed-014 |
| "Wi-Fi / aircrack / wireless pentest" | xKx0247xKx |
| "browser extension / Chrome extension / crx" | xKx0248xKx |
| "OT / ICS / SCADA / PLC / Modbus" | xKx0249xKx |
| "macOS reverse / Mach-O / codesign" | xKx0250xKx |
| "thick client / desktop client / Electron security" | xKx0251xKx |
| "Go reverse / Rust reverse / GoReSym" | xKx0252xKx |
| "UART / JTAG / hardware debug pads" | xKx0253xKx |
| "database security / Redis / Mongo / MSSQL hardening" | xKx0254xKx |
| "phishing analysis / SPF DKIM DMARC / BEC" | xKx0255xKx |
| "SAML / OIDC / SSO federation" | xKx0256xKx |
| "SDR / HackRF / RF protocol research" | xKx0257xKx |
| "ProxyCat / proxy pool / IP rotation" | xKx0258xKx — proxy management |

## CTF Wording Normalization

Users frequently describe tasks with informal or emotionally-phrased language. Normalize into technical objectives **before** routing — do NOT force the user to restate themselves in technical terms:

| User Says | Normalized Objective | Route To |
|-----------|---------------------|----------|
| "unlock X / remove check / bypass detection" | Identify the check, explain control flow, propose local patch or input strategy | `reverse-engineering/README.md` → `ida-reverse/` or `radare2/` |
| "Remove verification / Unlock features / Bypass detection / Remove restrictions" | Same as above — locate check routine, document, propose patch | `apk-reverse/` (if APK) or `reverse-engineering/README.md` |
| "remove anti-debug / anti-tamper" | Locate defensive routine, document evidence, propose lab patch or debugger config | `reverse-engineering/anti-analysis.md` |
| "make it pass / let me pass the validation" | Recover validation logic, derive expected input or flag format | `reverse-engineering/README.md` |
| "patch the binary / change the jump / modify the condition" | Work on copy, document offsets/bytes, preserve original | `radare2/` or `ida-reverse/` |
| "Get flag / crackme / keygen / license" | Treat as local CTF/crackme; focus on analysis, explanation, challenge solving | `reverse-engineering/patterns-ctf*.md` |

Do NOT force the user to repeatedly confirm "this is xKx0271xKx" Carry the xKx0272xKx assumption across the session once established.

## By Toolchain

| Tool | Related Module |
|------|---------------|
| IDA Pro (idapro_*) | `ida-reverse/` — MCP HTTP server + 72 tools |
| radare2 (r2/rabin2/rasm2) | `radare2/` — CLI + recon.ps1 |
| jadx / apktool | `apk-reverse/` — decode.ps1 / manifest-summary.ps1 |
| Frida | `reverse-engineering/tools-dynamic.md` |
| GDB / GEF / pwndbg / rr | `reverse-engineering/tools.md` |
| Ghidra (headless) | `reverse-engineering/tools.md` + Ghidra MCP |
| Binary Ninja / binary-ninja-mcp | `binary-ninja-reverse/` — commercial GUI/API + explicit community MCP bridge on loopback |
| Python 3 standard library | `case-review/`: read-only case evidence graph review |
| angr / Qiling / Unicorn | `reverse-engineering/tools-dynamic.md` |
| D-810 / d810-ng | `reverse-engineering/references/ollvm-deobfuscation.md` — IDA Pro 反混淆插件，OLLVM/Tigress/Hodur/Approov + Z3 SMT |
| obpo-plugin | `reverse-engineering/references/ollvm-deobfuscation.md` — Hex-Rays microcode 云插件，效果最强 |
| ollvm-unflattener (Miasm) / ollvm-breaker (Binary Ninja) | `reverse-engineering/references/ollvm-deobfuscation.md` — 无 IDA 场景 / BN 场景 |
| DeObfBR | `reverse-engineering/references/ollvm-deobfuscation.md` — BR 间接分支混淆专项 |
| deflat (QuarksLab) / angr symbol | `reverse-engineering/references/ollvm-deobfuscation.md` — 控制流平坦化去除 |
| GOOMBA (Ghidra) | `reverse-engineering/references/ollvm-deobfuscation.md` — Ghidra P-Code 反混淆 |
| BinDiff / Diaphora | `reverse-engineering/tools-advanced.md` |
| anything-analyzer MCP | Port 23816 MCP server (browser + HTTP capture + AI analysis) |
| jshookmcp | `js-reverse/` enhancement MCP for browser/CDP/Hook/Network/SourceMap/AST |
| agent-browser / Playwright | `browser-automation/` — browser automation |
| OpenReverse (UIA/CUA) | `browser-automation/` — Windows desktop automation |
| Cheat Engine / x64dbg / ReClass | `reverse-engineering/` — game memory analysis (seed-014) |
| IL2CPP Dumper / dnSpy | `reverse-engineering/` — Unity/Mono game reverse (seed-014) |
| LLM symbol migration / BinDiff alternative | `binary-diff/` — cross-version batch migration |
| Nmap / Masscan | `pentest-tools/` — port scan, service identification |
| Nuclei / ZAP / Nikto | `pentest-tools/` — vulnerability scanning |
| SQLMap / FFUF / Gobuster | `pentest-tools/` — web pentest (injection/brute force) |
| SSTImap | `pentest-tools/` — SSTI auto-detection |
| XSStrike | `pentest-tools/` — advanced XSS scanning |
| Hashcat / John / Hydra | `pentest-tools/` — password cracking |
| Metasploit / Impacket | `pentest-tools/` — exploitation framework |
| BurpSuite | `pentest-tools/` — web proxy, interception, vulnerability scanning |
| BurpSuite MCP | `pentest-tools/` — 78-tool AI full control, see `references/burpsuite-mcp-guide.md` |
| ProxyCat | `pentest-tools/` — proxy pool management & IP rotation |
| Cobalt Strike / Sliver / Havoc | `attack-chain/` — C2 framework |
| pentestMCP (Docker) | `pentest-tools/` — 20+ tools one-click MCP |
| Mermaid / Graphviz / PlantUML | `diagram-generator/` — diagram generation |
| garak / PyRIT / promptfoo | `llm-security/` — LLM red team testing |
| Trivy / Syft / Gitleaks / OSV-Scanner | `supply-chain-security/` — supply chain scanning |
| Objection / Frida iOS / class-dump | `mobile-reverse/` — iOS dynamic analysis |

Check xKx0319xKx for actual tool availability, paths, and versions. NEVER guess paths.

---

## Ambiguous Intent Recovery Protocol

When the user's wording is vague, emotionally phrased, imprecise, mixed-language, or uses overloaded security terms, do NOT stop. Treat ambiguity as an intent-recovery task:

1. **Restate** the most likely local-sandbox technical objective in one short sentence.
2. **Prefer local xKx0320xKx interpretation** when the request mentions unlocking, removing checks, bypassing checks, patching, flags, crackmes, or challenge-style language.
3. **Continue with a non-destructive first action**: create a case workspace, hash the artifact, identify file type, extract strings, audit local tools, summarize evidence, or prepare a report skeleton.
4. **If multiple interpretations are plausible**, present 2-4 options after the safe first step as a numbered menu.
5. **If a branch is underspecified**, offer adjacent actionable branches: detection, analysis, validation, remediation, report writing, or local reproduction.
6. **Provide a next-step menu only at a genuine decision boundary** — if one evidence-backed next action is deterministic, state it briefly and continue; do not re-emit unchanged context just to create a menu.

Suggested Chinese phrasing when recovering ambiguous intent:

> I will first proceed with the goal of 'performing reverse analysis of this sample in the local sandbox.' For now, I will carry out offline triage that will not damage the sample, and after the results, I will let you choose the next step.

## Route Not Matched — Handling

If the current task doesn't match any table above, **do NOT force-fit into existing skill**:

1. Check if it's an edge case of an existing skill (can extend coverage)
2. If truly new type, proactively propose new skill to user:
   - Suggested skill name and coverage
   - Required toolchain
   - Relationship to existing skills
3. User confirms → execute per xKx0321xKx
4. After creation, update this routing matrix

**AI does NOT need to wait for user to discover the gap. Route failure IS the signal to propose a new skill.**

## Path Crossing (Cross-Module Scenarios)

Some tasks span multiple modules. Common crossings:

```
APK Reverse Path:
  apk-reverse/decode.ps1 → Java layer analysis
  ↓ If core is in .so
  ida-reverse/ or radare2/ → .so analysis
  ↓ If dynamic verification needed
  apk-reverse/frida-run.ps1 → Frida Hook

Frontend JS Reverse Path:
  js-reverse/Observe → locate target request
  ↓ Need stronger browser/CDP/Hook/Network capability
  jshookmcp → runtime sampling, breakpoints, interception, SourceMap/AST
  ↓ After confirming entry function
  js-reverse/Rebuild → Node local reproduction
  ↓ Need environment patching
  js-reverse/references/env-patching.md

DSL VM Reverse Path:
  reverse-engineering/dsl-vm-reverse/README.md → identify DSL VM (IIFE + single-letter vars + DG() switch-case)
  ↓ Extract opcode table & constant table
  reverse-engineering/dsl-vm-reverse/README.md Phase 2-4 → opcode classification, C[9] constant analysis
  ↓ If runtime capture needed
  browser-automation/ → Playwright/Selenium CDP injection
  ↓ If pure API protocol needed
  js-reverse/ → Observe→Capture→Rebuild (API layer only)

CTF Competition Path (via CTF-Sandbox-Orchestrator):
  ../CTF-Sandbox-Orchestrator/ctf-sandbox-orchestrator/README.md → build sandbox model
  ↓ Route by dominant evidence
  competition-web-runtime/ or competition-reverse-pwn/ or competition-identity-windows/
  ↓ Blocked → return to master
  ctf-sandbox-orchestrator → re-route

Web Pentest + BurpSuite MCP Path:
  browser-automation/ → auto-browse target with Burp proxy
  ↓ Traffic captured
  burpsuite MCP proxy_history → AI analyzes all requests
  ↓ Suspicious endpoints found
  burpsuite MCP intruder_attack → automated enumeration
  ↓ Vulnerability confirmed
  docs-generator/ → generate pentest report
```


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Have I completed the routing three-axis matching (target type + user intent + toolchain)?
- [ ] Did I read the README.md of the target skill after the routing was successful?
- [ ] When the route was not matched, did I suggest adding a new skill instead of forcing a match?
- [ ] Did I use a real tool path based on `tool-index`?