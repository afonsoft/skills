---
name: radare2
description: |
  Use this skill whenever the user wants to analyze binaries with radare2/r2 from the command line, including reverse engineering, disassembly, function analysis, strings/import inspection, patching, binary diffing, hex inspection, or r2 scripting. Also use it when the user mentions PE/ELF/Mach-O/DEX/WASM files together with CLI analysis, `rabin2`, `rasm2`, `radiff2`, `r2pipe`, or asks for radare2 command help on Windows/Linux/macOS.
---

# radare2

Binary analysis skills for the `radare2` CLI. The focus is on performing reconnaissance, analysis, localization, exporting, and light modifications directly using the command line, without relying on a GUI.

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

## Scope of Application

This skill should be prioritized when the user has these intentions:

- Use `r2` / `radare2` to analyze `exe`, `dll`, `so`, `elf`, `apk`, `dex`, `wasm` and other files
- Ask `rabin2`, `rasm2`, `radiff2`, `rahash2`, `rax2` how to use
- Need command-line disassembly, view functions, view strings, check imports and exports, search cross-references, do patching
- Need to write `radare2` batch commands, `-c` automation commands, or `r2pipe` scripts

If the user explicitly wants GUI reverse engineering, Hex-Rays style pseudocode, or an IDA workflow, prioritize `ida-reverse`. If it is web JS reverse engineering, prioritize `reverse-engineering`.

## First, confirm the environment

Don't assume `r2` is available yet. Check first:

```powershell
r2 -v
rabin2 -v
```

If not installed, then check common installation locations or prompt for installation.

Common executable files in Windows:

- xKx0000xKx
- xKx0001xKx
- xKx0002xKx
- xKx0003xKx
- xKx0004xKx
- xKx0005xKx
- xKx0006xKx

## Built-in Resources

This skill comes with two resources, prioritize reusing them, and do not organize a set of duplicate commands every time temporarily.

### xKx0007xKx

Standard reconnaissance script, suitable for conducting the first round of overview analysis. It will output:

- Basic Information
- Section
- Import
- Export
- String
- Optional `r2 -A` automatic analysis summary

Invocation method:

```powershell
powershell -File "<skill-root>\radare2\scripts\recon.ps1" -TargetPath "C:\path\to\sample.exe"
```

If automatic analysis with `r2` is required:

```powershell
powershell -File "<skill-root>\radare2\scripts\recon.ps1" -TargetPath "C:\path\to\sample.exe" -RunAnalysis
```

### xKx0000xKx

When you need more command details, common scenario templates, or want to quickly recall grammar, read this cheat sheet instead of guessing from memory.

## Known Phenomena

### Intermittent `.sdb` Missing Alert on Windows

Some PE files may trigger alerts like the following during `rabin2` reconnaissance:

```text
ERROR: Cannot find ...\share\format\dll\*.sdb
```

If the main output still returns normally, it usually does not affect the basic reconnaissance conclusions, so just continue analyzing. Do not directly conclude that the analysis has failed because of such incidental alerts.

## Basic Principles

### 1. Scout first, then dig deeper

Don't start with a full automatic analysis right away. First, use lightweight commands to confirm the file type, architecture, entry point, strings, and import table, then decide whether to do `aaa`, `aaaa`, or targeted analysis.

### 2. Prefer the smallest sufficient command

The `radare2` command has a lot of options, but users usually only need the shortest path:

- View file information: `rabin2 -I`
- Look at the string: `rabin2 -z`
- Check import and export: `rabin2 -i` / `rabin2 -E`
- Interaction analysis: `r2 <file>` then execute local commands

### 3. Be Cautious Before Making Changes

If the user wants to patch the binary:

- Default is to open as read-only first: `r2 <file>`
- Use write mode only when modifications are explicitly necessary: `r2 -w <file>` or in sessions `oo+`
- Inform of risks before making modifications to avoid unintentionally overwriting the original file

## Common Workflows

## Workflow 1: Rapid Reconnaissance

Suitable for when you just get a binary file.

### Hard Access Control (MUST — Entry prohibited workflow 2 and beyond if not met)

For binaries like PE/ELF/Mach-O that contain import tables, **MUST** first complete the import table check and record Evidence before proceeding to function-level analysis or dynamic steps:

1. Execute `rabin2 -i <sample>` (or the imports section in `recon.ps1` output); DLL/SYS also MUST `rabin2 -E` and record `E-exports`
2. Write the complete/categorized import table results into Evidence (recommended id: `E-imports` or `E-triage-imports`), including at least:
   - Reproduction command (`repro_command`)
- Key Import Category Summary: Network / File / Encryption / Process Injection / Registry / Other Suspicious APIs
   - If the imported table is empty, parsing fails, or the tool reports an error: you MUST still record the failure phenomenon and the original output as Evidence, **you must not silently skip it**
   - Import table 'clean' (basic DLL only): MUST indicate suspicion of dynamic loading, SHOULD transfer to dynamic API capture
3. .NET and others without traditional IAT: MUST write to the same Evidence semantic slot through equivalent anchors (dnSpy/IL/ metadata summary), skipping is prohibited
4. Packed sample IAT repair: use ImportREC (or equivalent) for x86, and Scylla (or equivalent) for x64. If repair fails, MUST log `E-iat-repair-fail` and then switch to dynamic API breakpoint; **Do not** persistently struggle with the static IAT (see `reverse-engineering/references/re-agent-workflow.md` §1.2)
5. When the user explicitly requests "redo import table check / recheck import table / redo IAT": MUST redo the specified step itself (if blocked, first go through a feasibility gate: explain the premise + ask for confirmation; if forced, mark quality=unreadable), **it is forbidden to substitute unrelated steps to pretend it is completed**

Unrecorded import table (or legitimate equivalent anchor / IAT bypass) Evidence before: MUST NOT claim 'baseline reconnaissance completed', MUST NOT proceed to deep-dive conclusions in workflow 2+.

Prioritize running the built-in script directly:

```powershell
powershell -File "<skill-root>\radare2\scripts\recon.ps1" -TargetPath "sample.exe"
```

If only the minimum command needs to be executed manually, use:

```powershell
rabin2 -I sample.exe
rabin2 -z sample.exe
rabin2 -i sample.exe
rabin2 -E sample.exe
```

Focus:

- File format, bitness, architecture, platform
- Entry point address
- Suspicious strings: URL, path, error message, registry, command-line arguments
- Imported functions: network, file, encryption, process injection, registry operations (**MUST leave evidence, see the hard gate above**)

## Workflow 2: Interactive Analysis Functions

```powershell
r2 sample.exe
```

Commonly used after entering:

```text
aaa          # Regular Automatic Analysis
afl          # List functions
iz           # List the string
iS           # Section Column
is           # column symbol
s entry0     # Jump to entry point
pdf          # Disassemble the current function
VV           # Enter visual mode (if the terminal is suitable)
q            # Exit
```

Explanation:

- Default priority is `aaa`, do not use the heavier `aaaa` right from the start
- If the sample is large or the analysis is slow, you can analyze only near the entrance and then manually expand

## Workflow 3: Locating main / key logic

```text
afl~main
afl~sym.
iz~http
iz~error
axt <addr>
```

Idea:

- Start with `main`, entry points, and string references
- Use `axt` to check who referenced a certain string or address
- After finding the reference point, then `s <addr>`, `pdf`

## Workflow 4: Hexadecimal and Memory Viewing

```text
px 64        # 64 bytes in hexadecimal from the current address
pd 20        # Disassemble 20 instructions
psz          # Read the current address string
pxa          # A more user-friendly hexadecimal view
```

## Workflow 5: Binary Patch

Use only when the user explicitly requests to modify the file:

```powershell
r2 -w sample.exe
```

For example, after entering:

```text
s 0x401000
wa nop
wa jmp 0x401050
wq
```

Common write operations:

- `wa <asm>`: Writing Assembly
- `wx <hex>`: Write raw bytes
- `wq`: Write and exit

It is best to back up the original file before making changes. If the user does not mention a backup, at least remind them once.

## Workflow 6: Non-Interactive Automation

Suitable for one-time output results:

```powershell
r2 -A -q -c "afl;iz;ii;q" sample.exe
```

Common parameters:

- `-A`: Automatically analyze on startup
- `-q`: Quiet Mode
- `-c`: Execute command string

If there are many commands, prioritize organizing them into an easy-to-read order, and avoid cramming them into a difficult-to-maintain long string.

It is more recommended to first use the built-in reconnaissance script as a foundation, and then decide whether to add custom commands.

## Common Sub-tools

### xKx0003xKx

Suitable for static information extraction:

```powershell
rabin2 -I sample.exe   # 基本信息
rabin2 -S sample.exe   # 节区
rabin2 -s sample.exe   # 符号
rabin2 -i sample.exe   # 导入
rabin2 -E sample.exe   # 导出
rabin2 -z sample.exe   # 字符串
rabin2 -zz sample.exe  # 更详细字符串
```

### xKx0000xKx

Suitable for fast assembly/disassembly:

```powershell
rasm2 -d "9090"
rasm2 -a x86 -b 64 "xor eax, eax"
```

### xKx0000xKx

Suitable for comparing two binaries:

```powershell
radiff2 old.exe new.exe
radiff2 -C old.exe new.exe
```

### xKx0000xKx

Suitable for hashing:

```powershell
rahash2 -a md5 sample.exe
rahash2 -a sha256 sample.exe
```

### xKx0000xKx

Suitable for base and encoding conversion:

```powershell
rax2 0x401000
rax2 4198400
rax2 -s hello
```

## Recommended Analysis Order

When encountering unknown samples, follow this order:

1. xKx0000xKx Check format, structure, entry point
2. xKx0001xKx View string
3. xKx0002xKx Check import function — **MUST + Evidence (hard requirement, see workflow 1)**
4. If interactive analysis is needed, enter xKx0003xKx (only after the Evidence from step 3 has been saved to disk)
5. First xKx0004xKx, then xKx0005xKx / xKx0006xKx / xKx0007xKx
6. Gradually locate key functions through string references, import calls, and entry flow

The advantage of this sequence is low noise and the ability to quickly establish a sense of direction. Step 3 is not an optional optimization; it is a hard gate before digging deeper.

## Windows Precautions

- When there are spaces in the path, the command must correctly include quotation marks
- If the current terminal cannot find xKx0008xKx, it may be that xKx0009xKx was just updated; try opening a new terminal and trying again
- Some samples require administrator privileges to read, but do not elevate privileges by default unless the user explicitly needs it
- Before performing dynamic debugging on suspicious samples, you must first confirm the user's intentions to avoid mistakes.

## Output Style

When the user does not just want commands, but wants you to actually analyze the file:

- First, provide a summary of the reconnaissance results
- List the key evidence again: strings, imports, functions, addresses
- Finally, provide the next step suggestions or continue with a deeper analysis

Don't just list the commands without explaining why they are done.

## Typical Request Examples

### Example 1: Analyzing an exe

User: xKx0010xKx

Handling Method:

1. First use xKx0011xKx
2. Determine whether it is necessary to enter xKx0012xKx
3. Use xKx0013xKx, xKx0014xKx, xKx0015xKx to further explore entry points and key string references

### Example 2: Finding Where a String Is Called

User: xKx0016xKx

Handling Method:

1. Use xKx0017xKx to find the string address
2. Use xKx0018xKx to find references
3. Jump to the reference point xKx0019xKx after xKx0020xKx

### Example 3: Remove the jump

User: xKx0021xKx

Handling method:

1. First, confirm the target address
2. Clearly inform to enter write mode
3. Use xKx0022xKx or directly xKx0023xKx
4. Re-disassemble after modification to verify

## Practices to Avoid

- Do not treat xKx0024xKx as a tool that only has xKx0025xKx as a command
- Do not directly write mode to open user files without explaining the risks
- Don't draw conclusions before doing basic reconnaissance
- **Prohibit skipping import table check** (xKx0026xKx / recon imports): Do not proceed to the next step without writing the Evidence; when a user requests to redo the import table, changing to other steps is forbidden
- **Do not stubbornly persist with static analysis after IAT repair fails**: remember xKx0027xKx and then switch to dynamic; 64-bit samples must not use only ImportREC
- Do not mislead web JS reverse engineering to this skill; that is the scope of xKx0028xKx

## References

- Command Quick Reference: xKx0029xKx
- Standard reconnaissance script: xKx0030xKx

## radare2-skills Ecosystem

The radare2-skills project (xKx0031xKx) provides a more complete ecosystem of tools and workflows:

- **r2xsql**: SQL query binary import tables / strings / functions
- **r2mcp / r2http**: MCP tool with HTTP stateful command channel
- **radius2**: symbolic execution, symbolic dynamic analysis
- **r2pm**: Plugin management, extensions
- **decompiler plugins**: radare2 plugin mechanism

**Usage Strategy**:
- When the user mentions xKx0032xKx, xKx0033xKx, xKx0034xKx, xKx0035xKx, xKx0036xKx, xKx0037xKx, xKx0038xKx, xKx0039xKx, xKx0040xKx, xKx0041xKx, prioritize routing to this skill (xKx0042xKx)
- These tools are just ecosystem accelerators and **cannot bypass**: authorization access control, xKx0043xKx verification, Evidence import, write mode confirmation
- Provide a minimal reproducible command example:
  - xKx0044xKx
  - xKx0045xKx
  - xKx0046xKx
  - xKx0047xKx

This skill maintains the integrity of the original hard access control and evidence chain, and does not allow skipping any authorization or evidence steps.

---

## Routing Context

**Upstream Input**: xKx0048xKx (Main Control), xKx0049xKx
**Upstream Alternative**: xKx0050xKx (upgrade to IDA when xKx0051xKx is needed)
**Downstream Exports**:
- Requires dynamic analysis → xKx0052xKx（xKx0053xKx）
- Requires deep decompilation → xKx0054xKx
- After PAT discovers interesting strings, cross-referencing is required → xKx0055xKx (IDA's xref is more powerful)

**Peer-related modules**: xKx0056xKx (Complementary: r2 reconnaissance is fast, IDA decompilation is deep)

## On-Demand Bootstrap

The entry script for this skill has been integrated into the unified bootstrapping system. When radare2 is missing, it will not report an error directly, but will instead attempt to install it automatically.

### Automation Capability Boundaries

| Tool | Can be Automatically Installed | Installation Method | Description |
|------|-----------|---------|------|
| r2 | ✓ | GitHub Release ZIP (w64) | Automatically download and extract to xKx0057xKx |
| rabin2 | ✓ | Same as above (included in the radare2 distribution) | — |
| rasm2 | ✓ | Same as above | — |
| radiff2 | ✓ | Same as above | — |
| rahash2 | ✓ | Same as above | — |
| rax2 | ✓ | Same as above | — |

### Bootstrap Trigger Point

- xKx0058xKx: Automatically call xKx0059xKx when xKx0060xKx or xKx0061xKx is missing

### When Bootstrapping Fails

If the automatic installation fails (due to network issues, GitHub API rate limits, etc.), the script will throw a clear error and provide a link for manual installation.

Manual installation: Download xKx0062xKx from xKx0063xKx extract it to xKx0064xKx, and make sure the xKx0065xKx directory is in the PATH.


## Task Completion Self-Check (MUST Pass Before Claiming Completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Check if the import table has been executed and written to Evidence (E-imports / E-triage-imports or .NET equivalent)? Does xKx0066xKx contain E-exports?
- [ ] If IAT repair fails, should it log E-iat-repair-fail and switch to dynamic? Will a redo request return to the same step?
- [ ] Did I use a real tool path based on xKx0067xKx?
- [ ] Have I produced reproducible evidence (xKx0068xKx)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?