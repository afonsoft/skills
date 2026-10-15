# Kernel Driver Reverse Engineering Reference

> 覆盖 Windows/Linux 内核驱动逆向、Rootkit 分析、C/C++ 二进制模式识别。

---

## Windows Driver Reverse Engineering

### Drive Type

| Type | Characteristics | Focus of Analysis |
|------|------|---------|
| WDM (Windows Driver Model) | Legacy driver, manually manages IRP | DriverEntry → Device creation → Dispatch routine |
| KMDF (Kernel Mode Driver Framework) | Modern framework, event-driven | EvtDriverDeviceAdd → Queue → I/O callback |
| WDF (Windows Driver Foundation) | KMDF + UMDF collectively referred to | See WdfDriverCreate call |
| Minifilter | File System Filter Driver | FltRegisterFilter → Pre/Post Callback |

### WDM Driver Analysis Process

```text
1. Find DriverEntry (entry point)
- IDA automatic recognition, or search for IoCreateDevice / IoCreateSymbolicLink

2. Find the device name and symbolic link
- IoCreateDevice → DeviceName (e.g., \Device\MyDriver)
- IoCreateSymbolicLink → SymLink (e.g., \DosDevices\MyDriver)

3. Find the Dispatch routine
   - DriverObject->MajorFunction[IRP_MJ_DEVICE_CONTROL] = DispatchIoctl
- This is the entry point for user mode calling through DeviceIoControl

4. Analysis of IOCTL Handling
- switch(IoControlCode) Dispatch different functions
- IOCTL Encoding: CTL_CODE(DeviceType, Function, Method, Access)
   - Method: METHOD_BUFFERED / METHOD_IN_DIRECT / METHOD_OUT_DIRECT / METHOD_NEITHER

5. Find loopholes
- User-controlled buffer has unchecked length → overflow
- METHOD_NEITHER Directly use user pointer → arbitrary read/write
- IOCTL permissions not checked → can be called by non-privileged users
```

### IOCTL Encoding Analysis

```python
# Parsing IOCTL code
def decode_ioctl(code):
    device_type = (code >> 16) & 0xFFFF
    access = (code >> 14) & 0x3
    function = (code >> 2) & 0xFFF
    method = code & 0x3
    
    methods = {0: "BUFFERED", 1: "IN_DIRECT", 2: "OUT_DIRECT", 3: "NEITHER"}
    access_types = {0: "ANY", 1: "READ", 2: "WRITE", 3: "READ|WRITE"}
    
    return f"DevType=0x{device_type:X} Func=0x{function:X} Method={methods[method]} Access={access_types[access]}"

# Example
decode_ioctl(0x80002034)
# DevType=0x8000 Func=0x80D Method=BUFFERED Access=ANY
```

### IDA Plugin

| Plugin | Purpose | Link |
|------|------|------|
| **Driver Buddy Reloaded** | Automatically detects IOCTL, Dispatch, device name | https://github.com/VoidSec/DriverBuddyReloaded |
| **WinDbg + IDA** | Kernel Debugging + Combined Static Analysis | Built-in |
| **FLIRT/Lumina** | Identify WDK library functions | Built-in IDA |

### Reference Article

- [Windows Drivers RE Methodology (VoidSec)](https://voidsec.com/windows-drivers-reverse-engineering-methodology/) — The Most Complete WDM Driver Reverse Engineering Methodology]
- [Driver Reversing 101](https://eversinc33.com/posts/driver-reversing.html) — WDM vs KMDF Comparison
- [Methodology of Reversing Vulnerable Killer Drivers](https://whiteknightlabs.com/2025/10/28/methodology-of-reversing-vulnerable-killer-drivers/) — Vulnerable Driver Analysis]

---

## Linux Kernel Module Reverse Engineering

### LKM (Loadable Kernel Module) Structure

```text
Key function:
- init_module / module_init → Executed when the module is loaded
- cleanup_module / module_exit → executed when the module is unloaded

Key structure:
- struct file_operations → Character device's open/read/write/ioctl
- struct net_device_ops → Network device operations
- struct block_device_operations → block device operations
```

### Analysis Process

```text
1. Confirm that it is a kernel module
file module.ko → "ELF 64-bit ... relocatable" (note it is relocatable, not executable)

2. Find the init/exit function
   readelf -s module.ko | grep -E "init_module|cleanup_module"
Or find module information in the .modinfo section

3. Find the file_operations structure
Search register_chrdev / cdev_add / misc_register
→ Find the fops structure → Locate the ioctl/read/write handling function

4. Analyze ioctl handling
unlocked_ioctl / compat_ioctl function
→ switch(cmd) dispatch

5. Finding Rootkit Behavior
- Modify sys_call_table → syscall hook
- Modify the /proc file system → Hide processes/files
- Register netfilter hook → Hide network connections
- Modify VFS layer → Hide files
```

### Common Rootkit Techniques

| Technology | Features | Detection Methods |
|------|------|---------|
| syscall table hook | Modify `sys_call_table` entry | Compare the table in memory with vmlinux on disk |
| VFS hook | Modify `file_operations` function pointer | Check whether fops pointer points outside the kernel code segment |
| Netfilter hook | `nf_register_net_hook` | Traverse the netfilter hook linked list |
| kprobe/ftrace hook | Register kprobe or ftrace callback | Check ftrace registration list |
| eBPF rootkit | Load malicious BPF program | `bpftool prog list` |
| DKOM | Directly modify kernel objects (process lists) | Traverse task_struct list and compare with /proc |

### Tools

| Tool | Purpose |
|------|------|
| `crash` | Kernel dump analysis |
| `volatility3` | Memory Forensics (Linux profile) |
| `dmesg` / `journalctl` | Kernel Log |
| `lsmod` / `/proc/modules` | Loaded Module List |
| `modinfo` | Module Meta Information |
| `strace` | System Call Tracing (User-Space Perspective) |

---

## C/C++ Reverse Mode Recognition

### Common Patterns in C Language

| Source Code Mode | Disassembly Features |
|---------|-----------|
| `if-else` | `cmp` + `jcc` (conditional jump) |
| `switch-case` | Jump table (`jmp [rax*8 + table]`) or continuous `cmp` |
| `for` Loop | `cmp` + `jl/jle` + Loop Body + `inc/add` + `jmp` Jump Back |
| `while` Loop | Conditional check at the top of the loop |
| `do-while` | Conditional judgment at the bottom of the loop |
| Function pointer call | `call rax` or `call [reg+offset]` |
| `struct` Visit | `[reg+固定偏移]` (such as `[rdi+0x10]`) |
| `malloc` + use | `call malloc` → return value stored in register → subsequent access using this register + offset |
| String Comparison | `call strcmp` or `repe cmpsb` |

### C++ Specific Patterns

| Source Code Mode | Disassembly Features |
|---------|-----------|
| **Virtual Function Call** | `mov rax, [rcx]` (get vtable) → `call [rax+offset]` (call virtual function) |
| **Constructor** | Allocate memory → Write vtable pointer → Initialize members |
| **Destructor** | Cleans up members → may call `operator delete` |
| **this pointer** | The first parameter (rcx/rdi) is the object pointer |
| **Inheritance** | vtable contains parent class virtual functions + child class overrides |
| **Multiple Inheritance** | The object has multiple vtable pointers (with different offsets) |
| **RTTI** | There is an `type_info` pointer in front of the vtable |
| **Exception Handling** | `__cxa_throw` / `_CxxThrowException` |
| **STL Container** | `std::vector`: `{begin, end, capacity}` Three-pointer Structure |
| **std::string** | Small String Optimization (SSO): short strings are inlined, long strings are heap-allocated |

### vtable Reverse Engineering Methods

```text
1. Find vtable
- Search for a consecutive array of function pointers (in the .rodata or .rdata section)
- Writing the vtable pointer `mov [rcx], offset vtable` in the constructor

2. Determine the class hierarchy
- The offset -8 before the vtable is usually the RTTI pointer (if not stripped)
- Multiple vtables share the first few entries → inheritance relationship

3. Mark virtual functions
- vtable[0] is usually the destructor (or deleting destructor)
- Subsequent offset annotations: vtable[1] = func1, vtable[2] = func2...

4. Operations in IDA
- Create a struct at the vtable address (each field is a function pointer)
- Add a comment to `call [rax+offset]` indicating the virtual function being called
```

### Struct Recovery

```text
Method 1: Inferring from access patterns
  mov eax, [rdi+0x00]  → field_0: int/ptr (4/8 bytes)
  mov ecx, [rdi+0x08]  → field_8: int/ptr
  movss xmm0, [rdi+0x10] → field_10: float

Method 2: Deducing from sizeof
call malloc(0x30) → structure size 0x30 (48 bytes)
  
Method 3: Infer from the constructor
The constructor initializes all fields → Field types and offsets are clear at a glance

Method 4: Use IDA's "Create struct" feature
Select Access Mode → Edit → Struct → Create struct from selection
```

---

## Common Compiler Features

| Compiler | Recognition Features |
|--------|---------|
| MSVC | `_security_cookie` Checks, `__fastcall` Calling Convention, Rich Header |
| GCC | `__stack_chk_fail`, `-fstack-protector`, `.note.GNU-stack` |
| Clang/LLVM | Similar to GCC but with different optimization modes, `__asan_*` (if sanitizer is enabled) |
| MinGW | GCC Features + Windows API Calls |
| AOSP Clang | Android-specific `__android_log_print`, PGO flags |

### Optimization Level Identification

| Optimization Level | Features |
|---------|------|
| -O0 | A large number of redundant mov instructions, every variable is on the stack, functions are not inlined |
| -O1 | Basic optimization, some variables in registers |
| -O2 | Loop unrolling, function inlining, tail call optimization |
| -O3 / -Os | Aggressive inlining, vectorization (SIMD), code hard to read |
| PGO | Hot path optimization, cold code separation to `.text.cold` |
| LTO | Cross-module inlining, global dead code elimination |

---

## Kernel Debugging Environment

### Windows

```text
Debugger: WinDbg Preview
Connection method: Network debugging (recommended) or serial port

Set by the debugged machine:
bcdedit /debug on
bcdedit /dbgsettings net hostip:192.168.x.x port:50000

Debugging machine connection:
WinDbg → File → Attach to Kernel → Net → Port:50000 Key:xxx

Common commands:
!analyze -v          # Automatically analyze crashes
lm                   # List loaded modules
!drvobj \Driver\xxx # View the driver object
dt nt!_DRIVER_OBJECT # Display structure
bp module!function   # Set breakpoint
```

### Linux

```text
Debugger: GDB + QEMU or kgdb

QEMU Kernel Debugging:
qemu-system-x86_64 -kernel bzImage -s -S ...
gdb vmlinux -ex "target remote :1234"

Common commands:
info threads         # Kernel threads
lx-symbols           # Load kernel symbols (requires scripts/gdb/)
p init_task          # View the init process
lx-dmesg             # Kernel log
```

---

## Agent Action Anchors (Issue #65 U–AV)

Align with `references/nonpe-format-cookbook.md` §5 (short table, does not replace the above process):

| ID | Action | Evidence |
|----|------|----------|
| AG | `DriverEntry` Short → Sweep `MajorFunction` Non-empty slot, prioritize DEVICE_CONTROL/CREATE | `E-driver-irp-handlers` |
| AH | Establish IOCTL control code → handler table and METHOD_* | `E-driver-ioctl` |
| AI | Suspicion BYOVD: Compare with public vulnerability driver list; name/hash/signature with call intent; **do not write exploit steps** | `E-driver-byovd` |

## Reference Resources

| Resource | Description | Link |
|------|------|------|
| VoidSec Driver Reverse Engineering Methodology | Complete Windows WDM Driver Analysis Process | https://voidsec.com/windows-drivers-reverse-engineering-methodology/ |
| Elastic Rootkit Series | Linux Rootkit Classification + Detection | https://security-labs.elastic.co/security-labs/linux-rootkits-1-hooked-on-linux |
| Driver Buddy Reloaded | IDA Driver Analysis Plugin | https://github.com/VoidSec/DriverBuddyReloaded |
| LOLDrivers | List of Known Vulnerable Drivers | https://www.loldrivers.io/ |
| Windows Driver Samples | Microsoft Official Driver Examples | https://github.com/microsoft/Windows-driver-samples |
| Linux Kernel Module Programming | Kernel Module Development Tutorial | https://sysprog21.github.io/lkmpg/ |
| Trail of Bits - Devirtualizing C++ | vtable reverse engineering method | https://blog.trailofbits.com/2017/02/13/devirtualizing-c-with-binary-ninja/ |