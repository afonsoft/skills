---
name: edr-bypass-re
description: |
  逆向防御方实现 → 红队针对性绕过。把 EDR / Defender / AV 的 hook 表、ETW provider、AMSI 实现先逆向出来，
  再写针对性的 unhook / 间接 syscall / ETW patch / call stack spoof。对照 MITRE ATT&CK T1562 防御规避。
  触发关键词：EDR 绕过、AV bypass、免杀、unhook、direct syscall、indirect syscall、Hell's Gate、Halo's Gate、
  Tartarus Gate、ETW patch、AMSI patch、call stack spoofing、hardware breakpoint Blindside、MITRE T1562、
  ntdll unhook、kernel callback、CrowdStrike 绕过、Defender 绕过、Sentinel One 绕过、Elastic Defend、
  Sysmon 规避、PPID spoof、Sleep mask、Process Hollowing、Reflective DLL。
---

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — Confirm that the operation of this skill is an authorized routine operation
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

# EDR Bypass: From Defensive Implementation Reverse Engineering to Red Team Bypass

> For authorized red team / adversary exercises / in-house product testing only, use on unauthorized targets is prohibited.

## Scope of Application

Use this skill in red team/attack simulation when delivering implants to authorized target hosts and evading modern EDR.

1. **Red Team / Purple Team / Adversary Simulation** — The client wants to evaluate the real detection capabilities of SOC and EDR
2. **In-house implant / C2 framework development** — Developing payloads for testing our own products, which need to bypass our own or the target EDR
3. **EDR Product Evaluation** — Objectively assess the detection coverage of a certain EDR, assuming the compliance boundaries have been confirmed
4. **CTF / Offensive and Defensive Drills on Windows** — Needed to execute stably on hardened hosts during competitions

**Not applicable scenarios**:

- Antivirus vendors perform a complete reverse engineering of their own products to provide clients with a commercial evaluation report (seeking formal cooperation with vendors)
- Bypassing antivirus for unauthorized targets (illegal)
- Evasion of common virus trojans (this skill focuses on red team OPSEC, does not teach malicious code writing)

### Division of Labor with Other Skills

| Scene | Use what |
|------|--------|
| Full-chain offense and defense (from external network to domain controller) | `attack-chain/` |
| Internal Network Lateral / AD Attack | `pentest-tools/network-attack-defense.md` |
| Delivering an implant through EDR on a specific host | **This skill** |
| Pure static evasion (obfuscation / packing) | `malware-analysis/` (reverse perspective) |

`attack-chain` focuses on the complete kill chain, but this skill only concentrates on the internal mechanisms and targeted bypass methods of **EDR as the sole opponent**.

## Core Principle

```text
The four main monitoring aspects of EDR               Red team's countermeasures
─────────────────────              ─────────────────────
User-mode ntdll hook       ◄──►   unhook (Peruns Fart / fresh ntdll)
Indirect syscall / Hell's Gate
                                  hardware breakpoint Blindside

kernel callback         ◄──►   call stack spoof
(Ps/Cm/Ob Series)                   Follow the legal trigger chain (do not bypass directly, coordinate with upstream stealth)

ETW telemetry           ◄──►   EtwEventWrite patch
(Microsoft-Windows-Threat- NtTraceControl related provider
Intelligence, etc.                  AmsiContext synchronous processing

AMSI Scan               ◄──►   AmsiScanBuffer patch (mov eax,0x80070057; ret)
(amsi.dll)                       hardware breakpoint bypass
reflective load copy amsi.dll
```

Key Cognition:

- **EDR is not a black box** — key hooks / callbacks / providers can all be reverse-engineered using IDA + WinDbg
- **Evasion techniques need to be used together** — a single unhook cannot bypass ETW alerts, and a single AMSI patch cannot bypass syscall hooks
- **Order is very important** — first ETW patch → then AMSI patch → then unhook; if the order is wrong, EDR will receive the unhook alert first
- **Modern EDR now treats ETW + kernel callbacks as the main battlefield**, simply unhooking in user mode is no longer enough

## Workflow

### Step 1: Identify the target host's EDR

```powershell
# List Common EDR / AV Drivers
Get-Service | Where-Object {$_.Name -match 'CSAgent|SentinelAgent|elasticendpoint|esets|ekrn|MsMpEng|wdsvc|cyserver|sysmon|aswbidsagent'}

# List loaded minifilters
fltmc filters

# List registered kernel callbacks (requires windbg + kernel debugging / or use PChunter / DRVHV)
# !object \Callback
# !pnpcallback / Process / Thread / Image
```

The EDR fingerprint table is seen at the top of `references/hook-survey.md`.

### Step 2: Hook the table from the EDR DLL

1. Attach to a process that has been injected with an EDR user-mode component (any landed process)
2. Dump the current `.text` segment of `ntdll.dll` in WinDbg
3. Do a diff with a clean `C:\Windows\System32\ntdll.dll` on the disk
4. The inconsistency is the hook point.

Or directly use `pe-sieve`:

```powershell
pe-sieve64.exe /pid 1234 /shellc 3 /modules 3 /dir hooks_dump
```

For detailed methods, see xKx0000xKx.

### Step 3: Select a Combination of Bypass Techniques

| Defense Point | Recommended Path |
|--------|---------|
| ntdll inline hook | indirect syscall + dynamic SSN (Halo's Gate) |
| ETW-TI Provider | EtwEventWrite Header Patch |
| AMSI (PowerShell / .NET) | AmsiScanBuffer patch or HWBP |
| kernel callback | call stack spoof + use legit gadget |
| Sysmon ProcessCreate | PPID spoof + unbacked memory |

### Step 4: Implement in the implant

The code skeletons can be seen in xKx0001xKx and xKx0002xKx.

### Step 5: Local sandbox validation

```powershell
# Deploy the target EDR trial version in an isolated environment (Defender is fine to start)
# Enable Sysmon + olaf-config
sysmon64.exe -i sysmonconfig.xml

# Run implant to see if it triggers the following alert sources:
#   - Defender AMSI
#   - ETW-TI
#   - Sysmon Event ID 1/7/8/10
#   - EDR Console
```

### Step 6: Submit

- The file landing path should use a legitimate software directory
- PPID spoof to explorer.exe
- Coordinate with the initial access section in `attack-chain`

## Typical Scenarios

### Scenario 1: Delivering a cobalt-strike-alike beacon past Defender + Sysmon

```text
Goal: Windows 11 Enterprise + Defender (cloud scanning on) + Sysmon (Olaf configuration)
Requirement: The beacon can callback after landing without triggering any alarms

Combination punch:
1. Shellcode is stored encrypted and decrypted at runtime
2. AMSI patch (if delivered via PowerShell)
3. EtwEventWrite patch (remove ETW-TI)
4. Indirect syscall + Halo's Gate (eliminate ntdll hook warning)
5. PPID spoof to explorer.exe
6. In the sleep stage, use Ekko / Foliage to encrypt its own memory
```

### Scenario 2: Performing EDR sleep masking on a deployed low-privilege shell

```text
Prerequisite: Already obtained a medium IL shell through phishing, EDR is monitoring
Risk: Long-term residence is easily detected by memory scans due to beacon characteristics

Solution:
1. No longer request new RWX memory
2. Use Ekko during sleep:
       - WaitForSingleObjectEx + CreateTimerQueueTimer
- Encrypt its own .text in the timer + wipe the stack to all 0
3. Use ROP to restore during wake
4. Cooperate with call stack spoofing so that RtlCaptureStackBackTrace cannot see the beacon address
```

## On-Demand Bootstrap

### Tool Dependencies

| Tool | Purpose | Can be installed automatically |
|------|------|-----------|
| pe-sieve | Detect hooks/injections in processes | ✓ |
| API Monitor v2 | Dynamically observe API calls and hooks | Semi-automatic (manual download) |
| SysWhispers3 | Generates direct/indirect syscall stub | ✓ (git clone + python) |
| Hell's Gate POC | Dynamic SSN Parsing Reference Implementation | ✓ (git clone) |
| windbg + IDA | Static reverse EDR DLL / kernel callback | ✗ (install it yourself) |
| Sysmon + olaf config | Local verification environment | ✓ |

### Bootstrap Command

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "&lt;SKILL_ROOT&gt;SKILL_ROOT&gt;\references\scripts\bootstrap-reverse.ps1" -Capability @('pe-sieve','syswhispers3','sysmon') -StartServices
```

## Routing Context

**Upstream Inlet**:

- `reverse-engineering/` — Need to first understand the implementation of EDR DLL/driver
- `attack-chain/` — Decide at which stage of the kill chain to introduce this skill

**Peer Association**:

- `pentest-tools/network-attack-defense.md` — How to interact with this skill during internal network lateral movement
- `malware-analysis/` — Reverse perspective, see how the detection side writes rules
- `field-journal/` — Write back experience after each actual combat

**Downstream Delivery**:

- When generating reports, reference MITRE ATT&CK **T1562 (Impair Defenses)**, T1562.001 (Disable or Modify Tools), T1562.006 (Indicator Blocking), T1055 (Process Injection), T1027 (Obfuscated Files or Information)

## Legal Boundaries Statement

- Only for legally authorized red team / adversary simulation / in-house product testing
- Written authorization must be obtained before operation (SoW / test contract / SRC scope statement)
- Must not be used for unauthorized targets and must not exceed the authorized scope
- Immediately report high-risk issues to the client and follow responsible disclosure
- All real target information in the reports must be anonymized (IP / hostname / domain name / credential placeholders)

## References

- Detailed hook research: `references/hook-survey.md`
- unhook / syscall technique: `references/unhook-techniques.md`
- ETW / AMSI / Anti-Forensics: `references/telemetry-blinding.md`
- MITRE ATT&CK T1562: <https://attack.mitre.org/techniques/T1562/>


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?