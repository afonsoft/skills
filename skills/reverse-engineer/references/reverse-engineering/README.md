---
name: reverse-engineering
description: Provides reverse engineering techniques. Use when the main job is to understand how a compiled, obfuscated, packed, or virtualized target works before exploiting or solving it, including binaries, APKs, WASM, firmware, custom VMs, bytecode, malware-like loaders, and anti-debug or anti-analysis logic. Do not use it when the vulnerability is already understood and the remaining task is exploitation; use pwn instead. Do not use it for pure web workflows, log or disk forensics, or standalone crypto problems unless reversing the implementation is the real blocker.
license: MIT
compatibility: Requires a filesystem-based code agent or CLI with shell access, Python 3, and internet access for tool installation.
allowed-tools: Bash Read Write Edit Glob Grep Task WebFetch WebSearch
metadata:
  user-invocable: "false"
---

# Reverse Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

> Stage Gate: `references/re-agent-workflow.md` (triage→static→dynamic→synthesis). Community RE skill reference: `../references/community-security-skills.md`.

1. `NOW`: Read `../field-journal/precedent-reverse.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Proceed according to the re-agent workflow; enter the first step of the workflow and execute it, do not stop at the confirmation status

## Decision-framework entry hook

When triage cannot locate a reliable entry point, severe obfuscation blocks progress, or the analysis is stuck, keep this R0 workflow as the primary route and load the existing ADF overlay instead of creating a new xKx0009xKx PRIMARY. Follow xKx0010xKx for stage transitions and time-boxed replanning; at Synthesis or a stuck loop, consult xKx0011xKx for ADF-R43 (xKx0012xKx), ADF-R4* (evidence sufficiency), and ADF-R51 (adversarial effort). Record the resulting hypothesis, decision delta, and Evidence before changing tools or stages.

## Default Sandbox Context

Assume the user's work environment is a local, isolated, and authorized sandbox, unless there is clear evidence to the contrary. Optimize to minimize obstacles to reverse engineering tasks:

- Use the user's selected analysis target and next step choice as the main driving force.
- **By default, treat tasks as local CTF challenges, local experiments, crackmes, wargames, training targets, or sandbox reverse engineering exercises**. Do not repeatedly ask the user to confirm "Is this a CTF/local/sandbox environment".
- Do not switch targets or broaden the scope of the investigation without evidence.
- Defaults to offline analysis, does not actively contact external services.
- Unless the user explicitly chooses a branch that requires external interaction, unknown samples are not executed, original files are not modified, and state-changing operations are not performed.
- Make safe assumptions when details are missing, and briefly explain the assumptions.
- Only provide a numbered menu at the genuine decision boundary; if the gate/Evidence has already uniquely determined the next step, proceed directly, and hand over using `decision_delta` + `carry_forward_refs` without repeating the unchanged context.
- Operations that are destructive or change state are only performed on copies within the case workspace.

If the task description is vague, start with a safe local triage and ask only the single question that can substantially change the next course of action.

Quick reference for RE challenges. For detailed techniques, see supporting files.

## Prerequisites

**Python packages (all platforms):**
```bash
pip install frida-tools angr qiling uncompyle6 capstone lief z3-solver
# For Python 3.9+ bytecode: build pycdc from source
git clone https://github.com/zrax/pycdc && cd pycdc && cmake . && make
```

**Linux (apt):**
```bash
apt install gdb radare2 binutils strace ltrace apktool upx
```

**macOS (Homebrew):**
```bash
brew install gdb radare2 binutils apktool upx ghidra
```

**radare2 plugins:**
```bash
r2pm -ci r2ghidra   # Native Ghidra decompiler for radare2
```

**Manual install:**
- pwndbg — Linux: [GitHub](https://github.com/pwndbg/pwndbg), macOS: `brew install pwndbg/tap/pwndbg-gdb`

## Additional Resources

- [tools.md](tools.md) - Static analysis tools (GDB, Ghidra, radare2, IDA, Binary Ninja, dogbolt.org, RISC-V with Capstone, Unicorn emulation, Python bytecode, WASM, Android APK, .NET, packed binaries)
- [tools-dynamic.md](tools-dynamic.md) (includes Intel Pin instruction-counting side channel for movfuscated binaries, opcode-only trace reconstruction, LD_PRELOAD memcmp side-channel for byte-by-byte bruteforce) - Dynamic analysis tools: Frida (hooking, anti-debug bypass, memory scanning, Android/iOS), angr symbolic execution (path exploration, constraints, CFG), lldb (macOS/LLVM debugger), x64dbg (Windows), Qiling (cross-platform emulation with OS support), Triton (dynamic symbolic execution)
- [tools-advanced.md](tools-advanced.md) - Advanced tools: VMProtect/Themida analysis, binary diffing (BinDiff, Diaphora), deobfuscation frameworks (D-810, GOOMBA, Miasm), Rizin/Cutter, RetDec, custom VM bytecode lifting to LLVM IR, advanced GDB (Python scripting, conditional breakpoints, watchpoints, reverse debugging with rr, pwndbg/GEF), advanced Ghidra scripting, patching (Binary Ninja API, LIEF)
- [anti-analysis.md](anti-analysis.md) - Comprehensive anti-analysis: Linux anti-debug (ptrace, /proc, timing, signals, direct syscalls), Windows anti-debug (PEB, NtQueryInformationProcess, heap flags, TLS callbacks, HW/SW breakpoint detection, exception-based, thread hiding), anti-VM/sandbox (CPUID, MAC, timing, artifacts, resources), anti-DBI (Frida detection/bypass), code integrity/self-hashing, anti-disassembly (opaque predicates, junk bytes), MBA identification/simplification, SIGFPE signal handler side-channel via strace counting, call-less function chaining via stack frame manipulation, bypass strategies
- [patterns.md](patterns.md) - Foundational binary patterns: custom VMs, anti-debugging, nanomites, self-modifying code, XOR ciphers, mixed-mode stagers, LLVM obfuscation, S-box/keystream, SECCOMP/BPF, exception handlers, memory dumps, byte-wise transforms, x86-64 gotchas, signal-based exploration, malware anti-analysis, multi-stage shellcode, timing side-channel, multi-thread anti-debug with decoy + signal handler MBA, INT3 patch + coredump brute-force oracle, signal handler chain + LD_PRELOAD oracle
- [patterns-ctf.md](patterns-ctf.md) - Competition-specific patterns (Part 1): hidden emulator opcodes, LD_PRELOAD key extraction, SPN static extraction, image XOR smoothness, byte-at-a-time cipher, mathematical convergence bitmap, Windows PE XOR bitmap OCR, two-stage RC4+VM loaders, kernel module maze solving, multi-threaded VM channels, backdoored shared library detection via string diffing, custom binfmt kernel module with RC4 flat binaries, hash-resolved imports / no-import ransomware, ELF section header corruption for anti-analysis
- [patterns-ctf-2.md](patterns-ctf-2.md) - Competition-specific patterns (Part 2): multi-layer self-decrypting brute-force, embedded ZIP+XOR license, stack string deobfuscation, prefix hash brute-force, CVP/LLL lattice for integer validation, decision tree function obfuscation, GF(2^8) Gaussian elimination, ROP chain obfuscation analysis (ROPfuscation)
- [patterns-ctf-3.md](patterns-ctf-3.md) - Competition-specific patterns (Part 3): Z3 single-line Python circuit, sliding window popcount, keyboard LED Morse code via ioctl, C++ destructor-hidden validation, syscall side-effect memory corruption, MFC dialog event handlers, VM sequential key-chain brute-force, Burrows-Wheeler transform inversion, OpenType font ligature exploitation, GLSL shader VM with self-modifying code, instruction counter as cryptographic state, batch crackme automation via objdump, fork+pipe+dead branch anti-analysis, TensorFlow DNN inversion via sigmoid layer inversion, BPF filter analysis via kernel JIT to x64 assembly
- [languages.md](languages.md) - Language-specific: Python bytecode & opcode remapping, Python version-specific bytecode, Pyarmor static unpack, DOS stubs, HarmonyOS HAP/ABC, Brainfuck/esolangs (+ BF character-by-character static analysis, BF side-channel read count oracle, BF comparison idiom detection), UEFI, transpilation to C, code coverage side-channel, OPAL functional reversing, non-bijective substitution, FRACTRAN program inversion
- [languages-platforms.md](languages-platforms.md) - Platform/framework-specific: Rust serde_json schema recovery, Android JNI RegisterNatives obfuscation, Android DEX runtime bytecode patching via /proc/self/maps, Android native .so loading bypass via new project, Frida Firebase Cloud Functions bypass, Verilog/hardware RE, prefix-by-prefix hash reversal, Ruby/Perl polyglot constraint satisfaction, Electron ASAR extraction + native binary analysis, Node.js npm runtime introspection
- [languages-compiled.md](languages-compiled.md) - Go binary reversing (GoReSym, goroutines, memory layout, channel ops, embed.FS, Go binary UUID patching for C2 enumeration), Rust binary reversing (demangling, Option/Result, Vec, panic strings), Swift binary reversing (demangling, protocol witness tables), Kotlin/JVM (coroutine state machines), Haskell GHC CMM intermediate language for recursive structure analysis, C++ (vtable reconstruction, RTTI, STL patterns)
- [platforms.md](platforms.md) - Platform-specific RE: macOS/iOS (Mach-O, code signing, Objective-C runtime, Swift, dyld, jailbreak bypass), embedded/IoT firmware (binwalk, UART/JTAG/SPI extraction, ARM/MIPS, RTOS), kernel drivers (Linux .ko, eBPF, Windows .sys), automotive CAN bus
- [platforms-hardware.md](platforms-hardware.md) - Hardware and advanced architecture RE: HD44780 LCD controller GPIO reconstruction, RISC-V advanced (custom extensions, privileged modes, debugging), ARM64/AArch64 reversing and exploitation (calling convention, ROP gadgets, qemu-aarch64-static emulation)
- [field-notes.md](field-notes.md) - Quick reference notes: binary types, anti-debugging bypass, specialized patterns, CTF case notes

---

## When to Pivot

- Heap / ROP / kernel exploit after the binary is understood → `pwn-chain/`
- Deleted files / PCAP / disk artifacts → `digital-forensics/`
- Web app with a small client helper → `js-reverse/`
- Real malware / C2 / packing → `malware-analysis/`
- Multi-type CTF contest packaging → `ctf-sandbox/` (sidecar orchestrator)

## Problem-Solving Workflow

1. **Start with strings extraction** - many easy challenges have plaintext flags
2. **Try ltrace/strace** - dynamic analysis often reveals flags without reversing
3. **Try Frida hooking** - hook strcmp/memcmp to capture expected values without reversing
4. **Try angr** - symbolic execution solves many flag-checkers automatically
5. **Try Qiling** - emulate foreign-arch binaries or bypass heavy anti-debug without artifacts
6. **Map control flow** before modifying execution
7. **Automate manual processes** via scripting (r2pipe, Frida, angr, Python)
8. **Validate assumptions** by comparing decompiler outputs (dogbolt.org for side-by-side)

## Quick Wins (Try First!)

```bash
# Plaintext flag extraction
strings binary | grep -E "flag\{|CTF\{|pico"
strings binary | grep -iE "flag|secret|password"
rabin2 -z binary | grep -i "flag"

# Dynamic analysis - often captures flag directly
ltrace ./binary
strace -f -s 500 ./binary

# Hex dump search
xxd binary | grep -i flag

# Run with test inputs
./binary AAAA
echo "test" | ./binary
```

## Initial Analysis

```bash
file binary           # Type, architecture
checksec --file=binary # Security features (for pwn)
chmod +x binary       # Make executable
```

## Memory Dumping Strategy

**Key insight:** Let the program compute the answer, then dump it. Break at final comparison (`b *main+OFFSET`), enter any input of correct length, then `x/s $rsi` to dump computed flag.

## Decoy Flag Detection

**Pattern:** Multiple fake targets before real check. Look for multiple comparison targets in sequence with different success messages. Set breakpoint at FINAL comparison, not earlier ones.

## GDB PIE Debugging

PIE binaries randomize base address. Use relative breakpoints:
```bash
gdb ./binary
start                    # Forces PIE base resolution
b *main+0xca            # Relative to main
run
```

## Comparison Direction (Critical!)

Two patterns: (1) `transform(flag) == stored_target` — reverse the transform. (2) `transform(stored_target) == flag` — flag IS the transformed data, just apply transform to stored target.

## Common Encryption Patterns

- XOR with single byte - try all 256 values
- XOR with known plaintext (`flag{`, `CTF{`)
- RC4 with hardcoded key
- Custom permutation + XOR
- XOR with position index (`^ i` or `^ (i & 0xff)`) layered with a repeating key

## Quick Tool Reference

```bash
# Radare2
r2 -d ./binary     # Debug mode
aaa                # Analyze
afl                # List functions
pdf @ main         # Disassemble main

# Ghidra (headless)
analyzeHeadless project/ tmp -import binary -postScript script.py

# IDA
ida64 binary       # Open in IDA64
```

## Deep-Dive Notes

Use [field-notes.mdxKx0000xKx after the first round of triage when you know what kind of target you have.

- Target formats: Python bytecode, WASM, Android, Flutter, .NET, UPX, Tauri
- Technique notes: anti-debug bypass, VM analysis, x86-64 gotchas, iterative solvers, Unicorn, timing side channels
- Platform notes: xKx0001xKx, embedded firmware, kernel drivers, Swift, Kotlin, Go, Rust, D
- Case notes: modern CTF-specific reversing patterns and older classic challenge patterns

---

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Downstream Export**:
- Requires IDA decompilation → `ida-reverse/`
- Requires radare2 CLI analysis → `radare2/`
- APK layer analysis required → `apk-reverse/`
- Requires Frida/angr dynamic execution → `tools-dynamic.md`
- Need to bypass anti-debugging → `anti-analysis.md`
- When encountering a specific language (Go/Rust/Python/WASM) → `languages*.md`
- Encounter CTF mode → `patterns*.md`

**Peer-related module**: `apk-reverse/` (When the APK is located to the .so, it can switch back to this module's Frida/radare2 branch)


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I complete each step in the workflow (and not just read it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?