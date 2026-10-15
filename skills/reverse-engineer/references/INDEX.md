# reverse-skill 技能导航索引

> 本文件由 `references/scripts/extract-summaries.ps1` 自动生成，**请勿手改**。
> 修改摘要请编辑对应模块 `README.md` 的 frontmatter `description`，然后重跑脚本。

## 模块总览

| 模块 | 摘要 |
|------|------|
| [api-security](api-security/README.md) | Use for authorized security assessment of REST, GraphQL, WebSocket, or SOAP APIs, including discovery, authentication, authorization, rate-limit, and CI/CD t... |
| [apk-reverse](apk-reverse/README.md) | 在 CLI 环境下做 Android APK 逆向时使用。适用于 APK 解包、Java 反编译、smali 修改、重打包、Frida 动态 Hook，以及按需切换到 so/native 分析。优先使用本机已安装的 jadx、apktool、frida、adb、ida-reverse、radare2。 |
| [attack-chain](attack-chain/README.md) | Use for authorized multi-stage attack-path planning and orchestration when a task spans reconnaissance, initial access, privilege escalation, lateral movemen... |
| [binary-diff](binary-diff/README.md) | 跨版本符号迁移与二进制差分。当你有旧版本的符号/逆向结果，需要快速迁移到新版本时使用。 |
| [binary-ninja-reverse](binary-ninja-reverse/README.md) | Use for authorized binary analysis in Binary Ninja, including HLIL/MLIL/LLIL inspection, strings/imports/exports, cross-references, types, patch review, Pyth... |
| [browser-automation](browser-automation/README.md) | 统一自动化入口。覆盖浏览器自动化（Playwright）和 Windows 桌面应用自动化（OpenReverse）。 |
| [browser-extension-reverse](browser-extension-reverse/README.md) | Use for authorized reverse engineering of browser extensions (Chrome/Firefox) including manifest analysis, background workers, and extension-based credential... |
| [case-review](case-review/README.md) | Reviews a reverse-skill case package for scope readiness, Evidence to Finding to Path traceability, work item coverage, timeline references, and optional art... |
| [cloud-k8s](cloud-k8s/README.md) | Use for authorized cloud, container, and Kubernetes security assessment including metadata SSRF, IAM misconfig, container escape paths, and cluster RBAC review. |
| [code-audit](code-audit/README.md) | Use for authorized source-code security review and SAST workflows including Semgrep, CodeQL patterns, dangerous API hunting, and fix verification. |
| [ctf-sandbox](ctf-sandbox/README.md) | Thin PRIMARY for CTF / AWD / 靶场 multi-type orchestration. Hands off to the sidecar CTF-Sandbox-Orchestrator. Use when the user says CTF, AWD, 靶场, or 比赛题 and ... |
| [database-security](database-security/README.md) | Use for authorized database security assessment covering PostgreSQL/MySQL/MSSQL/Mongo/Redis exposure, authz, UDF/command paths, and misconfiguration review. |
| [diagram-generator](diagram-generator/README.md) | generate, refine, validate, and render diagrams from natural language, notes, code snippets, schemas, tables, or existing diagram source. use for flowcharts,... |
| [digital-forensics](digital-forensics/README.md) | Use for authorized digital forensics including memory dumps, disk timelines, PCAP investigation, artifact triage, and IR evidence preservation. |
| [docs-generator](docs-generator/README.md) | Creates task-oriented technical documentation with progressive disclosure. Use when writing READMEs, API docs, architecture docs, or markdown documentation. |
| [dotnet-reverse](dotnet-reverse/README.md) | .NET / C# 二进制逆向。当目标是 .NET assembly（PE 头含 CLR、.exe/.dll 托管程序）、C# 编译产物（含 NativeAOT）、红队 Sharp* 工具（Rubeus / SharpHound / SharpHound 等）、.NET 混淆程序（ConfuserEx / Sma... |
| [edr-bypass-re](edr-bypass-re/README.md) | 逆向防御方实现 → 红队针对性绕过。把 EDR / Defender / AV 的 hook 表、ETW provider、AMSI 实现先逆向出来， |
| [email-security](email-security/README.md) | Use for authorized email security review including phishing analysis, header authentication (SPF/DKIM/DMARC), BEC patterns, and mailbox token abuse research. |
| [firmware-pentest](firmware-pentest/README.md) | 固件 / IoT 渗透链。从拿到一坨 .bin / .img 开始，闭环走完逆向 → 提取 → 模拟 → 利用。 |
| [ghidra-reverse](ghidra-reverse/README.md) | Use for free/open reverse engineering with Ghidra (headless or GUI), including decompile, cross-refs, and optional Ghidra MCP workflows when IDA is unavailable. |
| [go-rust-reverse](go-rust-reverse/README.md) | Use for reverse engineering stripped Go and Rust binaries including runtime recognition, pclntab/moduel data recovery, panic strings, and idiomatic decompila... |
| [hardware-security](hardware-security/README.md) | Use for authorized hardware and embedded interface security research including UART/JTAG discovery, debug pad triage, secure boot overview, and offline firmw... |
| [ida-reverse](ida-reverse/README.md) | IDA Pro 逆向分析辅助技能。当用户提到逆向、反编译、分析二进制/PE/ELF/APK/DLL/SO、破解、找密码、漏洞分析、病毒分析、firmware 固件分析，或需要分析 exe/dll/so/elf/macho/sys 等文件时，务必使用此技能。 |
| [identity-federation](identity-federation/README.md) | Use for authorized assessment of federated identity systems including SAML, OIDC, OAuth2 flows, SSO misconfiguration, and token confusion issues. |
| [js-reverse](js-reverse/README.md) | 在使用 js-reverse-mcp 做前端 JavaScript 逆向时使用，适用于签名链路定位、页面观察取证、运行时采样、本地补环境复现与证据化输出。优先适配当前环境里的 js-reverse_* 工具，需要更强的浏览器/CDP/Hook 面时联动 jshookmcp。 |
| [llm-security](llm-security/README.md) | Use for authorized security assessment of LLM applications and AI agents, including prompt injection, tool abuse, RAG exposure, memory poisoning, and model s... |
| [macos-reverse](macos-reverse/README.md) | Use for authorized macOS and Mach-O reverse engineering including codesign, Objective-C/Swift recovery, endpoint security surfaces, and Apple platform malwar... |
| [malware-analysis](malware-analysis/README.md) | Use when analyzing suspected malware through static, dynamic, and behavioral techniques, including IOC extraction, YARA or Sigma rules, sandboxing, and anti-... |
| [mobile-reverse](mobile-reverse/README.md) | Use for authorized Android or iOS application reverse engineering and security testing, including APK or IPA analysis, runtime instrumentation, SSL pinning, ... |
| [ot-ics](ot-ics/README.md) | Use for authorized OT/ICS security assessment covering Purdue model zoning, PLC/SCADA exposure, industrial protocol discovery, and safe passive-first evaluat... |
| [patch-diff-exploit](patch-diff-exploit/README.md) | N-day 补丁差分到利用。从厂商发布的补丁里反推漏洞点、写 PoC、做成可用的攻击模块。 |
| [pentest-tools](pentest-tools/README.md) | 主动渗透测试工具链。覆盖信息收集、端口扫描、漏洞扫描、Web 渗透、SQL 注入、目录爆破、密码破解等场景。 |
| [src-hunter](pentest-tools/src-hunter/README.md) | 实战 SRC / 众测 / Bug bounty 漏洞挖掘工作流 skill。包含：5 阶段方法论（intake → recon → enum → hunt → report）、19 个攻击类 playbook（SQLi/XSS/RCE/SSRF/IDOR/CSRF/Path Traversal/File Upl... |
| [protocol-reverse](protocol-reverse/README.md) | Use for authorized reverse engineering of custom binary protocols, Protobuf/gRPC, WebSocket frames, and PCAP-driven protocol recovery. |
| [pwn-chain](pwn-chain/README.md) | 从逆向走到可用利用 (Working Exploit) 的全链路工程化方法。 |
| [radare2](radare2/README.md) | Use this skill whenever the user wants to analyze binaries with radare2/r2 from the command line, including reverse engineering, disassembly, function analys... |
| [radio-sdr](radio-sdr/README.md) | Use for authorized RF/SDR security research including signal identification, replay feasibility study in shielded labs, and wireless protocol analysis outsid... |
| [dsl-vm-reverse](reverse-engineering/dsl-vm-reverse/README.md) | Reverse JavaScript-based custom DSL/VM interpreters, non-standard WASM-like runtimes, and risk-control engines. Use when analyzing IIFE or switch-based opcod... |
| [reverse-engineering](reverse-engineering/README.md) | Provides reverse engineering techniques. Use when the main job is to understand how a compiled, obfuscated, packed, or virtualized target works before exploi... |
| [supply-chain-security](supply-chain-security/README.md) | Use for software supply-chain security assessment covering SBOM, SCA, CI/CD pipelines, container images, build integrity, dependency provenance, and vulnerab... |
| [thick-client](thick-client/README.md) | Use for authorized security testing of desktop thick clients including local storage, update channels, IPC, traffic, and client-side trust boundaries. |
| [threat-hunting](threat-hunting/README.md) | Use for blue-team threat hunting, detection engineering with Sigma/YARA, SIEM query design, and incident detection validation. |
| [threat-intelligence](threat-intelligence/README.md) | Use for authorized OSINT and cyber threat intelligence that enriches IOCs, campaigns, impersonation, scams, or threat actors from public sources. Includes bo... |
| [wifi-wireless](wifi-wireless/README.md) | Use for authorized wireless security assessment including Wi-Fi capture, WPA handshake analysis, rogue AP detection research, and lab-only deauth testing. |
| [windows-ad](windows-ad/README.md) | Use for authorized Active Directory and Windows identity attacks including Kerberos, AD CS, BloodHound paths, NTLM relay, and domain privilege escalation res... |

## 目录树

```
references/api-security/README.md/
references/apk-reverse/README.md/
references/attack-chain/README.md/
references/binary-diff/README.md/
references/binary-ninja-reverse/README.md/
references/browser-automation/README.md/
references/browser-extension-reverse/README.md/
references/case-review/README.md/
references/cloud-k8s/README.md/
references/code-audit/README.md/
references/ctf-sandbox/README.md/
references/database-security/README.md/
references/diagram-generator/README.md/
references/digital-forensics/README.md/
references/docs-generator/README.md/
references/dotnet-reverse/README.md/
references/edr-bypass-re/README.md/
references/email-security/README.md/
references/firmware-pentest/README.md/
references/ghidra-reverse/README.md/
references/go-rust-reverse/README.md/
references/hardware-security/README.md/
references/ida-reverse/README.md/
references/identity-federation/README.md/
references/js-reverse/README.md/
references/llm-security/README.md/
references/macos-reverse/README.md/
references/malware-analysis/README.md/
references/mobile-reverse/README.md/
references/ot-ics/README.md/
references/patch-diff-exploit/README.md/
references/pentest-tools/README.md/
references/pentest-tools/src-hunter/README.md/
references/protocol-reverse/README.md/
references/pwn-chain/README.md/
references/radare2/README.md/
references/radio-sdr/README.md/
references/reverse-engineering/dsl-vm-reverse/README.md/
references/reverse-engineering/README.md/
references/supply-chain-security/README.md/
references/thick-client/README.md/
references/threat-hunting/README.md/
references/threat-intelligence/README.md/
references/wifi-wireless/README.md/
references/windows-ad/README.md/
```

## 路由

PRIMARY 路由由 `references/config/routing.json`（唯一事实源）驱动，用 `master-route.ps1 -Hint "<任务>"` 分诊。
歧义场景读 `references/routing.md` 全矩阵；CTF 多类型任务走 `CTF-Sandbox-Orchestrator/`。
