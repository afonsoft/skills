# Cybersecurity Skills Router — Kali Linux Special Edition

> This directory is the optimized adaptation layer for Kali Linux 2026.1. It is specifically optimized based on Kali 2026.1 (kernel 6.18) released in March 2026.
> The core knowledge base (references/, CTF-Sandbox-Orchestrator/) is shared with the Windows version; the Kali-specific README and Bash entry need to cover the names of Windows core capabilities, while additionally providing Kali native tools/MCP capabilities.
> Root Directory [README-kali.md](../README-kali.md) is only a short link, **refer to this file as the standard**.

---

## AI: Execute immediately after reading

```text
1. Check the package root directory (including the repository roots of references/ and kali/)
2. Read kali/RULES-kali.md → Global Injection and Tool Scanning
3. bash kali/scripts/refresh-tool-index.sh
4. Shared combat chain with the main package:
- references/MASTER-ROUTING.md (or pwsh references/scripts/master-route.ps1)
   - references/scripts/case-init.ps1 → work/<case>/scope.md
- auth.status=granted + network_profile only then for the target ACT
- references/ops/ (Evidence Chain / Role / Timeline / IDENTITY)
5. Report configuration results to the user
```

General Agent guidance can be found at the root of the repository [README_AI.md](../README_AI.md) (read this file again when Kali is detected).

---

## 0. Relationship with the Windows version (ability name alignment)

```text
Project root directory/
├── references/                    # Shared: SKILL, routing, MASTER-ROUTING, ops, scripts, field-journal
├── CTF-Sandbox-Orchestrator/  # Shared: 40+ CTF sub-skills
├── kali/                      # ← You are here
│   ├── scripts/
│   │   ├── bootstrap-reverse.sh
│   │   ├── refresh-tool-index.sh
│   │   ├── bootstrap-manifest.json
│   │   └── lib/
│   │       └── tool-discovery.sh
│   ├── RULES-kali.md
│   └── README-kali.md
├── RULES.md                   # Windows version rules
└── Readme.md                  # Windows Version Instructions
```


### 0.1 Alignment Principles

The Kali-specific entry point is not a simple copy of the Windows README, but rather **the same core capability names + additional Kali capabilities**:

- Windows: `references/scripts/bootstrap-reverse.ps1`
- Kali: `kali/scripts/bootstrap-reverse.sh`
- Ordinary Linux/macOS: `references/scripts/bootstrap-reverse.sh`

JEB Pro is a commercial tool licensed and installed by users themselves; Reqable MCP uses the official fixed version of `reqable-mcp-server`, but still requires the separate installation of the Reqable desktop client.

Kali scripts should cover core capability names in the Windows manifest, such as `jadx`, `apktool`, `frida`, `jshookmcp`, `xquik-mcp`, `anything-analyzer`, `idapro`, `r2`, `adb`, `ghidra-mcp`, `seclists`, `burpsuite-mcp`, `nmap`, `pentestswarm`; at the same time, it can additionally support native Kali tools, such as `mcp-kali-server`, `metasploitmcp`, `hexstrike-ai`, `sstimap`, `xsstrike`, `netexec`, and so on.

**Shared Part** (no changes needed):
- All `README.md`, `routing.md`, `MASTER-ROUTING.md`
- `references/ops/` Combat Contract (scope / evidence chain / roles / timeline)
- All `references/` knowledge bases
- `field-journal/` Self-evolution Mechanism
- `CTF-Sandbox-Orchestrator/` All
- `docs-generator/`, `diagram-generator/`
- `references/scripts/case-init.ps1`, `master-route.ps1` (can be called using pwsh)

**Kali Exclusive Section**:
- The script is all bash (`.sh`)
- Package management goes `apt`
- The path is conventionally in Linux style (`/opt/`, `~/tools/`, `/usr/bin/`)
- A large number of tools pre-installed in Kali, bootstrap logic greatly simplified

---

## 1. Kali's Natural Advantages

The following tools are **ready to use out of the box** in Kali 2026.1 (no bootstrap required):

### Classic Pre-installed Tools

| Tool | Kali Package Name | Status |
|------|----------|------|
| nmap | nmap | Pre-installed |
| sqlmap | sqlmap | Pre-installed |
| hashcat | hashcat | Pre-installed |
| john | john | pre-installed |
| hydra | hydra | Pre-installed |
| metasploit | metasploit-framework | pre-installed |
| gobuster | gobuster | Pre-installed |
| ffuf | ffuf | Pre-installed |
| radare2 | radare2 | Pre-installed |
| binwalk | binwalk | Pre-installed |
| frida | python3-frida-tools | pre-installed or via pip |
| burpsuite | burpsuite | Pre-installed |
| wireshark | wireshark | Pre-installed |
| nikto | nikto | Pre-installed |
| wfuzz | wfuzz | Pre-installed |
| impacket | impacket-scripts | pre-installed |
| netexec | netexec | Pre-installed |
| responder | responder | pre-installed |
| aircrack-ng | aircrack-ng | pre-installed |
| bloodhound | bloodhound | apt installable |
| ghidra | ghidra | can be installed via apt |

### New Tools in Kali 2026.1 (March 2026)

| Tool | Package Name | Purpose |
|------|------|------|
| AdaptixC2 | adaptixc2 | Post-exploitation and adversary simulation framework |
| Atomic-Operator | atomic-operator | Cross-Platform Atomic Red Team Test Execution |
| Fluxion | fluxion | WiFi Security Auditing and Social Engineering |
| GEF | gef | GDB Modernized Enhanced Debugging Framework |
| MetasploitMCP | metasploitmcp | Metasploit's MCP Server Interface |
| SSTImap | sstimap | Server-Side Template Injection automatic detection and exploitation |
| WPProbe | wpprobe | Rapid WordPress Plugin Enumeration |
| XSStrike | xsstrike | Advanced XSS Scanner |

### New Tools in Kali 2025.4 (December 2025)

| Tool | Package Name | Purpose |
|------|------|------|
| evil-winrm-py | evil-winrm-py | Python version WinRM remote command execution |
| hexstrike-ai | hexstrike-ai | AI MCP Security Automation Platform (150+ Tools) |
| bpf-linker | bpf-linker | BPF Static Linker |

### Kali Native MCP Tool (Focus on Optimization)

| Tool | Package Name | Purpose | Installation |
|------|------|------|------|
| mcp-kali-server | mcp-kali-server | Official Kali MCP, AI directly calls terminal tools | `apt install mcp-kali-server` |
| MetasploitMCP | metasploitmcp | Metasploit MCP Interface | `apt install metasploitmcp` |
| HexStrike AI | hexstrike-ai | 150+ security tools MCP automation | `apt install hexstrike-ai` |

> **The biggest advantage of the Kali version compared to the Windows version**: Three MCP tools can be directly installed via apt, no need to manually configure GitHub/npm/Docker.

This means that `bootstrap-reverse.sh` requires far less workload on Kali than on the Windows version.

---

## 2. Quick Start

### 2.0 One-Click Initialization (Recommended for New Systems)

```bash
# Brand New Kali 2026.1 System One-Click Configuration (Root Required)
sudo bash kali/scripts/quick-setup.sh

# Skip system updates (when the network is slow)
sudo bash kali/scripts/quick-setup.sh --skip-update

# Minimal Installation (without AD/Internal Network Tools)
sudo bash kali/scripts/quick-setup.sh --minimal
```

This script will automatically perform: system update → install 2026.1 new tools → configure native MCP → install reverse engineering tools → refresh index → generate report.

### 2.1 Initial Configuration

```bash
# 1. Enter the project root directory
cd /path/to/cybersecurity-skills-router

# 2. Give the script execution permissions
chmod +x kali/scripts/*.sh kali/scripts/lib/*.sh

# 3. Refresh Tool Index (Check Local Tool Status)
bash kali/scripts/refresh-tool-index.sh

# 4. View Results
cat references/tool-index.md
```

### 2.2 One-Click Setup for Kali Native MCP (Highly Recommended)

```bash
# Install Kali Official MCP Three-Piece Set
bash kali/scripts/bootstrap-reverse.sh mcp-kali-server metasploitmcp hexstrike-ai

# After installation, MCP configuration is automatically written to ~/.claude/mcp.json
# If using Kiro, manually copy to ~/.kiro/settings/mcp.json
```

### 2.3 Installing the 2026.1 New Tool

```bash
# One-Click Installation of All New Tools
bash kali/scripts/bootstrap-reverse.sh adaptixc2 atomic-operator sstimap xsstrike wpprobe fluxion gef

# AD/Intranet Penetration Kit
bash kali/scripts/bootstrap-reverse.sh coercer evil-winrm-py netexec responder bloodhound certipy
```

### 2.4 Installing Missing Tools

```bash
# Install a single tool
bash kali/scripts/bootstrap-reverse.sh jadx

# Installing Multiple Tools
bash kali/scripts/bootstrap-reverse.sh jadx apktool frida jshookmcp

# Install and start the service
bash kali/scripts/bootstrap-reverse.sh idapro --start-services
```

### 2.5 Let AI Client Automatically Route

Tell your AI client to read `kali/RULES-kali.md`, it will automatically complete the global injection.

---

## 3. Path Conventions

| Purpose | Kali Path |
|------|----------|
| Tool Installation Directory | `~/tools/` or `/opt/` |
| jadx | `/opt/jadx/` or `~/tools/jadx/` |
| apktool | `/usr/local/bin/apktool` (apt) or `~/tools/apktool/` |
| Ghidra | `/opt/ghidra/` or `~/tools/ghidra/` |
| IDA Pro | `/opt/idapro/` (if there is a Linux version) |
| Android SDK | `~/Android/Sdk/` |
| SecLists | `/usr/share/seclists/` (apt) or `~/tools/SecLists/` |
| Node.js | `/usr/bin/node` (apt/nvm) |
| Python | `/usr/bin/python3` (system built-in) |
| MCP Configuration | `~/.claude/mcp.json` or `~/.kiro/settings/mcp.json` |

---

## 4. Summary of Differences with the Windows Version

| Dimension | Windows Version | Kali Version |
|------|-----------|---------|
| Scripting Language | PowerShell (.ps1) | Bash (.sh) |
| Package Management | winget / GitHub Release ZIP | apt / pip / npm / GitHub Release tar.gz |
| Path Separator | `\` | `/` |
| Environment Variable | `%USERPROFILE%` | `$HOME` |
| Preinstalled Tools | Almost None | Large Number of Security Tools Preinstalled |
| IDA Launch | `start.ps1` | Manually launch the Linux version of IDA; the script only registers/checks MCP, unless the launcher is added locally
| MCP Configuration Path | `%USERPROFILE%\.claude\mcp.json` | `~/.claude/mcp.json` |
| Port Detection | `TcpClient` | `nc -z` or `ss` |

---

## 5. Verification Checklist

```bash
# ─── Basic Commands ───
java -version
python3 --version
pip3 --version
node -v
npx -v

# ─── Reverse Engineering Tools ───
jadx --version
apktool --version
adb version
frida --version
r2 -v
gdb --version          # GEF 自动加载

# ─── Penetration Tools (Pre-installed with Kali) ───
nmap --version
sqlmap --version
hashcat --version
hydra -h | head -1
msfconsole --version
gobuster version
ffuf -V
nuclei -version

# ─── Kali 2026.1 New Tools ───
sstimap -h 2>&1 | head -3
xsstrike -h 2>&1 | head -3
wpprobe --help 2>&1 | head -3
coercer -h 2>&1 | head -3
evil-winrm-py -h 2>&1 | head -3

# ─── AD/Intranet Tools ───
netexec --help 2>&1 | head -3
responder -h 2>&1 | head -3
certipy --version 2>&1 | head -1

# ─── Kali Native MCP ───
which kali-server-mcp && echo "mcp-kali-server OK"
which metasploitmcp && echo "metasploitmcp OK"
which hexstrike-ai && echo "hexstrike-ai OK"

# ─── Refresh Tool Index ───
bash kali/scripts/refresh-tool-index.sh

# ─── Check MCP service (if configured) ───
nc -z 127.0.0.1 5000 && echo "mcp-kali-server OK" || echo "mcp-kali-server offline"
nc -z 127.0.0.1 8085 && echo "metasploitmcp OK" || echo "metasploitmcp offline"
nc -z 127.0.0.1 13337 && echo "IDA MCP OK" || echo "IDA MCP offline"
nc -z 127.0.0.1 23816 && echo "anything-analyzer OK" || echo "anything-analyzer offline"
```

---

## 6. Frequently Asked Questions

### Q: What should I do if the radare2 version that comes with Kali is too old?

```bash
# Install the latest version using the official source
bash kali/scripts/bootstrap-reverse.sh r2
# The Kali version defaults to prioritizing apt installation/completion of radare2; if you need the latest version, you can follow the platform documentation to use GitHub/source
```

### Q: I am using Parrot OS / BlackArch, can I use it?

Sure. The script checks whether a command exists and is not tied to a specific distribution. It's just that the `apt` related automatic installation might need to be changed to `pacman` (BlackArch).

### Q: How to set up the Linux version of IDA Pro?

Install IDA on `/opt/idapro/`, then modify the `startScript` path of `idapro` in `kali/scripts/bootstrap-manifest.json`.

### Q: I want to use this system on both Windows and Kali at the same time

No problem. The `references/` directory is synchronized via Git, and `field-journal/` experience is shared on both sides. It's just that when running scripts, Windows uses `references/scripts/*.ps1`, and Kali uses `kali/scripts/*.sh`.

