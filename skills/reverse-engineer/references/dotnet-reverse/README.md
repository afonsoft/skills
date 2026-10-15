---
name: dotnet-reverse
description: .NET / C# binary reverse engineering. Used when the target is a .NET assembly (PE header containing CLR, .exe/.dll managed program), C# compiled output (including NativeAOT), red team Sharp* tools (Rubeus / SharpHound / SharpHound, etc.), .NET obfuscated programs (ConfuserEx / SmartAssembly / Babel / Eazfuscator), .NET loader / info-stealer / packed malware. Prefer using dnSpyEx + de4dot, and when AI needs to operate directly, coordinate with dnSpy MCP. Not used for pure native binaries (use reverse-engineering / IDA reverse instead).
license: MIT
compatibility: Requires a filesystem-based code agent or CLI with shell access, Windows host preferred (dnSpyEx 是 Windows GUI)；Linux/macOS 可用 ILSpy/de4dot CLI + mono/dotnet runtime。
allowed-tools: Bash Read Write Edit Glob Grep Task WebFetch WebSearch
metadata:
  user-invocable: "false"
---

# .NET / C# Reverse Engineering Homework Specification

## ACTION REQUIRED (Read and execute immediately)

1. `NOW`: Use DIE/`file`/CLR header to confirm the target is .NET managed (otherwise SWITCH to `ida-reverse/` / `reverse-engineering/`)
2. `NOW`: If suspected of obfuscation → first `de4dot` unpack, output `*-clean.exe`, and retain the original sample
3. `NEXT`: dnSpyEx (or dnSpy MCP / `ilspycmd`) static: C# browsing + **IL view** to see critical judgments
4. `ACT`: Dynamic debugging is needed when plaintext/C2 is required; when logic changes are needed, **IL patch** takes precedence over C# recompilation
5. At the end of the stage, provide the user with 3–6 next-step menu options (including exporting the report)

## Scope of Application

Prioritize using this skill when the task falls into the following scenarios:

- Identify and reverse-engineer .NET / C# compiled outputs (managed PE / .exe / .dll)
- Analyze the Red Team Sharp* toolchain (Rubeus, SharpHound, SharpShell, etc.)
- Deobfuscate shells like ConfuserEx / SmartAssembly / Babel / Eazfuscator / .NET Reactor
- Decryption and C2 logic of reverse .NET loader / info-stealer / RAT
- Patch C# programs (change conditions, modify constants, keygen)
- Analyze the Mono/Unity managed layer before IL2CPP (Note: after IL2CPP compilation it becomes native, going through `reverse-engineering/` + seed-014)

If the goal is a pure native binary (C/C++/Go/Rust compilation, without CLR), please switch to `reverse-engineering/`, `ida-reverse/`, or `radare2/`.

## Core Principles

- **Identify before taking action**: First confirm that it is a .NET managed program (PE header CLR + `#~` / `#Strings` stream + mscoree `_CorExeMain`), then decide to use dnSpy instead of IDA
- **IL over C#**: dnSpyEx's C# decompiler may lose or distort information (compiler-generated state machines, async/await, yield), critical judgments and patches must switch to the **IL editor**, C# view is only used for quick browsing
- **de4dot first**: When encountering an obfuscator, first use `de4dot` to remove a round before doing static analysis, otherwise all strings/control flow will be messy
- **MCP Linkage**: If dnSpy MCP (`dnspy_*` tool) is registered in the environment, prioritize using MCP for decompile / IL inspection to avoid switching back and forth with the GUI
- **Evidence-based output**: deobfuscation results, extracted configuration/C2/key, and patch diffs all need to be saved to disk

## Toolchain Mapping

| Ability | First Choice | Remarks |
|------|------|------|
| Decompile + Debug + Patch | **dnSpyEx** | Ace, the only GUI with IL editor; the old dnSpy has stopped updating, using the Ex branch |
| Lightweight CLI / headless decompiler | **ILSpy** (`ilspycmd`) | Suitable for batch, scripted, Linux/macOS |
| Deobfuscation | **de4dot** | Default deobfuscation for mainstream protections like ConfuserEx suite, SmartAssembly, etc. |
| Obfuscator Identification | **Detect It Easy (DIE)** / **file** | First determine the type of shell, then decide the de4dot parameters |
| Programmatic IL Manipulation | **dnlib** | Writing C# Scripts to Batch Modify Metadata / String Decryptor |
| AI Direct Operation | **dnSpy MCP** | Tools Interface such as `dnspy_decompile` / `dnspy_inspect_il` |

> Prerequisite: Install dnSpyEx + de4dot on Windows host (via choco or release); Linux/macOS uses `ilspycmd` + `dotnet runtime`. See the installation matrix of `references/sharp-tools.md` for details.

## Six-Stage Workflow

### 1. Identify (.NET)

Confirm that the target is a hosted program, and do not analyze native PE as .NET:

```powershell
# Windows
file target.exe                       # "PE32 executable ... for MS Windows" 不够
# Key: Check if there is CLR
powershell -c "[System.Reflection.AssemblyName]::GetAssemblyName('target.exe')"
# or
dnSpyEx 直接拖进去 —— 能打开就是托管

# General
strings target.exe | grep -iE "mscoree|_CorExeMain|mscorlib|System\\."
```

**.NET Recognition Sign:**
- PE header `Data Directory[14]` (CLR Runtime Header) is non-zero
- `mscoree.dll` Import / `_CorExeMain` Entry
- `#~`, `#Strings`, `#US`, `#GUID`, `#Blob` metadata stream
- `mscorlib` / `System.Private.CoreLib` string

**NativeAOT Exception:** Compiled to native, no CLR header, but contains `System.Private.CoreLib` strings and reconstructed type metadata — this type goes through `reverse-engineering/` (IDA/r2), this skill only provides identification hints.

### 2. Detect (Obfuscator Detection)

```powershell
# DIE Quick Identification
diec target.exe                        # Detect It Easy CLI
# Or drag it into dnSpyEx to see if there are a large number of garbled class names/control flow obfuscations
```

Common packers → Unpacking strategies (see xKx0000xKx for details):

| Obfuscator | Features | de4dot Handling |
|--------|------|------------|
| ConfuserEx (1.0.0 / 2.x) | xKx0001xKx anti-tamper, control flow obfuscation, string encryption | xKx0002xKx usually automatically detected |
| SmartAssembly | xKx0000xKx, Resource Compression | xKx0005xKx |
| Babel.NET | Method Body Encryption, Control Flow | xKx0006xKx |
| Eazfuscator.NET | xKx0007xKx Encryption | xKx0008xKx, some versions require manual operation |
| .NET Reactor | anti-tamper + necrobit | xKx0009xKx, the new version may fail and require manual operation |

### 3. Deobfuscate (脱混淆)

```powershell
# de4dot defaults to automatically detect most obfuscators
de4dot target.exe -o target-clean.exe

# Specify type (when automatic detection fails)
de4dot --type cfze target.exe          # ConfuserEx
de4dot --type sa target.exe            # SmartAssembly

# Multi-layer obfuscation / de4dot reports unknown
de4dot --detect target.exe             # 看它识别成什么
# Might need to patch anti-tamper first and then de4dot (see references/obfuscators.md)
```

Output: xKx0000xKx, use it for subsequent analysis. **Keep the original sample** for comparison.

### 4. Static Analysis (静态分析)

dnSpyEx loaded unpacked sample:

- **C# View**: Quickly browse class structures, method signatures, strings (for locating)
- **IL View**: For key judgments, encryption logic, and state machines, you must view the IL (Right-click → Edit IL or IL View)
- Find entry: xKx0001xKx / xKx0002xKx / Module initializer (xKx0003xKx)
- Find the key logic: search xKx0004xKx, xKx0005xKx, xKx0006xKx, xKx0007xKx, xKx0008xKx, xKx0009xKx, xKx0010xKx

```text
Locate the string → backreference → find the method that uses it → view the IL to check the logic
```

### 5. Dynamic (Dynamic Debugging)

dnSpyEx Debugger: Attach to process / Start debugging, set breakpoints on key methods, observe runtime:
- Decrypted plaintext string (the strings of many obfuscators are only decrypted at runtime)
- C2 address and configuration decryption results
- Exception-driven control flow (commonly used in anti-debug `try/catch` to hide the real path)

.NET dynamic debugging is much more user-friendly than native debugging — you can directly see object values and string contents. Prioritize dynamic over stubbornly sticking to static.

### 6. Patch (Modify as Needed)

```text
dnSpyEx → Right-click method → Edit Method (C#) or Edit IL
- Change condition: ldc.i4.0 → ldc.i4.1 (false → true)
- Modify constants: directly edit strings/numbers
- Remove verification: nop out the entire segment
File → Save Module → Replace Original File
```

**IL patch reliability > C# patch**: C# recompilation may fail (missing references, incorrect syntax), while IL editing almost never distorts. See `references/common-workflow.md` for details.

## Trigger Scenario Routing

The user enters this skill when saying these:
- .NET / C# binary reverse engineering / C# program decompilation
- "dnSpy Analysis" / "dnSpyEx patch"
- "ConfuserEx / SmartAssembly / Babel deobfuscation / unpacking"
- "Sharp* Tool Analysis" (Rubeus / SharpHound / SharpShell)
- .NET malware / loader / info-stealer reverse engineering
- "C# program patch / keygen / modify check"

## When to Exit

- Unity games compiled with IL2CPP → `reverse-engineering/` + `seed-014_unity-il2cpp-reverse.md` (IL2CPP is native, does not go through dnSpy)
- NativeAOT output → `reverse-engineering/` (same as above, native)
- Pure native PE (no CLR) → `reverse-engineering/` / `ida-reverse/`
- Need to batch migrate symbols/functions to another version → `binary-diff/`
- Need to draw attack paths / call chain diagrams → `diagram-generator/`

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Downstream Export**:
- IL2CPP / NativeAOT (native) → `reverse-engineering/`
- Deep native .so/.dll segment analysis → `ida-reverse/` / `radare2/`
- AI needs to directly operate dnSpy → register and link dnSpy MCP (see `references/sharp-tools.md`)

**Peer-related Module**:
- `reverse-engineering/languages-compiled.md` (.NET Introduction points to this module)
- `apk-reverse/` (Xamarin/MAUI Android reverse engineering can switch back to this module to view the C# layer)

## Reference Documents

- [references/obfuscators.md](references/obfuscators.md) — Detailed Deobfuscation of ConfuserEx / SmartAssembly / Babel / Eazfuscator / .NET Reactor + anti-tamper Bypass
- [references/common-workflow.md](references/common-workflow.md) — Complete workflow, IL patch reliability, string decrypter extraction, state machine recognition
- [references/sharp-tools.md](references/sharp-tools.md) — Red Team Sharp* Tool Analysis, Tool Installation Matrix, dnSpy MCP Integration, Community Resource Index

## Task Completion Self-Check

- [ ] Have you confirmed CLR / managed identity (or switched out of this skill)?
- [ ] Should the obfuscated sample be de4dotted / equivalently unpacked before deep analysis?
- [ ] Has the key logic been verified using the IL view (rather than just looking at the C# pseudocode)?
- [ ] Are the outputs (clean samples / configuration / patch diff) saved to disk and reproducible?
- [ ] Is a next-step menu or report export provided?