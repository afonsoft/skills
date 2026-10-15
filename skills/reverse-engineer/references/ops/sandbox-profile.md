# Optional sandbox tool Profile (compare bootstrap-manifest)

> Z3r0 has a complete set of default imaging tools; reverse-skill **does not bundle images**. Use this table for "coverage comparison" and optional Docker recommendations.

## reverse-skill has the ability to automatically bootstrap

Source: `references/scripts/bootstrap-manifest.json` (subject to file):

| Capabilities | Typical scenarios |
|------|----------|
| jadx / apktool / adb / frida / frida-ps | Android |
| r2/rabin2 | Binary CLI |
| idalib-mcp / idapro | IDA MCP |
| jeb-pro | Commercial Android/ARM decompiler (manual licensed installation) |
| jshookmcp / reqable-mcp / anything-analyzer / agent-browser | Web/JS/ packet capture/browser |
| ghidra-mcp | Ghidra |
| nmap / seclists / proxycat / burpsuite-mcp / pentestswarm | Penetration |
| binwalk/pwntools/yara | firmware/pwn/malicious |

```powershell
powershell -File references\scripts\bootstrap-reverse.ps1 -Capability @('jadx','nmap','yara') -StartServices
powershell -File references\scripts\refresh-tool-index.ps1
```

## Z3r0 sandbox is common but this package manifest is not automatically installed.

| Tools | reverse-skill strategy |
|------|-------------------|
| subfinder / amass / httpx / ffuf / nuclei / sqlmap | documentation installation / Kali scripts / external MCP; **Don't pretend bootstrap already exists** |
| Ghidra GUI full version | ghidra-mcp capabilities + manual plug-in steps |
| gdb/pwndbg | Platform documentation manually; pwntools can bootstrap |
| hydra/hashcat | Manual or Kali |
| JEB Pro | Users install manually after holding a license; third-party MCP bridge must first complete supply chain review |
| Reqable desktop client | User manual installation; `reqable-mcp` only registers the official fixed version of the MCP runtime |
| SecLists | seclists capabilities |

## Recommended "Lightweight Docker Combat" profile (optional, not dependent)

Only if the user **himself** has Docker and is authorized to lab:

```text
Minimum: nmap + nuclei + sqlmap container or pentestMCP class image
Mobile: jadx + apktool + frida host
Reverse: host IDA/r2 + tool-index
```

**MUST NOT** Requires user to install Z3r0 to use reverse-skill.

## network_profile linkage

Scanning within the sandbox is still subject to `network_profile` for case `scope.md`:

- `offline` → It is not recommended to scan the container externally
- `authorized_target_only` → Containers can only be opened in_scope