# Expert Role → Skill Mapping (No Multi-Agent Server)

> The character code name is inspired by the Z3r0 expert team; **the implementation method** is a reverse-skill routing and handover protocol, not process orchestration.

## Character List

| Code | Name (Localizable) | Responsibilities | PRIMARY / Tool Skill |
|------|------------------|------|----------------------|
| **lead** | Lead / Chief Commander | Break down tasks, define scope, stage gate, summarize reports | `attack-chain/` or current PRIMARY hub; finish → `docs-generator/` |
| **CIE** | Intelligence Collection | Asset Discovery, Exposure Surface, Relationships | `pentest-tools/` (recon); Browser → `browser-automation/`; Cloud Surface → `cloud-k8s/` |
| **cpe** | Penetration Testing | Scanning, Exploitation Verification, Impact Confirmation | `pentest-tools/`; API → `api-security/`; AD → `windows-ad/`; Wireless → `wifi-wireless/`; Library → `database-security/`; SSO → `identity-federation/`; OT → `ot-ics/` |
| **cre** | Reverse Engineering | Binary/Firmware/Mobile/Frontend Logic | `ida-reverse/` `ghidra-reverse/` `binary-ninja-reverse/` `radare2/` `apk-reverse/` `mobile-reverse/` `macos-reverse/` `js-reverse/` `browser-extension-reverse/` `dotnet-reverse/` `go-rust-reverse/` `firmware-pentest/` `hardware-security/` `malware-analysis/` `protocol-reverse/` `thick-client/` `reverse-engineering/` |
| **cae** | Code Audit | Source Code/Dependencies/Supply Chain | `code-audit/` + `supply-chain-security/` |
| **cbe** | Blue Team/Forensics | Hunting, Detection, IR Artifacts | `threat-hunting/` `digital-forensics/` |
| **cce** | Cryptography | Algorithm/Protocol/Key Misuse | `reverse-engineering` Pattern Document |
| **llm** | AI Security | Prompt/Agent | `llm-security/` |
| **doc** | Document Officer | Report/writeup/Diagram | `docs-generator/` + `diagram-generator/` |

## Lead Mandatory Agreement

```text
1. Output PRIMARY (master-route) + lead_role=lead
2. Write scope.md (ops/scope-contract)
3. Specify specialist_roles[] and handoff conditions
4. At the end of each stage: update the timeline and work items; decide whether to continue/switch roles/produce a report
5. Prohibit skipping scope and directly using CPE to scan production
```

## Handoff Rules

| From → To | Trigger | Deliverable |
|---------|------|--------|
| lead → cie | requires asset perspective | scope + known domain/IP |
| cie → cpe | Has live surface/service | assets list + port/URL |
| cpe → cre | Requires reverse verification/client-side logic | Sample path + suspicious points |
| cre → cpe | Restore protocol/key/checksum | Algorithm description + reproduction command |
| any → doc | Phase or task completed | Evidence/Finding/Path Draft |
| any → lead | blockage/overstepping/path change | timeline notes + reason for being blocked |

## How to Use a Single-Person Agent (Features)

No need to actually start 6 agents:

```text
Within the same session:
[lead] Planning
[cie] Execute reconnaissance skill
[cpe] Switch pentest-tools
  …
Use character prefix tags when outputting, to facilitate timeline retrieval:
  [cpe] nuclei high findings → E-003
```

## Relationship with master-route

- `master-route` set **PRIMARY skill**
- `role-map` Determine **who is responsible at the current stage** (can be written in scope.md)
- Multi-stage tasks PRIMARY are usually `attack-chain/`, redistributed by the lead

## MUST NOT

- Do not assume the existence of a Z3r0 session API
- Do not initiate additional scans of unauthorized targets for the character