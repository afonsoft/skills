#Requires -Version 5.1
# Generate references/INDEX.md: Extract name + description from the frontmatter of each module README.md to generate a navigation index.
# Idempotent: Repeated execution produces consistent output (CI uses git diff to check for drift).
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File references/scripts/extract-summaries.ps1
# powershell -File references/scripts/extract-summaries.ps1 -Check   # Only check without writing (CI mode, exit 1 if inconsistent)
param(
    [switch] $Check
)
$ErrorActionPreference = 'Stop'

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$skillsRoot = Split-Path -Parent $scriptDir
$indexPath = Join-Path $skillsRoot 'INDEX.md'

# Scan the modules' README.md in the repository (excluding local ignored/private trees, ensuring a clean clone and idempotence with the development machine).
$skipDirs = @('ops', 'scripts', 'config', 'tests', 'field-journal', 'references')
$packageRoot = Split-Path -Parent $skillsRoot
$trackedSkillFiles = @()
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) {
    $trackedPaths = @(& $git.Source -C $packageRoot ls-files -- 'references/**/README.md')
    if ($LASTEXITCODE -eq 0) {
        $trackedSkillFiles = @($trackedPaths | ForEach-Object {
            $fullPath = Join-Path $packageRoot ($_ -replace '/', [IO.Path]::DirectorySeparatorChar)
            if (Test-Path -LiteralPath $fullPath -PathType Leaf) { Get-Item -LiteralPath $fullPath }
        })
    }
}
$candidateSkillFiles = if ($trackedSkillFiles.Count -gt 0) {
    $trackedSkillFiles
} else {
    @(Get-ChildItem -Path $skillsRoot -Recurse -Filter 'README.md')
}
$skillFiles = $candidateSkillFiles | Where-Object {
    $rel = $_.FullName.Substring($skillsRoot.Length + 1)
    $rel -ne 'README.md' -and -not ($skipDirs | Where-Object { $rel.StartsWith($_ + '\') -or $rel.StartsWith($_ + '/') })
} | Sort-Object { $_.FullName.Substring($skillsRoot.Length + 1) }

$rows = New-Object System.Collections.ArrayList
foreach ($sf in $skillFiles) {
    $rel = $sf.FullName.Substring($skillsRoot.Length + 1)
    # Compatible with both Windows (\) and Linux/macOS (/) path separators
    $dir = $rel.Split(@('\', '/'))[0]
    $head = Get-Content -LiteralPath $sf.FullName -TotalCount 15 -Encoding UTF8
    $name = ''; $desc = ''; $blockMode = $false; $inFm = $false
    foreach ($line in $head) {
        if ($line -match '^---') {
            if ($inFm) { break }   # 第二个 --- 结束 frontmatter
            $inFm = $true; continue
        }
        if (-not $inFm) { continue }
        if ($line -match '^name:\s*(.+)$') { $name = $Matches[1].Trim(); continue }
        if ($line -match '^description:\s*\|') { $blockMode = $true; continue }
        if ($line -match '^description:\s*(.+)$') { $desc = $Matches[1].Trim(); continue }
        if ($blockMode) {
            # YAML block: indented text lines concatenation (take the first line, truncate if too long)
            if ($line -match '^\s{2,}(.+)$') {
                if (-not $desc) { $desc = $Matches[1].Trim() }
            } elseif ($line -match '^\S') { $blockMode = $false }
        }
    }
    if (-not $name) { $name = $dir }
    if (-not $desc) { $desc = '(无摘要)' }
    if ($desc.Length -gt 160) { $desc = $desc.Substring(0, 157) + '...' }
    [void]$rows.Add([pscustomobject]@{
        Dir  = $dir
        Name = $name
        Desc = $desc
        Path = $rel
    })
}

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('# reverse-skill 技能导航索引')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('> 本文件由 `references/scripts/extract-summaries.ps1` 自动生成，**请勿手改**。')
[void]$sb.AppendLine('> 修改摘要请编辑对应模块 `README.md` 的 frontmatter `description`，然后重跑脚本。')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('## 模块总览')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('| 模块 | 摘要 |')
[void]$sb.AppendLine('|------|------|')
foreach ($r in $rows) {
    $esc = $r.Desc -replace '\|', '\|'
    [void]$sb.AppendLine(("| [{0}]({1}) | {2} |" -f $r.Name, ($r.Path -replace '\\', '/'), $esc))
}
[void]$sb.AppendLine('')
[void]$sb.AppendLine('## 目录树')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('```')
foreach ($r in $rows) {
    [void]$sb.AppendLine(("references/{0}/" -f ($r.Path -replace '\\', '/')))
}
[void]$sb.AppendLine('```')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('## 路由')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('PRIMARY 路由由 `references/config/routing.json`（唯一事实源）驱动，用 `master-route.ps1 -Hint "<任务>"` 分诊。')
[void]$sb.AppendLine('歧义场景读 `references/routing.md` 全矩阵；CTF 多类型任务走 `CTF-Sandbox-Orchestrator/`。')

$newContent = $sb.ToString()
# Unify LF line endings: consistent with .gitattributes (*.md eol=lf) to ensure idempotence after clone -Check
$newContent = $newContent -replace "`r`n", "`n"
$utf8 = New-Object System.Text.UTF8Encoding $true

if ($Check) {
    if (-not (Test-Path -LiteralPath $indexPath)) {
        Write-Host '[CHECK] INDEX.md missing' -ForegroundColor Red
        exit 1
    }
    # End-of-line immunity: On machines with autocrlf=true, the worktree may use CRLF, compare after normalizing
    $old = ([System.IO.File]::ReadAllText($indexPath)) -replace "`r`n", "`n"
    if ($old -eq $newContent) {
        Write-Host '[CHECK] INDEX.md up to date' -ForegroundColor Green
        exit 0
    }
    Write-Host '[CHECK] INDEX.md out of date (run extract-summaries.ps1)' -ForegroundColor Red
    exit 1
}

[System.IO.File]::WriteAllText($indexPath, $newContent, $utf8)
Write-Host ("INDEX.md regenerated: {0} modules" -f $rows.Count) -ForegroundColor Green
