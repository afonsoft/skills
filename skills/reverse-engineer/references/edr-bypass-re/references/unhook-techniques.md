# Syscall / Unhook Technique Catalog (Defensive View)

> For authorized security assessments and defensive analysis only.
> Purpose: describe **what each publicized technique does at the mechanism
> level** so analysts can recognize it in samples and telemetry — not to
> implement it. Technique names correspond to public research and MITRE
> ATT&CK T1562.001 / T1027 / T1055.

---

## 1. Clean-`ntdll` remapping ("unhook")

**Mechanism**: EDR user-mode hooks live in the in-memory copy of
`ntdll.dll`. The technique maps a fresh copy of the on-disk DLL and
overwrites the hooked `.text` section, restoring original stubs.

**What defenders/analysts see**:

- `NtCreateSection`/`NtMapViewOfSection` calls referencing the disk path of
  `ntdll.dll` inside ordinary processes
- `NtProtectVirtualMemory` flipping `ntdll` `.text` to RW and back
- ETW-TI `KERNEL_MODULE_LOAD` / `PROTECTVM` events
- Result: `.text` in memory equals the disk image — ironically visible via
  a diff (pe-sieve-style) because legitimate processes have EDR-modified
  `ntdll`

## 2. Direct syscall stubs

**Mechanism**: code invokes the `syscall` instruction with a hardcoded or
resolved SSN instead of calling `ntdll` exports.

**Detection surface**:

- `syscall` executed from unbacked/non-`ntdll` memory regions
- SSN tables that do not match the OS build (dynamic resolution noise)
- Kernel callbacks still observe the resulting object operations —
  user-mode hook removal does not remove kernel visibility

## 3. Indirect syscall

**Mechanism**: jumps into a legitimate `syscall; ret` gadget inside
`ntdll.dll` so the return address looks clean.

**Detection surface**: call-stack validation still shows anomalies
(returning into `ntdll` from unexpected frames); ETW stack-walk capture.

## 4. Dynamic SSN resolution ("Hell's Gate" family)

**Mechanism**: reads the syscall number out of a clean `ntdll` on disk or
from neighboring stub patterns at runtime.

**Detection surface**: file reads of `ntdll.dll` from unexpected processes;
PE-basing heuristics on the reading pattern.

## 5. Hardware-breakpoint instrumentation ("Blindside" class)

**Mechanism**: uses debug registers to redirect execution at syscall
boundaries without patching memory.

**Detection surface**: debug-register usage on threads that never enabled
a debugger; `NtGetContextThread`/`NtSetContextThread` anomalies.

## 6. Sleep encryption

**Mechanism**: an implant encrypts its own image while idle between
callbacks, so memory scans see ciphertext.

**Detection surface**: timer-queue callbacks that flip memory protection
on a schedule; periodic `PAGE_EXECUTE`↔`PAGE_READWRITE` transitions; memory
that is never simultaneously plaintext and referenced.

## 7. Module stomping / hollowing

**Mechanism**: overwrites the code section of a legitimately loaded module
(or a hollowed host process) so scans see a valid module name.

**Detection surface**: module hash mismatch vs disk; image sections whose
in-memory pages are private/dirty; Sysmon Event 7 + Event 8 correlation.

## 8. Call-stack spoofing

**Mechanism**: fabricates return addresses so behavior-analysis stack
walks attribute the call to legitimate code.

**Detection surface**: frames with no unwind metadata, returns into
non-image memory, shadow-stack (CET) mismatches where enabled.

---

## Analyst checklist

For each technique observed in a sample or engagement telemetry, record:

- Detection layer it defeats (user-mode hook / ETW / kernel callback /
  memory scan / network)
- Observable artifact it leaves (which layer still sees it)
- ATT&CK technique ID for the report
- A concrete detection-rule surface (Sysmon event ID, ETW provider,
  memory-scan heuristic)
