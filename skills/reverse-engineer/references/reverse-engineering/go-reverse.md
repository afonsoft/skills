# Go Binary Reverse Engineering Guide

> Binaries compiled with Go have unique challenges: static linking results in enormous size, there are tens of thousands of functions, string formats are special, and symbols are difficult to recover after being stripped.
> This document covers toolchains, recovery techniques, and practical workflows.

---

## Feature Recognition of Go Binaries

Quickly determine whether a binary is compiled with Go:

```bash
# String Features
strings binary | grep -E "runtime\.|go\.buildid|GOROOT"

# rabin2 reconnaissance
rabin2 -z binary | grep -i "runtime"

# File size abnormally large (statically linked runtime)
# Typical Hello World: C ~20KB, Go ~2MB
```

Common features:
- A large number of functions with the `runtime.` prefix
- Includes `go.buildid` section
- Includes `GOROOT` and `GOPATH` path strings
- Number of functions: 5,000–50,000+ (including the entire runtime and standard library)

---

## Core Toolchain

### Symbol Restoration

| Tool | Purpose | Link |
|------|------|------|
| **GoReSym** | Produced by Mandiant, analyzes Go symbol information (pclntab/moduledata) | https://github.com/mandiant/GoReSym |
| **GoResolver** | Produced by Volexity, automatically deobfuscates Garble binaries using CFG similarity | https://github.com/volexity/GoResolver |
| **redress** | Analyze stripped Go binaries, recover types/interfaces/package structures | https://github.com/goretk/redress |
| **GoStringUngarbler** | Produced by Google, specifically for recovering Garble-obfuscated strings | https://github.com/mandiant/GoStringUngarbler |

### IDA Plugin

| Tool | Purpose | Link |
|------|------|------|
| **go_parser** | IDA plugin, parses moduledata/pclntab/ type information | https://github.com/0xjiayu/go_parser |
| **IDAGolangHelper** | IDA script collection, parses Go type information | https://github.com/sibears/IDAGolangHelper |
| **AlphaGolang** | SentinelLabs' IDAPython script collection | https://github.com/SentineLabs/AlphaGolang |
| **Native Support in IDA 9.2+** | Official Hex-Rays Go Decompiler Improvements | https://hex-rays.com/blog/stop-guessing-and-start-going |

### Ghidra Plugin

| Tool | Purpose | Link |
|------|------|------|
| **Ghidra + GoReSym Output** | Import into Ghidra after exporting symbols with GoReSym | Used together |
| **golang_loader_assist** | Ghidra Go loading assistant | Community script |

### Independent Analysis Tool

| Tool | Purpose | Link |
|------|------|------|
| **gore** | Go reverse engineering library (underlying layer of redress) | https://github.com/goretk/gore |
| **garble** | Go obfuscation tool (understand it to counter it) | https://github.com/burrowers/garble |

---

## Key Structures of Go Binaries

### pclntab (PC Line Table)

The most important structures in Go binary include:
- All function names and address mappings
- Source file path
- Line number information
- Stack frame size

Even if the symbols are stripped, the pclntab usually still exists (the Go runtime depends on it).

```text
Positioning method:
1. Search for magic bytes: 0xFFFFFFF0 (Go 1.16+) or 0xFFFFFFFB (Go 1.18+)
2. Automatically locate using GoReSym
3. Automatically parse with the go_parser IDA plugin
```

### moduledata

Includes:
- pclntab pointer
- Type Information Table
- itab (interface table)
- Global Variable Information

### String Format

Go strings are not C-style null-terminated, but have an `(pointer, length)` structure:

```text
C string:   "hello\0"
Go string:  struct { ptr *byte; len int } → ptr points to "hello" (no \0)
```

This causes IDA/Ghidra's default string recognition to miss a large number of Go strings.

**Solution**:
- Automatically recognize Go strings using `go_parser`
- Export a list of strings using GoReSym
- Manual: find `runtime.stringtable` or locate it through cross-references

---

## Practical Workflow

### Scenario 1: Go binary without stripping

```text
1. GoReSym -t -d -p binary > symbols.json
→ Export all function names, types, and source file paths
2. Load to IDA/Ghidra
3. Import GoReSym symbol information
4. Filter out runtime.* and standard library functions, focusing on user code
5. Start analysis from main.main
```

### Scenario 2: Go binary after strip

```text
1. GoReSym -t -d -p binary > symbols.json
→ Even after stripping, pclntab usually remains
2. If GoReSym fails → use redress
redress -src binary    # Restore source file path
redress -pkg binary    # Restore package structure
redress -type binary   # Restore type information
3. Load into IDA + go_parser plugin
4. Run go_parser to automatically recover
5. Start from the recovered main.main
```

### Scenario 3: Garble Obfuscated Go Binary

```text
Garble Meeting:
- Randomize function names (main.main → main.a3f2b1c)
- Encrypted string
- Remove file path information
- Obfuscated package name

Countermeasures:
1. GoResolver (CFG signature matching)
→ Recover standard library function names through control flow graph similarity
2. GoStringUngarbler (String Decryption)
→ Automatically identify Garble's string encryption mode and decrypt
3. Dynamic Analysis (Frida/dlv)
→ Hook runtime function to observe actual behavior
4. Comparative Analysis
→ Compile a Hello World with the same version of Go, and use binary-diff to compare the runtime parts
```

### Scene 4: CGo Mixed Compilation

```text
1. Identify CGo boundaries (_cgo_* functions)
2. Restore the Go part using go_parser
3. Part C uses conventional IDA analysis
4. Pay attention to bridging functions such as _cgo_topofstack and crosscall2
```

---

## Quick Reference for Common Commands

```bash
# GoReSym: Export Symbols
GoReSym -t -d -p binary > symbols.json
GoReSym -t -d -p binary -o ida_script.py  # 生成 IDA 脚本

# redress: Analyze stripped binaries
redress -src binary          # 源文件路径
redress -pkg binary          # 包结构
redress -type binary         # 类型信息
redress -interface binary    # 接口信息
redress -filepath binary     # 完整文件路径

# GoResolver: Deobfuscate Garble
GoResolver -binary binary -output resolved.json

# GoStringUngarbler: Decoding Garble Strings
GoStringUngarbler -i binary -o deobfuscated_binary

# Quickly Determine Go Version
strings binary | grep "go1\."
GoReSym -p binary | grep "Version"
```

---

## Go Analysis Process in IDA

```text
1. Load the binary (select the correct architecture)
2. Wait for the automatic analysis to complete
3. Run the go_parser plugin:
   - File → Script File → go_parser.py
- Or Edit → Plugins → Go Parser
4. The plugin will automatically:
- Analyze pclntab
- Restore function name
- Mark Go string
- Parse type information
5. Filter View:
- Hide runtime.* functions
- Focus on main.* and third-party packages
6. Reverse from main.main
```

---

## Common Pitfalls

| Trap | Description | Solution |
|------|------|------|
| Too many functions to look through | Go static linking results in 5,000-50,000 functions | Filter by package name, only look at main.* and business packages |
| String recognition incomplete | Go strings are not null-terminated | Recover using go_parser or GoReSym |
| Decompiled results are hard to read | Go's defer/goroutine/interface makes pseudocode complex | IDA 9.2+ has improvements, or use dynamic analysis for assistance |
| Garble Obfuscation | All function names/strings randomized | GoResolver + GoStringUngarbler |
| Version Differences | The pclntab format varies across different Go versions | GoReSym supports Go 1.2-1.23+ |
| CGo Boundary | Mixing Go and C code | Identify _cgo_* functions as the dividing line |

---

## Coordination with Other Skills

| Requirement | Use what |
|------|--------|
| In-depth IDA Analysis of Go Binaries | `ida-reverse/` + go_parser Plugin |
| Ghidra Analysis (Free) | Ghidra + GoReSym Symbol Import |
| Rapid Reconnaissance | `radare2/` — `rabin2 -z` View String |
| Dynamic Hook | Frida (Hook runtime functions) or dlv (Go native debugger) |
| Cross-Version Comparison | `binary-diff/` — Migration from Old Version to New Version with Sign |
| Garble for obfuscation | GoResolver + GoStringUngarbler |