# Telemetry Internals: ETW / AMSI / Logging (Defensive View)

> For authorized security assessments and defensive analysis only.
> Purpose: document the Windows telemetry pipeline that EDR relies on, and
> the **classes of tampering** analysts should recognize — not how to
> perform them. MITRE ATT&CK anchors: T1562.001 / T1562.002 / T1562.006 /
> T1070 / T1027.

## 1. ETW Internal Structure

ETW is Windows' built-in high-performance event tracing framework, which
EDR uses for lightweight kernel telemetry. The providers that matter most:

| Provider GUID | Name | Who uses it |
|--------------|------|--------|
| `{F4E1897C-BB5D-5668-F1D8-040F4D8DD344}` | Microsoft-Windows-Threat-Intelligence (ETW-TI) | Defender, MDE, third-party EDR |
| `{A0C1853B-5C40-4B15-8766-3CF1C58F985A}` | Microsoft-Antimalware-Scan-Interface | Defender AMSI report |
| `{22FB2CD6-0E7B-422B-A0C7-2FAD1FD0E716}` | Microsoft-Windows-Kernel-Process | Process / thread basic events |
| `{2839FF94-8F12-4E1B-82E3-AF7AF77A450F}` | Microsoft-Windows-DotNETRuntime | .NET loading, JIT |
| `{E13C0D23-CCBC-4E12-931B-D9CC2EEE27E4}` | .NET CLR | CLR startup |

### Key user-mode APIs

| API | DLL | Function |
|-----|-----|------|
| `EtwEventWrite` | `ntdll.dll` | Write event (most commonly hooked/patched) |
| `EtwEventWriteFull` | `ntdll.dll` | Event with activity ID |
| `EtwEventWriteEx` | `ntdll.dll` | Extended version |
| `NtTraceEvent` | `ntdll.dll` | `EtwEventWrite` underlying layer |
| `NtTraceControl` | `ntdll.dll` | Control trace session (start/stop/query provider) |
| `EtwEventEnabled` | `ntdll.dll` | Is the provider enabled |
| `EtwEventRegister` | `ntdll.dll` | Register provider |

### Call chain

```text
Application code EventWrite(...)
→ Microsoft packaging (TraceLogging API)
  → ntdll!EtwEventWrite[Full|Ex]
  → ntdll!NtTraceEvent (syscall)
→ nt!NtTraceEvent (kernel)
→ Kernel ETW core → consumer (EDR user-mode process subscribes to session)
```

## 2. ETW tampering classes → detection surface

| Tampering class | Mechanism (public literature) | What still sees it |
|------|------|------|
| `EtwEventWrite` head patch | Overwrite entry to return success | Memory-integrity scans on `ntdll`; ETW-TI `PROTECTVM` during the write |
| `EtwEventEnabled` always-false | Make the provider look disabled | Byte-level integrity checks of `ntdll`; suspiciously silent providers |
| `NtTraceControl` stop-trace | Close the consumer's trace session | "Provider stopped" audit events; requires high privilege |
| Kernel-mode ETW tamper | Zero kernel provider registrations | Only reachable with kernel read/write (BYOVD class); PatchGuard/boot telemetry |

**Analyst note**: user-mode telemetry gaps are themselves evidence. A host
that stops emitting ETW-TI events mid-execution is a high-confidence
signal — record the last observed event before the gap.

## 3. AMSI internals and tamper classes

AMSI is the interface Windows provides for PowerShell / .NET / WMI / VBA
to request an antimalware scan before executing script content.

| Tamper class | Mechanism | Detection surface |
|------|------|------|
| `AmsiScanBuffer` patch | Force early `E_INVALIDARG`/clean return | Module-hash integrity checks; AMSI's own telemetry |
| Context/session corruption | Malformed `AmsiContext` fails closed-lookalike | AMSI result anomalies |
| Reflective AMSI redirection | Load a clean `amsi.dll` copy for scan calls | Unexpected module loads in script hosts |
| Downgrade execution | Invoke engines without AMSI (e.g. PSv2) | Version checks; missing AMSI correlation |
| Field-based reflection bypass | Flip internal "init failed" flags | Signature + behavioral detections on known patterns |

## 4. Anti-forensics classes → forensic artifacts

| Tamper class | What the actor removes | What remains for investigators |
|------|------|------|
| Event-log clearing | `Security.evtx` etc. | Event ID 1102 "log cleared"; forwarded copies; VSS |
| PowerShell history wipe | PSReadLine history file | Transcription logs, ScriptBlock logs (if enabled), USN journal |
| Prefetch deletion | `.pf` execution evidence | AmCache, ShimCache, USN journal entries |
| Timestamp manipulation | File MAC times | `$STANDARD_INFORMATION` vs `$FILE_NAME` divergence; USN journal |
| Memory-residue cleanup | In-memory tooling | Hibernation/pagefile capture, crash dumps, EDR memory scan history |

## 5. Sysmon event reference (for detection authors)

| Event ID | Meaning | Evasion attempt it catches |
|----------|------|------|
| 1 | ProcessCreate (PPID, CommandLine, Hash) | PPID spoofing still records the *declared* vs *real* creator |
| 7 | ImageLoad (DLL loading) | Unexpected module loads |
| 8 | CreateRemoteThread | Classic cross-process injection |
| 10 | ProcessAccess (OpenProcess) | Handle opens on sensitive processes (e.g. credential stores) |
| 11 | FileCreate | Dropped artifacts |
| 12/13/14 | Registry | Persistence writes |
| 22 | DNS Query | Resolver telemetry |
| 25 | Process Tampering | Hollowing / image replacement |

**Key detection insight**: techniques that avoid *creating* events are
visible as **missing** telemetry — correlate expected-vs-observed event
sequences rather than only looking at what was logged.

## 6. Writing the finding

For each tampering class observed, report:

- Which pipeline was affected (ETW provider / AMSI / log source)
- The residual artifact that proves tampering
- ATT&CK technique ID
- Recommended detection surface (Sysmon ID, ETW provider, integrity scan)

## References

- ETW Threat Intelligence Provider: <https://learn.microsoft.com/en-us/windows/win32/etw/event-tracing-portal>
- ETW patching overview: <https://www.mdsec.co.uk/2020/03/hiding-your-net-etw/>
- Sysmon community config: <https://github.com/olafhartong/sysmon-modular>
- MITRE T1562.002 (Disable Windows Event Logging): <https://attack.mitre.org/techniques/T1562/002/>
- MITRE T1562.006 (Indicator Blocking): <https://attack.mitre.org/techniques/T1562/006/>
- MITRE T1070 (Indicator Removal): <https://attack.mitre.org/techniques/T1070/>

## Route Callback

After completing the telemetry mapping, return to `README.md` Step 4 to
document coverage, then deliver findings per the reporting phase in
`attack-chain/`.
