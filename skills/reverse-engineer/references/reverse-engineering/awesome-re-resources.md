# Summary of Reverse Engineering Reference Resources

> Selected from multiple awesome lists and sorted by practicality. AI can refer to these resources for methodology and tool guidance during reverse analysis.

---

## Comprehensive Resource Library

| Project | Stars | Coverage | Link |
|------|-------|------|------|
| **awesome-reversing** (tylerha97) | 3k+ | Reverse engineering tools/books/courses/exercises | https://github.com/tylerha97/awesome-reversing |
| **awesome-reverse-engineering** (alphaSeclab) | 4k+ | 3500+ tools + 2300 articles, all platforms | https://github.com/alphaSeclab/awesome-reverse-engineering |
| **Reverse-Engineering** (mytechnotalent) | 10k+ | Free Tutorial: x86/x64/ARM/AVR/RISC-V | https://github.com/mytechnotalent/Reverse-Engineering |
| **awesome-malware-analysis** (rshipp) | 12k+ | Malware analysis tools/resources | https://github.com/rshipp/awesome-malware-analysis |
| **reversingBits** | — | Reverse/Binary Analysis Quick Reference Collection | https://github.com/mohitmishra786/reversingBits |
| **awesome-arm-exploitation** | — | ARM exploitation resources (videos/articles/books) | https://github.com/HenryHoggard/awesome-arm-exploitation |
| **Binary-Analysis-Automation** | — | Automated Binary Analysis (ML/Scripts/Static/Dynamic) | https://github.com/user1342/Awesome-Binary-Analysis-Automation |

---

## ELF / Linux Reverse Engineering Special

| Resource | Description | Link |
|------|------|------|
| **libelfmaster** | Secure ELF parsing library (forensics/malware reconstruction) | https://github.com/elfmaster/libelfmaster |
| **ELF Specification** | Official ELF Format Documentation | https://refspecs.linuxfoundation.org/elf/elf.pdf |
| **Linux Internals** | /proc file system, memory layout, syscall | https://0xax.gitbooks.io/linux-insides/ |
| **Compiler Explorer** | See online what C/C++/Rust/Go compiles into | https://godbolt.org/ |

---

## ARM / AArch64 Special Topics

| Resource | Description | Link |
|------|------|------|
| **ARM Official Architecture Manual** | Complete Instruction Set Reference | https://developer.arm.com/documentation |
| **Azeria Labs** | ARM Assembly/Exploitation Tutorial (Best Beginner Guide) | https://azeria-labs.com/writing-arm-assembly-part-1/ |
| **ARM64 syscall table** | Linux AArch64 system call numbers | https://arm64.syscall.sh/ |
| **QEMU User-mode Emulation** | Analyze ARM binaries without real devices | `qemu-aarch64 -strace ./binary` |

---

## Malware Analysis

| Resource | Description | Link |
|------|------|------|
| **YARA** | Malware signature matching rules | https://github.com/VirusTotal/yara |
| **Volatility 3** | Memory Forensics Framework | https://github.com/volatilityfoundation/volatility3 |
| **FLOSS** | Automatically extract obfuscated strings | https://github.com/mandiant/flare-floss |
| **Detect It Easy (DiE)** | File Type/Shell/Compiler Identification | https://github.com/horsicq/Detect-It-Easy |
| **PE-bear** | PE file analyzer | https://github.com/hasherezade/pe-bear |
| **Capa** | Automatic recognition of binary capabilities (network/file/encryption, etc.) | https://github.com/mandiant/capa |
| **Unpacker** | General Unpacking Framework | https://github.com/malwaretech/UnpackerFramework |

---

## Dynamic Analysis / Sandbox

| Resource | Description | Link |
|------|------|------|
| **Frida** | Cross-platform dynamic instrumentation | https://frida.re/ |
| **strace** | Linux system call tracing | Comes with the system |
| **ltrace** | Library function call tracing | Comes with the system |
| **QEMU** | User-mode/System-mode emulation | https://www.qemu.org/ |
| **Unicorn** | CPU simulation framework (programmable) | https://www.unicorn-engine.org/ |
| **Qiling** | Advanced Binary Emulation Framework | https://qiling.io/ |
| **angr** | Symbolic execution + binary analysis | https://angr.io/ |
| **Triton** | Dynamic Binary Analysis Framework | https://triton-library.github.io/ |

---

## Anti-Obfuscation / Unpacking

| Resource | Description | Link |
|------|------|------|
| **UPX** | The most common packer, `upx -d` unpacking | https://upx.github.io/ |
| **unipacker** | Universal PE Unpacker | https://github.com/unipacker/unipacker |
| **de4dot** | .NET deobfuscation | https://github.com/de4dot/de4dot |
| **JADX** | Android DEX Deobfuscation | https://github.com/skylot/jadx |
| **JEB** | Commercial Android/ARM Decompiler | https://www.pnfsoftware.com/ |
| **Miasm** | Reverse engineering framework (IR/Symbolic Execution/Deobfuscation) | https://github.com/cea-sec/miasm |
| **OLLVM Deobfuscation** | Control Flow Flattening/Obfuscated Control Flow Countermeasures | Recover Using angr/Triton Symbolic Execution |

---

## Online Analysis Platform

| Platform | Description | Link |
|------|------|------|
| **VirusTotal** | Multi-engine scanning + behavior analysis | https://www.virustotal.com/ |
| **Joe Sandbox** | Automated Malware Analysis | https://www.joesandbox.com/ |
| **ANY.RUN** | Interactive Online Sandbox | https://any.run/ |
| **Hybrid Analysis** | Free Malware Analysis | https://www.hybrid-analysis.com/ |
| **Compiler Explorer** | View Compiler Output | https://godbolt.org/ |
| **Dogbolt** | Comparison of Multiple Decompilers (IDA/Ghidra/Binary Ninja) | https://dogbolt.org/ |

---

## Learning Path

### Getting Started (0-3 Months)

1. [Reverse Engineering for Beginners](https://beginners.re/) — Free eBook
2. [Azeria Labs ARM Tutorial ](https://azeria-labs.com/) — ARM Assembly Basics
3. [Nightmare](https://guyinatuxedo.github.io/) — CTF Reverse Engineering/Pwn Tutorial
4. [crackmes.one](https://crackmes.one/) — Reverse Engineering Exercise]

### Advanced (3-12 months)

1. [Practical Binary Analysis](https://practicalbinaryanalysis.com/) — Practical Binary Analysis
2. [The IDA Pro Book](https://nostarch.com/idapro2.htm) — In-depth Use of IDA
3. [Malware Unicorn RE101](https://malwareunicorn.org/workshops/re101.html) — Malware Reverse Engineering
4. [pwnable.kr](http://pwnable.kr/) / [pwnable.tw](https://pwnable.tw/) — Pwn Practice

### Advanced

1. [Modern Binary Exploitation](https://github.com/RPISEC/MBE) — RPI Course
2. [How to Hack Like a Ghost](https://nostarch.com/how-hack-ghost) — Advanced Penetration
3. [Windows Internals](https://docs.microsoft.com/en-us/sysinternals/) — Windows Kernel
4. Practical Exercise: Analyzing Real Malware Samples (MalwareBazaar)

---

## Quick Reference

| Quick Reference | Link |
|--------|------|
| x86/x64 Command Quick Reference | https://www.felixcloutier.com/x86/ |
| ARM64 Instruction Quick Reference | https://developer.arm.com/documentation/ddi0602/latest |
| Linux syscall table (x64) | https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/ |
| Linux syscall table (ARM64) | https://arm64.syscall.sh/ |
| GDB Quick Reference | https://darkdust.net/files/GDB%20Cheat%20Sheet.pdf |
| radare2 Quick Reference | This package `radare2/references/cheatsheet.md` |
| IDA Hotkey | https://hex-rays.com/products/ida/support/freefiles/IDA_Pro_Shortcuts.pdf |
| Ghidra Shortcuts | Ghidra Built-in Help → Keyboard Shortcuts |