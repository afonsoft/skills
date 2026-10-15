# RE Agent Workflow Gate (Static ↔ Dynamic)

> Source Inspiration: binary-re phase division, community RE skill (Frida/r2/Ghidra/IDA loop), Cerberus three-headed ring (static/dynamic/instrumentation)
> Issue #65 Incremental: IAT fix golden rule, six-stage mapping, .NET/DLL·SYS equivalent paths; user instruction feasibility latch; bypass patches 6–10; anti-debug/obfuscation recipes A–T; non-PE multi-format recipes U–AV (2026-08-12) 
> Applicable: `reverse-engineering/`, `ida-reverse/`, `radare2/`, `malware-analysis/`, and handover with the cre role

## 0. Start

```text
□ scope.md: offline sample path or authorized device/target machine
□ tool-index: file/strings/r2/ida/frida and other actual paths
□ Character: cre (ops/role-map)
```

## 0.1 Transition handoff（decision delta）

Do not re-inject the complete case context between stages. `scope.md` / `workitems.md` / Evidence remain authoritative; `timeline.md` only carries the transition delta:

1. stage/turn At the end, only write `decision_delta` for actions that actually change; write `[]` if there is no change.
2. unchanged route/auth/scope/network profile/tool state/hypothesis only put `carry_forward_refs`, the consumer reads according to the reference, without re-serializing/emitting.
3. `decision_delta` is not a complete state; the consumer must first inherit refs, and then apply the delta.
4. Only when there are two or more evidence-supported branches leading to different next actions does it stop at the next-step menu; a deterministic gate proceeds directly.

Example: When Triage is completed and the only valid next step is Static, the transition only requires `decision_delta: [phase=triage->static]` + `carry_forward_refs: [scope.md, evidence/E-triage.md]`.

## 0.5 User Command Feasibility Gate (Issue #65)

**Principle**: Obey the user's **goals**, but do not blindly follow the user's **step sequence**. Before skipping steps, the prerequisites must be explained and confirmed; after confirmation, mandatory steps must be performed, and the quality of the Evidence must be honestly indicated.

| Situation | Agent MUST |
|------|------------|
| The user wants to do X, and the current state can obtain **valid** evidence | Execute X, update the evidence |
| The user wants to do X, but there is a **known blocking prerequisite** (e.g., the file is packed and the static IAT is unreadable) | **Do not** pretend to complete a meaningful IAT; ① Explain the blockage in one sentence; ② Provide a recommended sequence (first unpack/repair IAT, or directly capture API dynamically); ③ **Ask the user to confirm** whether they still want to 'force viewing the current mapping' or 'follow the recommended sequence' |
| The user explicitly **forces** the current step (e.g., even if not unpacked, still check IAT) | Execute and record Evidence, MUST mark `quality=unreadable` / `packed` (or equivalent); **forbidden** to draw conclusions such as "no network capability" based on this |
| User Acceptance of Recommended Sequence | Perform prerequisite steps first; after completion, automatically or upon further request do X; **do not** use prerequisite steps (such as unpacking) to **pretend** that 'import table check' has been completed |

**Relationship with 'Redo X'**: Redoing X still = redoing the specifically mentioned step (or its confirmed legitimate prerequisite negotiation result). Replacing it with unrelated steps is forbidden. Extracting the shell is a **prerequisite** for importing the table, not a **substitute** for importing the table.

Typical conflict: The user says on a packed sample, 'Don't unpack yet, first look at the import table' → The packer often tampers with the import directory/encrypts descriptors, making the static table obfuscated and meaningless → Follow the 'blocking prerequisite' in this table, do not silently unpack and impersonate, and do not silently hand over an obfuscated table as if completed.

## 1. Triage (5–15 minutes · Mandatory starting point)

```text
□ Calculate sample Hash (MD5/SHA256) → Unique ID
□ Identify file types: EXE / DLL / SYS / ELF / Mach-O / .NET / Scripts (bat/ps1/vba) / JS / APK, etc.
□ Non-PE/Script/APK/Driver Special: see §3.4 and `references/nonpe-format-cookbook.md` (U–AV)
□ file / DIE / entropy / shell characteristics (PEiD / DIE / Exeinfo etc.)
□ Architecture: x86 / x64 / ARM; Compilation language clues (VC++ / Delphi / .NET / Go / Rust)
□ Pack type clues: UPX / ASPack / VMProtect / Themida / Unknown obfuscation
□ strings / rabin2 -z pick up bargains
□ MUST import/export anchor points (see below 'Import Table Hard Gate and Equivalent Path'); if the user jumps ahead and there is a shell → first follow §0.5
□ Output: E-triage (MUST include imports or equivalent anchor classification summary, including quality annotation if applicable) + List of assumptions
```

**Phase Gate (Triage → Static/Dynamic)**: Before imports **or** a valid equivalent anchor summary are recorded in E-triage, you MUST NOT enter Dynamic (unless an IAT repair failure has been recorded and a dynamic bypass is chosen, see §1.2), and you MUST NOT claim that 'basic triage is complete.' If parsing fails, you MUST still write the failure output into Evidence and must not skip it. When the user requests a 'redo of the import table check,' you MUST redo the imports/equivalence steps themselves (or first complete the prerequisites after §0.5 negotiation); switching to other analysis steps and pretending is prohibited.

### 1.1 Import Table Hard Gates and Equivalent Paths

| Sample Type | MUST Anchor (Evidence) | Description |
|----------|----------------------|------|
| Native PE/ELF/Mach-O (IAT readable) | `E-imports` / `E-triage-imports`: Import category summary | `rabin2 -i` / IDA imports / equivalent |
| DLL / SYS / Shared Library | **Parallel** `E-imports` + `E-exports` (`rabin2 -i` + `rabin2 -E`) | Export table priority equals import table (external entry) |
| .NET Managed (no traditional IAT) | **Equivalent Path**: dnSpy/IL/ metadata/assembly references and sensitive API summary → still written into `E-imports` or `E-triage-imports` semantic slots | **Prohibited** to skip the hardened gate just because there is 'no IAT'; dnSpy view = native 'check import table' |
| Import table parsing failed / empty / packed table | Still record failure or packed table output as Evidence, and mark `quality` | Must not be silently skipped; packed table must not support capability negation conclusion |

**Clean Import Table Warning (MUST Notify)**: If the imported table is 'too clean' (only basic DLLs like kernel32/ntdll, almost no business APIs), there is a high suspicion of `LoadLibrary` + `GetProcAddress` dynamic loading → note the suspicion in Evidence, and **SHOULD** switch to dynamically capturing memory APIs; one must not claim 'no network/file capability' based solely on a static IAT.

**High-Risk API Combinations (Patch 8 · SHOULD)**: When the import table is too long, prioritize outputting **malicious combination clusters**, filtering out purely system-based calls. Examples (not exhaustive):

- High-risk cluster: `FindWindowA/W` + `WriteProcessMemory` + `CreateRemoteThread` (injection)
- High-risk cluster: `CryptEncrypt` / `CryptAcquireContext` + large amounts of `FindFirstFile` / `DeleteFile` (ransomware tendency)
- High-risk clusters: `InternetOpen` / `WinHttp` / `URLDownloadToFile` + persistence API (`RegSetValue` / `CreateService`)
- Individual `CreateFile` / `ReadFile` and similar are mostly benign noise, unless co-occurring with the above cluster

### 1.2 Unpacking and IAT Handling (High-Risk Divergence · Issue #65)

```text
Branch A: Shell-less / .NET Managed
→ Directly go to §2 Static (.NET follows the equivalent anchor)

Branch B: Shell / Strong Obfuscation
Step 1: Attempt unpacking (automatic unpacker / manually find OEP) — must be done in an authorized and isolated environment
Step 2: Try to fix the IAT
Tools: x86 → ImportREC (or equivalent); x64 → Scylla (or equivalent). Do not stubbornly use ImportREC for 64-bit samples.
Situation B1: Repair successful and parsable → Note E-imports (after repair) → §2 Static
Scenario B2: ImportREC/Scylla error, unable to run after repair, or IAT completely garbled (VMP/encrypted shell)
→ [IAT Repair Iron Rule] Immediately stop continuing static IAT repair
→ MUST record E-iat-repair-fail (command, tool, failure phenomenon, decision to switch to dynamic)
→ Directly go to §3 Dynamic: API Breakpoints / Hardware Execution Breakpoints / Memory Search Capture Import
→ This does not count as 'skipping the import table': the import table path has been tried and the evidence has been recorded
Situation B3 (Patch 6): Crashes or blue screen on double-click after unpacking and repairing IAT (suspected file CRC/size self-check)
→ Give up continuing to statically fix the file; note E-self-check-crash or merge into E-iat-repair-fail
→ Switch to §3 Dynamic: Set breakpoints on CreateFile / GetFileSize / hash-related APIs to locate verification bypass points
```

**IAT Fix Rule (MUST)**: Prioritize attempting automatic/semi-automatic fixes; once the repair tool reports an error or the program cannot run after the fix, **immediately stop** struggling with the static import table, switch to dynamic debugging, and use API breakpoints (such as `bp CreateFile` / critical network APIs) to capture import functions at runtime.

## 2. Static (Basic Static Anchor → Deep Dive)

| Tool | When |
|------|------|
| radare2 / rabin2 | Quick functions/imports/strings (imports must have been completed in Triage or a failure bypass recorded) |
| IDA / Ghidra (MCP or headless) | Deep analysis, cross-referencing, types; review imports classification during the survey phase |
| jadx / dnSpy | Android / .NET |
| OLLVM Documentation | Suspected Control Flow Flattening |

```text
□ Confirm that E-imports / E-triage already include the import table or equivalent anchor evidence (if missing, add it first; post-adding is prohibited)
□ If DLL/SYS: Confirm that E-exports have been recorded
□ Sensitive API Grouping + High-Risk Combination Clustering (Patch 8)
□ Hard-coded domain/IP/URL string; whether the resource section hides the payload
□ Locate key functions (encryption/checksum/network/authorization) → write addresses/symbols into Evidence
□ If one path is blocked → switch tools (IDA↔r2↔Ghidra)
□ Time Box (Patch 9 · SHOULD default): If static deep dive lasts about 15 minutes without a critical path → forcibly switch to §3 Dynamic (duration can be overridden by user/task)
```

**Without MCP**: You can export the decompiled text for further analysis (refer to P4nda0s reverse-skills / IDA-NO-MCP approach) and still write the Evidence path.

## 3. Dynamic (Cross-Validation Loop Area)

Core Concept: **Provide clues statically → Verify dynamically → Verification stalls → Return to static re-evaluation** (no fixed unique order).

### 3.0 Breakpoint Opening Moves (Patch 7 + 10 · MUST Order)

Before launching the sample in a user-mode debugger (such as x64dbg), set the preset breakpoints for 'Level 4 Rocket' (the names may vary slightly depending on the architecture/tool, but the order remains the same):

1. **TLS Callback** breakpoint (may have already run before the debugger EP)
2. **Entry Point (EP)** Breakpoint
3. **Sensitive API** Breakpoints (such as `CreateRemoteThread` / Network / File Write)
4. **Guarantee**: `ExitProcess` / Process exit path breakpoint (Patch 10) — Once an anti-debug direct exit occurs, **do not rush to restart**; immediately dump memory and write the pre-crash image path into Evidence for string/data recovery

```text
□ Frida / x64dbg / gdb / emulator: Verify static hypothesis
□ Run after presetting breakpoints according to §3.0; single-step trace stack/registers (white box)
□ Behavior Monitoring: Sandbox / Procmon / RegShot (Black Box)
□ IAT repair failed / Self-check crash sample: hardware execution breakpoint or memory search forcibly capturing API; CreateFile/GetFileSize checks CRC
□ Anti-debugging/Anti-Frida → reverse-engineering/anti-analysis
□ Android: Root detection / SSL pinning bypass scripts generated as needed, **must be on authorized devices**
□ Crash log drives the next round of hook (adaptive loop)
□ Time box (Patch 9 · SHOULD default): Single-step tracing about 200 instructions still shows no signs of malicious behavior → Force return to static string search / change anchor point (can be overridden)
```

### 3.1 Sandbox / Dynamic No-Action Emergency Branch (MUST)

```text
No action or exit immediately / infinite sleep
→ Check anti-debugging / anti-VM routines (CPUID, high-precision timing, sandbox characteristics, etc.)
→ Try hardware breakpoint bypass, patch detection points, or switch to a physical machine/higher-fidelity environment
→ Write 'No action + suspected anti-VM' in Evidence, and do not write 'Sample harmless' without conditions
```

### 3.2 Timebox Strategy (Patch 9 · SHOULD)

| Stage | Default Threshold (can be overridden by user/task) | Action |
|------|------------------------------|------|
| Static deep dive with no critical path | ~15 minutes | Switch to Dynamic |
| Dynamic step without progress | ~200 instructions | Return to Static string/cross-reference re-anchor |
| Any path repeatedly fails | Record evidence and then change tools or bypass | Do not let the same failure method idle |


### 3.3 Anti-Debugging / Obfuscation Bypass Quick Reference (Issue #65 Patch A–T · High Frequency)

For the complete index and action details, see `reverse-engineering/anti-analysis.md` 'Agent Response Recipe A–T'. Here, only **P0 must-check + common transitions** are listed. The default is **authorized isolated lab**; patching/changing flag bits is not an unauthorized production action.

| Trigger Feature | Preferred Action (Summary) | Evidence |
|----------|------------------|----------|
| `cpuid` then jz/jnz (A) | lab: change the flag bit or patch to follow the real branch; record the checkpoint address | `E-anti-debug-cpuid` |
| `rdtsc` + sub/cmp (B) | bp rdtsc or hook time source; prohibit infinite spinning and other sandbox timeouts considered 'harmless' | `E-anti-debug-rdtsc` |
| PEB BeingDebugged / NtGlobalFlag (K) | ScyllaHide or manually modify PEB; patch conditional jump | `E-anti-debug-peb` |
| `NtQueryInformationProcess` DebugPort/Flags/Object (P) | ScyllaHide / hook return value; record class parameter | `E-anti-debug-ntqip` |
| Import very little but behavior is rich → API hash (N) | bp GetProcAddress; hash reverse lookup with IDA | `E-api-hash` |
| strings empty but has network/file behavior → string encryption (I) | find decode routine xref; dump and re-annotate after decryption | `E-string-decrypt` |
| Signed but source is questionable (F) | SigCheck: Valid/Revoked/Time; **Invalid does not lower** threat level | `E-sig-forge` |
| Standard strings without IOC → try wide characters (T) | `strings -el` / UTF-16LE; Alt+A unicode | `E-wide-strings` |
| Debugger name string / Toolhelp scan (C) | bp CreateToolhelp32Snapshot chain | `E-anti-debug-procscan` |
| AddVectoredExceptionHandler + deliberate exception (D) | bp VEH registration; analyze handler | `E-anti-debug-veh` |
| int3 / DR0–DR7 (M) | patch int3; soft breakpoint or ScyllaHide hides hardware BP | `E-anti-debug-bp` |
| Multiple PE heads/overlapping segments (G) | True segment table mapping + entropy; do not trust segment names | `E-pe-anomaly` |
| End of File > Section Summary and Overlay (J) | Extract overlay; file/entropy; find load offset xref | `E-overlay` |
| .rsrc unusually large/high-entropy RT_RCDATA (Q) | Extract resource; FindResource chain + decryption dump | `E-rsrc-payload` |
| Load DLL at runtime (R) | Check Delay Import; bp delay-load helper | `E-delay-import` |
| while+switch star-shaped CFG (H) | **See** `ollvm-deobfuscation.md`; plugin failure then dynamic path | `E-cff` |
| Always True / Always False Branch (S) | **See** ollvm / Symbolic Execution; Dynamic Prevails | `E-opaque-pred` |
| `/proc/self/status` TracerPid (L) | **Linux/ELF**; hook or patch; Windows main path is not enforced | `E-anti-debug-tracerpid` |

**Constraint**: Keep track of Evidence even if bypasses fail; do not write 'anti-debug triggered exit' as 'sample is harmless'. Complete A–T and P2 (E compilation time, O no-op instructions) can be found in the anti-analysis recipe section.

### 3.4 Non-PE / Multi-format Bypass (Issue #65 Patch U–AV · Routing)

Complete index: `reverse-engineering/references/nonpe-format-cookbook.md`. Here only **Type → Entry** is listed; action details are in the cookbook / corresponding skill.

| Type | Jump | P0 Evidence Anchor (Example) |
|------|------|---------------------------|
| BAT/CMD | cookbook §1 + malware | `E-batch-deobf` |
| PowerShell | cookbook §2 + malware | `E-ps-decode-layer-N` |
| VBA Macro | cookbook §3 + malware | `E-vba-pcode` |
| JS Strong Obfuscation / JSVMP | **js-reverse** + cookbook §4 | `E-js-vmp` / `E-js-deobf` |
| SYS Driver | kernel-driver-reverse + cookbook §5 | `E-driver-irp-handlers` / `E-driver-ioctl` |
| DLL Focus | cookbook §6 (AM≡A–T **R**) | `E-dll-tls-dllmain` / `E-exports` |
| Android phone modification/hidden icons | **apk-reverse** + cookbook §7–8 | `E-android-wiper-*` / `E-android-hidden-icon-*` |

**Constraints**: Do not create a separate 'non-PE six stages'; division of labor with §3.3 A–T (PE anti-debugging vs multi-format). Authorized lab; patterned machine/BYOVD/reflection = detection and forensic description.


## 4. Synthesis (IOC / Attack Chain / Report)

### Decision quality overlay (Issue #77)

Before closing Synthesis, apply [analysis-decision-framework.mdxKx0042xKx **P0 checklist**: R41 grounded claims, R4* validated sufficiency, R1 confidence->dynamic, R2 hypothesis exit, R43 deadlock replan (under feasibility gate), xKx0043xKx no default xKx0044xKx Multi-module -> R50; anti-analysis effort -> R51 + A-T cookbook.

Blindspots (xKx0045xKx): [analysis-blindspot-cookbook.mdxKx0046xKx R52-R81 — detection-oriented; not a parallel master flow.



```text
□ Finding: Algorithm/Verification Logic/Exploitable Points / Behavioral Conclusion
□ Path: callflow or solve step hangs E-*
□ IOC: Network fingerprint + Host fingerprint (if available, list; if not, n/a + reason)
□ Report docs-generator (malware/apt/null/vuln overlay task selection) + optional image
□ Optional: YARA / Snort·Suricata rule-based accumulation
□ field-journal desensitization
```

## 5. Six-Phase Practical Mapping (Issue #65 Mind Map → This Document)

| Combat Phase | This Document Chapter | Hard Rules / Iron Laws |
|----------|------------|-------------|
| 1 Preliminary Quick Assessment | §0–§1 Triage | Hash, architecture, file type, unpacking; imports/equivalent anchors; §0.5 Instruction Gate |
| 2 Unpacking and IAT | §1.2 | IAT Iron Law; Failure/Self-Check Crash → Evidence → Dynamic |
| 3 Basic Static Anchors | §2 Static | High-risk API Combination; Time-box SHOULD |
| 4 Deep Cross-Validation | §3 Dynamic | Four-stage break-point rocket; No-Action Emergency; Time Box; §3.3 A–T; §3.4 U–AV Type Routing |
| 5 Extract IoC and Attack Chain | §4 Synthesis | IOC + Kill Chain / Path |
| 6 Archiving and Normalization | §4 + docs-generator / YARA | Structured reports; rules optional |

## 6. Differences from the "Stack RE skill plugin"

- This package uses **phase gate + tool-index**, and does not enable Hex-Rays "unsafe fully automatic execution" type plugins by default
- Dynamic instrumentation defaults to **offline/lab** network_profile
- IAT/Import Table: **Try + Record** is preferred over 'endless static grind' or 'silent skip'
- User Instruction: **Prioritize goals + negotiate premises**, do not use irrelevant steps to masquerade as the specified steps