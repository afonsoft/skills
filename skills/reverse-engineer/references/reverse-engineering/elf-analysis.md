# ELF Binary Deep Analysis Reference

> Structural analysis, anti-analysis recognition, and analytical techniques when reverse-engineering Linux/Android ELF files.

---

## ELF Structure Quick Reference

### File Header (ELF Header)

```text
Offset  Size  Field              Description
0x00  4    e_ident[EI_MAG]   Magic: 7f 45 4c 46 ("\x7fELF")
0x04  1    e_ident[EI_CLASS] 1=32bit, 2=64bit
0x05  1    e_ident[EI_DATA]  1=LE, 2=BE
0x10  2    e_type            2=EXEC, 3=DYN(PIE/SO), 4=CORE
0x12  2    e_machine         0x03=x86, 0x3E=x86_64, 0xB7=AArch64, 0x28=ARM
0x18  8    e_entry           Entry point virtual address
0x20  8    e_phoff           Program header table offset
0x28  8    e_shoff           Section header table offset (may be 0 after strip)
0x38  2    e_phnum           Number of program headers
0x3C  2    e_shnum           Number of section headers
```

### Program Header

```text
Type Value  Name  Description
0x01   PT_LOAD    Loadable segment (code/data)
0x02   PT_DYNAMIC Dynamic Linking Information
0x03   PT_INTERP  Interpreter path (/lib/ld-linux.so)
0x04   PT_NOTE    Auxiliary Information
0x06   PT_PHDR    Program Header Table Itself
0x6474e550 PT_GNU_EH_FRAME Exception Handling
0x6474e551 PT_GNU_STACK     Stack Executable Flag
0x6474e552 PT_GNU_RELRO     Read-only relocations
```

### Common Festivals (Sections)

| Section Name | Description |
|------|------|
| `.text` | Code Segment |
| `.rodata` | Read-only data (string constant) |
| `.data` | Global variable initialized |
| `.bss` | Uninitialized global variable |
| `.plt` / `.got` | Dynamic Link Jump Table |
| `.init_array` | Constructor Pointer Array |
| `.fini_array` | Destructor Pointer Array |
| `.dynamic` | Dynamic Link Information |
| `.symtab` / `.dynsym` | Symbol Table |
| `.strtab` / `.dynstr` | String Table |

---

## Anti-Analysis Techniques Identification

### Common ELF Anti-Analysis Techniques

| Technique | Characteristics | Countermeasures |
|------|------|---------|
| Damaged program header | PHDR filled with garbage data (such as 0x0a) | Manually repair or ignore the damaged PHDR |
| No section header | `e_shoff = 0`, `e_shnum = 0` | Only relies on program header analysis, does not rely on section |
| Strip symbols | No `.symtab`, all function names lost | GoReSym (Go) / Signature matching / FLIRT |
| Static linking | No `.dynamic`, huge size | Use FLIRT/Lumina to identify library functions |
| Fake file type | Suffix .sh/.txt/.jpg | Determined by `file` command / magic bytes |
| UPX packing | contains `UPX!` marker | `upx -d` unpacking |
| Custom shell | Entry point jumps to decompression code | Dump after dynamically running to OEP |
| Anti-debugging | ptrace(TRACEME) | LD_PRELOAD hook / patch |
| Anti-VM | Check /proc/cpuinfo | Modify cpuinfo or hook reading |
| Code encryption | Runtime decryption of .text | Breakpoint and dump after decryption |

### Identifying Self-Extracting/Self-Modifying Code

```text
Features:
1. There is an mmap(PROT_READ|PROT_WRITE|PROT_EXEC) call near the entry point
2. Immediately followed by memcpy or loop copy
3. Then use mprotect to change the permissions
4. Finally br/jmp to the newly mapped address

Analysis Strategy:
1. Find the mmap call → Record the returned address
2. Set a breakpoint after mprotect(PROT_EXEC)
3. dump the decompressed memory area
4. As a new binary analysis
```

---

## ARM64 (AArch64) Reverse Engineering Quick Reference

### Registers

| Register | Purpose |
|--------|------|
| x0-x7 | Parameters/Return Values |
| x8 | Indirect result (syscall number) |
| x9-x15 | Temporary registers |
| x16-x17 | IP0/IP1 (PLT jump) |
| x18 | Platform register (Android: shadow call stack) |
| x19-x28 | Callee-saved |
| x29 (FP) | Frame Pointer |
| x30 (LR) | Link Register (Return Address) |
| SP | Stack Pointer |
| PC | Program Counter |

### Common Instruction Patterns

```text
Function prologue:
stp x29, x30, [sp, #-N]!    # Save FP and LR
mov x29, sp                  # Set frame pointer

Function epilogue:
ldp x29, x30, [sp], #N      # Restore FP and LR
ret                          # return (br x30)

System call:
mov x8, #NR                  # syscall number
svc #0                       # Trigger syscall

Conditional Branch:
  cmp x0, #0
b.eq label                   # Branch if equal
b.ne label                   # branch if not equal
cbz x0, label                # jump if x0 == 0
cbnz x0, label               # x0 != 0 jump

Address Loading:
adrp x0, page                # Load the high bits of the page address
add x0, x0, #offset          # Add lower 12-bit offset
ldr x0, [x1, #offset]        # Load from memory
```

### Linux ARM64 System Call Numbers

| Number | Name | Description |
|------|------|------|
| 56 | openat | Open file |
| 63 | read | read |
| 64 | write | write to |
| 57 | close | close |
| 222 | mmap | Memory Mapping |
| 226 | mprotect | Change memory permissions |
| 117 | ptrace | Process Tracing |
| 220 | clone | create process/thread |
| 221 | execve | Execute program |
| 93 | exit | Exit |
| 94 | exit_group | exit process group |

---

## Common Compression/Packaging Algorithm Identification

| Algorithm | Recognition Features | Decompression Method |
|------|---------|---------|
| **LZSS** | Bitstream + literals/match markers | Custom decompressor (such as this report) |
| **ZLIB/Deflate** | Magic: `78 01`/`78 9C`/`78 DA` | `zlib.decompress()` |
| **GZIP** | Magic: `1F 8B` | `gzip -d` / `gunzip` |
| **LZ4** | Magic: `04 22 4D 18` | `lz4 -d` |
| **LZMA/XZ** | Magic: `FD 37 7A 58 5A 00` (XZ) | `xz -d` / `lzma -d` |
| **Brotli** | No fixed magic, depends on context | `brotli -d` |
| **Zstandard** | Magic: `28 B5 2F FD` | `zstd -d` |
| **UPX** | String `UPX!` | `upx -d` |
| **Custom** | The entry point has a decompression loop | Write the decompressor after reverse engineering the algorithm |

### Identifying Clues for Custom Compression

```text
1. There are loops + bit operations (shift, AND, OR) near the entry point
2. Has 'sliding window' back-reference (reading back from the output buffer) → LZ series
3. Construct frequency table/Huffman tree → Deflate/Huffman
4. Processing with fixed-size blocks → Block compression (LZ4/Snappy)
5. Has arithmetic coding features (interval narrowing) → LZMA/ANS
```

---

## Linux Process Injection Techniques

### mmap + Code Injection

```text
Process:
1. mmap(NULL, size, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0)
2. Write shellcode/payload into the mapped area
3. mprotect(addr, size, PROT_READ|PROT_EXEC)  # Change to executable
4. Jump to the mapped address to execute

Features:
- The return value of mmap is saved
- Immediately followed by memcpy or loop writing
- Then use mprotect to change permissions
- Finally br/blr to this address
```

### ptrace Injection

```text
Process:
1. ptrace(PTRACE_ATTACH, target_pid)
2. waitpid(target_pid)
3. ptrace(PTRACE_GETREGS, target_pid, &regs)
4. Modify regs.pc to point to the injected code
5. ptrace(PTRACE_SETREGS, target_pid, &regs)
6. ptrace(PTRACE_CONT, target_pid)

Features:
- Open /proc/<pid>/mem or use ptrace
- Read/Modify target process registers
- Write shellcode into the target process space
```

### /proc/self/mem Self-modification

```text
Process:
1. open("/proc/self/mem", O_RDWR)
2. lseek(fd, target_addr, SEEK_SET)
3. write(fd, new_code, size)

Purpose:
- Bypass W^X protection (mmap pages cannot be both W+X at the same time)
- Modify one's own code segment (.text is usually read-only)
- Runtime patch instruction
```

---

## Strategies for Analyzing Large ELF Files

For large binaries over 5MB:

```text
1. Quick reconnaissance (5 minutes)
- file / rabin2 -I → Architecture, Type, Protection
- strings | grep -i "error\|fail\|http\|/proc\|/dev" → key strings
- rabin2 -i → Import functions (if any)
- rabin2 -E → Export functions

2. Structural Analysis (10 minutes)
- readelf -l → Program headers (LOAD segment layout)
- Code near the entry point → Is there decompression/decryption
- Find .init_array → constructors (may have anti-debugging)

3. Positioning Key Logic
- Start from string cross-referencing
- Starting from system calls (mmap/ptrace/open)
- Start with the network function (connect/send/recv)

4. Divide and rule
- If it is self-extracting → extract first, then analyze the payload
- If it is multi-module → analyze by functional sections
- Compare different versions using binary-diff
```

---

## Quick Reference for Tool Commands

```bash
# Basic Information
file binary
readelf -h binary          # ELF 头
readelf -l binary          # 程序头
readelf -S binary          # 节头（如果有）
rabin2 -I binary           # 综合信息

# String
strings -a binary | less
rabin2 -z binary           # 数据段字符串
rabin2 -zz binary          # 全文件字符串

# Disassembly
r2 -A binary               # radare2 分析
objdump -d binary          # GNU 反汇编
aarch64-linux-gnu-objdump -d binary  # ARM64 交叉反汇编

# Dynamic Analysis
strace -f ./binary         # 系统调用跟踪
ltrace -f ./binary         # 库函数跟踪
qemu-aarch64 -strace ./binary  # ARM64 模拟执行

# Memory dump
gdb -p <pid> -ex "dump memory out.bin 0xADDR 0xADDR+SIZE" -ex quit

# Fix corrupted ELF
# Manually modify e_phnum or patch a damaged PHDR
python -c "
import struct
with open('binary', 'r+b') as f:
    f.seek(0x38)  # e_phnum offset (64-bit)
    f.write(struct.pack('<H', 2))  # 修改为正确的 PHDR 数量
"
```
