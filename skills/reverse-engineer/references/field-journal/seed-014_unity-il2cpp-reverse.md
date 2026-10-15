# [Seed] Unity IL2CPP Game Reverse Engineering → Restore Metadata + Modify Logic

## Scene Classification
Game Security / Mobile Reverse Engineering

## Overview of Goals
A Unity-packed Android game (IL2CPP mode), with in-game purchases or core algorithms written in C# but compiled into native code. It is necessary to restore method names, locate key logic, and implement modifications / hooks.

## Complete Execution Chain

1. Unpack the APK and confirm it is IL2CPP
   ```bash
   unzip target.apk -d apk
   ls apk/lib/arm64-v8a/        # Seeing libil2cpp.so means IL2CPP
   ls apk/assets/bin/Data/Managed/Metadata/
   # Key file: global-metadata.dat
   ```
2. Restore metadata using **Il2CppDumper**
   ```bash
   Il2CppDumper libil2cpp.so global-metadata.dat output/
   # Output: DummyDll/ + script.json + il2cpp.h + dump.cs
   ```
3. Run the IDA IL2CPP script (`ida_with_struct.py`) once
   - Load libil2cpp.so → File → Script File → select ida_with_struct.py → select script.json
   - IDA can now see C# method names, signatures, and strings
4. In dump.cs, search by business keywords (`AddCoin` / `OnPurchase` / `Verify` / `IsVip` / `CheckSign`)
5. Get the offset of the key method → Use IDA to jump and look at the disassembly/decompilation
6. Choose the modification method:
   - **Static patch**: Directly change the check to `mov w0, #1; ret` in IDA
   - **Dynamic hook**: Frida hooks il2cpp methods (using Frida-Il2CppBridge)
7. Repackaging Verification / Injection Verification

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| Il2CppDumper reports metadata version not supported | Newer Unity changed metadata format | Upgrade Il2CppDumper to the latest / use Il2CppInspectorRedux as a replacement | 30min |
| global-metadata.dat is encrypted | Uses AntiCheatToolkit / custom encryption | Find the decryption function when the game initializes (usually around il2cpp_init) → dump with Frida after mmap | 2h |
| Seen method name in dump.cs but no match in IDA | script.json is inconsistent with so | Must use the product from the same dump; clear cache when switching IDA | 20min |
| Frida hook IL2CPP method error | IL2CPP method is not standard Java/ObjC, need to calculate method offset | Use frida-il2cpp-bridge library, do not hardcode Interceptor.attach | 1h |
| Game crashes after patch | Verify file hash or anti-tamper | Find the hash verification logic and patch it, or use a hook without modifying the files | 2h |
| Crashes on startup after repackaging | apksigner v2 signature cannot be modified and then re-signed | Delete META-INF + apktool b + apksigner sign in one go | 30min |

## Toolchain Discovery

- **Il2CppDumper** is an established tool but still the default choice
- **Il2CppInspectorRedux** is more modern, supports newer Unity versions, and can output scripts for IDA / Ghidra / Binary Ninja plugins
- **frida-il2cpp-bridge** is the de facto standard for hooking on IL2CPP, far stronger than plain Frida.
- **DnSpy** / **dnSpyEx** are used to view DummyDll (a dumped pseudo .NET assembly)
- **UnityCheat** series of auxiliary tools (GameGuardian series not expanded)

## Key Code/Commands

frida-il2cpp-bridge hook example:

```typescript
// hook.ts
import "frida-il2cpp-bridge";

Il2Cpp.perform(() => {
    const Assembly = Il2Cpp.domain.assembly("Assembly-CSharp").image;

    // hook static method
    const PlayerData = Assembly.class("PlayerData");
    PlayerData.method("AddCoin").implementation = function (n: number) {
        console.log("[+] AddCoin called with:", n);
        return this.method("AddCoin").invoke(99999); // 改成 99999
    };

    // hook instance method
    const Purchase = Assembly.class("Purchase");
    Purchase.method("VerifyReceipt").implementation = function () {
        console.log("[+] VerifyReceipt → always true");
        return true;
    };
});
```

```bash
# Compile + Inject
npm install frida-il2cpp-bridge
frida-compile hook.ts -o hook.js
frida -U -f com.target.game -l hook.js --no-pause
```

IDA static patch:

```text
1. Open libil2cpp.so and run il2cpp_load_metadata.py
2. Jump to the offset corresponding to IsPurchaseValid in dump.cs
3. Change the beginning of the function to MOV W0, #1; RET (ARM64)
4. Apply Patches → Save → Replace back into APK → Re-sign
```

## Suggestions for Improvement of This Package

- `reverse-engineering/README.md` has covered Unity, but lacks **complete IL2CPP workflow** cases
- `reverse-engineering/references/il2cpp-cheatsheet.md` Standalone document: dump tool comparison, frida-bridge template, encrypted metadata handling
- bootstrap manifest adds frida-il2cpp-bridge

## Reusable patterns/script snippets

**IL2CPP Standard Process**:

```text
1. Confirm IL2CPP (check if there is libil2cpp.so under lib/abi)
2. Find the metadata (assets/bin/Data/Managed/Metadata/global-metadata.dat or encrypted)
3. Il2CppDumper / Inspector Restoration
4. IDA + script returns meta information
5. dump.cs Search business keywords
6. Choose patch or hook
7. Validation (Startup + Real Scenario)
```

**Encrypted metadata processing**:

```text
1. Frida hooks onto the fopen/open call to see who reads global-metadata.dat
2. Dump the decrypted metadata from memory after mmap/read
3. Feed the memory dumped as metadata to Il2CppDumper
```

## Evolution Actions
- [ ] reverse-engineering/references Add complete il2cpp chapter
- [ ] Add frida-il2cpp-bridge / Il2CppInspectorRedux to bootstrap-manifest
- [x] The routing matrix already includes Unity / IL2CPP

## Environmental Information
- Windows / macOS (used to run Il2CppDumper), target device Android arm64
- IDA Pro 7.7+ or Ghidra 11+
- frida-tools 16.x, frida-il2cpp-bridge 0.9+
- Unity version: 2019.x - 2022.x (metadata format varies slightly between versions)

## Desensitization Requirements
This entry is seed data, written based on publicly available technical patterns, and does not involve any real game. The package name `com.target.game` is a placeholder.