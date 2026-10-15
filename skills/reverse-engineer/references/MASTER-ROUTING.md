# reverse-skill PRIMARY quick path

> `scripts/master-route.ps1` and `scripts/master-route.sh` must maintain the same routing contract; the platform only changes the execution entry, not the routing semantics.

## Executing Contracts

```text
1. Plan the route first, then take action
2. Output the PRIMARY path + a sentence of reasoning
3. case-init / scope.md (ops/scope-contract) — auth not granted, prohibited from accessing target ACT
4. Assign lead + specialist roles (ops/role-map)
5. Immediately open PRIMARY's README.md → ACTION REQUIRED
6. The tool path recognizes only the tool-index; if missing, bootstrap (manifest capability only)
7. Append timeline/work items to the process; conclusions follow Evidence → Finding → Path
8. Miss → Read routing.md for the full table or propose a new skill
```

### Windows

```powershell
powershell -File references\scripts\master-route.ps1 -Hint "<用户任务>"
# By default, write out the current project's work/master-route-<ts>/route-scope.md; when calling from other directories, explicitly specify the project root
powershell -File references\scripts\master-route.ps1 -Hint "<用户任务>" -ProjectRoot "C:\path\to\analysis-project"
powershell -File references\scripts\case-init.ps1 -Hint "<用户任务>" -CaseName "my-case"
# By default, the case is written to the current project's work/<case>/; -PackageRoot remains for compatibility, -ProjectRoot has higher priority
powershell -File references\scripts\case-init.ps1 -Hint "<用户任务>" -CaseName "my-case" -ProjectRoot "C:\path\to\analysis-project"
# One-time molding can ACT (Authorization + Target + Network File):
powershell -File references\scripts\case-init.ps1 -Hint "<任务>" -CaseName "my-case" -AuthGranted -TargetUrl "https://target/" -NetworkProfile authorized_target_only
# Local offline sample:
powershell -File references\scripts\case-init.ps1 -Hint "offline apk" -CaseName "my-sample" -Preset offline-sample -Sample ".\app.apk"
# Smoking: verify + script parsing + routing matrix (including Chinese Hint)
powershell -File references\scripts\smoke.ps1
# ACT pre-lightweight scope access control (exit 2 if not ready; -Force is a compatibility parameter, cannot bypass hard gate)
powershell -File references\scripts\case-guard.ps1 -CaseRoot work\my-case
# Evidence Added
powershell -File references\scripts\append-evidence.ps1 -CaseRoot work\my-case -Id E-001 -Title "..." -ReproCommand "..."
python3 references/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

### Linux / macOS / Kali

No need to install PowerShell for the core route/case process:

```bash
bash references/scripts/master-route.sh --hint "<用户任务>"
bash references/scripts/master-route.sh --hint "<用户任务>" --project-root "/path/to/analysis-project"
bash references/scripts/case-init.sh --hint "<用户任务>" --case-name "my-case"
bash references/scripts/case-init.sh --hint "<用户任务>" --case-name "my-case" --project-root "/path/to/analysis-project"
# Local offline sample:
bash references/scripts/case-init.sh --hint "offline apk" --case-name "my-sample" --preset offline-sample --sample ./app.apk
# ACT pre-lightweight scope access control (--force is a compatibility parameter, cannot bypass hard gate):
bash references/scripts/case-guard.sh --case-root work/my-sample
# Routing parity:
bash references/scripts/test-routing.sh
bash references/scripts/test-bootstrap-manifest.sh
python3 references/case-review/scripts/review_case.py work/<case> --verify-hashes --strict
```

## Combat Contract (ops)

| Document | Purpose |
|------|------|
| `ops/IDENTITY.md` | We are routing packets, not the Z3r0 platform |
| `ops/scope-contract.md` | Activation Threshold |
| `ops/evidence-finding-path.md` | Evidence Chain |
| `case-review/README.md` | Evidence Review and Report Handover |
| `ops/role-map.md` | Character → skill |
| `ops/timeline-workitem.md` | Timeline and Coverage |
| `ops/sandbox-profile.md` | Tool Comparison |
| `ops/skill-supply-chain.md` | Install the exterior skill/MCP security latch |
| `references/community-security-skills.md` | Community skill ecosystem (referenced but not merged) |
| `reverse-engineering/references/re-agent-workflow.md` | RE: triage → static → dynamic → synthesis |
| `pentest-tools/references/recon-pipeline.md` | Authorized Reconnaissance Pipeline + Evidence Gate |

## Priority (High → Low)

> The order must be consistent with the `config/routing.json` array of `priority`. Changing the route only modifies the JSON, then modify this table. `verify-routing-coherence.ps1` will parse this table.

| ID | Condition | PRIMARY |
|----|------|---------|
| **R4** | DSL VM / fireye / custom opcode VM | `reverse-engineering/dsl-vm-reverse/` |
| **R1** | APK / smali / jadx / apktool | `apk-reverse/` |
| **R2** | IPA / iOS / Objection / MobSF / mobile | `mobile-reverse/` |
| **R3** | JS Signature / Front-end Encryption / jshook / CDP | `js-reverse/` |
| **R30** | Browser Extension Reverse Engineering | `browser-extension-reverse/` |
| **R31** | macOS / Mach-O | `macos-reverse/` |
| **R33** | Go / Rust Binary | `go-rust-reverse/` |
| **R5** | .NET / dnSpy / de4dot / ConfuserEx | `dotnet-reverse/` |
| **R9** | Malicious Samples / YARA / Sandbox | `malware-analysis/` |
| **R21** | Protocol / Protobuf / PCAP Protocol | `protocol-reverse/` |
| **R22** | Ghidra / Open Source Decompiler | `ghidra-reverse/` |
| **R45** | Binary Ninja / Binja / HLIL / MLIL / Binary Ninja MCP | `binary-ninja-reverse/` |
| **R6** | IDA / Decompiling / Disassembly Deep Dive | `ida-reverse/` |
| **R7** | radare2 / r2 | `radare2/` |
| **R8** | Firmware / binwalk / IoT / EMBA | `firmware-pentest/` |
| **R34** | Hardware Debug Port / UART/JTAG | `hardware-security/` |
| **R28** | OT / ICS / Industrial Control | `ot-ics/` |
| **R17** | pwn / ROP / stack exploitation | `pwn-chain/` |
| **R16** | N-day / Patch Difference | `patch-diff-exploit/` |
| **R18** | EDR / Bypass antivirus / syscall | `edr-bypass-re/` |
| **R24** | Windows / AD / Kerberos / AD CS | `windows-ad/` |
| **R37** | Federal ID SAML/OIDC | `identity-federation/` |
| **R23** | Cloud / Containers / K8s | `cloud-k8s/` |
| **R35** | Database Security | `database-security/` |
| **R25** | Evidence Collection / Memory Dump / Timeline | `digital-forensics/` |
| **R44** | OSINT / Threat Intelligence / Public X IOC Supplement | `threat-intelligence/` |
| **R36** | Email / Phishing Analysis | `email-security/` |
| **R29** | Wi-Fi / Wireless Penetration | `wifi-wireless/` |
| **R38** | RF / SDR Research | `radio-sdr/` |
| **R32** | Thick Client Security | `thick-client/` |
| **R26** | Code Audit / SAST / Semgrep | `code-audit/` |
| **R27** | Threat Hunting / Detection Engineering / Blue Team | `threat-hunting/` |
| **R10** | Attack Chain / Red Team / Lateral / Full Penetration | `attack-chain/` |
| **R11** | Nmap / Nuclei / SQLMap / SRC / Penetration Tools | `pentest-tools/` |
| **R12** | API / GraphQL / BOLA / JWT Attack | `api-security/` |
| **R13** | SBOM / Trivy / Supply Chain | `supply-chain-security/` |
| **R14** | LLM / Prompt Injection / Agent Security | `llm-security/` |
| **R15** | bindiff / symbol migration / PDB | `binary-diff/` |
| **R19** | Browser/Desktop Automation | `browser-automation/` |
| **R40** | Case / Evidence Image Review | `case-review/` |
| **R20** | Report / writeup | `docs-generator/` |
| **R39** | Charts / Mermaid / Graphviz / PlantUML / Architecture Diagram | `diagram-generator/` |
| **R41** | CTF / AWD / Training Ground (single entry, do not expand 40 sub-skills) | `ctf-sandbox/` |
| **R0** | General reverse engineering / anti-debugging / OLLVM / unknown binary | `reverse-engineering/` |

Did not hit strong keyword → PRIMARY=`R0`, and prompt to open `routing.md` (ambiguity appendix, not the second router).

## Border

| Task | Process |
|------|------|
| Pure CTF Multi-Type Orchestration | PRIMARY `ctf-sandbox/` → sidecar `../CTF-Sandbox-Orchestrator/` |

## Reading Preface

```text
RULES.md → MASTER-ROUTING.md → PRIMARY README.md
→ (Optional) routing.md Three Axes / Field Journal
  → tool-index.md → bootstrap → ACT
```
