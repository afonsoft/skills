# Defense-Evasion Technique Recognition Reference

> Audience: security analysts reviewing telemetry during an authorized
> engagement, and reverse engineers classifying a sample's anti-analysis or
> defense-evasion behavior.
> Purpose: recognize evasion techniques in observed artifacts/telemetry and
> map them to detection opportunities — **not** to execute them.
> Every technique below is documented in public threat-intelligence and
> MITRE ATT&CK literature; consult ATT&CK T1562 (Impair Defenses) and T1027
> (Obfuscation) for canonical descriptions.

---

## Technique → detection surface map

| Evasion technique (as seen in samples) | What the sample/actor does | Where defenders can see it |
|------|------|------|
| Static-signature evasion | Custom packing, encrypted payloads, modified characteristics | YARA on dropped stages, entropy anomalies, unpackers |
| User-mode hook removal | Restores `ntdll.dll` to unhook EDR instrumentation | .text integrity diff (pe-sieve-style), ETW-TI events |
| Direct/indirect syscalls | Skips `ntdll` stubs to reach the kernel directly | Syscall-from-unbacked-memory heuristics, kernel callbacks |
| Call-stack spoofing | Forges return addresses so calls look legitimate | Stack-walk validation, unattributed image regions |
| Sleep/obfuscation timers | Encrypts own memory while idle between callbacks | Periodic memory scans, timer-callback auditing |
| Module stomping | Overwrites a legitimate loaded DLL's code section | Module/hash mismatch vs disk image |
| Process injection | Writes/executes inside another process | Sysmon Event 8/10, cross-process thread creation |
| Parent spoofing (PPID) | Claims a benign parent process | Sysmon Event 1 creator-PID mismatch checks |
| AMSI tampering | Disables script scanning interfaces | AMSI integrity checks, script-block logging gaps |
| ETW tampering | Patches event write / disables providers | Telemetry gaps from a host that should emit events |
| Living-off-the-land abuse | Uses signed system binaries for downloads/exec | Command-line analytics on LOLBins (certutil, mshta, rundll32, regsvr32, wmic, msiexec, bitsadmin, forfiles) |
| C2 traffic blending | Hides callbacks in legitimate cloud/CDN flows | JA3/JA4 fingerprints, beaconing cadence analysis, DNS-over-HTTPS anomalies |

---

## Analyst workflow

1. **Identify which detection layers the sample tries to defeat** — static,
   behavioral, memory, network, or logging — before classifying behavior.
2. **Correlate gaps with actions** — telemetry that *stops* mid-execution is
   itself evidence; record the last observed event before the gap.
3. **Prefer offline evidence** — analyze memory dumps, ETW captures, and
   extracted stages rather than executing the sample.
4. **Record technique IDs** — attach MITRE ATT&CK technique IDs (T1562.*,
   T1027.*, T1055.*) to findings so detections can be written directly.

## Reporting notes

- For each observed technique, record: detection layer defeated, the
  observable artifact it left, and a suggested detection rule surface.
- Do not reproduce evasion payloads in reports; describe behavior at the
  technique level and reference public ATT&CK write-ups.

## OpSec reading for defenders

Attacker operational-security patterns (low-and-slow timing, memory-only
execution, log-awareness) translate directly into **detection gaps to
monitor**: irregular logging cadence, missing event sources, and time-window
clustering. Treat absence of expected telemetry during an engagement window
as a signal, not silence.
