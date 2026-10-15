# xKx0000xKx Task Automatic Routing Rules (Kali Linux Version)

> **This document is the Kali path adaptation layer, not the second set of behavior chains.** Behavior and authorization are subject to the repository root xKx0001xKx.
> The core knowledge base (xKx0002xKx, README.md, references) is shared with the Windows version.
> **Do not** write this file to xKx0003xKx or other client global configurations. Core scripts must not write client global files.

Hot path (same as xKx0004xKx): xKx0005xKx → xKx0006xKx (target ACT prohibited before xKx0007xKx) → PRIMARY xKx0008xKx. Identity: xKx0009xKx. Script uses this directory xKx0010xKx.

---

## Trigger Keywords (Exactly the Same as the Windows Version)

- APK、Android 逆向、反编译、smali、jadx、apktool、Frida、Hook
- 二进制分析、IDA、radare2、r2、反汇编、逆向工程、RE、还原源码、源码还原、逆向还原
- 前端签名、加密参数、JS 逆向、jshookmcp、CDP、SourceMap
- 抓包、HTTP 捕获、请求重放、anything-analyzer
- CTF、Pwn、Web 渗透、漏洞利用、提权
- MCP 逆向工具、idalib-mcp
- 重打包、签名、证书校验、root 检测、反调试
- so 分析、native hook、JNI
- 渗透测试、红队、安全评估、蓝队、应急响应
- 写报告、写文档、出报告、writeup、技术文档、渗透报告、逆向报告
- 浏览器自动化、打开网页、填表、爬取、截图、自动化登录、Playwright、agent-browser、headless
- 符号迁移、bindiff、跨版本、PDB 缺失、函数偏移迁移、symbol migration、版本对比、旧版符号
- N-day、Nday、补丁差分、patch diff、patch tuesday、1day、CVE 复现、漏洞还原、ghidriff、Diaphora、DeepDiff、补丁分析
- pwn、栈溢出、堆溢出、ROP、ret2libc、ret2csu、one_gadget、libc-database、tcache、fastbin、kernel pwn、SMEP、SMAP、KASLR、modprobe_path、commit_creds、pwntools、GEF、pwndbg
- 固件、firmware、IoT、binwalk、unblob、squashfs、UBI、JFFS2、Firmadyne、FAT、QEMU 全系统仿真、EMBA、固件渗透、路由器固件、嵌入式漏洞利用、AFL++、boofuzz、UART、JTAG
- BurpSuite、Burp MCP、Intruder、Repeater、Collaborator、代理历史分析
- LLM 安全、AI 安全测试、Prompt 注入、jailbreak、越狱、Agent 安全、garak、PyRIT
- API 安全测试、GraphQL 安全、JWT 攻击、供应链安全、SBOM、Trivy
- iOS 逆向、Objection、YARA、恶意软件分析、AI 反编译、LLM4Decompile
- Agent 不干活、AI 懒、跳过步骤、Prompt 工程、Agent 服从性
- EDR 绕过、AV bypass、免杀、unhook、direct syscall、indirect syscall、Hell's Gate、SysWhispers、ETW patch、AMSI patch、call stack spoofing、MITRE T1562、CrowdStrike 绕过、Defender 绕过、SentinelOne 绕过、pe-sieve
- 端口扫描、Nmap、漏洞扫描、Nuclei、SQL 注入、SQLMap、目录爆破、FFUF、密码破解、Hashcat、Hydra、Metasploit、Impacket、pentestMCP
- SRC、Bug Bounty、众测、漏洞赏金、HackerOne、WAF bypass、绕过 WAF、IDOR、越权、任意账号
- 画图、流程图、架构图、攻击路径图、时序图、状态图、数据流图、Mermaid、Graphviz、PlantUML、diagram
- 恶意软件分析、病毒分析、样本分析、沙箱、YARA、IOC
- 内核驱动、Rootkit、LKM、IOCTL、DeviceIoControl
- 密码学、加解密、AES、RSA、哈希碰撞、签名验证
- 协议逆向、自定义协议、Protobuf、序列化
- 固件逆向、IoT、binwalk、ARM、MIPS、嵌入式
- WASM、WebAssembly、Python 字节码、pyc、.NET、dnSpy、IL
- macOS、iOS、Mach-O、ObjC、Swift、Frida iOS
- Go 逆向、Rust 逆向、stripped binary、GoReSym
- 内存转储、memory dump、取证、forensic、隐写、steganography
- 云安全、容器逃逸、K8s、Docker、AWS、Azure
- Prompt 注入、AI 安全、Agent 安全、LLM 攻击
- 内网渗透、横向移动、Pass-the-Hash、域渗透、AD 攻击、BloodHound
- 权限提升、提权、SUID、Potato、UAC bypass
- 凭证提取、Mimikatz、Kerberoasting、DCSync、LSASS
- C2、远控、持久化、后门、Cobalt Strike、反弹 shell
- 蓝队、检测、防御、应急响应、SIEM、EDR、威胁狩猎、IOC
- 移动安全测试、OWASP MASTG、APP 安全、脱壳、加固分析
- SSTI、模板注入、SSTImap、XSS、XSStrike、跨站脚本
- WordPress、WPScan、WPProbe、CMS 渗透
- AdaptixC2、C2 框架、对抗模拟、红队模拟、Atomic Red Team
- WiFi 攻击、无线渗透、Fluxion、aircrack-ng、deauth
- NTLM relay、Coercer、认证强制、PetitPotam
- WinRM、evil-winrm、Windows 远程执行
- NetExec、nxc、CrackMapExec、SMB 枚举
- AI 自动渗透、HexStrike、MetasploitMCP、mcp-kali-server
- Pentest Swarm、pentestswarm、群体渗透、Swarm AI、自主扫描、stigmergy
- Bug Bounty 自动化、攻击面管理、ASM、持续监控
- GEF、GDB 增强、调试框架
- Wireshark、tshark、PCAP 分析、抓包分析
- BurpSuite、Web 代理、拦截请求、Intruder
- Responder、LLMNR 投毒、NBT-NS、MDNS
- BloodHound、AD 路径、攻击图、SharpHound
- Certipy、AD CS、证书攻击、ESC1、ESC8
- wfuzz、参数模糊、Web Fuzz
- objdump、strings、file、静态分析
- ProxyCat、代理池、IP 轮换
- 红队、HW、攻防演练、打点、初始突破、边界突破
- 完整渗透、全流程渗透、从外网打到内网、从外打到域控
- 攻击面评估、攻击路径规划、攻击链、kill chain
- 拿到 shell 下一步、后渗透、据点扩展、纵深渗透
- 近源渗透、BadUSB、Rubber Ducky、WiFi Pineapple、Proxmark3、RFID 克隆
- EDR 绕过、免杀、AV bypass、Shellcode 加载器、无文件攻击
- 钓鱼邮件、社会工程、OAuth 钓鱼、HTML 走私
- 供应链攻击、组件投毒、第三方渗透
- 痕迹清理、反取证、日志清除、时间戳修改
- Cobalt Strike、Sliver、Havoc、Mythic、C2 框架

---

## Route Entry

> **Detection Method**: Find the parent directory of the directory where this file (xKx0011xKx) is located; that is the package root directory.

Hot path (same as xKx0012xKx / xKx0013xKx):

1. xKx0014xKx — PRIMARY
2. xKx0015xKx — xKx0016xKx; xKx0017xKx Previous prohibition on the target ACT
3. PRIMARY xKx0018xKx ACTION REQUIRED
4. xKx0019xKx — real path; if missing, xKx0020xKx

---

## Execution Principles (Same as Windows version, only the commands are different)

### Tool Usage
- **Never guess the tool path**, read xKx0021xKx first
- When tools are lacking, first call xKx0022xKx for automatic completion
- Kali comes preinstalled with a large number of tools, and the probability of bootstrap failure is much lower than on Windows
- After the same tool fails to install automatically 2 times, stop retrying and output the manual steps
- When the MCP service ports are inconsistent, ask the user for the actual port and help the user update the configuration

### Routing Decision
- Do not force existing skills when the route is not matched; proactively suggest adding new ones
- If one approach doesn't work, try another: if static analysis fails, try dynamic; if the Java layer doesn't work, check the .so files; if IDA doesn't work, switch to r2
- Cross-module tasks combine multiple skills according to the 'Path Crossing' section of xKx0023xKx

### Experience Reuse
- Before entering the route each time, **you must first check** xKx0024xKx
- When there is similar experience, first read the corresponding logs and reuse the already validated solution
- If the historical plan is not applicable, state the reason in the new log

### Safety Boundary
- All operations must be within the scope of user authorization
- Penetration testing must ensure that the user has legal authorization (xKx0025xKx xKx0026xKx xKx0027xKx)
- Do not proactively expand the attack surface, do not exceed the target range specified by the user
- Immediately inform the user when a high-risk vulnerability is found, and wait for instructions before proceeding
- Do not retain unsanitized sensitive information in reports or logs

### Output Quality
- Key operations must provide reproducible commands (do not just describe the steps)
- Reverse analysis must indicate the xKx0028xKx name (don't just say 'a certain function')
- Penetration testing must provide a complete PoC (curl xKx0029xKx path)
- Conclusions that are uncertain must indicate confidence level

---

## Complete Behavior Chain

```
1. The recognition task belongs to the security/reverse engineering category
2. Base root = Parent directory of this document
3. master-route.sh → PRIMARY（routing.json）
4. case-init.sh / scope.md — auth.status=granted Before this, prohibit actions on the target ACT
5. Open PRIMARY README.md
6. Missing tool → kali/scripts/bootstrap-reverse.sh
7. Do not write to the client global configuration
```

---

## Bootstrap Commands (Kali Version)

```bash
bash "<本包根目录>/kali/scripts/bootstrap-reverse.sh" <capability1> [capability2] ... [--start-services]
```

### Common Combinations

```bash
# One-Click Setup of Native Kali MCP (Recommended for First-Time Use)
bash kali/scripts/bootstrap-reverse.sh mcp-kali-server metasploitmcp hexstrike-ai

# Install all new tools in 2026.1
bash kali/scripts/bootstrap-reverse.sh adaptixc2 atomic-operator sstimap xsstrike wpprobe fluxion gef

# AD/Intranet Penetration Toolchain
bash kali/scripts/bootstrap-reverse.sh coercer evil-winrm-py netexec responder bloodhound certipy

# Reverse Engineering Toolchain
bash kali/scripts/bootstrap-reverse.sh jadx frida gef ghidra-mcp

# Web Penetration Toolkit
bash kali/scripts/bootstrap-reverse.sh sstimap xsstrike wpprobe nuclei
```

All supported capability names: jadx, apktool, frida, idalib-mcp, jshookmcp, xquik-mcp, anything-analyzer, idapro, r2, rabin2, adb, agent-browser, ghidra-mcp, nmap, sqlmap, hashcat, hydra, gobuster, ffuf, msfconsole, nuclei, seclists, proxycat, mcp-kali-server, metasploitmcp, hexstrike-ai, pentestswarm, adaptixc2, atomic-operator, sstimap, xsstrike, wpprobe, fluxion, gef, evil-winrm-py, coercer, netexec, responder, crackmapexec, bloodhound, certipy, wfuzz, aircrack-ng

## Refresh Tool Index

```bash
bash "<本包根目录>/kali/scripts/refresh-tool-index.sh"
```

---

## MCP Service Management

### Kali Native MCP (directly installed via apt, no additional configuration required)

| Service | Package Name | Port | Purpose | Startup Method |
|------|------|------|------|---------|
| mcp-kali-server | mcp-kali-server | 5000 | Official Kali MCP, AI directly calls terminal tools | `kali-server-mcp --port 5000` |
| MetasploitMCP | metasploitmcp | 8085/stdio | Metasploit Framework MCP Interface | `metasploitmcp --transport stdio` |
| HexStrike AI | hexstrike-ai | — | 150+ security tools MCP automation platform | `hexstrike-ai` |

### Third-Party MCP Services

| Service | Port | Purpose | Startup Method |
|------|------|------|---------|
| Pentest Swarm AI | stdio | Collective Intelligence Autonomous Penetration (recon→classify→exploit→report) | `pentestswarm mcp serve` |
| idapro | 13337-13350 | IDA Pro reverse engineering tool | `bash kali/scripts/ida-start.sh` |
| anything-analyzer | 23816 | Browser Automation + HTTP Capture | `cd ~/tools/anything-analyzer && pnpm dev` |
| jshookmcp | — | JS Hook/CDP/Network/AST | `npx -y @jshookmcp/jshook@0.3.4` (stdio) |
| ghidra | 8765 | Ghidra free decompiler | Ghidra GUI automatically listens after startup |
| burpsuite | 9876 | BurpSuite Web Proxy | BurpSuite Extension Startup |

### MCP Priority Recommendations (Kali 2026.1)

For penetration testing scenarios, the recommended MCP usage priority is:

1. **pentestswarm** — Fully automated collective penetration, suitable for large-scale targets (1000+ subdomains) and continuous Bug Bounty monitoring
2. **mcp-kali-server** — The most versatile, can invoke any terminal tool on Kali
3. **metasploitmcp** — Dedicated to Metasploit, managed by exploit/payload/session
4. **hexstrike-ai** — Automated orchestration, suitable for multi-tool interaction scenarios
5. **jshookmcp** — Web/JS Reverse engineering dedicated

One-click setup for all penetration MCP:```bash
bash kali/scripts/bootstrap-reverse.sh mcp-kali-server metasploitmcp hexstrike-ai pentestswarm
```

---

## Error Handling Strategy

| Scene | What AI Should Do |
|------|-------------|
| bootstrap successful | continue task |
| apt install failed | Check the network/sources, try `apt update` and then retry |
| pip install failed | Try adding `--break-system-packages`, or it is recommended to use venv |
| GitHub download failed | Check network/proxy, provide manual download link |
| Server port inconsistency | Inquire about the actual port and help the user update the MCP configuration |
| The same tool failed twice | Provide complete manual steps, do not retry |

---

## Kali Unique Advantage Tips

AI in the Kali 2026.1 environment should know:

1. **A large number of tools pre-installed** — nmap/sqlmap/hashcat/hydra/metasploit/gobuster/ffuf/radare2/binwalk/burpsuite/wireshark/nikto/impacket/netexec/responder/bloodhound and others do not require installation
2. **Native MCP Support** — The three MCP tools `mcp-kali-server`, `metasploitmcp`, `hexstrike-ai` have been added to the official Kali repository, `apt install` is ready
3. **2026.1 New Tools** — AdaptixC2 (C2 framework), Atomic-Operator (Red Team testing), SSTImap (SSTI detection), XSStrike (XSS scanning), WPProbe (WP enumeration), Fluxion (WiFi social engineering), GEF (GDB enhancement)
4. **New Tools in April 2025** — evil-winrm-py (WinRM remote execution), hexstrike-ai (AI security automation), bpf-linker
5. **Kernel 6.18** — Supports the latest hardware, NetHunter wireless injection patch (QCACLD-3.0)
6. **Full Wayland Support** — GNOME 49 + KDE Plasma 6.5, Wayland is also supported in VMs
7. **apt source rich** — `apt install ghidra`, `apt install seclists`, `apt install coercer` can all be handled in one line
8. **Python Environment Complete** — python3/pip3 pre-installed, frida-tools can be directly pip installed
9. **No Permission Restrictions** — Default root or sudo without a password
10. **Comprehensive network tools** — nc/curl/wget/socat/proxychains/chisel and others pre-installed
11. **SecLists Path** — after apt installation on `/usr/share/seclists/`
12. **Wordlists** — `/usr/share/wordlists/` has common dictionaries such as rockyou
13. **LLM Integration** — The official Kali blog has a tutorial on local LLM integration with Claude Desktop + Ollama + 5ire
14. **BackTrack Mode** — `kali-undercover --backtrack` can switch to the classic BackTrack 5 appearance (social engineering scenario)

---

## Prohibited Actions (Same as the Windows Version)

- ❌ Do not start reverse engineering/penetration operations without first reading routing.md
- ❌ Do not guess the tool path; it must be obtained from the tool index
- ❌ Do not skip the field-journal query and start the task directly
- ❌ Do not skip the Checklist after completing the task
- ❌ Do not keep real target information that has not been anonymized in the report
- ❌ Do not expand the scope of penetration without user authorization
- ❌ Do not repeatedly retry an automatic installation that has already failed twice
- ❌ Do not remain silent — You must inform the user immediately when a problem occurs
- ❌ Do not make up tool version numbers or feature descriptions yourself

---

## Mandatory Checklist After Task Completion (Cannot Be Skipped)

After the task is completed (vulnerability verified / reverse engineering completed / flag obtained), the AI **must** perform each item step by step:

```text
□ 1. Generate formal reports (docs-generator skill)
- Use the corresponding template (reverse report / penetration report / CTF writeup / signature report)
- Must include: objective overview, complete steps, key evidence, reproduction commands
- Output to the user's project directory (not inside the skill package)

□ 2. Generate charts (diagram-generator skill)
- At least one flowchart embedded in the report
- Type Selection: Penetration → Attack Path Map / Reverse → Call Graph / JS → Sequence Diagram / CTF → Solution Process

□ 3. Write back field-journal (anonymized)
- In field-journal/_template.md format
- Must include: pitfall records, reusable patterns, toolchain discoveries, environment information
- Desensitization check: no real domain/IP/Token/ username

□ 4. Consolidate the knowledge found through the search (if an online search was conducted for this task)
- Write the valuable content found into the references/ of the corresponding skill
- Indicate the source URL and date
- If a new tool is found → update bootstrap-manifest.json
- If a new scenario is discovered → update routing.md + RULES-kali.md keywords

□ 5. Inquire about community contributions
- "Do you want to contribute this experience to the community main repository? The data has been anonymized, only the field-journal file is submitted."
- User agrees → Create PR following the CONTRIBUTE-BACK.md process
- User declined → Skip

□ 6. Update System Index
- Update field-journal/_index.md (new entry)
- Check if updates are needed: routing.md / bootstrap-manifest / tool-index
- If a new tool or new scenario is found → execute the corresponding update
```

If the AI does not complete the above checklist after finishing the task, the user can remind it: 'You forgot to write the report and provide feedback on the experience,' and the AI must immediately make up for it.

---

## Multitasking and Interrupt Handling

- If the user switches topics during task execution, first save the current progress to the field-journal (marked as 'incomplete')
- When the user returns to continue, restore the context from field-journal
- If the user provides multiple security tasks at the same time, execute them one by one according to priority, do not run them in parallel (to avoid tool conflicts)
- For long tasks (such as analyzing large files in IDA), report progress regularly so users don’t think it’s frozen

---

## Supplementary Network Knowledge (Must be used when search capability is available)

When AI has internet search capabilities, **it must actively search in the following scenarios**:

| Scenario | What to search | What to do after searching |
|------|---------|-------------|
| Encounter unknown shell/protection/obfuscation | Search for unpacking methods and tools for this shell | Write the methods into the references/ of the corresponding skill |
| Encounter unknown framework/protocol | Search for methods to reverse engineer/penetrate this framework | Write into references/ or propose adding a new skill |
| Tool Error/Incompatibility | Search Error Information + Version Compatibility | Write Down Field-Journal Pitfall Records |
| Discover new CVE/vulnerabilities | Search for PoC and exploitation methods | Write into pentest-tools/references/ |
| Route missed (entirely new scenario) | Search for methodologies and tools in this field | Propose adding a new skill and include the found information |
| Requires a specific Frida script | Search for ready-made scripts on GitHub/CodeShare | Write to apk-reverse/references/ or use directly |
| Requires specific payload | Search PayloadsAllTheThings/HackTricks | Write pentest-tools/payloads/ |
| Tool version is outdated | Search for the latest version and breaking changes | Update bootstrap-manifest and documentation |

### Knowledge Accumulation Process After Search

```text
1. Search for information
2. Verify the reliability of information (prioritize official documents > GitHub > blogs > forums)
3. Extract actionable content (commands/scripts/configuration/steps)
4. Write to the corresponding location in this package:
- General methodology → references/*.md corresponding to the skill
- Usage of specific tools → references/ or README.md corresponding to the skill
- Pitfall experiences → field-journal/
- New tool discovery → kali/scripts/bootstrap-manifest.json + tool-discovery.sh
- New scene discovery → routing.md + RULES-kali.md keywords
5. Mark the source (URL + date) to facilitate verification of timeliness later
6. If the amount of information is sufficient (new field), it is proposed to add an independent skill
```

### Search Quality Requirements

- **Do not just give the user a link after searching** — key content must be extracted and written into this package
- **Do not blindly trust search results** — cross-check with official documentation and indicate confidence levels
- **Prefer Chinese resources** (if the user communicates in Chinese) — but technical details should follow the official English documentation
- **Timeliness of Annotation** — The security field changes quickly, annotate the search date, mark outdated content `[可能过时]`

---

## Add Skill

When it is found that the routing matrix cannot cover the current task type, add a skill according to the `CONTRIBUTING.md` process.

Path: `<本包根目录>/references/CONTRIBUTING.md`

After adding, the following must be updated simultaneously: routing.md, kali/scripts/bootstrap-manifest.json, kali/scripts/lib/tool-discovery.sh, kali/scripts/refresh-tool-index.sh.