---
name: edr-bypass-re
description: |
  Reverse-engineer how EDR / Defender / AV products instrument a host —
  hook placement, ETW providers, AMSI integration, kernel callbacks — to
  understand the detection surface during authorized engagements or
  defensive-product evaluation. Anchored to MITRE ATT&CK T1562.
  Trigger keywords: EDR internals, AV telemetry, unhook analysis,
  syscall monitoring, AMSI, ETW, kernel callback, MITRE T1562,
  detection coverage assessment, EDR product evaluation.
---

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

# EDR Internals Analysis: Mapping the Detection Surface

> For authorized security assessments, purple-team detection-gap reviews, and
> defensive-product evaluation only. This module **analyzes** how EDR products
> instrument a system — it does not produce, ship, or deliver evasive
> implants or payloads.

## Scope of Application

1. **Detection coverage assessment** — The client wants to know which
   telemetry its EDR actually produces (reverse its components, map hooks
   and providers, then document gaps for the SOC).
2. **Purple-team exercise support** — explain *why* an ATT&CK technique did
   or did not alert, traced to the specific hook/provider that saw it.
3. **EDR product evaluation** — objectively measure detection coverage of a
   product inside a licensed lab.
4. **Malware-analysis support** — classify a sample's anti-analysis behavior
   by which detection layer it tries to defeat.

**Not applicable**:

- Building or delivering code that disables/avoids EDR on any host
- Evasion of commodity malware (out of scope)
- Any target without written authorization

## Core Principle

```text
EDR detection layers                What an analyst reverse-engineers
─────────────────────              ─────────────────────────────
User-mode ntdll hook        ◄──►   Which APIs are patched, by which DLL
kernel callback             ◄──►   Registered process/thread/image callbacks
(Ps/Cm/Ob series)
ETW telemetry               ◄──►   Which providers exist (ETW-TI, AMSI,
(Microsoft-Windows-                CLR, Kernel-Process) and who consumes them
Threat-Intelligence…)
AMSI scan                   ◄──►   How amsi.dll integrates with Defender/
(amsi.dll)                         third-party engines
```

Key points:

- **EDR is not a black box** — hooks, callbacks, and providers can be
  enumerated with IDA + WinDbg and documented precisely.
- **Detection gaps are layered** — a product that hooks user-mode APIs may
  still rely on ETW and kernel callbacks; document each layer separately.
- **Order of visibility matters for reporting** — knowing which layer fires
  first tells the SOC which alert to expect for a given technique.

## Workflow

### Step 1: Identify the host's EDR presence

Read-only enumeration on an analysis host you are authorized to inspect:

```powershell
# List common EDR / AV services and drivers
Get-Service | Where-Object {$_.Name -match 'CSAgent|SentinelAgent|elastic|esets|ekrn|MsMpEng|wdsvc|sysmon'}

# List loaded minifilter drivers
fltmc filters
```

The product fingerprint table is at the top of `references/hook-survey.md`.

### Step 2: Map the product's instrumentation

1. Attach a debugger to a process where the product's user-mode component is loaded.
2. Dump the in-memory `.text` of `ntdll.dll` and diff it against the clean on-disk copy.
3. Each divergence is an instrumentation point — record API, patch bytes, and owning module.

Or use a diffing tool such as pe-sieve on an analysis VM:

```powershell
pe-sieve64.exe /pid 1234 /shellc 3 /modules 3 /dir hooks_dump
```

For the hook catalog method, see `references/hook-survey.md`.

### Step 3: Document technique coverage

For each ATT&CK-relevant behavior class, record which detection layer would
observe it — see `references/unhook-techniques.md` and
`references/telemetry-blinding.md` for the technique→telemetry catalog
written from the defender's perspective.

### Step 4: Validate in an isolated lab

```powershell
# On an isolated analysis VM with the licensed EDR trial:
# Enable Sysmon with a community config, exercise benign test behaviors,
# and record which events appear — never test evasive code.
sysmon64.exe -i sysmonconfig.xml
```

### Step 5: Deliver

- Report detection coverage as a technique → alert matrix with gaps.
- Reference MITRE ATT&CK **T1562 (Impair Defenses)**, T1562.001, T1562.006,
  T1055, T1027 for the relevant technique classes.

## On-Demand Bootstrap

### Tool Dependencies

| Tool | Purpose | Can be installed automatically |
|------|------|-----------|
| pe-sieve | Detect hooks/injections in processes | ✓ |
| API Monitor v2 | Observe API calls and hooks | Semi-automatic (manual download) |
| windbg + IDA | Static reverse of EDR DLL / drivers | ✗ (install it yourself) |
| Sysmon + community config | Local telemetry baseline | ✓ |

### Bootstrap Command

```powershell
powershell -NoProfile -File "<SKILL_ROOT>\references\scripts\bootstrap-reverse.ps1" -Capability @('pe-sieve','sysmon') -StartServices
```

## Routing Context

**Upstream Inlet**:

- `reverse-engineering/` — Needed to first understand the implementation of EDR DLL/driver
- `attack-chain/` — Decides at which assessment phase this analysis applies

**Peer Association**:

- `malware-analysis/` — Same telemetry layers read from the sample's side
- `field-journal/` — Write back experience after each engagement

## Legal Boundaries Statement

- Only for legally authorized assessments / in-house product testing
- Written authorization must be obtained before operation (SoW / test contract / scope statement)
- Must not be used on unauthorized targets and must not exceed the authorized scope
- Do not produce or deliver evasive payloads; deliverables are analysis and detection mapping
- Report high-risk issues to the client immediately and follow responsible disclosure
- All real target information in reports must be anonymized

## References

- Detailed hook research: `references/hook-survey.md`
- Syscall/unhook technique catalog (defensive view): `references/unhook-techniques.md`
- ETW / AMSI internals: `references/telemetry-blinding.md`
- MITRE ATT&CK T1562: <https://attack.mitre.org/techniques/T1562/>

## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (records/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?
