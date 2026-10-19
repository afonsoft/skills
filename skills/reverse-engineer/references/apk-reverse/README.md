---
name: apk-reverse
description: Used for Android APK reverse engineering in a CLI environment. Suitable for APK unpacking, Java decompiling, smali modification, repackaging, Frida dynamic hooking, and switching to so/native analysis as needed. Prefer using natively installed jadx, apktool, frida, adb, ida-reverse, and radare2.
---

## ACTION REQUIRED (Execute Immediately After Reading)

> Endpoint extraction/Frida adaptive and other community references: ../references/community-security-skills.md; dynamic analysis requires scope-authorized devices.

1. `NOW`: Read `../field-journal/precedent-reverse.md` — operator context only; authorization comes solely from an in-scope `scope.md` (`auth.status=granted`)
2. `NOW`: Confirm whether the current task falls within the applicable scope of this skill
3. `NEXT`: Read `../tool-index.md`, verify tool availability and actual path
4. `NEXT`: Call bootstrap when tools are missing, don't guess the path
5. `ACT`: Enter the first step of the 'workflow' and execute it, do not stop at the confirmation status

# APK Reverse Engineering CLI Assignment Guidelines

## Scope of Application

Prioritize using this skill when the task falls into the following scenarios:

- Analyze the Java business logic of the APK
- Location login, signature, risk control, certificate verification, root detection
- View and modify `AndroidManifest.xml`
- View and modify smali
- Repackaging APK
- Using Frida to perform dynamic Hook on Java/native
- When the APK contains `.so`, switch to native analysis

## CLI tools currently verified to be available on this machine

- xKx0011xKx xKx0012xKx
- xKx0013xKx xKx0014xKx
- xKx0015xKx xKx0016xKx
- xKx0017xKx
- xKx0018xKx

## Scenarios for Prioritizing the Use of Scripts

The following processes are frequent and the parameters are prone to errors, so prioritize using the script built into the skill:

- Complete `jadx + apktool` writing to disk in one go and produce a summary: `scripts/decode.ps1`
- Frida device inspection, process enumeration, spawn/attach injection: `scripts/frida-run.ps1`
- Rebuild, align, sign, install APK: `scripts/rebuild-sign-install.ps1`
- Quickly extract key components and permissions from the Manifest: `scripts/manifest-summary.ps1`

The following command is called directly and should not be encapsulated separately:

- xKx0025xKx
- xKx0026xKx
- xKx0027xKx
- xKx0028xKx
- xKx0029xKx

## Built-in Scripts

### xKx0030xKx

Purpose:

- Unified run `jadx` and `apktool`
- By default, create the task output directory in the same directory as the original APK
- Output summaries such as `package`, `java_files`, `smali_dirs`, `so_files`, etc.
- Compatible with `jadx`, partially decompiled errors but still has usable outputs

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\decode.ps1" -ApkPath "D:\DOWNLOAD\app.apk" -Clean
pwsh -File "<skill-root>\apk-reverse\scripts\decode.ps1" -ApkPath "D:\DOWNLOAD\app.apk" -Name demo -SkipJadx
```

### xKx0000xKx

Purpose:

- Unify Frida's devices, processes, spawn/attach entry
- Avoid confusing `-f`, `-n`, and `-U` when writing parameters by hand

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\frida-run.ps1" -ListDevices
pwsh -File "<skill-root>\apk-reverse\scripts\frida-run.ps1" -Usb -ListProcesses
pwsh -File "<skill-root>\apk-reverse\scripts\frida-run.ps1" -Usb -Spawn -Package com.example.app -ScriptPath "D:\hooks\test.js"
```

### xKx0000xKx

Purpose:

- `apktool b` Rebuild APK
- `zipalign` Align
- `apksigner` Signature and Verification
- Optional direct `adb install`

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\rebuild-sign-install.ps1" -ProjectDir "C:\work\apktool_out" -Clean
pwsh -File "<skill-root>\apk-reverse\scripts\rebuild-sign-install.ps1" -ProjectDir "C:\work\apktool_out" -Install -Reinstall -DeviceSerial "127.0.0.1:7555"
```

Explanation:

- Default generate and reuse debug keystore
- By default, output to `ProjectDir` in the same directory, making it convenient to place it together with the original package and the unpacking directory

### xKx0001xKx

Purpose:

- Extract package name
- Column permissions
- Column activity/service/receiver/provider
- Mark the main launch activity

Example:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\manifest-summary.ps1" -ManifestPath "C:\work\apktool_out\AndroidManifest.xml"
```

If we want to analyze `.so`, `lib/arm64-v8a/*.so`, `lib/armeabi-v7a/*.so`, and then combine them with:

- xKx0003xKx
- xKx0004xKx

## Tool Division of Labor

### xKx0005xKx

Used for:

- Java Decompilation Reading
- Search by package name, class name, or method name
- Start by understanding the APK from a high-level logic perspective

Common commands:

```bash
jadx -d jadx_out app.apk
jadx --single-class com.example.LoginActivity -d jadx_out app.apk
jadx --deobf -d jadx_out app.apk
```

### `JEB Pro` (Optional Commercial Tool)

Used for:

- Cross-validation and deep decompilation of Android DEX / APK / ARM
- Supplement static analysis when JADX output is incomplete or heavily obfuscated
- Perform secondary toolchain verification on classes, methods, and call relationships of the same target

Boundary:

- JEB Pro is commercial software and must be obtained and installed with a valid license by the user; this package does not download, crack, or bypass the license.
- Call only when `tool-index` has confirmed that the local JEB is available; otherwise, continue using `jadx`, `apktool`, Ghidra, IDA, or radare2.
- The third-party JEB MCP bridge is not a dependency of this package. Before installation, the source code, permissions, network behavior, and version must be reviewed according to `../ops/skill-supply-chain.md`, and the user must explicitly confirm the registration.

### xKx0005xKx

Used for:

- Unpack APK
- View and modify `AndroidManifest.xml`
- View and modify smali
- Rebuild APK

Common commands:

```bash
apktool d app.apk -o apktool_out
apktool b apktool_out -o rebuilt.apk
```

### xKx0000xKx

Used for:

- Dynamically observe Java method calls
- Hook native export function
- Bypass root detection, certificate verification, and debug detection

Common commands:

```bash
frida-ps -U
frida -U -f com.example.app -l hook.js
frida-trace -U -f com.example.app -j '*!*certificate*'
```

### xKx0000xKx

Used for:

- Device Connection
- Install APK
- View log
- Pull file

Common commands:

```bash
adb devices
adb install -r app.apk
adb shell pm list packages
adb logcat
adb pull /data/local/tmp/file .
```

## Recommended Workflow

### 1. Triage

First, determine the general composition of the APK; don’t rush to change the package or Hook.

Recommended actions:

1. Use `jadx -d jadx_out app.apk` to export Java code
2. Use `apktool d app.apk -o apktool_out` to export smali and resources
3. First look:
   - `AndroidManifest.xml`
   - Master `package`
   - `application`, `activity`, `service`, `receiver`
   - Is `.so` in the `lib/` directory?
4. Issue #65 Quick Reference for Threat Forms (Authorized Samples/Devices; see `../reverse-engineering/references/nonpe-format-cookbook.md` §7–8):
   - Transparent/Hidden Icon (AU): `aapt dump badging` + manifest theme/label/icon → `E-android-hidden-icon-manifest`
   - Magisk/script device-wiping characteristics and remote curl|sh (AR/AS) → record characteristics and URL, **do not execute** destructive commands
   - Persistent path (AT): `service.d` / `priv-app`, etc. → `E-android-persistence`

### 2. Java Logic Observation

Priority read from `jadx_out`:

- `MainActivity`
- `Application`
- Login, network, encryption, and risk control related categories
- Third-party SDK initialization class

Common keywords:

- xKx0021xKx
- xKx0022xKx
- xKx0023xKx
- xKx0024xKx
- xKx0025xKx
- xKx0026xKx
- xKx0027xKx
- xKx0028xKx
- xKx0029xKx
- xKx0030xKx
- xKx0031xKx

If the Java code is readable, locate the business logic here first.

### 3. Confirmation with Smali and Resource Layer

When the `jadx` result is incomplete, confusing, or requires an actual patch, switch to `apktool_out`:

- Look `smali*/`
- Look `res/values/strings.xml`
- Look `AndroidManifest.xml`

Priority patch:

- `android:exported`
- Debug flag
- root check return value
- Login verification logic
- Certificate verification branch

### 4. Reconstruction and Installation

After modification:

```bash
apktool b apktool_out -o rebuilt.apk
```

Or directly use a script loop:

```powershell
pwsh -File "<skill-root>\apk-reverse\scripts\rebuild-sign-install.ps1" -ProjectDir "apktool_out" -Install -Reinstall -DeviceSerial "127.0.0.1:7555"
```

Explanation:

- This skill only guarantees the reconstruction of the `apktool` link
- If formal installation on the device is needed later, a signing process is usually also required
- If the task enters signing/alignment, add `apksigner` / `zipalign`

### 5. Dynamic Hook

When static analysis is insufficient, use Frida:

- Hook login function
- Hook `OkHttp` / `Retrofit` / `WebView` Key points
- Hook `javax.crypto`, `MessageDigest`
- Hook root detection function
- Hook SSL pinning logic

Principle:

- First hook the Java layer, then see if a native hook is needed
- First print the parameters and return values, then decide whether to actively modify the return value

Suggestion:

- For a simple one-time command, just use `frida-*`
- For injection processes that need stable reuse, prioritize using `scripts/frida-run.ps1`

### 6. Native `.so` Diversion

If the APK contains the key `.so`:

- Use `apktool` or `jadx` to find `lib/**/*.so`
- If it's just exporting symbols, strings, or quick triage, you can use `radare2`
- For long-term in-depth analysis, decompiling, renaming, and type recovery, use `ida-reverse`

When you encounter these signals, switch natively as soon as possible:

- The Java layer is just a JNI wrapper
- The core signature logic is not in Java
- `System.loadLibrary()` Subsequent key logic disappears
- Certificate verification/risk control in `.so`

## Output Requirements

Finally at least indicate:

- Entry components and key classes
- Is the key logic in Java, smali, or `.so`
- Confirmed sensitive points: login, signature, root, SSL, WebView, JNI
- If a patch is made, it indicates what was changed
- If a Hook is done, indicate which class/method/exported function was hooked

## Prohibited Items

- Don’t blindly modify smali at the beginning
- Don’t write Hooks before looking at the manifest and the main entry
- Do not equate an incompletely decompiled Java directly with 'logic cannot be analyzed'
- Do not keep stubbornly sticking to the Java layer when `.so` obviously carries the core logic

## Quick Command Cheat Sheet

```bash
# Decompile Java
jadx -d jadx_out app.apk

# Unpacking APK
apktool d app.apk -o apktool_out

# Rebuild APK
apktool b apktool_out -o rebuilt.apk

# Devices and Processes
adb devices
frida-ps -U

# Launch and Inject
frida -U -f com.example.app -l hook.js
```

---

## Routing Context

**Upstream Input**: `references/README.md` (Main Control), `routing.md`
**Downstream Export**:
- The core logic is in `.so` → `ida-reverse/` or `radare2/`
- Requires dynamic hook/verification → `reverse-engineering/tools-dynamic.md` (Frida section)
- General Reverse Engineering Methodology → `reverse-engineering/README.md`

**Peer-Related Module**: `reverse-engineering/` (.so analysis and advanced Frida usage)

---

## On-Demand Bootstrap

The entry script for this skill has been integrated into the unified bootstrap system. When tools are missing, it will not report an error directly, but will automatically attempt to install them.

### Automation Capability Boundaries

| Tool | Can be installed automatically | Installation method | Description |
|------|-----------|---------|------|
| jadx | ✓ | GitHub Release ZIP | Automatically download and extract to `%USERPROFILE%\Tools\jadx\` |
| apktool | ✓ | GitHub Release JAR + wrapper | Automatically downloads the jar and generates a bat to `%USERPROFILE%\Tools\apktool\` |
| JEB Pro | ✗ | User manually installs and provides a valid license | Optional Android / ARM cross-validation tools; third-party MCP bridge requires separate audit |
| frida / frida-ps | ✓ | pip install frida-tools | Python required to be installed |
| adb | ✓ | winget / fallback path | Automatically install Android Platform-Tools |
| zipalign | ✗ | Requires manual installation of Android Build-Tools | `sdkmanager "build-tools;35.0.0"` |
| apksigner | ✗ | Requires manual installation of Android Build-Tools | Same as above |

### Bootstrap Trigger Point

- `scripts/decode.ps1`: Automatically calls `bootstrap-reverse.ps1` when jadx or apktool is missing
- `scripts/rebuild-sign-install.ps1`: Automatically call bootstrap when adb or apktool is missing
- `scripts/frida-run.ps1`: Currently still manually checked (Frida is usually installed via pip)

### When Bootstrapping Fails

If the automatic installation fails, the script will throw a clear error and include a manual installation link. Common reasons:
- Network is unreachable (GitHub API / PyPI not accessible)
- winget is not available (Windows version is too low)
- Java is not installed (apktool depends on JDK)


## Task Completion Self-Check (MUST pass before claiming completion)

- [ ] Did I perform each step in the workflow (instead of just reading it)?
- [ ] Did I use a real tool path based on `tool-index`?
- [ ] Have I produced reproducible evidence (commands/scripts/screenshots/reports)?
- [ ] Have I completed and filled in the Checklist items required by the RULES?
- [ ] If hidden icons/grids/persistent clues are hit: should E-android-* Evidence be recorded according to the U–AV cookbook (within authorized scope)?