# OLLVM Deobfuscation / Obfuscator-LLVM Deobfuscation

OLLVM deobfuscation workflow for APK .so, ELF binaries, and control flow flattening scenarios.
> Tool and variant information is based on the 2026 community active project survey, not on training memory.
> Applicable: Android NDK hardening, CTF reverse engineering, analysis of packed .so files, countering commercial obfuscators.

---

## 0. Quick Decision: Which Tool Should I Use?

Directly match according to your environment and judgment of the target type of confusion:

| Your Situation | Preferred Tool | Alternative | Notes |
|---------|---------|------|------|
| Have IDA Pro 7.5-7.7 + Hex-Rays, want to deobfuscate with one click | **obpo-plugin** | d810-ng | obpo uses microcode + data flow + hybrid execution, most effective, but cloud plugin (requires internet, core closed-source) |
| Has IDA Pro (any recent version), wants a local one-stop deobfuscation | **d810-ng** | Original D-810 | Local, open-source, integrates Z3, supports various OLLVM/Tigress/Hodur/Approov variants |
| Has Binary Ninja | **ollvm-breaker** | — | Practical cases for Android .so (reinforced samples like libvdog) |
| No IDA/BN, pure script, target x86/x64 | **ollvm-unflattener** (Miasm) | angr deflat | Based on Miasm symbolic execution, BFS multi-layer processing |
| No IDA/BN, pure script, target x86/x64 | **ollvm-unflattener** (Miasm) | angr deflat | Based on Miasm symbolic execution, BFS multi-layer processing |
| Pure Python symbolic execution, CTF scenarios | **angr** Deobfuscator | Triton | GUI-independent, scriptable |
| Target is ARM64 .so, no IDA | **deollvm** (Unicorn) | angr | ARM64 deflat based on Unicorn |
| Encounter BR Obfuscation (Indirect Branch) | **DeObfBR** | Set data segment to read-only | Goron/Arkari style BR obfuscation can be easily countered by setting the data segment to read-only |
| Encounter Tigress Confusion | d810-ng `UnflattenerSwitchCase`/`UnflattenerTigressIndirect` | — | d810-ng Built-in Tigress Dedicated Unflattener |

> **Core Recommendation:** Prioritize using **d810-ng** (local, actively maintained, wide variant coverage). When cloud services are available, **obpo-plugin** works best. If both fail, then use **angr/Miasm** symbolic execution for customized handling.

---

## 1. Modern OLLVM Variant Ecosystem (2026 Community Survey)

OLLVM has long ceased to be just the original repository from 2017. The following are currently active obfuscator branches, and **before deobfuscating, it is necessary to determine which variant the target is**, because the countermeasures for different variants vary greatly:

### 1.1 Obfuscator Branch Lineage

| Variant | Baseline LLVM | New Features Compared to Original OLLVM | Key Points for Attack |
|------|----------|----------------------|---------|
| **Obfuscator** (Original) | 3.3~4.0 | sub + bcf + fla (three basic passes) | Standard tools can handle
| **Hikari** | 6~8 | Anti Class Dump, Function Call Obfuscate, Function Wrapper, Indirect Branching, Split BB, String Encryption | Requires decrypting strings first + fixing indirect jumps |
| **Hikari-LLVM15** | 15~19 | + Anti Debugging, Anti Hook, Constant Encryption | Closed source; Constant Encryption increases the difficulty of static analysis |
| **goron** | 7~10 | Indirect Branch/Call/GlobalVariable | ⚠️ Goron-style indirect obfuscation can be easily countered by 'setting the data segment to read-only' |
| **Arkari** (komimoe/Hikari) | 14~latest | Based on goron, continuously maintained | Same as goron, data segment read-only can partially counter
| **Pluto** | 14 | MBA Obfuscation, Random CF, Split BB, **Trap Angr** (specifically traps angr) | ⚠️ Trap Angr pass will cause angr symbolic execution to fail, need to change tools or bypass the trap |
| **Polaris** (originally Pluto) | 16 | Alias Access, Indirect Branch/Call, String Encryption, Merge Function, Linear MBA, Dirty Bytes Insertion, Function Splitting, Junk Insertion | Integration of Hikari + Pluto, the most troublesome, requires layered handling |
| **O-MVLL** | open-obfuscator | Python-driven pass manager; Anti Hooking, Arithmetic (MBA), BB Duplicate, CF Breaking, Function Outline, Indirect Branch/Call, Opaque Constants | Commonly used in modern Android protection, Python configuration is easy to customize |
| **amice** (Rust) | Rust implementation | Complete set + VM Flatten, Instruction Virtualization, Delayed Offset Loading, Parameter Aggregation | Includes VM transformation, requires VM handler restoration rather than simple deflat |
| **VMP System** (SmallVmp/VMPilot/xVMP/VMPacker) | — | Instruction Virtualization | **Not within the scope of OLLVM**, requires VM reverse engineering, refer to VM-specific tools |

### 1.2 Key Clues for Judgment

- **Trap Angr** (Pluto/Polaris): If angr crashes while running or path explosion occurs, suspect the target used the Trap Angr pass → switch to d810-ng or Unicorn dynamic methods
- **Goron/Arkari Indirect Jump**: If the dispatcher uses an indirect jump (BR x8 instead of switch), first try to set the related data segment to read-only. The target of the indirect jump often becomes solvable statically.
- **Constant Encryption** (Hikari-LLVM15/Polaris/O-MVLL): Constants are decrypted at runtime, the real values are not visible statically → requires Unicorn to dynamically execute the decryption stub
- **VM Flatten** (amice): The control flow becomes a VM dispatch loop. **Do not treat it as ordinary fla processing**; you need to first identify the VM handler table.

---

## 2. OLLVM Obfuscation Type Detection

The identifying features of OLLVM's three core passes:

### 2.1 Control Flow Flattening (Control Flow Flattening / `fla`)

**IDA View Features:**
- The function entry first jumps to the unique dispatcher block
- The main logic is split into multiple basic blocks, each block jumps back to the dispatcher at the end
- The dispatcher determines the next block to execute through **state variables**
- Huge `switch` structure, no logical connection between each case

```
Original:             OLLVM flattened:
  block_A               entry -> dispatcher
  block_B                 ↓
  block_C              state_machine:
                         switch(state):
                           0 → block_A
                           1 → block_B
                           2 → block_C
```

**Variant Forms (Multiple dispatchers identified by d810-ng):**
- O-LLVM: switch / if-chain + state variables
- Tigress: `m_jtbl` (switch-case) or `m_ijmp` (indirect jump, requires `goto_table_info` configuration)
- Hodur (PlugX): Nested `while(1)` state machines, `jnz state, #CONST`, **no switch dispatcher**
- Approov: `while(v8 != C)`, state constants are concentrated in `0xF6000–0xF6FFF`

### 2.2 Bogus Control Flow (Bogus Control Flow / `bcf`)

- Insert **unreachable dummy branches** between each real branch
- Fake branches are protected by **opaque predicates** (conditions that are always true/false, but cannot be directly proven by static analysis)
- A large amount of dead code bloats the function size

```c
// Classic opaque predicate: x(x+1) must be even, the compiler cannot prove it
if (x * (x + 1) % 2 == 0) {
// Real logic
} else {
// Unreachable garbage code
}
```

### 2.3 Instruction Substitution (Instruction Substitution / `sub`) → MBA

- Replace simple arithmetic/bitwise operations with equivalent complex expressions (MBA, Mixed Boolean-Arithmetic)

```
a + b  →  (a ^ b) + 2*(a & b)
a ^ b  →  (a | b) - (a & b)
a - b  →  a + (~b) + 1
```

### 2.4 Quick Classification Table

| Obfuscation Type | IDA Features | Main Countermeasures |
|---------|---------|------------|
| fla (flattening) | huge switch + distributor | obpo / d810-ng / deflat |
| bcf (False Control Flow) | Unreachable Branch + Dead Code | d810-ng opaque predicate removal / Symbolic Execution |
| sub/MBA | Complex arithmetic expression | d810-ng MBA simplifier / SiMBA (Z3) |
| fla + bcf + sub | Fully up, extremely swollen | **Layered de-obfuscation (first bcf, then fla, then sub)** |

---

## 3. Detailed Explanation of Mainstream Tools (Active Community Projects)

### 3.1 obpo-plugin — The Most Powerful Effect, Cloud Plugin

> [obpo-project/obpo-plugin](https://github.com/obpo-project/obpo-plugin) · 629⭐ · Active in 2026-06]

A pseudocode optimizer based on Hex-Rays **microcode**, using **data flow tracking + program slicing + concolic execution** to reconstruct flattened control flow. It is widely recognized in the community as one of the strongest.

**Key Features:**
- Operate at the microcode level, directly optimizing the decompiled output (not modifying the ASM)
- Supports IDA 7.5.0 / 7.6.0 / 7.7.0 + Hex-Rays
- Architectures: ARM, ARM64, x86, x86_64, PowerPC, PowerPC64, MIPS (7.6/7.5)
- **Cloud Plugin**: The target function binary will be uploaded to the obpo-server for processing (core is closed-source, plugin is free and open-source)
- Server maintenance at own expense, timeout 600s, **multithreading/malicious calls prohibited**

**Installation and Use:**```text
1. Download obpo_plugin.py and the obpoplugin directory
2. Copy to the IDA plugins path
3. Restart IDA and open the target binary
4. Locating the dispatcher block in the CFG, it usually looks like this:
[Screenshot reference repository assets/dispatchblock.png]
5. Right-click → OBPO → Mark and process function
6. Refresh the decompiler after processing
7. New distribution blocks can continue to be marked based on changes from decompilation (iteratively processing nested fla)
```

**Applicable Scenarios and Limitations:**
- ✅ Standard and nested fla, good effect
- ⚠️ Internet connection required, use caution with sensitive samples (unpublished internal vulnerabilities, trade secrets) — the binary will be uploaded
- ⚠️ The server may go down, relying on the author's maintenance
- ❌ Cannot resolve all confusion (explicitly stated by the author)

### 3.2 d810-ng — Local One-Stop First Choice

> [w00tzenheimer/d810-ng](https://github.com/w00tzenheimer/d810-ng) · 223⭐ · Updated on 2026-06-26

The modern maintenance/refactored version of D-810 (Next Generation). Runs locally, open source, integrates the **Z3 SMT** solver, with the widest variant coverage.

**Core Competencies (compiled according to the d810-ng README):**

*Instruction-level optimization:*
| Category | Description |
|------|------|
| MBA simplification | `(a+b)-2*(a&b) => a^b`, DSL rules verified by Z3 |
| Hacker's Delight | Bitwise operation equivalences (from the book Hacker's Delight) |
| O-LLVM patterns | Obfuscator-LLVM specific MBA patterns |
| Constant folding | 22 constant simplification rules |
| Predicate simplification | Opaque predicate removal (setz/setnz/lnot/smod) |
| Z3 rules | Use SMT to solve when template matching fails |
| Hodur-specific | MBA mode of PlugX (Hodur) malware |

*Control Flow Unflattener (by target obfuscation category):*
| Unflattener | Target | Description |
|------------|------|------|
| `Unflattener` | O-LLVM | Standard switch/if-chain + State Variables |
| `UnflattenerSwitchCase` | Tigress | Tigress switch-case dispatch (`m_jtbl`) |
| `UnflattenerTigressIndirect` | Tigress | Tigress indirect jump (`m_ijmp`), requires `goto_table_info` configuration |
| `HodurUnflattener` | Hodur (PlugX) | Nested `while(1)` + `jnz state, #CONST`, no switch |
| `BadWhileLoop` | Approov | `while(v8 != C)`, status constants in 0xF6000–0xF6FFF |
| `UnflattenerFakeJump` | General | Remove always-true/always-false conditional jumps |
| `SingleIterationLoopUnflattener` | Residue | Clean `INIT == CHECK` and `UPDATE != CHECK` single cycle |
| `UnflattenControlFlowRule` (Experiment) | General | CFG unflattener based on path emulation |

**Installation and Use:**```text
1. clone d810-ng
2. Install dependencies (including Z3)
3. Copy to the IDA plugins directory
4. Load the plugin in IDA by pressing Ctrl-Shift-D
5. Check the rule set to apply in the GUI
6. Apply to the objective function
```

**Why choose the d810-ng instead of the original D-810:**
- The original D-810 is now less maintained
- d810-ng has CI testing, refactoring code, and adding a dedicated unflattener for Tigress/Hodur/Approov
- Integrate Z3, fall back to SMT solving when template matching fails, higher success rate

### 3.3 ollvm-unflattener — Miasm Symbolic Execution, Pure Script

> [cdong1012/ollvm-unflattener](https://github.com/cdong1012/ollvm-unflattener) · 265⭐ · Active in 2026-06]

Based on the **Miasm** symbolic execution engine, it does not rely on IDA/BN, purely a Python command line.

**Features:**
- Use Miasm symbolic execution to restore the original control flow (as opposed to MODeflattener's purely static method)
- **BFS multi-layer processing**: Automatically follows the calls of the target function, recursively obfuscating
- Support Windows/Linux x86/x64
- Output the deobfuscated new binary

**Installation and Use:**```bash
git clone https://github.com/cdong1012/ollvm-unflattener.git
cd ollvm-unflattener
pip install -r requirements.txt   # miasm, graphviz, keystone-engine

# Basic Usage
python unflattener -i <input.bin> -o <output.bin> -t <function_addr> -a
# -a: Automatically follow calls to perform multi-level processing
```

**Applicable:** No IDA, target x86/x64, requires batch scripting processing.

### 3.4 ollvm-breaker — Binary Ninja Practical Application

> [xKx0001xKxxKx0002xKx · 441⭐

Use **Binary Ninja** to flatten. The repository comes with an Android protection sample `libvdog.so` as a test case, with functions such as JNI_OnLoad, crazy::GetPackageName, and prevent_attach_one already fixed.

**Applicable to:** Binary Ninja users, Android .so practical exercises.

### 3.5 deollvm — ARM64 Unicorn

> [xKx0004xKxxKx0005xKx · 34⭐ · 2026-04

ARM64 OLLVM deflate based on **Unicorn**. An alternative for handling ARM64 .so files when IDA is not available.

### 3.6 DeObfBR — BR Obfuscation Special

> [xKx0006xKxxKx0007xKx · 96⭐ · 2026-06-25

Specifically removes **BR obfuscation** (indirect branch obfuscation, Goron/Arkari style).

**⚠️ Simple Anti-Reverse Techniques (from awesome-ollvm):** Goron/Arkari style indirect-related obfuscation can be simply countered by **setting the data section to read-only** — indirect jump targets often rely on runtime writable data sections, and setting them to read-only makes them statically solvable.

### 3.7 angr — General Framework for Symbolic Execution

```python
import angr

proj = angr.Project("target.so", auto_load_libs=False)
cfg = proj.analyses.CFGFast()
func = proj.kb.functions[0x12345]

# Built-in Deobfuscator
deob = proj.analyses.Deobfuscator(func=func)
deob.normalize()
```

**⚠️ Pluto/Polaris's Trap Angr pass:** These two variants specifically write traps to fool angr symbolic execution. If the angr path explodes or behaves abnormally, it is suspected that the target used Trap Angr → switch to d810-ng or Unicorn dynamic methods.

---

## 4. Complete De-identification Workflow (by Scenario)

### 4.1 General Decision Tree

```
Target binary
  ↓
1. Identify OLLVM variants (see clues in Section 1.2)
├── Original OLLVM / Hikari / O-MVLL  → Standard fla/bcf/sub
├── Pluto / Polaris                → Note Trap Angr, avoid angr
├── Goron / Arkari                 → First try the data segment as read-only, then handle BR
  ├── Tigress                        → d810-ng Tigress unflattener
  ├── Hodur (PlugX)                  → d810-ng HodurUnflattener
└── amice (including VM)                  → Not just a simple fla, requires VM handler to restore
  ↓
2. Select tools (see decision table in Section 0)
├── Has IDA + network-capable + non-sensitive sample → obpo-plugin
├── Has IDA + local              → d810-ng
├── Has Binary Ninja            → ollvm-breaker
├── No GUI + x86/x64           → ollvm-unflattener (Miasm)
├── No GUI + ARM64             → deollvm (Unicorn) / angr
└── Pure Symbolic Execution / CTF           → angr
  ↓
3. Layered deobfuscation (order is very important)
a) First remove opaque predicates (bcf) → d810-ng opaque predicate removal
b) Then remove control flow flattening (fla) → unflattener
c) Final simplified MBA (sub)       → d810-ng MBA simplifier / SiMBA
  ↓
4. Verification
├── Function size significantly reduced?
├── CFG changes from star/radial form to chain/tree form?
└── Frida hook key function to verify logic correctness?
```

### 4.2 Android NDK .so De-obfuscation Project

The .so compiled with Android NDK and reinforced by OLLVM is the most common scenario for APK reverse engineering.

**Step 1 — Extract .so:**```bash
adb pull /data/app/~~/lib/arm64/libnative.so
# Or directly extract from the APK: unzip target.apk -d out/ ; find out -name "*.so"
```

**Step 2 — Identify OLLVM and its variants:**```bash
readelf -a libnative.so | grep -E "Size|text"   # .text is abnormally large but has few functions → most likely OLLVM
# Open in IDA to view function characteristics:
#   Huge switch → fla
#   Unreachable branch → bcf
#   Complex Arithmetic → sub/MBA
#   Indirect jump BR x8 → Goron/Arkari, test data segment is read-only
#   while(1) + jnz state → Hodur, use d810-ng HodurUnflattener```

**Step 3 — Declassify (Layering):**```
a) bcf: d810-ng opaque predicate removal (or obpo automatic processing)
b) fla: d810-ng Unflattener / obpo-plugin / deollvm(ARM64)
c) sub: d810-ng MBA simplifier
```

**Step 4 — Frida Dynamic Verification:**xKx0000xKx`javascript
// Trace OLLVM state variables, assisting deflat in determining state variable addresses
const target = Module.findBaseAddress("libnative.so");
console.log("[+] libnative.so @", target);

// Hook under the dispatcher entry to observe the sequence of state changes
Interceptor.attach(target.add(0x1234), {  // dispatcher offset
    onEnter(args) {
// Read the status variable (need to determine register/stack position based on decompilation)
        console.log("[state]", this.context.x8);  // Assuming state is in x8
    }
});```

### 4.3 Quick Declassification in CTF Scenarios

CTF usually has tight time limits, prioritize using the fastest path:

```python
#!/usr/bin/env python3
"""CTF OLLVM quick deflat with angr"""
import angr

proj = angr.Project("challenge", auto_load_libs=False)
cfg = proj.analyses.CFGFast()

# Find the largest few functions (most likely obfuscated)
funcs = sorted(cfg.functions.values(), key=lambda f: f.size, reverse=True)[:5]
for func in funcs:
    print(f"[*] {func.name} @ {hex(func.addr)} size={hex(func.size)}")
    try:
        deob = proj.analyses.Deobfuscator(func=func)
        deob.normalize()
        print(f"    [+] deobfuscated")
    except Exception as e:
        print(f"    [-] failed: {e}")
# angr failed → suspect Trap Angr → switch to d810-ng / Unicorn
```

---

## 5. MBA Expression Simplification

### 5.1 Common OLLVM MBA Patterns

```python
# These equations are the simplification targets for expressions generated by the OLLVM sub pass
"(a | b) + (a & b)"        # → a + b
"(a | b) - (a & b)"        # → a ^ b
"(a ^ b) + 2*(a & b)"      # → a + b
"(a | b) & ~(a & b)"       # → a ^ b
"~(~a & ~b)"               # → a | b (De Morgan)
```

### 5.2 Tool Selection

| Tool | Method | Applicable |
|------|------|------|
| **d810-ng MBA simplifier** | Batch processing in IDA, Z3 verification | Preferred, integrated into the decompilation process |
| **SiMBA** (`pip install simba-simplifier`) | Command Line/Library | Pure Expression Simplification, Batch Processing |
| **Arybo** | Sign-bit vector | Large number of MBA expressions |
| **Z3 Direct Solving** | SMT | Most general, when template matching fails |

```python
# SiMBA Example
from simba import simplify_mba
exprs = ["(a | b) + (a & b)", "(a ^ b) + 2*(a & b)"]
for e in exprs:
    print(f"{e}  →  {simplify_mba(e)}")
```

---

## 6. Complete De-identification Case Script

```bash
#!/xKx0000xKx
# OLLVM deobfuscation pipeline (2026 community tools)
# Applicable Standards OLLVM / Hikari / O-MVLL Reinforced xKx0001xKx

BINARY=$1

echo "[*] Stage 0: Basic Analysis and Variant Identification"
file $BINARY
readelf -h $BINARY 2>/dev/null | head -5
echo "    → Confirm the variant in IDA (refer to Section 1)"

echo "[*] Stage 1: d810-ng local deobfuscation (preferred)"
echo "    IDA → Ctrl-Shift-D load d810-ng"
echo "    Check: MBA + Opaque predicate + Unflattener"
echo "    Apply to target functions"
echo "    Save IDB"

echo "[*] Stage 2: obpo-plugin (if d810-ng is insufficient and can connect to the network)"
echo "    IDA → Right-click dispatcher → OBPO → Mark and process"
echo "    ⚠️ Do not use sensitive samples (upload binary to cloud service)"

echo "[*] Stage 3: No IDA alternative (x86/x64)"
echo "    python unflattener -i $BINARY -o deobf.bin -t <func_addr> -a"

echo "[*] Stage 4: ARM64 .so without IDA alternative"
echo "    deollvm (Unicorn) or angr Deobfuscator"

echo "[+] Done. Reanalyze in IDA to verify."```

---

## 7. Common Pitfalls (Community Practice Summary)

| Problem | Cause | Solution |
|------|------|---------|
| angr path explosion/abnormal exit | Pluto/Polaris's **Trap Angr** pass | switch to d810-ng or Unicorn dynamic method |
| obpo-plugin cannot connect | Server maintained at own expense, may be down | Switch to local d810-ng; issues can be submitted in the obpo repository |
| Goron/Arkari indirect jump deflat failed | Dispatcher uses BR x8 instead of switch | First set the data segment to read-only, then use DeObfBR |
| d810-ng processed functions are still messy | OLLVM customizes pass parameters/seed | First perform symbolic execution to handle opaque predicates, then unflatten |
| Nested fla (multi-layer flattening) was never cleaned completely | obpo/d810-ng Only one layer is cleaned at a time | **Iterative processing**: each time mark the newly appeared dispatcher |
| ARM64 .so throws an error with deflat | Old deflat script only supports x86 | Use d810-ng / obpo (supports ARM64) / deollvm |
| Hikari strings are not visible | String Encryption pass | Use Unicorn to emulate and decrypt the stub, dump the decrypted strings |
| amice target deflat is completely ineffective | Includes VM Flatten / Instruction Virtualization | **Not OLLVM fla**, requires VM handler restoration (refer to VM reverse engineering) |
| Hodur(PugX) sample has no switch dispatcher | Nested while(1) + jnz state | Use d810-ng **HodurUnflattener**, do not use the regular Unflattener |
| Approov sample status constants show no pattern | Constants concentrated in 0xF6000–0xF6FFF | Use d810-ng **BadWhileLoop** unflattener |
| Misuse of sensitive samples obpo | Binary upload cloud service | Confidential/unpublished vulnerability samples **only use local tools** (d810-ng/angr) |
| Frida hook OLLVM function freezes | State variable change causes infinite loop | Add conditional breakpoint at dispatcher entry to limit execution times |

---

## 8. Tool Quick Reference (2026 Community Activity)

| Tool | Platform | Method | Stars/Price | Recent Update | Open Source | Notes |
|------|------|------|---------|---------|------|------|
| **obpo-plugin** | IDA | microcode+concolic (cloud) | 629 | 2026-06 | Plugin open source / core closed source | Most effective, requires internet connection |
| **ollvm-breaker** | Binary Ninja | BN API | 441 | 2026-06 | ✅ | Android .so Practical Combat |
| **ollvm-unflattener** | CLI | Miasm symbolic execution | 265 | 2026-06 | ✅ | x86/x64, BFS multi-layer |
| **d810-ng** | IDA | microcode+Z3 | 223 | 2026-06 | ✅ | **Locally preferred**, wide variant coverage |
| **DeObfBR** | — | BR Obfuscation Special | 96 | 2026-06 | ✅ | Goron/Arkari Indirect Branch |
| **IDA_Ollvm-unflattener** | IDA | Miasm plugin version | 90 | 2026-04 | ✅ | IDA plugin encapsulation of ollvm-unflattener |
| **deollvm** | CLI | Unicorn | 34 | 2026-04 | ✅ | ARM64 Special |
| **angr** | CLI | Symbolic Execution | — | Active | ✅ | General, countered by Trap Angr |
| **SiMBA** | CLI/Library | MBA Simplification | — | — | ✅ | Expression Simplification |
| **Triton** | CLI | Symbolic Execution + Taint | — | Active | ✅ | Dynamic Symbolic Execution |

---

## 9. Reference Links

**Confuser (for understanding adversarial targets):**
- [obfuscator-llvm/obfuscator](https://github.com/obfuscator-llvm/obfuscator) — Original OLLVM
- [HikariObfuscator/Hikari](https://github.com/HikariObfuscator/Hikari) — Hikari
- [komimoe/Hikari](https://github.com/komimoe/Hikari) — Arkari (based on goron, LLVM 14+)
- [amimo/goron](https://github.com/amimo/goron) — goron
- [bluesadi/Pluto](https://github.com/bluesadi/Pluto) — Pluto
- [za233/Polaris-Obfuscator](https://github.com/za233/Polaris-Obfuscator) — Polaris (originally Pluto)
- [open-obfuscator/o-mvll](https://github.com/open-obfuscator/o-mvll) — O-MVLL
- [fuqiuluo/amice](https://github.com/fuqiuluo/amice) — Rust implementation of OLLVM passes
- [lich4/awesome-ollvm](https://github.com/lich4/awesome-ollvm) — **Overview of Variant Ecology (Highly Recommended to Read First)****

**Deobfuscation Tool:**
- [obpo-project/obpo-plugin](https://github.com/obpo-project/obpo-plugin) — The Strongest Cloud Plugin
- [w00tzenheimer/d810-ng](https://github.com/w00tzenheimer/d810-ng) — Local Preferred
- [cdong1012/ollvm-unflattener](https://github.com/cdong1012/ollvm-unflattener) — Miasm Pure Script
- [amimo/ollvm-breaker](https://github.com/amimo/ollvm-breaker) — Binary Ninja
- [GeT1t/deollvm](https://github.com/GeT1t/deollvm) — ARM64 Unicorn
- [Mrack/DeObfBR](https://github.com/Mrack/DeObfBR) — BR Obfuscation Special
- [maskelihileci/IDA_Ollvm-unflattener](https://github.com/maskelihileci/IDA_Ollvm-unflattener) — IDA Plugin Version
- [angr](https://angr.io/) — Symbolic Execution Framework
- [SiMBA](https://github.com/tech-srl/simba) — MBA Simplified

**Academic/Blog:**
- [Quarkslab: Deobfuscation: Recovering an OLLVM-protected program](https://blog.quarkslab.com/deobfuscation-recovering-an-ollvm-protected-program.html) — deflat classic principles
- [MODeflattener](https://github.com/mrT4ntr4/MODeflattener) — Static deflat (counterpart of ollvm-unflattener)

> Related documents: [[anti-analysis.md]] (Anti-Debugging/Anti-Analysis Overview), [[tools-advanced.md]] (Advanced Toolset), [[elf-analysis.md]] (ELF File Analysis), [[ai-assisted-re.md]] (AI-Assisted Reverse Engineering)