# 2026-08-20 Flutter APK server-side driver advertisement removal (third-party counterfeit package)

## Scene classification
APK reverse engineering / Flutter AOT patch

## Goal Overview
Locally owned APK (`{target_app}` 1.0.8, third-party counterfeit package) removes banner/pop-up ads driven by the server and re-signs the output.

## Scope Summary (Desensitization)
- auth_basis: User's local file, modified for personal use
- network_profile: pure static analysis + local build, no external system ACT
- asset_types: [android_apk, flutter_aot_libapp.so]

## Role
- lead_role: lead
- specialists: []

## Complete execution link

1. Target identification: `{target}.apk` — Flutter 3.4.4 (libapp.so 13MB) + 360 reinforced shell (`com.frezrik.jiagu.StubApp`, real dex encrypted in classes.dex tail payload 2.58MB)
2. Static reconnaissance: apktool d/jadx → manifest no third-party advertising SDK; scan libapp.so string → discover server-side advertising system (`ad_slot_key`/`ad_show:`/`wcstream_*` slot, `system/banner/bannerListByMAcct` API)
3. Tool chain construction: gitee pre-compiles blutter for ARM64-Linux (not available) → Download blutter-unmgr source code → Windows MSVC build (VS2026 BuildTools + cmake + ninja) → Compile dartvm3.4.4_android_arm64 static library (~15min) → blutter.exe analyzes libapp.so → Output pp.txt/objs.txt/asm/ + frida script
4. Advertising system restore: classes `qya` (ad model, 11 fields), `pya` (banner list), `GBg` (Map<String,dynamic>→Map<String,List<qya>> parser), all slot keys and API endpoints
5. Patch design (v2 revision): **Equal-length string replacement** (31 advertising strings × 2 ABI): JSON key → garbage string (parse null), slot key → garbage string (table lookup failed), reporting label → garbage string. **API path string remains and will not be replaced** (After the first version was replaced, the real machine started with a 404 card, see the last entry in the pitfall record). The client is self-consistent and the server contract is broken.
6. String table format adaptation: arm64 packed table `[0x80|(len<<1)][chars]`; armv7 object table `[len*2 u32le][chars]`. Prefix verification + long string priority to avoid substring overlap (welfare_ad_top/welfare_ad, ad_click:/ad_click).
7. Repackage: Python zipfile copy 1010 entries (replace libapp.so×2, delete old signature) → zipalign -p 4 → apksigner v1+v2+v3 (debug keystore)
8. Verification: libapp.so passes after Blutter re-analyzes the patch (snapshot is intact); apksigner verify passes; aapt badging is consistent; zip difference is only libapp.so+signature; 0 advertising string residue in APK
9. **Real machine runtime verification (supplementary)**: arm64 real machine installation → Enter the main interface normally and the advertisement disappears; logcat confirms zero Flutter exceptions (see pitfall records for details)

## Evidence chain summary
| E-id | source_type | Reusable command pattern | Association Finding |
|------|-------------|----------------|--------------|
| E-001 | blutter_out/pp.txt | `[pp+0x210a8] String: "wcstream_banner_top"` | F-001 |
| E-002 | Patch Script | `work/patch_libapp.py` | F-001 |
| E-003 | Blutter reanalysis | `python blutter.py <patched_dir> <out>` exit 0 | F-002 |

## Finding / Path Summary
- top_finding: A Flutter application that drives advertising on the server side. There is no need to change the code logic to remove advertising - just replace the JSON keys/slot keys in the string table with equal lengths. The client is internally self-consistent and the server-side contract is invalid; **but the API path string cannot be replaced** (starting process request 404 → jsonDecode exception → card startup)
- path_type: solve
- path_one_liner: locate string table → replace advertising JSON key/slot key with equal length (preserve API path) → repackage signature → real machine logcat verification

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| 360 reinforcement: real Java dex encryption | jadx only sees the shell (com.frezrik.jiagu + a.*) | Advertising logic is in the Flutter Dart layer (libapp.so), no need to unpack | 0.5h |
| gitee pre-compiled blutter cannot run | The binary is ARM64-Linux (for Termux) | Download the blutter-unmgr source code and compile it yourself x64 | 1h |
| Windows build cmake cannot find cl | %PATH% parsing period expansion in cmd, covering vcvars environment | `cmd /V:ON` + `set PATH=...;!PATH!` delayed expansion | 0.2h |
| `string(REPLACE "/EHsc" ...)` CMake error | Insufficient REPLACE parameter when CMAKE_CXX_FLAGS is empty (new version of CMake) | Patch and add `if(CMAKE_CXX_FLAGS)` guard (template + generated file) | 0.2h |
| Obfuscated app advertising function asm is missing (size=-1) | Blutter fails to analyze obfuscated/complex functions | Abandon code-level patching and use string table replacement | 0.5h |
| Manual search for pool entry references failed | Snap pool entries are compressed pointer encoding, offset relative to the pool base address | Abandon manual coding reverse, directly use Blutter pp.txt to locate string objects | 1h |
| Substring mismatch | "welfare_ad" hits "welfare_ad_top" internal | Long string priority replacement + check prefix byte (arm64: 0x80\|len<<1; armv7: len*2) | 0.3h |
| ⚠️ **After replacing the API path, the real machine is stuck at startup Logo** | The first version also replaces `system/banner/bannerListByMAcct` → The startup pull ad request hits a non-existent endpoint → Server 404 (error body is not legal JSON) → Start process `jsonDecode` throws `FormatException` (logcat `E flutter`) → Enter the Future of the homepage and interrupt the UI Permanently stay on the splash screen | **API path/URL string is not replaced**; only JSON key/slot key/reporting label is replaced. Variable isolation for positioning (only re-signed comparison package) + `adb logcat -d \| grep "E flutter"`; MIUI installation interception requires `settings put global verifier_verify_adb_installs 0` | 1h |

## Toolchain discovery
- blutter-unmgr (gitee.com/fest_1/blutter-unmgr): The precompiled package is ARM64-Linux; the source code contains `blutter.py` (automatically detects Dart version + build + run integration)
- Blutter Windows build dependencies: VS BuildTools (including cl) + cmake (≥3.20) + ninja + ICU/capstone (init_env_win.py automatically downloaded)
- CMakeLists REPLACE bug needs to be fixed (see above)

## Reusable mode
**General process for server-side driven ad removal** (Flutter or native):
1. Decompile to find advertising API endpoint/model key/slot key string
2. Confirm the string table format (arm64 packed / armv7 object / general length-prefixed)
3. Equal-length ASCII replacement **JSON key/slot key/reported label** (offset preserved) → server-side contract broken; **API path preserved**
4. Repackage + zipalign + apksigner (note to uninstall the old signature first)
5. Real machine installation + `adb logcat` verification (pay attention to `E flutter` uncaught exception and ensure that there is no 404 in the startup process)