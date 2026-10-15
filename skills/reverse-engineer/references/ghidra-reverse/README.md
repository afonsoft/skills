---
name: ghidra-reverse
description: Use for free/open reverse engineering with Ghidra (headless or GUI), including decompile, cross-refs, and optional Ghidra MCP workflows when IDA is unavailable.
---

# Ghidra Reverse Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md`
2. `NOW`: Confirm that **Ghidra** is needed (no IDA / preference for open source / batch headless)
3. `NEXT`: Read `../tool-index.md` to check the ghidra / ghidra-mcp path
4. `NEXT`: Missing tools → bootstrap `ghidra-mcp` (if manifest is supported) or install Ghidra manually according to the steps
5. `ACT`: Import sample → Automatic analysis → Export key function decompilation

## Applicable Scenarios

- Main reverse-engineering entry without an IDA license
- Batch headless analysis / decompilation in CI
- Ghidra script (Java/Python Jython/PyGhidra) automation
- Collaboration with `binary-diff` / `patch-diff-exploit` on ghidriff

## Division of Work with IDA

| Requirement | Priority |
|------|------|
| Already have IDA MCP in-depth | `ida-reverse/` |
| Open Source / Bulk / Teaching | **This skill** |
| CLI Only Quick Reconnaissance | `radare2/` |

## Workflow

### 1. Projects and Automatic Analysis

```text
□ New Project → Import File → Analyze (Default Analyzer)
□ Record language/compiler recognition results and base address
□ Mark entry, export table, string xref
```

### 2. Key Functions

```text
□ Reverse lookup from string / import API
□ Decompile window restoration algorithm
□ Rename function/variable; write Plate comment
□ Handover Frida/GDB needed when dynamic (reverse-engineering dynamic seal)
```

### 3. Headless (Batch)

```bash
# Example: The path for analyzeHeadless varies depending on the installation and MUST be retrieved from the tool-index
analyzeHeadless /path/to/project Proj -import sample.bin -postScript ExportDecomp.py
```

### 4. MCP (if configured)

```text
□ Confirm the ghidra MCP port (commonly 8765, based on tool-index)
□ Use the MCP tool to decompile / xrefs, guessing ports is prohibited
```

## Toolchain

| Tool | Purpose | Bootstrapping |
|------|------|------|
| Ghidra | Main Decompilation Tool | Manual release / Package manager |
| ghidra-mcp | AI Bridge | bootstrap ability name `ghidra-mcp` |
| ghidriff | Patch Difference | See `patch-diff-exploit` |

## References

- xKx0002xKx
- xKx0003xKx xKx0004xKx xKx0005xKx

## Routing Context

**Upstream**: MASTER R22
**Downstream**: Dynamic verification → Frida/GDB; Utilization → `pwn-chain`
**Same level**: `ida-reverse` (Business Deep Dive)

## Task Completion Self-Check

- [ ] Is it based on the real Ghidra/tool-index path?
- [ ] Whether to mark function addresses and rename?
- [ ] Are there reproducible steps?
- [ ] Checklist / journal?