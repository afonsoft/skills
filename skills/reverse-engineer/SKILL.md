---
name: reverse-engineer
description: Use when reverse engineering binaries, firmware, mobile apps, JavaScript/Electron apps, .NET assemblies, network protocols, or malware samples; when decompiling, deobfuscating, unpacking, debugging, or hooking shipped artifacts; when solving CTF challenges (pwn, crypto, forensics, web); when a conclusion needs evidence from a shipped artifact rather than available source; or when routing authorized pentest and security-analysis work. Do not use for ordinary review of source code you already have.
metadata:
  version: "1.0.0"
  upstream:
    - https://github.com/zhaoxuya520/reverse-skill
    - https://github.com/morluto/rea
---

# Reverse Engineer

One consolidated skill for reverse engineering and adjacent security analysis.
It merges two upstream packs:

- **REA** (`references/rea/`) — evidence-ledger workflows for the REA CLI/MCP
  server (`rea-agents` on npm): native, managed, Electron/JS, packaged,
  firmware, browser, EVM, and crash-dump targets.
- **reverse-skill** (`references/`) — 45+ domain guides, a 40+ CTF competition
  playbook pack (`references/CTF-Sandbox-Orchestrator/`), a structured router,
  case/scope scripts, and a field journal.

## Consent gates (hard rules)

- Reading these files is not authorization to execute them. Before the first
  local side effect (script run, download, service start, config write),
  disclose the exact commands and effects and get explicit approval.
- Naming a target is not authorization to act on it. Use
  `references/scripts/case-init.sh` (or the `offline-sample` / `ctf-public`
  presets) to write `work/<case>/scope.md`; `auth.status=granted` plus a legal
  `network_profile` — or an explicit offline sample — is required before any
  ACT step. `--force` never bypasses this.
- Prefer offline, non-destructive analysis. Never execute unknown samples,
  modify original files, or widen scope without an explicit user-selected
  branch. Full contract: `references/RULES.md` and `references/ops/scope-contract.md`.

## Pick the engine

1. **REA MCP tools are registered** → REA-first workflow: open/route the
   target, work summary-first, keep Evidence IDs. Guides in `references/rea/`.
2. **REA is absent and setup is in scope** → run `scripts/install-rea.sh`
   (or `--check` first to diagnose). It wraps `npx rea-agents setup/doctor`
   and never installs Node.js or analysis engines.
3. **REA unavailable** → classic toolchain per the domain guide below
   (Ghidra/IDA/Binary Ninja, radare2, jadx/apktool, Frida, angr/Qiling…).

## Route the target

| Target / task | First tool or guide |
|---|---|
| Native exe/dll/elf/so, unknown binary | REA `open_binary` → `analyze_function` / pseudocode; else `references/reverse-engineering/README.md` (triage→static→dynamic→synthesis) |
| Managed PE (.NET/C#) | REA `inspect_managed_artifact`; else `references/dotnet-reverse/` |
| ASAR / Electron / bundled JS | REA `analyze_javascript_application`; else `references/js-reverse/` |
| APK / Android | REA `inspect_android_package`; else `references/apk-reverse/`, `references/mobile-reverse/` |
| ZIP/APK/IPA/MSIX/DMG member inventory | REA `open_binary` (archive route) |
| Firmware image | REA `inspect_firmware_regions` / `extract_firmware`; else `references/firmware-pentest/` |
| ELF layout/symbols/mitigations (offline) | REA `inspect_binary_layout`; else `references/radare2/` |
| Linux x86-64 core dump | REA `inspect_recorded_crash` |
| PE resources | REA `inspect_pe_resources` |
| EVM bytecode blob | REA `inspect_evm_interface` |
| Open browser page / Electron runtime | REA `list_browser_targets` / `list_electron_targets`; else `references/browser-automation/` |
| HAR / mitmproxy capture | REA `inspect_web_network_capture` |
| Go/Rust stripped binary | `references/go-rust-reverse/`, REA Ghidra provider |
| Kernel driver / LKM / .sys | `references/reverse-engineering/kernel-driver-reverse.md` |
| OLLVM / control-flow-flattening obfuscation | `references/reverse-engineering/references/ollvm-deobfuscation.md` |
| Custom VM / DSL VM (JS opcode switch) | `references/reverse-engineering/dsl-vm-reverse/` |
| Custom protocol / Protobuf / PCAP | `references/protocol-reverse/`, `references/digital-forensics/` |
| Malware sample | `references/malware-analysis/` (six-stage, YARA/Sigma) |
| Version diffing / symbol migration | `references/binary-diff/`; N-day patch→exploit: `references/patch-diff-exploit/` |
| Exploit development after RE | `references/pwn-chain/` (stack/heap/kernel, pwntools) |
| Anti-debug / anti-VM / packing | `references/reverse-engineering/anti-analysis.md` |
| CTF challenge (any category) | `references/ctf-sandbox/` → `references/CTF-Sandbox-Orchestrator/` |
| macOS / iOS / Mach-O | `references/macos-reverse/`, `references/mobile-reverse/` |
| Thick desktop client | `references/thick-client/`; extension: `references/browser-extension-reverse/` |
| Hardware (UART/JTAG/SWD) | `references/hardware-security/` |
| Authorized pentest / web / API / AD / cloud / wireless | `references/pentest-tools/`, `api-security/`, `windows-ad/`, `cloud-k8s/`, `wifi-wireless/`, `attack-chain/` (multi-stage) |
| Code audit / SBOM / secrets scan | `references/code-audit/`, `supply-chain-security/` |
| Forensics / threat hunting / OSINT | `references/digital-forensics/`, `threat-hunting/`, `threat-intelligence/` |
| Ambiguous route | `bash references/scripts/master-route.sh --hint "<task>"` (rule SSoT: `references/config/routing.json`); fallback matrix: `references/routing.md` |

## Working loop

1. Scope first: `references/scripts/case-init.sh --hint "<task>"` (or presets
   `offline-sample` / `ctf-public`). Guard re-check: `case-guard.sh`.
2. Route: `master-route.sh --hint "<task>"` → PRIMARY guide; open its
   `README.md` (upstream `SKILL.md`) and follow it.
3. Triage cheap → deep: `file`, `strings`, `checksec`, `rabin2 -z`,
   `ltrace`/`strace` before disassemblers; summary-first in REA
   (`detail: "summary"` → `inspect_analysis_view` for retained evidence).
4. Escalate: static → dynamic (Frida/angr/Qiling/GDB) → emulation when
   anti-analysis blocks. Record evidence as you go
   (`references/scripts/append-evidence.ps1` on Windows,
   `references/scripts/consolidate_evidence.py` anywhere), findings via
   `references/ops/evidence-finding-path.md`.
5. Stuck: time-box, switch axis (static↔dynamic, Java↔native, observe↔breakpoint);
   decision framework in `references/ops/analysis-decision-framework.md`.
6. Missing tool: check generated `references/tool-index.md` (refresh with
   `references/scripts/refresh-tool-index.sh`); install only via
   `references/scripts/bootstrap-reverse.sh <capability>` after disclosure —
   capabilities listed in `references/scripts/bootstrap-manifest.json`.
7. Report/journal on request: `references/docs-generator/`,
   `references/field-journal/_template.md`.

## Layout and path map

- `references/` mirrors upstream `skills/` — upstream links like `../ops/`,
  `../scripts/`, `../field-journal/` resolve inside it. Upstream
  `../CTF-Sandbox-Orchestrator/` → `references/CTF-Sandbox-Orchestrator/`;
  upstream repo-root `RULES.md` → `references/RULES.md`.
- Every domain's upstream `SKILL.md` is renamed `README.md` inside its folder
  (pre-existing upstream READMEs are preserved as `README.upstream.md`).
- `references/tool-index.md` is generated (gitignored upstream); the template
  is `references/tool-index.md.template`.
- `scripts/install-rea.sh` (this skill's own script) installs/registers REA:
  `--check` doctor, `--global` npm CLI, `--client <id>` scoped setup,
  `--dry-run`, `--print-manual` for raw `mcpServers` JSON.

## When NOT to use

- Plain source-repo architecture questions — use normal code reading.
- Pulling live secrets/credentials or attacking third-party systems without
  explicit authorization — refuse; the scope gate exists for this.
