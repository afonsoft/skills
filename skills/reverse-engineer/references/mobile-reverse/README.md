---
name: mobile-reverse
description: Use for authorized Android or iOS application reverse engineering and security testing, including APK or IPA analysis, runtime instrumentation, SSL pinning, and platform protection checks.
---
# Mobile Reverse Engineering

## ACTION REQUIRED (Execute Immediately After Reading)

1. `NOW`: Read `../field-journal/precedent-reverse.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

> Unified Reverse Engineering Methodology for Android + iOS
> Frida / Objection / OWASP MSTG / SSL Pinning Bypass

## Applicable Scenarios

- Android APK Reverse Engineering and Security Testing
- iOS IPA Reverse Engineering and Security Testing
- Dynamic Instrumentation of Mobile Applications at Runtime
- SSL Pinning / Root Detection / Jailbreak Detection Bypass
- Mobile encryption algorithm extraction (AES/RSA/HMAC key)
- Mobile Application Penetration Testing (OWASP MASTG)
- Application testing in non-root/jailbroken environments

## Four-Stage Workflow

### Phase 1: Information Collection

```text
Android：
□ APK Acquisition (Google Play / APKMirror / adb pull)
□ Manifest Analysis: Permissions, Exported Components, Intent Filter, Backup Flags
□ androguard: androguard analyze APK → Components/Permissions/Signature
□ APKLeaks: Hardcoded API Key / Token / Secret Scan
□ Reinforcement Check: Whether it is packed (360/Tencent/Bangbang/Ai Encryption)

iOS：
□ IPA acquisition (App Store / ipatool / Apple Configurator)
□ Decrypt App Store Binaries: frida-ios-dump / Clutch
□ Info.plist Analysis: ATS Configuration, URL Scheme, Queries Schemes
□ class-dump: Export ObjC class structures
□ Reinforcement Check: Whether Swift/ObjC Obfuscation is Used
```

### Phase 2: Static Analysis

```text
Cross-platform:
□ JADX-GUI: APK → Java Source Code (Android)
□ Ghidra / Hopper: .so / Mach-O Decompilation
□ radare2 / Cutter: CLI Quick Reconnaissance

Android Special:
□ apktool d app.apk → smali code + resources
□ dex2jar: DEX → JAR → JD-GUI
□ smali/baksmali: Dalvik Bytecode Modification

iOS Special:
□ class-dump: Export ObjC header files
□ Swift Symbol Recovery: swift-demangle
□ dsymutil: Debug symbol extraction
□ otool -L: View dynamic library dependencies
□ jtool2: Mach-O Analysis
```

### Phase 3: Dynamic Analysis

```text
Frida — General Dynamic Instrumentation:
□ frida-ps -U: List device processes
□ frida-trace -U -i "open*" com.app: Trace function calls
□ Custom Hook Script: Modify Parameters/Return Values, Call Private Methods

Objection — Frida enhancement layer (no scripting required):
□ objection -g "com.app" explore
□ android root disable / ios jailbreak disable
□ android sslpinning disable / ios sslpinning disable
□ android keystore list / ios keychain dump
□ env / ls / sqlite connect

Frida Gadget (No Root/Jailbreak):
□ Inject frida-gadget.so / FridaGadget.dylib into APK/IPA
□ Re-sign → Install → Hook without device permissions
□ objection patchapk --source app.apk (fully automatic)
```

### Phase 4: Network Analysis

```text
□ Burp Suite: Intercept HTTP/HTTPS, modify requests/responses
□ mitmproxy: Scriptable Proxy (Python API)
□ Wireshark: PCAP Packet Capture Analysis
□ Certificate Installation: Android User Certificate → System Certificate (Magisk + MoveCert)
□ SSL Pinning Bypass: Frida/Objection/Xposed/SSL Kill Switch 2
□ WebSocket / gRPC Traffic Analysis
```

## Common Workarounds Quick Reference

### SSL Pinning

```bash
# Objection (Simplest)
objection -g "com.app" explore
android sslpinning disable

# Frida General Script
frida -U -l ssl_pinning_bypass.js -f com.app

# Xposed（Android）
TrustMeAlready 模块 → 全局禁用证书校验
```

### Root / Jailbreak Detection

```bash
# Objection
android root disable
ios jailbreak disable

# Frida Custom (Multi-layer Detection)
Java.perform(function() {
    var RootBeer = Java.use("com.scottyab.rootbeer.RootBeer");
    RootBeer.isRooted.implementation = function() { return false; };
// Additional bypass: Magisk su detection, frida-server detection, /proc/self/maps detection
});
```

### Anti-Debugging

```bash
# Android
frida -U -l anti_debug_bypass.js -f com.app
# Bypass: ptrace(TracerPid), /proc/self/status, isDebuggerConnected()

# iOS
# Bypass: PT_DENY_ATTACH, sysctl CTL_KERN/KERN_PROC/KERN_PROC_PID
frida -U -l ios_anti_debug.js -f com.app
```

## Mobile Encryption Extraction

```javascript
// Android — Hook Cipher.getInstance to obtain key + algorithm
Java.perform(function() {
    var Cipher = Java.use("javax.crypto.Cipher");
    Cipher.getInstance.overload('java.lang.String').implementation = function(algo) {
        console.log("[Cipher] Algorithm: " + algo);
        return this.getInstance(algo);
    };
    Cipher.init.overload('int', 'java.security.Key').implementation = function(mode, key) {
        console.log("[Cipher] Key: " + bytesToHex(key.getEncoded()));
        return this.init(mode, key);
    };
});

// iOS — Hook CCCrypt
Interceptor.attach(Module.findExportByName("libcommonCrypto.dylib", "CCCrypt"), {
    onEnter: function(args) {
        console.log("CCCrypt op: " + args[0] + " alg: " + args[1]);
        console.log("Key: " + hexdump(args[3], { length: args[4].toInt32() }));
    }
});
```

## Toolchain

| Tool | Platform | Purpose |
|------|:--:|------|
| JADX-GUI | A | Java Decompiler |
| apktool | A | APK unpacking/rebuilding |
| Ghidra | A+I | Multi-architecture decompilation |
| Hopper | I | iOS Dedicated Disassembler |
| Frida | A+I | Dynamic Instrumentation |
| Objection | A+I | Frida REPL Enhancement |
| MobSF | A+I | Automated SAST+DAST |
| class-dump | I | ObjC Class Export |
| frida-ios-dump | I | IPA Decryption |
| jtool2 | I | Mach-O Analysis |
| Burp Suite | A+I | HTTP Interception |
| mitmproxy | A+I | Scriptable Proxy |

> A=Android, I=iOS

## References

- `references/frida-objection-deep.md` — Frida + Objection In-depth Usage
- `references/ios-reverse-guide.md` — iOS Reverse Engineering Special
- `references/anti-detection-bypass.md` — Root/Jailbreak/Anti-Debugging/SSL Pinning Bypass


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?