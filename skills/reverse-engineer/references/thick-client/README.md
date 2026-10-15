---
name: thick-client
description: Use for authorized security testing of desktop thick clients including local storage, update channels, IPC, traffic, and client-side trust boundaries.
---

# Thick Client Security Testing

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-pentest.md`
2. `NOW`: Confirm that the target is a **desktop thick client** (Win/macOS/Linux GUI or service companion), not a pure web
3. `NOW`: case-init; installation package source and test account written into scope
4. `NEXT`: Tools (Burp upstream proxy, process monitoring, reverse engineering tools)
5. `ACT`: Trust Boundary Diagram → Local Surface → Network Surface → Update/Supply Chain

## Applicable Scenarios

- C/S architecture client, Electron/Qt/.NET WinForms/WPF
- Local configuration/credential storage, IPC, named pipes
- Research on bypassing client-side mandatory validation (authorized)
- Automatic update channel and code signing verification

## Workflow

### 1. Build Borders

```text
□ Process tree, child process, driver/service
□ Listening Port and Outbound Domain
□ Local sensitive paths: %APPDATA%, Keychain, Registry
```

### 2. Local Attack Surface

```text
□ Plaintext configuration, hard-coded keys, debug switches
□ DLL Hijacking/Search Order (Windows)
□ Database File (SQLite) Permissions and Encryption
□ IPC: Who can connect? Is authentication required?
```

### 3. Network Side

```text
□ System Proxy / App Custom TLS
□ Certificate pinning → Joint mobile/js methodology or Frida
□ API Privilege Escalation: Hidden Management Interfaces in the Client
```

### 4. Reverse Verification

```text
□ .NET → dotnet-reverse; Native → ida/ghidra; Electron → asar + js-reverse
```

## Toolchain

| Tool | Purpose |
|------|------|
| Process Monitor / API Monitor | Behavior |
| Burp / mitmproxy | Traffic |
| dnSpy / IDA / Ghidra | Reverse Engineering |
| Sysinternals | Windows Side |
| asar / nexe Detection | Electron |

## References

- xKx0000xKx
- xKx0001xKx xKx0002xKx xKx0003xKx xKx0004xKx

## Routing Context

**Upstream**: MASTER R32
**Downstream**: Pure protocol `protocol-reverse`; Supply chain update `supply-chain-security`

## Task Completion Self-Check

- [ ] Whether to draw trust boundaries?
- [ ] Are both local and online aspects covered?
- [ ] Checklist?