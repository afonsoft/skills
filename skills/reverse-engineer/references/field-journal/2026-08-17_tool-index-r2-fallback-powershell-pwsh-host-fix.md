# 2026-08-17 reverse-skill

## Scene Classification
Toolchain and Environment (Boot Phase Defect Fix)

## Overview of Goals
Fix three types of defects that are gradually hidden in the native boot process: tool-index falsely reports the radare2 main analyzer `r2` as no; multiple test scripts hard-code `powershell` subprocess calls that fail on machines with only PowerShell 7+ installed; and the pin gate StrictMode property access bug that is masked by this failure.

## Scope Summary (Desensitized)
- auth_basis: own_system (this repository itself)
- network_profile: offline / no external target ACT
- asset_types: [Local Scripts and Tools Index]

## Characters
- lead_role: lead
- specialists: [bootstrap, test-infra]

## Complete Execution Chain

1. 按 `README_AI.md` 第 0 节执行引导：`refresh-tool-index.ps1` 生成 tool-index.md（37 工具）。
2. 读 `tool-index.md` 发现异常：`r2`（radare2 主分析器）= no，但同目录 `rabin2/rasm2/radiff2/rahash2/rax2/r2pm` 全部 = yes。
3. 列 `C:\Users\{username}\Tools\radare2\bin` 确认：存在 `r2.bat`（21 字节，内容 `@"%~dp0\radare2" %*`）与 `radare2.exe`，**无 `r2.exe`**。
4. 读 `lib/ToolDiscovery.ps1:131-141`，`r2` 的 Fallbacks 只找 `r2.exe`，漏掉 `r2.bat`/`radare2.exe`。对比 `jadx`/`apktool`/`analyzeHeadless` 都为 `.bat` 工具配了 fallback。
5. 修复：给 `r2` Fallbacks 补 `r2.bat` 与 `radare2.exe` 路径（覆盖 `%USERPROFILE%\Tools\radare2\bin`、根目录、`C:\Tools\` 三套位置），保留原 `r2.exe` fallback 兼容其他机器。
6. 重跑 `refresh-tool-index.ps1`，`r2` 转 yes，路径 `r2.bat`，版本 `radare2 6.2.0`，来源 `FallbackPath`。
7. 跑 `smoke.ps1` 仍 FAIL：`verify-routing-coherence exit 1`。直接跑 verify 看错误，定位到 `verify-routing-coherence.ps1:257` 硬编码 `& powershell`，本机无 `powershell`（只有 `pwsh` 7.6.4）。
8. grep 全仓 `.ps1` 的 `powershell\s(-NoProfile|-ExecutionPolicy|-File|-Command)`，发现 5 个脚本共 20+ 处硬编码 `& powershell` 子进程调用（verify 7 处 / test-p0-friction 18 处 / test-routing 1 处 / case-init 1 处；其余为注释示例）。
9. 发现 `smoke.ps1:31-46` 已正确用 `$SmokeHostExe`（当前进程路径优先 → pwsh → Windows PowerShell 路径兜底）。提取该已验证逻辑为共享函数 `Resolve-ReverseHostExe`，新建 `lib/HostRuntime.ps1`，解析顺序：当前进程 → `pwsh` → `powershell` → `%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe`。
10. 4 个子脚本 dot-source `HostRuntime.ps1` 并定义 `$HostExe`，`replaceAll` 把 `& powershell -NoProfile -ExecutionPolicy Bypass -File` → `& $HostExe -NoProfile -ExecutionPolicy Bypass -File`；`test-p0-friction.ps1:244` 的 `cmd /c "powershell ..."` 单独改为 `cmd /c "`"$HostExe`" ..."`（路径可能含空格需引号包裹）。
11. 重跑 smoke，verify 走过 257，但暴露 `verify-routing-coherence.ps1:414` pin gate 在 `Set-StrictMode -Version Latest` 下访问 `$cap.pinnedVersion` 等不存在属性报错——这是被 powershell bug 掩盖至今的预存在 bug。
12. 修复 414：把 `$cap` 转 hashtable（`$capMap`），用索引访问不存在的 key 返回 `$null` 不报错，pin gate 语义不变。
13. 重跑 smoke → ALL PASS（VERIFY_EXIT=0 / PARSE 11/11 / ROUTE 9/9）。
14. 跑 `test-routing.ps1` → 166/166 ALL PASS。
15. 跑 `test-p0-friction.ps1` → 大部分过，但 `:343` 与 `:364` 又遇 `Start-Process -FilePath 'powershell.exe'`（之前 grep 模式 `powershell\s+(-NoProfile...)` 漏了 `powershell.exe` 字面）。
16. grep `powershell\.exe`，确认仅 test-p0-friction 的 343/364 两处是硬编码 Start-Process（其余为兼容查找或 fallback 路径），`replaceAll` 改为 `Start-Process -FilePath $HostExe`。
17. 重跑 `test-p0-friction.ps1` → ALL PASS（FAIL_COUNT=0）。三套件全绿。

## Evidence Chain Summary (De-identified)
> This is a self-guided repair for this repository, with no external target ACT, and does not produce evidence files under the case directory. The following are reproducible verification commands (equivalent to Evidence).

| E-id | severity | status | source_type | reusable command pattern | related Finding |
|------|----------|--------|-------------|----------------|--------------|
| E-r2 | info | validated | command | `pwsh -File references/scripts/refresh-tool-index.ps1` After tool-index.md in `r2` line = yes | F-r2 |
| E-smoke | info | validated | command | `pwsh -File references/scripts/smoke.ps1` → `OVERALL: ALL PASS` | F-host |
| E-route | info | validated | command | `pwsh -File references/scripts/test-routing.ps1` → `166/166 ALL PASS` | F-host |
| E-p0 | info | validated | command | `pwsh -File references/scripts/test-p0-friction.ps1` → `OVERALL: ALL PASS` | F-host |

## Finding / Path Summary
- top_finding: Three types of defects cover each other layer by layer — `r2` fallback omission `.bat` entry → `verify` hard-coded `powershell` failure interruption → conceals pin gate StrictMode property access bug; grep-compatible scan also misses `powershell.exe` literals.
- path_type: solve
- path_one_liner: Use shared `Resolve-ReverseHostExe` (current process priority) to unify subprocess entry, provide `.bat`/`radare2.exe` fallback for `r2`, and safely access optional properties of PSCustomObject using hashtable.

## Pitfall Record

| Problem | Cause | Solution | Time Consumed |
|------|------|---------|------|
| tool-index marks `r2` as no, but other r2* tools in the same directory as yes | `ToolDiscovery.ps1`'s `r2` Fallbacks only look for `r2.exe`, while radare2 Windows distributions wrap `r2.bat` around `radare2.exe`, without `r2.exe` | patch `r2.bat` and `radare2.exe` path fallback | short |
| smoke still FAIL: verify exit 1 | verify internally hard-coded `& powershell`, this machine only has pwsh 7+, no `powershell` | create `lib/HostRuntime.ps1` of `Resolve-ReverseHostExe`, 4 scripts replaced with `& $HostExe` | middle |
| verify After fixing PowerShell, it failed again at 414 | Pre-existing bug covered by 257's PowerShell bug: accessing non-existent properties like `$cap.pinnedVersion` in StrictMode causes an error | `$cap` converts to hashtable `$capMap`, index access does not report an error | Short |
| test-p0-friction failed again at 343/364 | `Start-Process -FilePath 'powershell.exe'` Hard-coded; previously the grep pattern `powershell\s+(-NoProfile...)` missed `powershell.exe` literal | grep `powershell\.exe` completion, changed to `$HostExe` | Short |
| test-p0-friction outputs a large amount of `Exception: case-init.ps1:54` | Test 14b deliberately uses an illegal CaseName to trigger case-init to throw an exception, which is expected | No action required, the final FAIL_COUNT=0 means it passes | — |

## 工具链发现
- **radare2 Windows 发行版结构**：主程序是 `radare2.exe`，`r2.bat`（`@"%~dp0\radare2" %*`）是其批处理包装器，**没有 `r2.exe`**。任何按 `r2.exe` 探测的工具扫描都会误报。同目录 `rabin2.exe`/`rasm2.exe` 等是独立 `.exe`，可正常探测。
- **PowerShell 7+ 单装环境**：本机 `pwsh` 7.6.4（路径 `C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe`），**无 `powershell` / `powershell.exe`**。所有 `& powershell ...` 子进程调用在此环境直接失败。
- **StrictMode 属性访问**：`Set-StrictMode -Version Latest` 下访问 `PSCustomObject` 不存在的属性会抛错；用 hashtable 索引访问不存在的 key 返回 `$null`，是 pin gate 这类"可选属性多"场景的安全写法。
- **grep 兼容扫描盲区**：用 `powershell\s+(-NoProfile...)` 只能抓 `& powershell -File` 形式，漏掉 `Start-Process -FilePath 'powershell.exe'` 与 `cmd /c "powershell ..."`。兼容性扫描应同时覆盖 `powershell\s` 与 `powershell\.exe` 两类。

## Key Code/Commands

```powershell
# lib/HostRuntime.ps1 —— Unified subprocess PowerShell entry (current process prioritized)
function Resolve-ReverseHostExe {
    [CmdletBinding()] [OutputType([string])] param()
    $hostExe = $null
    try { $p = (Get-Process -Id $PID -ErrorAction Stop).Path; if ($p -and (Test-Path -LiteralPath $p)) { $hostExe = $p } } catch { }
    if (-not $hostExe) { $c = Get-Command pwsh -ErrorAction SilentlyContinue; if ($c -and $c.Source) { $hostExe = $c.Source } }
    if (-not $hostExe) { $c = Get-Command powershell -ErrorAction SilentlyContinue; if ($c -and $c.Source) { $hostExe = $c.Source } }
    if (-not $hostExe -and $env:SystemRoot) { $f = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'; if (Test-Path -LiteralPath $f) { $hostExe = $f } }
    if (-not $hostExe) { throw 'No usable PowerShell host executable found.' }
    return $hostExe
}

# ToolDiscovery.ps1 r2 Fallbacks —— Patch .bat/.exe Entry
Fallbacks = @(
    @{ Type = 'command'; Value = 'r2' },
    @{ Type = 'command'; Value = 'radare2' },
    @{ Type = 'path'; Value = (Join-Path $userProfile 'Tools\radare2\bin\r2.bat') },
    @{ Type = 'path'; Value = (Join-Path $userProfile 'Tools\radare2\bin\radare2.exe') },
    @{ Type = 'path'; Value = (Join-Path $userProfile 'Tools\radare2\bin\r2.exe') }
# ... Root directory and C:\Tools image
)

# verify-routing-coherence.ps1:412 —— pin gate security attribute access
foreach ($cap in $mc.capabilities) {
    $capMap = @{}
    foreach ($prop in $cap.PSObject.Properties) { $capMap[$prop.Name] = $prop.Value }
    if (-not $capMap['canAutoInstall']) { continue }
    $hasPin = ($capMap['pinnedVersion'] -or $capMap['pinnedCommit'] -or $capMap['pinPolicy'])
    # ... switch ($capMap['bootstrapKind']) ...
}
```

## Suggestions for Improvement of This Package
- **Compatibility Scanning Scripting**: In `verify-routing-coherence.ps1` or standalone lint, scan all child process calls of `.ps1`, prohibit bare `powershell` / `powershell.exe`, and uniformly require processing through `Resolve-ReverseHostExe`. Currently done by manual grep, prone to omissions (already hit the `powershell.exe` blind spot).
- **Agreement for `.bat` in the tool catalog**: On Windows, `jadx`/`apktool`/`r2`/`analyzeHeadless` are all `.bat` wrapped `.exe`, and the catalog should provide both `.bat` and the corresponding `.exe` fallback for each such tool to avoid pitfalls one by one.
- **CI should include a 'pwsh only' matrix**: On GitHub Actions' `windows-latest`, if Windows PowerShell 5.1 is not pre-installed, this kind of bug will be exposed. Currently `smoke.ps1` has been corrected using `$SmokeHostExe`, but the sub-scripts have not been reused.
- **Iterating PSCustomObject under StrictMode**: For pin gate and this type of 'loose object schema' checks, uniformly use hashtable conversion for access, or provide `Get-SafeProp` helper functions.

## Reusable patterns/script snippets
- `Resolve-ReverseHostExe`: Whenever any script needs to start a child PowerShell process, dot-source `lib/HostRuntime.ps1` after `& $HostExe -NoProfile -ExecutionPolicy Bypass -File <script> ...`, compatible with pwsh-only / powershell-only / mixed environments.
- `$capMap` Conversion: Traverse `PSCustomObject` properties into a hashtable and then access by index to avoid StrictMode property does not exist exception.
- `r2.bat` → `radare2.exe` transparent transmission: version check `r2.bat -v` can correctly return `radare2 6.2.0`, proving that the `.bat` wrapper's transparent transmission of parameters is effective and can be safely used as the catalog entry.

## Evolution Actions
- [x] Updated tool-index (r2 changed to yes, path r2.bat)
- [x] Added `references/scripts/lib/HostRuntime.ps1`
- [x] Fixed `ToolDiscovery.ps1` r2 Fallbacks
- [x] Fixed `verify-routing-coherence.ps1` PowerShell hardcoding + pin gate StrictMode
- [x] Fixed `case-init.ps1` / `test-routing.ps1` / `test-p0-friction.ps1` PowerShell hardcoding
- [ ] Updated the routing matrix (none)
- [ ] Updated bootstrap-manifest (none)
- [ ] Added a pitfalls record (this entry)

## Environmental Information
- OS: Windows (win32)
- Shell/Host: pwsh 7.6.4 (`C:\Program Files\WindowsApps\Microsoft.PowerShell_7.6.4.0_x64__8wekyb3d8bbwe\pwsh.exe`); this machine has no `powershell` / `powershell.exe`
- radare2: 6.2.0 +1 abi:132 @ windows-x86_64 (installed on `C:\Users\{username}\Tools\radare2\bin\`)
- Warehouse Root: `D:\Sources\reverse-skill`

## Desensitization Requirements
This is a script fix for this repository itself, with no real target domain/IP/credentials, so no need for desensitization.

## Index Synchronization (Final Step Before Submission)

After finishing this log, simultaneously update `_index.md`:
1. A new line ✓ has been added in the 'Toolchain and Environment' section
2. Add this file name to the 'High-Frequency Success Mode' (PowerShell subprocess entry unified) ✓
3. "Entity Inversion" add this file name (reverse-skill guide script) ✓
4. Update the total number in 'Statistics' and the most recent update date ✓

---
<!-- [Evolution Statistics] Total projects completed by this package: 19 | New modes added this time: 1 (Resolve-ReverseHostExe subprocess entry unified) | Toolchain issues fixed this time: 3 (r2 fallback / powershell hardcoding / pin gate StrictMode) -->
<!-- [Community Contribution] This fix addresses a boot defect within the repository itself and qualifies as a fix-type PR according to CONTRIBUTING.md; after completion, ask the user whether to submit. -->