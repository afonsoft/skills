# 2026-07-20 Windows reverse tool chain complete bootstrap

## Scene classification

Others/Toolchains and Environments

## Goal Overview

Install and verify reverse engineering toolchain covering native, managed, Android, firmware, protocols, forensics, browser and MCP on Windows 24H2 hosts.

## Complete execution link

1. Read the shared tool-index and reuse the installed tools first.
2. Run the universal PATH probe and fill in the gaps with static, dynamic, firmware, and protocol tools.
3. Extract URL and SHA-256 from trusted list for large files, use aria2 direct download with IPv6 disabled.
4. Establish `{user_profile}\Tools\reverse-bin` unified entrance for portable tools.
5. Build and register Ghidra, IDA, JS, browser traffic, and Burp MCP.
6. Use the real PE/APK/.NET/PYC/WASM/ firmware fixture verification tool, not just run the version command.
7. Refresh the shared tool-index and output the formal installation report and flow chart.

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|---|---|---|---|
| winget large file download has no progress for a long time | Delivery Optimization and default IPv6 path are unstable | Get the official URL/hash from winget metadata, use `aria2c --disable-ipv6=true` | High |
| anything-analyzer SQLite ABI mismatch | Normal `pnpm rebuild better-sqlite3` is built into Node ABI, while Electron requires Electron ABI | Using project's `pnpm run postinstall` | Medium |
| WSL service 1053, system function does not exist | Windows image cuts out WSL, VirtualMachinePlatform, Hyper-V function package | Keep the real Linux command gap, use Windows native tools and QEMU full-system instead | Medium |
| Dr. Memory version is normal but injection crashes | Windows 11 24H2 build 26100 compatibility issues | Record upstream issue, use AppVerifier/PageHeap/UMDH/CDB/Frida | Medium |
| Codex TOML cannot be loaded | The historical project path is garbled, causing missing quotes, invalid escapes and duplicate keys | Only fix the header syntax and verify `codex mcp list` | Low |
| No tools after Burp MCP registration | Burp GUI has not loaded extensions, 9876 is not listening | Build fixed JAR, record GUI loading conditions | Low |

## Toolchain discovery

- The universal probe ends up being 57/64; all 7 notches belong to Linux user mode or kernel capabilities.
- Windows SDK Debugging Tools are an important addition when Dr. Memory is incompatible: CDB, GFlags, UMDH, NTSD, KD.
- MCP should verify "stdio/HTTP initialization" and "GUI backend online" respectively; successful registration does not mean that the tool can be called.
- IDA Free can be used for local interactive analysis but is not a replacement for the legitimate IDA Pro idalib/Hex-Rays MCP backend.

## Key code/command

```powershell
python "{skill_root}\scripts\toolchain_probe.py" --format markdown
aria2c --disable-ipv6=true --max-connection-per-server=16 --split=16 "{official_url}"
powershell -NoProfile -ExecutionPolicy Bypass -File "{package_root}\references\scripts\refresh-tool-index.ps1"
codex mcp list
cdb -g -G C:\Windows\System32\where.exe cmd
```

## Suggestions for improving this package

- Incorporate Dr. Memory, CDB, GFlags, UMDH, DTC, SquashFS, flashrom and Frida Trace into the Windows tool-index catalog.
- The capability status should distinguish `installed`, `bridge-ready`, `backend-online`, `runtime-verified`.
- Add explicit Linux-only notch description for the cut version of Windows and do not generate pseudo-wrappers with the same name.

## Reusable patterns/script snippets

Fixed mode for large file downloads: check version, URL and SHA-256 from official package metadata before using aria2 to disable IPv6 downloads; verify both hash and Authenticode (if applicable) after downloading.

## Evolution action

- [ ] Updated routing matrix
- [x] Updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation
- [x] Added pitfalls record
- [ ] No update required

## Environment information

- OS: Windows NT build 26100.4946，24H2，x64
- Tool version: For details, please refer to the official installation report and tool-index of this machine.
- Target platform/version: Windows native tool chain, and covers Android, Linux/ELF static analysis and full-system simulation

## Desensitization requirements

This record does not contain the real target, credentials, token, internal URL, or username; paths use placeholders.

## Index synchronization

Updated statistics and "Toolchain & Environment" categories for `_index.md`.

---
<!-- [Community Contribution] Local logging completed. -->