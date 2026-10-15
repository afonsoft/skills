# Coverage Map of This Package Domain (Depth-First)

> Compared to the community's 'hundreds of micro skills': we cover the main battlefield with **a few deep skills + routing + ops**.
> Date: 2026-07-18

## Domain → Package Entry

| Domain | PRIMARY / Module | Remarks |
|----|----------------|------|
| Mobile Android | `apk-reverse/` `mobile-reverse/` | |
| Mobile iOS | `mobile-reverse/` | |
| Binary Deep Dive | `ida-reverse/` `radare2/` `ghidra-reverse/` | Ghidra = Open Source Main Path |
| General RE / Anti-Debugging / OLLVM | `reverse-engineering/` | |
| .NET | `dotnet-reverse/` | |
| Frontend JS / Signature | `js-reverse/` | |
| Browser Extension | `browser-extension-reverse/` | |
| DSL/Risk Control VM | `reverse-engineering/dsl-vm-reverse/` | |
| Protocol / PCAP Protocol | `protocol-reverse/` | |
| Firmware IoT | `firmware-pentest/` | |
| Malicious Sample | `malware-analysis/` | |
| Digital Forensics / IR | `digital-forensics/` | |
| Threat Hunting / Blue Team | `threat-hunting/` | |
| Penetration Tool | `pentest-tools/` (+ src-hunter) | |
| Windows / AD | `windows-ad/` | |
| Cloud / Container / K8s | `cloud-k8s/` | |
| Code Audit / SAST | `code-audit/` | |
| Wi-Fi / Wireless | `wifi-wireless/` | |
| OT / ICS | `ot-ics/` | Passive priority; writing to registers is disabled by default |
| macOS | `macos-reverse/` | iOS still uses mobile-reverse |
| Binary Ninja | `binary-ninja-reverse/` | Commercial GUI/Python API; Community MCP only explicitly enabled and binds to localhost by default |
| Thick Client | `thick-client/` | |
| Go / Rust Binary | `go-rust-reverse/` | |
| Hardware Debug Port | `hardware-security/` | Handover firmware-pentest |
| Database | `database-security/` | |
| Email / Phishing | `email-security/` | |
| Federated Identity SSO | `identity-federation/` | Complementary to api-security JWT |
| RF / SDR | `radio-sdr/` | Default receive only; not Wi-Fi |
| Multi-stage Attack | `attack-chain/` | |
| Pwn | `pwn-chain/` | |
| N-day patch | `patch-diff-exploit/` | |
| EDR Research | `edr-bypass-re/` | |
| API | `api-security/` | |
| Supply Chain SBOM | `supply-chain-security/` | |
| LLM/Agent | `llm-security/` | + `ops/skill-supply-chain.md` |
| Browser Automation | `browser-automation/` | |
| Report/Chart | `docs-generator/` `diagram-generator/` | |
| Symbol Migration | `binary-diff/` | |
| Combat Contract | `ops/` | **Features** |
| CTF Orchestration | `CTF-Sandbox-Orchestrator/` | |
| Cryptography Pattern Recognition | `reverse-engineering` Pattern Document | Shared with Reverse Engineering Tasks, No Separate Extension Package Maintained |

## Clearly define the domains that will not integrate the entire library (policy when the route is not matched)

| Domain | Strategy |
|----|------|
| Pure game cheat development | Not as a product direction; Unity samples can still go `reverse-engineering` + seed-014 |
| Deep automotive/aerospace certification level | Can be externally linked; this package only has RF/OT entry level |
| Pure GRC/Compliance Long Text | Does not replace professional GRC tools; can be used to write report template references |
| 800+ ATT&CK micro skills | Use this table + ATT&CK optional tags (Finding field) |

## With MITRE ATT&CK (Optional)

Finding templates allow `optional_attack: Txxxx` (see `ops/evidence-finding-path.md`), **not required** to have a complete ATT&CK engine.