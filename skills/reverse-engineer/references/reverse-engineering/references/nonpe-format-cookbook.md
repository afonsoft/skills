# Non-PE / Multi-Format Agent Response Recipe U–AV + AW–DN

> Listed alongside the PE anti-debugging recipe A–T (xKx0000xKx): Provide 'Trigger → Action One Line → Evidence' according to **file type**.
> **Not** the second main process. After Triage identifies the type, it jumps to the corresponding skill + this table.
> Default **authorized isolation lab / authorized samples and devices**. For bricking devices, BYOVD, reflective injection, etc., write **detection and forensics**, do not write tutorials on unauthorized xKx0001xKx
> Bypassing or restoration failure MUST also record Evidence; silently treating it as 'harmless' is prohibited.
>
> §1–§8 / U–AV = Original rules (Issue #65). §9–§23 / AW–DN = Extended rules (Issue #87, deduplicated + semantic enhancements + edge-case patches).

## 0. Routing Quick Reference

| Type Clue | Main Skill | Chapter in This Table |
|----------|----------|----------|
| .bat / .cmd / batch processing | malware-analysis | §1, §19 |
| .ps1 / PowerShell | malware-analysis | §2, §20 |
| Office Macros / VBA / XLM / .xKx0002xKx | malware-analysis | §3 (including DD OLE extraction, DJ XLM macros) |
| .xKx0003xKx OOXML external link / DDE / .rtf OLE | malware-analysis | §10 (including DK RTF) |
| xKx0004xKx JS Obfuscation, JSVMP | js-reverse | §4, §21 (including xKx0005xKx) |
| .sys / Kernel Driver | xKx0006xKx + cre | §5 |
| .dll Focus | malware-analysis / re-agent-workflow | §6 (deduplicated with A–T) |
| APK / Magisk / Hide Icon | apk-reverse | §7–§8, §23 |
| .pdf / PDF Document | malware-analysis | §9 |
| .wasm / WebAssembly | reverse-engineering | §11 |
| .xKx0007xKx / Java Bytecode | reverse-engineering | §12 |
| .exe(AutoIt) / .au3 | malware-analysis | §13 |
| .hta / HTML Application | malware-analysis | §14 |
| .xKx0008xKx | malware-analysis | §15 |
| .msi / Windows Installer | malware-analysis | §16 |
| .reg / Registry Script | malware-analysis | §17 |
| .vbs / VBScript | malware-analysis | §18 |
| xKx0009xKx Module | apk-reverse | §22 |
| ELF / Linux Binary | reverse-engineering | → elf-analysis.md, anti-analysis.md |
| Mach-O / xKx0010xKx | reverse-engineering | → platforms.md |
| Python bytecode | reverse-engineering | → languages.md |

## 1. xKx0009xKx（U V W）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **U** | Extensive use of SET single-character variables + %a%%b% concatenation, or ^ to split commands across lines | Expand SET by line; restore the command list; batch deobfuscation tools can be used; **considered 'no-op' before restoration** | E-batch-deobf | P0 |
| **V** | Text opens with garbled characters, HEX header FF FE (UTF-16 LE BOM) | Confirm BOM → convert to UTF-8 and then parse; or chcp 65001 + type | E-batch-encoding | P2 |
| **W** | A large number of REM/:: and redundant GOTO/labels overwhelm the real logic | Remove comments; sort out the true GOTO paths; isolate execution to capture the actual command logs | E-batch-deadcode | P1 |

## 2. PowerShell（X Z）

> Retain the submitter's numbering convention: **No patch Y**.

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **X** | Multi-layer FromBase64String / Gzip / Compress / Nesting -replace | Decode **layer by layer**; record the result of each layer separately; tools optional (PowerDecode, etc.), if no tool then xKx0012xKx | E-ps-decode-layer-N | P0 |
| **Z** | Reverse string, fragment + concatenate xKx0013xKx | Restore complete string; set breakpoint on IEX or script block log; plaintext command into Evidence | E-ps-string-restore | P1 |

## 3. VBA Macros / XLM (AA AB AC DD DJ)

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AA** | xKx0001xKx Only P-Code is seen, source code stream is empty (VBA Stomping) | P-Code decompilation tool; if not complete then xKx0002xKx macro debugging observation; specify limitations clearly | E-vba-pcode | P0 |
| **AB** | Large amounts of Chr() concatenation or Base64 strings, suspected xKx0003xKx scripts | Immediate xKx0004xKx to restore strings; determine type after decoding; dynamically monitor xKx0005xKx | E-vba-str-decode | P1 |
| **AC** | Nonsense If 1=2, or xKx0006xKx self-modifying | Static follows true branch; dynamic bp self-modifying API and dump modified macro | E-vba-selfmod | P2 |
| **DD** | xKx0007xKx Detected VBA macro project (vbaProject.bin); extension .xKx0008xKx | oledump.py checks OLE stream structures; olevba extracts VBA source code to detect suspicious APIs; checks xKx0009xKx and other auto-executing macros | E-office-vba | P0 |
| **DJ** | .xKx0010xKx contains Excel xKx0011xKx macros (hidden in cell formulas, not VBA stream); olevba checks for XLM macro tags | olevba --xlm extracts XLM macro formulas; checks functions in hidden worksheets xKx0012xKx; XLMMacroDeobfuscator dynamically simulates and restores | E-office-xlm | P0 |

## 4. JavaScript (AD AE AF) → Main path js-reverse

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AD** | Custom bytecode array + xKx0024xKx interpreter (JSVMP) | Find VM entry and opcode dispatch; dynamic log tracing; AST + dynamic dual-track; see js-reverse DeepDive | E-js-vmp | P0 |
| **AE** | while(1){switch} + large string array index | xKx0025xKx refactor; restore string from array index; wakaru and other options; **do not** paste the entire PE ollvm-deobfuscation long text | E-js-deobf | P0 |
| **AF** | debugger, hijack console, performance.now discrepancies, DevTools detection | Disable xKx0026xKx time xKx0027xKx browser; patch detection points; authorized page | E-js-anti-debug | P1 |

## 5. SYS Kernel Drivers (AG AH AI)

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AG** | DriverEntry is very short, logic is not in the entry | Scan MajorFunction[] non-empty slots; prioritize xKx0028xKx; address list into record | E-driver-irp-handlers | P0 |
| **AH** | Presence of DeviceIoControl / IOCTL dispatch | Built control code → handler table; marks METHOD_* and buffer direction; user-mode communication interface | E-driver-ioctl | P0 |
| **AI** | Sample xKx0029xKx of known vulnerable or abnormal signature drivers (BYOVD mode) | Refer to public lists like LOLDrivers; record driver xKx0030xKx; analyze **call intent**; **do not** perform exploit steps | E-driver-byovd | P1 |

For details, see the kernel-driver-reverse.md process; this table only supplements the agent action anchors.

## 6. DLL (AJ–AQ) — Deduplicate with A–T / #72

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AJ** | The DLL analysis only looked at xKx0031xKx, ignoring TLS or DllMain | **Both TLS callbacks + DllMain must be checked**; the order of dynamic breakpoints still follows the four-stage rocket (TLS → xKx0032xKx → API → ExitProcess) | E-dll-tls-dllmain | P0 |
| **AK** | Export with correct name but bad afterward, misnamed, or export inconsistent with behavior | Cross-check between export table and actual calls; list of abnormal exports | E-exports-anomaly | P0 |
| **AL** | No exports or very few exports, but still loaded | Locate from entry points, strings, xrefs, callers; do not give up because of 'no exports' | E-dll-noexport | P0 |
| **AM** | Static IAT missing DLL, used only at runtime | **See A–T patch R** (Delay-Load / E-delay-import), do not duplicate long text here | E-delay-import | P0 pointer |
| **AN** | Need to restore exported function parameters and calling conventions | Cross-reference + dynamically check xKx0033xKx; annotate xKx0034xKx etc. | E-dll-export-abi | P1 |
| **AO** | Suspected DLL xKx0035xKx | Check for DLLs with the same name in the application directory, search paths, KnownDLLs; legitimate program + abnormal DLL combination | E-dll-sideload | P1 |
| **AP** | Fileless xKx0036xKx Loading Indicators | Memory characteristics, loader behavior, pathless modules; authorized environment forensics | E-dll-reflective | P1 |
| **AQ** | Lower risk merely because the export name 'doesn't seem malicious' | **Prohibited** to judge safety solely based on export name; consider section permissions, entry point, strings, dynamic behavior | E-dll-export-priority | P1 |

xKx0037xKx Hard door still: E-imports + E-exports (see re-agent-workflow).

## 7. Android Device Cracking / Persistence (AR AS AT) → apk-reverse

> **Only authorized samples, images, or test devices.** The actions involve detecting, extracting IOCs, and persistence paths, not causing damage.

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AR** | Magisk xKx0038xKx containing commands such as database deletion, flashing, batch rm of system partitions, etc. **Factory reset characteristic commands** | Characteristic command table + module path; high-risk destructive capability; does not execute factory reset commands | E-android-wiper-cmd | P0 |
| **AS** | Looping curl|sh / Remotely fetching scripts, unconventional C2 URL | Provide URL; analyze whether the downloaded payload contains malware commands; note temporary path | E-android-wiper-backdoor | P0 |
| **AT** | /xKx0039xKx, post-fs-data.d, suspicious /xKx0040xKx, etc. | Lists persistent xKx0041xKx; content summary for evidence | E-android-persistence | P1 |

## 8. Android xKx0042xKx Icon (AU AV) → apk-reverse

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AU** | LAUNCHER icon fully xKx0043xKx label, Theme.NoDisplay, no LAUNCHER category, component disabled | aapt dump badging + manifest; decompile to check icon pixels; record abnormal items | E-android-hidden-icon-manifest | P0 |
| **AV** | Installed but no desktop icon, background xKx0044xKx xKx0045xKx icon recovery | pm list vs desktop; dumpsys package; broadcast and device_admin; behavior evidence collection | E-android-hidden-icon-behavior | P1 |

---

> **The following §9–§23 are the extended rules for Issue #87 (AW–DC).**
> Duplicate sections with existing files have been removed: ELF (→ elf-analysis.md), Mach-O (→ platforms.md), Python (→ languages.md).

## 9. PDF Malicious Documents (AW AX AY AZ)

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **AW** | pdfid detects /JS, /JavaScript, /OpenAction, /AA, /Launch counts >0 (including obfuscated counts with hex-encoded names like /4A#61#76#61...) | pdfid -e statistics (compare plain vs obfuscated counts); pdf-parser extract suspicious objects; peepdf interactive analysis + JS simulation | E-pdf-autoaction | P0 |
| **AX** | pdfid detects /EmbeddedFile >0; object streams contain xKx0013xKx cascade filter chain; or hidden encoded payload in /Annot objects | pdf-parser extracts stream data; peepdf decodes multi-level cascade filters (including AES-encrypted stream security handler xKx0014xKx); check Annotation objects; file identifies decoded result type | E-pdf-embedded | P0 |
| **AY** | Extracted PDF JS contains a large amount of eval, unescape, String.fromCharCode, atob | peepdf JS emulation environment execution tracing; layer-by-layer decoding xKx0015xKx; CyberChef assistance | E-pdf-js-deobf | P1 |
| **AZ** | PDF structural anomalies: /JBIG2Decode, XREF table manipulated, object number skipping | pdfid -d rename suspicious keywords; check known CVE exploitation patterns; extract exploit trigger conditions | E-pdf-exploit | P1 |

## 10. Office OOXML / DDE / RTF (BA BB DK) → Complementary to §3 VBA

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BA** | xKx0049xKx ZIP after extraction xKx0050xKx or xKx0051xKx contains suspicious external relationships (including remote template injection) | Check *.rels external links; check vbaData.xml; extract embedded OLE objects; check protocol handler abuse (ms-msdt: / search-ms: / ms-officecmd:) | E-office-ooxml | P0 |
| **BB** | The document contains DDEAUTO or DDEEXEC field codes, which execute external commands through the fields | Scan with olevba --dde; extract DDE command parameters; check if it points to xKx0052xKx exe | E-office-dde | P0 |
| **DK** | .rtf file contains embedded OLE objects (not OOXML, not classic OLE compound document) | rtfobj extracts embedded OLE objects; oleobj analyzes object type; check for Equation Editor exploit (CVE-2017-11882, etc.); file identifies type of extract | E-rtf-ole | P0 |

## 11. WebAssembly（BC BD BE）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BC** | File starts with \x00asm Magic Byte; Or JS code containing WebAssembly instantiation logic | wasm2wat converts to text; Check import section to identify host environment import function; wasm-decompile generates pseudocode; Check Emscripten glue signature (__wasm_call_ctors) to determine if it was compiled by JS | E-wasm-struct | P0 |
| **BD** | Many WASM functions but simple logic, function bodies are split into tiny functions; or meaningless xKx0053xKx nesting exists | Use diswasm to assess function minimization level; deep analysis with JEB Pro / IDA WASM plugin; dynamically trace execution logs | E-wasm-obfuscation | P1 |
| **BE** | WASM modules interact with the browser through xKx0054xKx functions, with WebSocket, fetch, and WebGL calls | Analyze both JS glue code and WASM modules; track data exchange using browser DevTools; extract network communication xKx0055xKx | E-wasm-c2 | P1 |

## 12. Java xKx0036xKx（BF BG BH BI）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BF** | xKx0056xKx When opening a JAR, class xKx0057xKx names are meaningless short characters (a.a.a / _0x prefix / numeric class names); or extensive xKx0058xKx control flow obfuscation | Identify obfuscator type (ProGuard / Allatori / ZKM); Java Deobfuscator static deobfuscation; dynamic debugging for key logic tracing under high intensity | E-java-obfuscation | P0 |
| **BG** | A large number of Class.forName(), Method.invoke(), Constructor.newInstance(); or custom ClassLoader + defineClass() to load classes from byte arrays in memory; importing the table is harmless but dynamically loading malicious classes at runtime | Use javap -c -v to view reflection call details; track Class.forName parameter strings; check the source of defineClass() byte arrays; dynamically set breakpoints on Method.invoke | E-java-reflection | P0 |
| **BH** | JAR containing .so (xKx0059xKx) or .dll (Windows); or System.loadLibrary() call | Extract native library files; file format identification; transfer to xKx0060xKx independent analysis process | E-java-native | P1 |
| **BI** | xKx0061xKx Contains nested xKx0062xKx after extraction; high entropy .xKx0063xKx files exist in /resources, /assets | Recursively extract all nested archives; entropy analysis to determine xKx0064xKx; check xKx0065xKx and pom.xml | E-java-nested | P1 |

## 13. AutoIt（BJ BK BL DM）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BJ** | PE strings contain AutoIt / AU3 / EA05 / EA06 signatures; or resource section contains AutoIt script resources (note distinction from AutoHotKey, both share MITRE T1059.010) | Use autoit-ripper to extract compiled scripts; identify encoding family (EA05 = AutoIt3.00 / EA06 = AutoIt3.26); after EA06 header, extract 8-byte decryption key to decrypt payload; restore source code | E-autoit-extract | P0 |
| **BK** | The extraction script contains a large amount of xKx0066xKx; or Execute dynamic execution + meaningless variable names | myAutToExe static decompilation; identification of anti-debugging techniques; analysis of obfuscated control flow | E-autoit-deobf | P1 |
| **BL** | The script contains RegWrite (registry persistence), FileInstall (file drop), InetGet (network download), xKx0067xKx | Mark sensitive API call sequences; analyze InetGet URL; trace FileInstall drop path | E-autoit-malicious | P0 |
| **DM** | AutoIt as a loader performs process hollowing: xKx0068xKx callback + shellcode + injection into legitimate processes (regsvcs.exe, etc.), releasing .NET payloads (DarkGate / Snake Keylogger / ArechClient2 mode) | Check xKx0069xKx call chain to kernel32 injection APIs; extract shellcode data; identify injected target processes; extract .NET payloads for independent analysis | E-autoit-hollowing | P0 |

## 14. HTA / HTML Application（BM BN BO）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BM** | HTML contains HTA:APPLICATION tag, window.execScript or CreateObject calls | Check HTA:APPLICATION attributes (Application, WindowState); extract xKx0070xKx in script tags | E-hta-bypass | P0 |
| **BN** | HTA launches via mshta.exe and executes payloads remotely through XMLHttpRequest / ActiveXObject | Extract network request URLs; trace ActiveXObject creation (ADODB.Stream, etc.); reconstruct the complete download-execution chain | E-hta-download-chain | P0 |
| **BO** | HTA contains only a single extremely long obfuscated string, executed via eval / execScript | Extract xKx0071xKx encoded payload for decoding; use CyberChef to recursively detect encoding types; restore payload | E-hta-oneline | P1 |

## 15. WSF / JSE / VBE（BP BQ BR BS）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BP** | .wsf contains the tags \xKx0072xKx + \xKx0073xKx tags, mixed with xKx0074xKx | Split code blocks by \xKx0075xKx; Analyze according to the corresponding language rules | E-wsf-multi | P0 |
| **BQ** | .xKx0076xKx starts with #@~^ signature, Microsoft Script Encoder encoded | screnc-decoder decoding; if no tool, dynamically execute + dump decoding script | E-jse-decode | P0 |
| **br** | WSF multiple \xKx0077xKx block + \xKx0078xKx referencing external resources + \xKx0079xKx referencing COM components | Create a cross-block call diagram; Track function calls between \xKx0080xKx; Restore the complete execution process | I-Youseifer-Kar-Chehn | P1 |
| **BS** | WSF contains WshShell.SendKeys to bypass UAC, WshShell.Run used with 0 window to hide, WScript.Sleep delay to bypass | Check if user simulated operations are used to bypass security prompts; log stealth execution parameters | E-wsf-anti-detect | P1 |

## 16. MSI Installation Package (BT BU BV)

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BT** | MSI file contains CustomAction table (Custom actions of Binary / Script / DLL type) | Extract contents using msiexec /a or lessmsi; check the CustomAction table; extract custom action binary files | E-msi-custom-action | P0 |
| **BU** | MSI Binary table containing xKx0081xKx custom action scripts | Extract the script binary from the Binary table and decode it into a readable script; analyze according to xKx0082xKx rules | E-msi-script | P1 |
| **BV** | MSI silent installation via /quiet /passive /qn; ALLUSERS=1 for elevation | Record installation command line parameters; analyze Property table permission settings; mark silent + elevation combination | E-msi-privilege | P1 |

## 17. REG Registry Script (BW BX BY)

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BW** | .reg writes xKx0083xKx or xKx0084xKx and other auto-start paths | Extract all paths; mark Run path entries as persistent; record full path and value | E-reg-persistence | P0 |
| **BX** | .reg modifies xKx0085xKx (file association) or xKx0086xKx{...}\InprocServer32 (DLL injection) | Check whether xKx0087xKx is a non-standard exe; check InprocServer32 DLL path | E-reg-hijack | P0 |
| **BY** | .reg modify xKx0088xKx (UAC level), EnableLUA, ConsentPromptBehaviorAdmin | Check the default security configuration before modification; analyze the impact on UAC; mark downgrade behavior | E-reg-uac-bypass | P1 |

## 18. VBScript（BZ CA CB CC DN）

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **BZ** | .xKx0089xKx Parsed by both VBScript and JScript; conditional compilation (@_win32) or cross-execution of language features | Separate xKx0090xKx code blocks; parse separately; identify mixed execution logic | E-vbs-mixed | P1 |
| **CA** | Script contains CreateObject("WScript.Shell") / CreateObject("Shell.Application") / Scripting.FileSystemObject | Marks high-risk COM object calls; tracks xKx0091xKx parameters; traces file paths created by FSO | E-vbs-com-abuse | P0 |
| **CB** | Script beginning #@~^ signature, Microsoft Script Encoder encoding (VBS specific) | screnc-decoder decoding; dynamically execute + dump decode script if no tool available | E-vbs-encoded | P0 |
| **CC** | xKx0092xKx contains WScript.Shell.Run + cmd /c + PowerShell, subsequent process injection | Trace CreateObject COM object chain; analyze injection characteristics in Run parameters; record complete process creation chain | E-vbs-inject-chain | P0 |
| **DN** | xKx0093xKx achieves fileless persistence through WMI ActiveScriptEventConsumer (no Startup xKx0094xKx Run key) | Check WMI event subscriptions (__EventFilter + __FilterToConsumerBinding + ActiveScriptEventConsumer); extract bound script content; flag fileless persistence | E-vbs-wmi-persist | P0 |

## 19. xKx0095xKx Advanced Obfuscation (CD–CI) → Complementary to §1 U–W

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CD** | setlocal enabledelayedexpansion + !var! + dynamic variable names (!var_%i%!) | Expand one by one after enabling delayed expansion; Batch-Dump --expand automatically expands | E-bat-delayed-expand | P0 |
| **CE** | Use xKx0096xKx to read its own or a file's :stream ADS alternate data stream execution | Check : suffix reference (file.bat:payload); dir /r lists ADS; type file:stream extracts | E-bat-ads-hidden | P0 |
| **CF** | A large number of echo statements write line by line into a .xKx0097xKx temporary file and then call to execute | Extract all echo redirections to restore the temporary file content; monitor scripts generated in the temporary directory | E-bat-temp-gen | P1 |
| **CG** | for %%i in (...) do set var=%%i Accumulate variable; for /f Parse command output line by line | Expand each for loop recording each iteration assignment; Serialize and restore for /f result | E-bat-for-expand | P1 |
| **CH** | The main batch process receives parameters through %1 %* , passed in by the parent xKx0098xKx as obfuscated instructions | Check the calling context to record incoming parameters; decode Base64 parameters to restore; restore the complete call chain | E-bat-param-call | P1 |
| **CI** | certutil -decode / powershell -Command / echo \| findstr Combined Decoding Execution | Extract xKx0099xKx string and decode; Check if the decoding result is an executable xKx0100xKx | E-bat-encoded-exec | P0 |

## 20. Advanced PowerShell Bypass (CJ–CO, DL) → Complementary to §2 X–Z

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CJ** | [Ref].Assembly.GetType('...AmsiUtils') / amsiInitFailed / GetTypes() and other AMSI bypasses (including hardware breakpoint bypass: CPU debug registers, no memory xKx0101xKx) | Identify bypass patterns (Patch / Registry / Environment Variable / Hardware Breakpoint); dynamically confirm effectiveness; mark bypass technique type | E-ps-amsi | P0 |
| **CK** | [PSConstraintLanguage] Type operations or modifying the session state through DefaultRunspace to bypass CLM | Detect CLM bypass patterns; tag as bypass-clm; analyze execution context after bypass | E-ps-clm-bypass | P0 |
| **CL** | [ScriptBlock]::Create / xKx0102xKx constructor; or override ScriptBlock logging settings | Check if the script disables logging; dynamically verify if logging is bypassed | E-ps-sb-log-bypass | P1 |
| **CM** | IEX (New-Object Net.WebClient).DownloadString(...) or [Reflection.Assembly]::Load(FromBase64...) fileless execution | Extract download URL to check xKx0103xKx reputation; PS logging captures in-memory loaded code; isolate network to simulate payload extraction | E-ps-reflect-load | P0 |
| **CN** | More than three layers of encoding nesting: outer layer Base64 → Gzip → XOR → plaintext (exceeding the two-layer range of §2 X) | Recursively decode to plaintext or until unable to continue; record intermediate state at each layer; PowerDecode automation; enter each layer's result as evidence | E-ps-multi-decode | P0 |
| **CO** | Set-Alias maps IEX to a single-character alias; Get-ChildItem variable: dynamically retrieves variable values | Expand all alias mappings back to the original command names; AST analysis restores variables | E-ps-alias-decode | P1 |
| **DL** | The script contains a ntdll.dll EtwEventWrite patch (stomping) to silently disable telemetry; often used in combination with AMSI bypass | Check for the presence of EtwEventWrite address retrieval + memory patch (ret 0xC3); check simultaneously with CJ AMSI bypass; mark as dual bypass combination | E-ps-etw-bypass | P0 |

## 21. Advanced JavaScript Obfuscation (CP CQ DE DF) → Complementary to §4 AD–AF

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CP** | JS uses Proxy objects to intercept property access + Reflect API to dynamically invoke methods to bypass static analysis | Identify Proxy xKx0104xKx trap functions; track the actual target of Reflect.get; mark dynamic interception behavior | E-js-proxy | P1 |
| **CQ** | JS contains _0x... hexadecimal string array + while(!![]) infinite loop + for+switch control flow (obfuscator.io feature) | Identify obfuscator.io features (string array + infinite loop); use de4js / jsnice for automatic deobfuscation; submit restored code as evidence | E-js-obfuscator | P0 |
| **DE** | The JS body consists of a large bytecode array + VM interpreter loop (multiple xKx0105xKx), with entry pointing to the xKx0106xKx constructor; business logic is completely unreadable (further development of §4 AD) | Identify the VM entry function and trace opcode→handler mapping; dynamically execute and hook eval in the browser to output; JSimplifier AST reconstruction; record opcode mapping table | E-jsvmp-deep | P0 |
| **DF** | JS contains eval to dynamically generate new code and execute it immediately, document.write to rewrite the page, or Function constructor to dynamically construct function bodies | Hook eval and Function constructor to record generated code; capture dynamically executed content from the browser | E-js-selfmod | P1 |

## 22. xKx0107xKx Module Analysis (CR–CX) → apk-reverse

> Analyzing xKx0108xKx **the module itself** as a reverse engineering target (not a tool usage scenario).

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **CR** | AndroidManifest.xml does not have an android:name entry Activity; meta-data specifies xposedmodule=true | Check xKx0109xKx to determine the entry class; search xKx0110xKx interface implementation | E-xp-entry | P0 |
| **CS** | Code contains XposedHelpers.findAndHookMethod / XposedBridge.hookMethod / findClass | Extract the first parameter of findAndHookMethod (target class) + the second parameter (target method); create a target app list | E-xp-hook-targets | P0 |
| **CT** | Module contains xKx0111xKx dynamic loading; or executes commands via Runtime.exec / ProcessBuilder | Trace DexClassLoader constructor parameters; extract dynamically loaded DEX for independent analysis; check exec command parameters | E-xp-dynamic-load | P0 |
| **CU** | Hook targets involve sensitive APIs such as xKx0112xKx keys | Classify the sensitivity of Hook target xKx0113xKx; mark xKx0114xKx and contacts categories; summarize threat levels | E-xp-sensitive-hooks | P0 |
| **CV** | Code includes XposedBridge detection evasion / Zygote injection trace removal / custom network communication | Check stacktrace modifications / XposedBridge class reference removal; check independent network requests (xKx0115xKx); identify C2 targets | E-xp-anti-detection | P1 |
| **CW** | Code involves dynamic replacement of Resources / View drawing interception / AccessibilityService declaration | Check AssetManager replacement / Resources.updateConfiguration; check AccessibilityService configuration; identify UI hijacking | E-xp-ui-hijack | P1 |
| **CX** | AndroidManifest.xml declares lsposed xposedscope meta-data; or code contains package name whitelist checks | Parse the target application scope of xposedscope; check for dynamic whitelist bypass (reflection modifying scope); identify global Hook privilege escalation | E-xp-scope-bypass | P1 |

## 23. In-depth Analysis of Magisk Modules (CY–DC, DG–DI) → Complementary to §7 AR–AT

> §7 Focused on Module xKx0116xKx Behavior. This section covers non-destructive but suspicious module behaviors: installation script analysis, file deployment, Zygisk injection, anti-detection, persistence, privilege escalation, and lateral infection.

| ID | Trigger | Action (Summary) | Evidence | Priority |
|----|------|--------------|----------|------|
| **DG** | Magisk module ZIP root directory contains config.sh / install.sh; xKx0117xKx is a non-standard installer | Extract xKx0118xKx function from xKx0119xKx; check if update-binary contains extra payload; flag pm install / dd block device / mount -o remount,rw operations | E-mg-install-script | P0 |
| **DH** | The ZIP contains directories system/, vendor/, /data/; or startup execution scripts such as post-fs-data.sh / service.sh | Extract and release file paths to identify whether APKs are released to /xKx0120xKx; check the content of service.sh + post-fs-data.sh to identify startup auto-execution / background persistence / C2 communication; mark all operations writing to the system partition | E-mg-file-drop | P0 |
| **CY** | Module contains zygisk/ directory (arm64-v8a.so and other native libraries); or config.sh declares IS_ZYGISK=true | Extract zygisk/ native libraries to analyze ZygiskModule callbacks (onLoad / preAppSpecialize / postAppSpecialize); check JNI Hook | E-mg-zygisk | P0 |
| **DI** | Module script writes /xKx0121xKx or /xKx0122xKx; or modifies xKx0123xKx (§7 Deepening of AT) | Extract the script contents written to service.d + post-fs-data.d; check the logic of automatically infecting other modules upon uninstallation (post-uninstall.sh / module directory monitoring); check magisk --remove-modules triggering protection mechanisms | E-mg-persistence | P0 |
| **CZ** | Module script contains resetprop to modify system properties / magiskhide / DenyList; or integrates Shamiko (hides Zygisk itself) / TrickyStore (tamper with certificate chain) / PlayIntegrityFork (spoof Play Integrity API) | Extract all resetprop calls to identify modified properties (ro.debuggable / ro.build.tags, etc.); check DenyList for self-hiding; identify xKx0124xKx module-level anti-detection | E-mg-anti-detect | P0 |
| **DA** | Module script contains setenforce 0 / mount -o rw,remount /system / chmod 777 sensitive directories | Check SELinux operations (xKx0125xKx); check system partition mount + dm-verity disabled; mark as high-risk privilege escalation | E-mg-privilege | P0 |
| **DB** | Release xKx0126xKx containing xKx0127xKx client; or release APK requesting INTERNET + xKx0128xKx and other sensitive permissions | Extract network request targets xKx0129xKx; analyze released APK permission declarations; identify data exfiltration logic | E-mg-c2 | P0 |
| **DC** | Script traverses the /xKx0130xKx directory, modifies other module files, or writes its own copy to other modules | Check module.prop for injected malicious instructions; check other modules' service.sh for appended malicious code; identify 'parasitic' logic | E-mg-cross-infect | P0 |

---

## 24. Constraints (Global)

1. **Non-parallel main process**: The stage gates still follow the re-agent workflow / each skill.
2. **Evidence Must Remember**: Includes failure, semi-restoration, quality= labeling.
3. **Deduplicate with A–T**: PE anti-debugging does not repeat; AM→R; AJ supplement DLL perspective does not overturn TLS rocket.
4. **Tool Absence**: Remember xKx0131xKx + manual equivalence, do not pretend to have used a commercial suite.
5. **Authorization**: For xKx0132xKx vulnerabilities, only defense analysis and forensic descriptions are performed.
6. **Extended Rule Deduplication**: ELF → elf-analysis.md; Mach-O → platforms.md; Python → languages.md. This table does not repeat the rules for these formats.

## 25. P0 Minimum Check (When Type Hits)

```text
□ bat/cmd → U (+ use V/W if needed; advanced CD–CI)
□ ps1 → X (+ Z; Advanced CJ–CO + DL ETW)
□ vba/xlm → AA + DD + DJ（+ AB/AC）
□ office ooxml/rtf → BA + DK (+ BB if DDE is suspected)
□ js strong obfuscation → AD or AE (+ AF; advanced CP/CQ/DE/DF)
□ sys → AG + AH (+ AI if BYOVD suspected)
□ dll → AJ + AK/AL; Delay-Load goes R
□ apk damage/hide → AR/AS or AU (+ AT/AV)
□ pdf → AW + AX（+ AY/AZ）
□ wasm → BC（+ BD/BE）
□ jar/class → BF + BG（+ BH/BI）
□ autoit → BJ + BL + DM（+ BK）
□ hta → BM + BN（+ BO）
□ wsf/jse/vbe → BP + BQ（+ BR/BS）
□ msi → BT（+ BU/BV）
□ reg → BW + BX（+ BY）
□ vbs → CA + CB + CC + DN（+ BZ）
□ Xposed module → CR + CS + CT + CU (+ CV–CX)
□ magisk depth → DG + DH + CY + DI + CZ + DA (+ DB/DC)
```
