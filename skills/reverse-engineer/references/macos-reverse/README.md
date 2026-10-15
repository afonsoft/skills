---
name: macos-reverse
description: Use for authorized macOS and Mach-O reverse engineering including codesign, Objective-C/Swift recovery, endpoint security surfaces, and Apple platform malware analysis.
---

# macOS / Mach-O Reverse Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md`
2. `NOW`: Confirm the target is macOS/Mach-O/App bundle (iOS IPA → `mobile-reverse/`)
3. `NEXT`: tool-index; jtool2/lldb, etc.
4. `ACT`: Signature and loading information → Static → Dynamic (lldb/Frida)

## Applicable Scenarios

- Mach-O executable / dylib / framework
- .app bundle, LaunchAgent/Daemon
- Objective-C / Swift Symbols and Runtime
- Analysis of notarization/signature, Hardened Runtime, and TCC-related behaviors
- macOS malware static/dynamic analysis (in conjunction with malware analysis)

## Workflow

### 1. Package Body and Signature

```bash
file target
codesign -dv --verbose=4 target
spctl -a -vv target 2>&1
otool -L target
```

### 2. Static

```text
□ class-dump / swift-demangle / Hopper / Ghidra / IDA
□ Strings and XPC Service Names, TCC Sensitive APIs
□ LC_LOAD_dylib Dependency and rpath
```

### 3. Dynamics

```text
□ lldb / Frida
□ fs_usage / log stream observation
□ Network: combine protocol-reverse or proxy
```

## Toolchain

| Tool | Purpose |
|------|------|
| otool / nm / codesign | Built-in to the system |
| Hopper / Ghidra / IDA | Decompilation |
| class-dump / dsdump | ObjC |
| Frida / lldb | Dynamic |
| jtool2 | Mach-O |

## References

- xKx0000xKx
- xKx0001xKx（iOS） xKx0002xKx xKx0003xKx

## Routing Context

**Upstream**: MASTER R31
**Downstream**: iOS → mobile-reverse; general sample → malware-analysis

## Task Completion Self-Check

- [ ] Whether to record the signature/Hardened Runtime status?
- [ ] Is there an address-level/symbol-level conclusion?
- [ ] Checklist?