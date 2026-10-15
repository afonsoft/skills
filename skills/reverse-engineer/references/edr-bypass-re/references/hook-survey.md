# EDR Hook Quick Research Reference

> For authorized red team / adversary exercises / in-house product testing only, use on unauthorized targets is prohibited.

This document summarizes the monitoring points of mainstream EDR/AV in user mode and kernel mode, for the red team to quickly locate during the reconnaissance phase. What should be done about it?

## 1. Quick Reference for Mainstream EDR Fingerprints and Hook Modes

| Manufacturer / Product | User-mode Components | Kernel Driver | Main Monitoring Aspect |
|------------|-----------|---------|-----------|
| CrowdStrike Falcon | `CSFalconService.exe`, `CSAgent.sys` injected into target process | `CSAgent.sys`, `CSBoot.sys` | Heavy kernel callback + ETW-TI; few user-mode hooks (cloud check) |
| Microsoft Defender for Endpoint (MDE) | `MsMpEng.exe`, `MpClient.dll` | `WdFilter.sys`, `WdBoot.sys`, `WdNisDrv.sys` | AMSI + ETW-TI + ntdll inline hook + kernel callback comprehensive |
| SentinelOne | `SentinelAgent.exe`, `SentinelHelperService.exe` | `SentinelMonitor.sys`, `SentinelDeviceControl.sys` | ntdll user-mode hook heavy + kernel callback + proprietary ETW provider |
| Elastic Defend (formerly Endpoint Security) | `elastic-endpoint.exe` | `elastic-endpoint-driver.sys` | Mainly ETW + a few ntdll hooks, working with Elastic Agent to upload |
| ESET | `ekrn.exe`, `eamsi.dll` | `eamonm.sys`, `epfwwfp.sys` | There are many user-mode hooks (NtCreateFile / NtOpenProcess, etc.) |
| Sophos Intercept X | `SophosFileScanner.exe`, `SophosNtpService.exe` | `SophosED.sys`, `hmpalert.sys` | ntdll hook + HMPA memory protection + kernel callback |
| Kaspersky | `avp.exe`, `klif.sys` | `klif.sys`, `klhk.sys` | Heavy user-mode hook + KLIF proprietary mini-filter + network filter driver |
| Trend Micro Apex One | `TmListen.exe`, `TmCCSF.dll` | `tmcomm.sys`, `tmactmon.sys` | User-mode hook + behavior monitoring driver |
| Carbon Black | `RepMgr.exe`, `RepWAV.exe` | `ParityDriver.sys` | Partial kernel callback + ETW |

### Quick Fingerprint Script

```powershell
$edrSigs = @{
    'CSAgent'           = 'CrowdStrike Falcon'
    'SentinelAgent'     = 'SentinelOne'
    'elastic-endpoint'  = 'Elastic Defend'
    'ekrn'              = 'ESET'
    'MsMpEng'           = 'Microsoft Defender'
    'SophosFileScanner' = 'Sophos Intercept X'
    'avp'               = 'Kaspersky'
    'TmListen'          = 'Trend Micro Apex One'
    'cb'                = 'Carbon Black'
}

Get-Process | ForEach-Object {
    foreach ($k in $edrSigs.Keys) {
        if ($_.ProcessName -match $k) {
            "[+] $($edrSigs[$k]) detected: $($_.ProcessName) (PID $($_.Id))"
        }
    }
}

Get-ChildItem 'C:\Windows\System32\drivers\*.sys' |
    Where-Object { $_.Name -match 'CSAgent|Sentinel|elastic|eam|WdFilter|Sophos|klif|tmcomm|Parity' } |
    Select-Object Name, VersionInfo
```

## 2. Key ntdll Hooks in User Mode

EDR almost certainly hooks `ntdll.dll` exports (grouped by ATT&CK behavior):

| Function | Monitored Behavior | ATT&CK |
|------|-----------|--------|
| `NtCreateThreadEx` | Remote Thread Injection, QueueUserAPC Injection | T1055.002 / T1055.004 |
| `NtAllocateVirtualMemory` | shellcode requests RWX memory | T1055 |
| `NtAllocateVirtualMemoryEx` | Cross-process memory allocation (Win10+ new API) | T1055 |
| `NtProtectVirtualMemory` | Change page permissions RW→RX | T1055 |
| `NtWriteVirtualMemory` | Cross-process shellcode writing | T1055.012 |
| `NtMapViewOfSection` | section-based injection (Process Doppelganging / Ghosting) | T1055.013 |
| `NtCreateSection` | Cooperate with MapViewOfSection | T1055.013 |
| `NtOpenProcess` | Open target process to get handle | T1057 |
| `NtQueueApcThread` / `NtQueueApcThreadEx` | APC Injection | T1055.004 |
| `NtCreateProcess` / `NtCreateProcessEx` / `NtCreateUserProcess` | Create subprocess (including PPID spoof) | T1106 |
| `NtSetContextThread` | Change thread context (thread hijacking injection) | T1055.003 |
| `NtResumeThread` | Restore thread after injection | T1055 |
| `NtQuerySystemInformation` | Enumerate processes / drivers / handles | T1057 / T1082 |
| `NtAdjustPrivilegesToken` | Privilege escalation to obtain SeDebugPrivilege, etc. | T1134 |
| `NtLoadDriver` | Load Kernel Driver (BYOVD) | T1543.003 |

### Verify if the hook exists

```powershell
# Simple: Diff the disassembly of the disk ntdll and the current process's ntdll
# 1. Take the disk ntdll
copy C:\Windows\System32\ntdll.dll C:\temp\ntdll_clean.dll

# 2. Attach to any process in windbg and export the current ntdll .text section
# .writemem c:\temp\ntdll_live.bin ntdll!.text L?<size>

# 3. Disassemble NtAllocateVirtualMemory using IDA / radare2, it should normally be:
#    mov r10, rcx
#    mov eax, <SSN>
#    test byte ptr [...]
#    jne ...
#    syscall
#    ret
# If the first line becomes jmp <some address>, then that's a hook
```

## 3. Kernel callback monitoring points

Common kernel callbacks registered by EDR (all can be unregistered by the BYOVD route in `attack-chain`, but at a high cost):

| API | Callback Timing for Registration | Defender's Use |
|-----|--------------|-----------|
| `PsSetCreateProcessNotifyRoutineEx` | Process creation / exit | Intercept suspicious child process |
| `PsSetCreateThreadNotifyRoutine` | Thread creation / exit | Detect remote thread injection |
| `PsSetLoadImageNotifyRoutine` | DLL / EXE loaded into any process | Module integrity / unsigned interception |
| `CmRegisterCallback` / `CmRegisterCallbackEx` | Registry Operations | Persistence Detection |
| `ObRegisterCallbacks` | `OpenProcess` / `OpenThread` Handle Request | Prevent LSASS Handle Access (T1003.001) |
| `MmRegisterPhysicalMemoryCallback` | Physical Memory Mapping | Prevent DMA / Memory Forensics |
| `IoRegisterFsRegistrationChange` | File System Registration | Minifilter Collaboration |
| `KeRegisterNmiCallback` | NMI (rarely used by EDR) | Abnormal monitoring |
| `EtwRegister` (Kernel Side) | Kernel ETW Reporting | Symbiotic with ETW-TI |

### Enumerate Registered Callbacks with WinDbg

```text
0: kd> dx -r1 nt!PspCreateProcessNotifyRoutine
0: kd> dx -r1 nt!PspCreateThreadNotifyRoutine
0: kd> dx -r1 nt!PspLoadImageNotifyRoutine

0: kd> !object \Callback
0: kd> !object \Callback\ProcessObject
```

Alternatively, tools like PChunter/DRVHV can be used, allowing ordinary users to visually view the callback list.

## 4. Static dump hook table (IDA + WinDbg process)

### Process A: Single-Process Comparison

```text
1. Find a process that has had a user-mode component injected by EDR (any alive process)
2. windbg attach (-pn target.exe)
3. lm m ntdll  → Get the module base address
4. .writemem c:\temp\ntdll_live.bin ntdll+0x0 L?<image size>
5. Copy C:\Windows\System32\ntdll.dll as c:\temp\ntdll_disk.dll
6. Load two files in IDA and jump to NtAllocateVirtualMemory:
- disk: standard prologue
- live: first jmp <0x7FFE000000xx>
7. Follow the jmp target address → that’s the EDR’s trampoline, dump it out
8. Enter the trampoline to see which DLL it eventually lands in, and confirm the EDR module name
```

### Process B: Bulk Hook Table Generation

Use `HookHunter` or write your own script:

```powershell
# pseudo workflow, see the scripts mentioned in references for details
$disk = Get-Content C:\Windows\System32\ntdll.dll -Encoding Byte
$live = # 通过 OpenProcess + ReadProcessMemory 拿
# Compare the first 16 bytes of each export in the .text section
```

## 5. pe-sieve Automatic Detection

`pe-sieve` is the preferred choice for EDR hook reconnaissance and implant self-check:

```powershell
# Basic Scan
pe-sieve64.exe /pid 1234

# Recommended Combination (Including Shellcode and Hook Detection)
pe-sieve64.exe /pid 1234 /shellc 3 /modules 3 /imp 3 /data 3 /dir hooks_dump

# Key Parameters:
#   /shellc N    shellcode scan level (0-3)
#   /modules N   Module integrity check (0-3)
#   /imp N       IAT hook check
#   /data N      Data Segment Scan
#   /dir <path>  dump output directory
```

The output will generate the `*.tag` file under `hooks_dump/<pid>.<name>/`, listing the hook addresses:

```text
modified_modules.tag example:
71f10000;ntdll.dll
71f1a3b0;hook;jmp_far
71f1c020;hook;jmp_near
```

It can be directly fed to IDA to jump to the corresponding RVA for subsequent analysis.

### Embedding pe-sieve (self-check) in the implant

In practice, `pe-sieve` is often compiled as lib (`libpe-sieve`), so that when the implant starts, it first performs a self-check: if ntdll has hooks, it triggers the unhook process; if it finds that it itself is hooked, it should be careful, as it might be in a sandbox.

## 6. API Monitor v2 Dynamic Observation

API Monitor v2 (Rohitab) is suitable for observing when and where the EDR inserts hooks in the lab:

```text
1. Launch API Monitor v2 (Administrator)
2. API Filter Check:
     - NT Native API → Memory Management
     - NT Native API → Process and Thread
- Windows Defender / AMSI (if visible)
3. Monitor New Process → Select implant test sample
4. Observation:
- NtAllocateVirtualMemory call sequence
- Whether it is relayed by the EDR DLL
5. In the Modules tab, see which EDR DLLs are injected by LoadLibrary
```

## 7. Common EDR DLLs (User Mode) Quick Reference

| DLL | Vendor | Remarks |
|-----|------|------|
| `umppc*.dll` | Microsoft Defender | MpClient userland |
| `mpoav.dll` | Microsoft Defender | AMSI provider |
| `aswAMSI.dll` | Avast | AMSI provider |
| `eamsi.dll` | ESET | AMSI provider |
| `IDPMServiceClient.dll` | Sophos | HMPA Injection |
| `klsihk64.dll` | Kaspersky | Injected into the target process |
| `CrowdStrike.Sensor.dll` | CrowdStrike | Old version, the new version mainly relies on the kernel |
| `SentinelInjection64.dll` | SentinelOne | User-mode Injection |
| `TmUmEvt64.dll` | Trend Micro | Behavior Monitoring |

After confirming the target EDR, decide which DLL to reverse engineer to obtain the hook table.

## Reference Links

- pe-sieve：xKx0009xKx
- HollowsHunter：xKx0010xKx
- API Monitor v2：xKx0011xKx
- MITRE ATT&CK T1562：xKx0012xKx
- MITRE ATT&CK T1055：xKx0013xKx
- ired.team EDR notes：xKx0014xKx

## Route Callback

After completing the hook research, return to Step 3 of `README.md` to select the bypass technology combination, then execute according to `references/unhook-techniques.md` and `references/telemetry-blinding.md`.