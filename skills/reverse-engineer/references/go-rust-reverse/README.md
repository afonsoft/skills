---
name: go-rust-reverse
description: Use for reverse engineering stripped Go and Rust binaries including runtime recognition, pclntab/moduel data recovery, panic strings, and idiomatic decompilation recovery.
---

# Go / Rust Binary Reverse Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md`
2. `NOW`: Confirm that the sample is a compilation product of Go/Rust (`file`/string/runtime characteristics)
3. `NEXT`: GoReSym / Whether the related plugin is available
4. `ACT`: Runtime recognition → Symbol/metadata recovery → Business logic

## Applicable Scenarios

- Go malware/tool stripped of symbols
- Rust binary release, analysis driven by panic strings
- Language-specific methods complementary to general ida/ghidra

## Workflow

### Go

```text
□ Identify go.buildid, runtime symbol remnants, pclntab
□ GoReSym / redress / IDA Go plugin restore function names
□ Pay attention to the forms of interface, slice, and string structures in decompilation
□ Network/Encryption Library Path: crypto/* net/http
```

### Rust

```text
□ panic string, rust_begin_unwind, crate path hints
□ Code bloat caused by template instantiation; first locate the string xref
□ Asynchronous/tokio state machine needs to be combined with cross-references
```

### Updates

```text
□ Frida can still be used; pay attention to the Go stack and scheduling
□ Priority log and configuration string-driven breakpoint
```

## Toolchain

| Tool | Purpose |
|------|------|
| GoReSym | Go Metadata |
| IDA/Ghidra + Go/Rust Plugin | Decompile |
| radare2 | Quick Strings |
| strings / rabin2 | triage |

## References

- xKx0002xKx
- xKx0003xKx xKx0004xKx xKx0005xKx
- seed: xKx0006xKx

## Routing Context

**Upstream**: MASTER R33
**Downstream**: Malicious sample process `malware-analysis`; General RE `reverse-engineering`

## Task Completion Self-Check

- [ ] Should the original key function names or equivalent mappings be restored?
- [ ] Whether to mark runtime language evidence?
- [ ] Checklist?