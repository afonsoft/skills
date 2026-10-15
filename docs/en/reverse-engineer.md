# Reverse Engineer

One consolidated skill for reverse engineering and adjacent security analysis — merges the REA evidence-ledger tooling with the `reverse-skill` domain playbook pack.

## 🎯 Purpose

Give the agent a single entry point for any shipped-artifact question: binaries, firmware, mobile apps, JavaScript/Electron bundles, .NET assemblies, network protocols, malware samples, CTF challenges, and authorized pentest/security-analysis tasks. It routes each target to the right engine (REA CLI/MCP first when available, classic toolchains otherwise) and enforces upstream consent and scope gates before any action on a target.

## 🛠️ How it Works

- **Hub skill**: `skills/reverse-engineer/SKILL.md` is a compact router. All heavy material lives under `skills/reverse-engineer/references/` — 40+ domain guides, a CTF competition pack, REA guides, scripts, configs, and ops docs.
- **REA-first routing**: when the `rea` CLI or `rea-agents` MCP tools are present, artifact inspection goes through REA (`open_binary`, `analyze_javascript_application`, `inspect_android_package`, `inspect_firmware_regions`, `inspect_managed_artifact`, `list_browser_targets`, …) so every claim keeps an Evidence ID. When REA is absent, the domain guides drive Ghidra/IDA/Binary Ninja, radare2, jadx/apktool, Frida, angr/Qiling, and friends.
- **Scope gate**: `references/scripts/case-init.sh --hint "<task>"` writes `work/<case>/scope.md`. ACT on a target requires `auth.status=granted` plus a legal `network_profile` or an explicit offline sample — `--force` never bypasses it.
- **Deterministic router**: `references/scripts/master-route.sh --hint "<task>"` maps task hints to a PRIMARY guide via `references/config/routing.json` (single source of truth; `references/routing.md` is the human matrix).
- **Tool readiness**: `references/scripts/check-tools.sh <module>` reports required/optional tool presence per module (read-only, never installs) with bootstrap hints pointing at `references/scripts/bootstrap-manifest.json`.

## 🚀 Usage

Typical flows:

1. **Artifact to understand** → run `references/scripts/case-init.sh --hint "analyze app.apk offline"` → `master-route.sh --hint "apk jadx smali"` → open the PRIMARY guide.
2. **REA present** → open/route the target with REA tools, summary-first, keep Evidence IDs, close with `close_binary`.
3. **Missing tools** → `check-tools.sh <module>` shows what is missing; install only after disclosure via `references/scripts/bootstrap-reverse.sh <capability>`.

Auxiliary scripts:

- `scripts/install-rea.sh` — installs/registers REA (`--check`, `--global`, `--client <id>`, `--dry-run`, `--print-manual`). Wraps `npx rea-agents` official commands; never installs Node.js or analysis engines.
- `references/scripts/check-tools.sh` — per-module tool readiness (`--all`, `--list`, `--json`).
- `references/scripts/master-route.sh` / `case-init.sh` / `case-guard.sh` — routing and scope.
- `references/scripts/refresh-tool-index.sh` — regenerates `tool-index.md` from PATH.

## 📚 Reference map (selected)

| Area | Path |
|---|---|
| Core RE workflow | `references/reverse-engineering/` |
| APK / Android / mobile | `references/apk-reverse/`, `references/mobile-reverse/` |
| JavaScript / Electron | `references/js-reverse/` |
| .NET | `references/dotnet-reverse/` |
| IDA / Ghidra / Binary Ninja / radare2 | `references/ida-reverse/`, `references/ghidra-reverse/`, `references/binary-ninja-reverse/`, `references/radare2/` |
| Firmware / hardware / radio | `references/firmware-pentest/`, `references/hardware-security/`, `references/radio-sdr/` |
| Malware / forensics / threat intel | `references/malware-analysis/`, `references/digital-forensics/`, `references/threat-hunting/` |
| Protocols / PCAP | `references/protocol-reverse/` |
| Exploit dev / patch diffing | `references/pwn-chain/`, `references/binary-diff/`, `references/patch-diff-exploit/` |
| CTF pack | `references/ctf-sandbox/`, `references/CTF-Sandbox-Orchestrator/` |
| Pentest / web / AD / cloud | `references/pentest-tools/`, `references/api-security/`, `references/windows-ad/`, `references/cloud-k8s/` |
| REA guides | `references/rea/` |

## ⚠️ Consent gates

- Reading skill files is not authorization to execute them; first local side effect requires explicit approval.
- Target authorization is separate: `scope.md` with `auth.status=granted` before any ACT step.
- Never execute unknown samples, modify originals, or widen scope silently.
- Do not claim runtime evidence from static analysis; keep Evidence IDs and confidence boundaries.

## 🔗 Correlation

- **`diagnose`**: for ordinary bugs in code you have source for — reverse-engineer is for shipped artifacts, not source review.
- **`code-review-and-quality` / `quality-test-implementation`**: after RE findings feed back into a codebase fix.
- **`orchestrator`**: long multi-target engagements can be tracked as issues/epics by the orchestrator.
