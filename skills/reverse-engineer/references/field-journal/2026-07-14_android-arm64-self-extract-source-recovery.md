# 2026-07-14 Android ARM64 self-extracting program source code recovery

## Scene classification

Binary analysis / Android ARM64 / Self-extracting Shell / Control flow flattening

## Goal Overview

Read-only source code recovery of user-owned local `.sh` delivery package, unpacking multi-layer compression payload, analyzing ARM64 main program and protection library, and recovering business text and high-level pseudo source code without running the target.

## Complete execution link

1. Do read-only listing, size, magic number, and SHA-256 triage on the input directory, and do not read or log credentials.
2. Identify the first layer as "Shell leading + bzip2 trailing stream" and locate the precise offset through the `BZh` effective stream test.
3. Save the leader, compressed stream and decompressed payload in a separate Chinese product directory, and do not execute the payload.
4. Identify the second layer as the `__ARCHIVE_BELOW__` self-extracting script, safely expand tar.gz, and reject absolute paths, `..`, links, and device nodes.
5. Obtain the Android AArch64 PIE main program and AArch64 shared library; use pyelftools/Capstone to generate ELF header, section, symbol, import, string and entry disassembly.
6. The protected library preserves readable C++ symbols, exports pseudocode on a function-by-function basis, and confirms `/proc` scanning, `TracerPid`, third-level process termination, and background thread behavior.
7. The symbol length of the main program `main` is significantly larger than the ordinary CFG identification length, confirming that the indirect jump control flow is flattened.
8. Static solution to jump table: `target = table_entry + fixed_delta`, enumerating all unique real basic blocks.
9. Scan the isomorphic string decryptor to identify the "first N bytes cyclic XOR key + last M bytes ciphertext" layout.
10. Perform AArch64 constant propagation on each real basic block, parse the target of the indirect decryptor call and the `x1` data source, and recover the business text in batches.
11. Deliver complete disassembly, function-by-function pseudocode, high-level semantic source code, Mermaid flowcharts, and formal reports.
12. Recalculate the original input hash and confirm that it is completely consistent before and after analysis.

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|---|---|---|---|
| PowerShell directly runs bootstrap and is intercepted by the execution policy | The system prohibits scripts | Use `powershell.exe -ExecutionPolicy Bypass -File ...` once, without changing the permanent policy | Low |
| radare2 bootstrap returns GitHub API 403 | API current limit/deny, but the release page is accessible | Obtain official assets and page SHA-256 from `releases/latest` 302 and `expanded_assets/<tag>`, decompress after verification | Medium |
| Winget's Rizin silent/user-scope installation has not been implemented | Installer scope does not match | Stop retrying after two failures and switch back to the verified radare2 official ZIP | Low |
| `r2pm -U` stuck in git clone for a long time | Network speed/recursive repository | Terminate optional plugin route, continue using `pdc` + Capstone custom recovery | High |
| radare2 only recognizes `main` front CFG | Indirect BR jump table enables regular analysis to end at dispatcher | Enumerate real blocks by jump table formula, does not rely on default CFG | Medium |
| Direct string scan sees only a few paths | Text is XORed with independent loops per string | Extract key/output length from decryptor instructions, static replay algorithm | Medium |

## Toolchain discovery

- The Python 3.13 standard library is safe enough to handle bzip2 and tar.gz; `tarfile.extractall` is not as safe as writing out after member-by-member verification.
- pyelftools recovers ELF/DYNSYM/RELA, Capstone is suitable for ARM64 constant propagation and dedicated decryptor identification.
- `pdc` from radare2 6.1.8 is valid for unobfuscated protected library functions and only provides partial pseudocode for indirect BR flattened main functions.
- GitHub API 403 is not equivalent to the official release page asset being inaccessible; the release page can provide tag, asset name and SHA-256.

## Key code/command

```python
# General Loop XOR Text Layout
key = blob[:key_length]
encrypted = blob[key_length:key_length + output_length]
plain = bytes(value ^ key[index % key_length]
              for index, value in enumerate(encrypted))
```

```python
# Static Analysis of Indirect Jump Tables
targets = {
    (entry + fixed_delta) & 0xFFFFFFFFFFFFFFFF
    for entry in jump_table_entries
}
```

```powershell
Read-only retrieval of the latest tag when API returns 403
curl.exe -sS -I '<official-release-url>/radareorg/radare2/releases/latest'
```

## Suggestions for improving this package

- Added "`.sh` self-extracting disguised binary" target type route to avoid misjudgment as a pure shell review.
- Windows GitHub Release bootstrap should fallback to release page/expanded_assets on API 403 and force SHA-256 verification.
- The "ARM64 jump table + loop XOR" universal recovery script template can be added as a low-dependency route when there is no IDA.
- The session id must be retained and polled when the tool is called beyond the foreground window to avoid losing download or export tasks that are still running.

## Reusable patterns/script snippets

1. Scan the valid compressed stream first instead of just looking for the magic number; fully decompress and test each candidate offset in memory.
2. Self-extracting archives are always written securely by member one by one, without direct execution and without trusting member paths.
3. When the length of the function declared in the symbol table is much larger than the length recognized by CFG, the BR/BLR indirection table is checked first.
4. Isomorphic decryptors can be identified in batches through the `add x16,x1,#key_len`, `cmp w16,#output_len`, `ldrb/eor/strb` instruction combinations.
5. Local constant propagation of the flattened block is usually sufficient to recover the indirect function target and string source addresses without first deflattening them completely.

## Evolution action

- [x] Updated routing matrix
- [x] Updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation
- [x] Added pitfalls record
- [ ] No update required

## Environment information

- OS: Windows
- Tool version: Python 3.13; radare2 6.1.8; pyelftools; Capstone
- Target platform/version: Android ARM64, NDK r17/Clang 6.0.2

## Desensitization check

- The software name, author name, real domain name, real API endpoint, credentials, fixed signature material, business package name or local user path are not recorded.
- No sample files or sample hashes are attached.
- Only public tool names, versions and common algorithm modes are retained.

## Index synchronization

This record has been added to the "Binary/Firmware/CTF" category of `_index.md` and the statistics have been updated.

---
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. See CONTRIBUTE-BACK.md for the process -->