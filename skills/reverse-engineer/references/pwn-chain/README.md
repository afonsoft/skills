---
name: pwn-chain
description: |
  从逆向走到可用利用 (Working Exploit) 的全链路工程化方法。
  适用场景：拿到了二进制 + 漏洞点 + 目标环境，需要写出一个能稳定打通的 exploit（不是只能本地复现一下、远程一打就崩的脚本）。
  覆盖三大方向：栈溢出 / 堆利用 / 内核 pwn。强调"CTF 本地通 → 真实远程稳定打通"的工程差距：libc 版本错配、堆喷射时序、SMEP/SMAP/KASLR、栈对齐、远程缓冲。
  核心工具链：pwntools + GEF/pwndbg + ROPgadget/Ropper + one_gadget + libc-database + qemu-system 内核调试。
  触发关键词：pwn、栈溢出、堆溢出、ROP、ret2libc、ret2csu、one_gadget、libc-database、堆利用、tcache、fastbin、unsorted bin、kernel pwn、kROP、SMEP、SMAP、KASLR、modprobe_path、pwntools、GEF、pwndbg。
---

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

# From Vulnerability Point to Working Exploit (Pwn Chain)

## Scope of Application

Use this skill when the task falls into the following scenarios:

1. **Obtain the binary + known vulnerability point** — Static/audit/fuzzing has already found overflow/UAF/double free, need to go from trigger to getting a shell
2. **CTF challenges already work locally, but can't connect remotely** — Differences in the remote environment cause the script to fail, need stabilization
3. **Binary Exploitation on Real Targets** — In SRC / Red Team scenarios, once a memory corruption vulnerability is identified, an RCE needs to be crafted
4. **Linux kernel driver ioctl bug** — triggered from user space, the goal is to escalate privileges to root

**Premise**: You already know 'where it exploded.' This skill is not responsible for discovering vulnerabilities (that's fuzzing/auditing), it only deals with 'writing exploits from the vulnerability point.'

### Division of Labor with Other Skills

| Scene | Use what |
|------|--------|
| Identify custom VM / anti-debug / complex obfuscation | `reverse-engineering/` |
| Open Binary from Scratch for Static Analysis | `ida-reverse/` or `radare2/` |
| **There is a vulnerability, write an exploit to gain remote access** | **This skill** |
| Integrate the shell obtained from pwn into the complete attack chain | `attack-chain/` (downstream) |

`reverse-engineering/` focuses on 'understanding what the program is doing' (pattern recognition, protocol reconstruction, solving strange mechanisms in CTF challenges); this skill focuses on 'turning a vulnerability you already understand into an executable attack.' The two are often used together, but their roles are clearly defined.

## Core Workflow

```text
Step 1: Confirm Vulnerability Type + Protection Mechanism
   ├─ checksec ./vuln（NX / Canary / PIE / RELRO / Fortify）
   ├─ file ./vuln  + readelf -d ./vuln
├─ Vulnerability Classification: Stack Overflow / Format String / Heap (UAF/DF/OF) / Integer / Race Condition / Kernel
└─ → Decide which references/ to go

Step 2: Choose a strategy to use
├─ NX off + no ASLR → direct shellcode
├─ NX enabled + give libc → ret2libc / one_gadget
├─ NX on + not giving libc → leak then reverse lookup libc in libc-database
├─ Heap → According to glibc version corresponding technique (tcache/fastbin/unsorted/large)
└─ Kernel → commit_creds / modprobe_path / core_pattern

Step 3: Prepare libc + gadget
   ├─ libc-database：./find puts 0x6f0
   ├─ ROPgadget --binary ./libc.so.6 --only "pop|ret"
   ├─ one_gadget ./libc.so.6
└─ Calculate base: leak_addr - libc.sym['puts']

Step 4: Write pwntools template (local process)
   ├─ context.binary = ELF('./vuln')
   ├─ p = process('./vuln')  /  p = gdb.debug('./vuln','b *main+xx')
   ├─ payload = cyclic(N) + p64(ret) + ...
   └─ p.interactive()

Step 5: Local Pass
├─ Repeat attach + check registers + adjust offset
├─ Use pwndbg/GEF's vmmap / heap / bins / telescope
└─ After running successfully, switch to remote()

Step 6: Remote Stabilization
├─ libc offset: Use leak to reverse-check the libc-database, don't guess blindly
├─ Stack alignment: 16-byte misalignment → movaps crash → add a ret gadget
├─ Remote network latency → recvuntil exact anchor string, disable fuzzy sleep
├─ Remote buffering: sendlineafter is more stable than sendline
├─ Heap spray success rate: Increase the number of sprays + leave padding chunks to prevent merging
└─ Run multiple times: write while True to verify success rate ≥ 95%
```

## Typical Scenarios

### Scene 1: Remote 64-bit binary (NX+PIE+canary, libc provided)

```text
Already have: ./vuln (64-bit ELF, NX, PIE, canary) + ./libc.so.6 + nc host port
Vulnerability: read(buf, 0x200) but buf is only 0x40 bytes → stack overflow
Protection: Canary intercepts, PIE allows .text randomization

Strategy:
1. First leak canary (stack/format string/partial read)
2. Leak another libc function address (puts@got)
3. Use libc.address = leaked - libc.sym['puts'] to calculate the libc base
4. one_gadget ./libc.so.6 Choose a magic gadget that satisfies a constraint
5. payload = padding + canary + saved_rbp + (pop_rdi + bin_sh + system) or directly one_gadget
6. Add a ret gadget to fix stack alignment (crucial!)
```

For the complete template, see `references/stack-pwn.md`.

### Scenario 2: Linux Kernel Driver ioctl Out-of-Bounds Write → Get Root

```text
Already have: vmlinux + bzImage + initramfs.cpio.gz + custom vuln.ko
Vulnerability: In ioctl(0x1337, ptr), the length in copy_from_user is controllable → kernel heap overflow (kmalloc-64 slab)
Protection: SMEP, SMAP, KASLR, KPTI

Strategy:
1. Modify the init script to get a root shell (CTF) or first leak the KASLR base and then continue (real)
2. Obtain the kernel base address through /proc/kallsyms (possibly restricted) or uninitialized heap spray leak
3. Spray tty_struct / msg_msg / pipe_buffer in the kmalloc-64 slab
4. Overwriting the vtable pointer to point to user mode → Not feasible (SMEP), switch to stack pivot + kernel ROP
5. ROP chain: prepare_kernel_cred(0) → commit_creds → swapgs+iretq → user mode execve("/bin/sh")
6. Or even easier: overwrite modprobe_path with "/tmp/x", write a /tmp/x, and then trigger modprobe
```

For the complete template, see `references/kernel-pwn.md`.

## On-Demand Bootstrap

### Tool Dependencies

| Tool | Purpose | Installation Method |
|------|------|---------|
| pwntools | exploit writing framework | `pip install pwntools` |
| GEF | gdb enhancement (recommended for both kernel + user mode) | `git clone https://github.com/bata24/gef` (actively maintained fork) |
| pwndbg | gdb enhancement (best for heap debugging experience) | `git clone https://github.com/pwndbg/pwndbg && ./setup.sh` |
| ROPgadget | gadget search | `pip install ropgadget` |
| Ropper | gadget search (alternative, supports multiple architectures) | `pip install ropper` |
| one_gadget | libc magic gadget search | `gem install one_gadget` (requires ruby) |
| libc-database | libc fingerprint reverse lookup | `git clone https://github.com/niklasb/libc-database && ./get` |
| qemu-system-x86_64 | Kernel Debugging | `apt install qemu-system-x86` |
| binwalk / cpio | initramfs unpacking | `apt install binwalk cpio` |
| patchelf | Switch libc version | `apt install patchelf` |

### Bootstrap Check Script

```bash
# One-Click Check + Install Core Tools
for t in pwntools ropgadget ropper; do
  pip show $t >/dev/null 2>&1 || pip install $t
done

command -v one_gadget >/dev/null || gem install one_gadget

[ -d ~/tools/libc-database ] || git clone https://github.com/niklasb/libc-database ~/tools/libc-database
[ -d ~/tools/libc-database/db ] || (cd ~/tools/libc-database && ./get ubuntu debian)

[ -d ~/tools/pwndbg ] || (git clone https://github.com/pwndbg/pwndbg ~/tools/pwndbg && cd ~/tools/pwndbg && ./setup.sh)
```

### After the same tool fails to install automatically 2 times

Stop retrying, output structured manual installation steps (pip source / gem source / domestic git mirror / apt source) for user confirmation.

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Trigger Condition**: There is a binary + a recognized vulnerability point, and an exploit needs to be written

**Upstream skills (use them first, then return to this skill):**
- Still don't understand what binary is doing → `reverse-engineering/`
- Requires static detailed analysis → `ida-reverse/`
- Rapid reconnaissance to confirm architecture/protection mechanism → `radare2/`

**Downstream skill (after obtaining the shell)**:
- Integrate into the complete attack chain (lateral movement, privilege escalation, persistence) → `attack-chain/`

**Submodule Navigation**:
- Stack exploitation (ret2libc / ret2csu / one_gadget / stack alignment) → `references/stack-pwn.md`
- Heap exploitation (tcache / fastbin / unsorted / large bin / FILE struct) → `references/heap-pwn.md`
- Kernel pwn (kROP / SMEP-SMAP bypass / KASLR leak / modprobe_path) → `references/kernel-pwn.md`

## Notes

- **Don't submit just because it runs locally** — The local libc / ASLR / network environment is different from the remote one, so you must run it in remote mode more than 20 times consecutively to verify stability
- **The libc version must be confirmed** — use leak + libc-database to check, do not assume it is the default libc of Ubuntu 22.04
- **Stack alignment is a common pitfall in 64-bit** — `movaps xmm0, [rsp]` causes a segmentation fault when rsp is not 16-byte aligned, adding a dummy `ret` gadget fixes it
- **Heap exploitation is extremely sensitive to the glibc version** — tcache was introduced in 2.27, safe-linking in 2.32, hooks were removed in 2.34, and the exploitation path differs for each version
- **Kernel pwn must first check the CPU flags** — whether QEMU startup parameters include +smep +smap +pku directly determines how to write the ROP chain
- **One KASLR leak is enough** — Once you get a kernel address, all addresses are considered offsets; don't leak repeatedly

## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?