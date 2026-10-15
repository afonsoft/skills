#Requires -Version 5.1
# reverse-skill PRIMARY router.
# Rule single fact source: references/config/routing.json (do not hardcode the routing table in this script).
# CLI compatible with the old version: -Hint / -OutDir; output route-scope.md; exit code 0 for success / 2 for missing configuration or skills.
# Read the UTF-8 BOM source to ensure CJK works correctly in Windows PowerShell 5.1.
param(
    [string] $Hint = '',
    [string] $OutDir = '',
    [string] $ProjectRoot = ''
)
$ErrorActionPreference = 'Stop'

# Lowercase for Latin tokens; CJK unchanged by ToLowerInvariant.
$t = if ($Hint) { $Hint.ToLowerInvariant() } else { '' }

$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$skillsRoot = Split-Path -Parent $scriptDir
$packageRoot = Split-Path -Parent $skillsRoot
$configPath = Join-Path $skillsRoot 'config/routing.json'

# --- Read routing configuration (single source of truth) ---
if (-not (Test-Path -LiteralPath $configPath)) {
    Write-Host ("ERROR: routing config missing: {0}" -f $configPath) -ForegroundColor Red
    Write-Host 'Restore references/config/routing.json (git checkout / git pull) and retry.' -ForegroundColor Yellow
    exit 2
}
try {
    $cfg = Get-Content -LiteralPath $configPath -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Write-Host ("ERROR: routing config is not valid JSON: {0}" -f $_.Exception.Message) -ForegroundColor Red
    exit 2
}

# --- Rule Matching: Each keyword rule hit is counted into the candidate set (consistent with the old version's behavior of checking each condition individually) ---
$sel = New-Object System.Collections.Generic.List[string]
foreach ($route in $cfg.routes.PSObject.Properties) {
    $id = $route.Name
    foreach ($kw in $route.Value.keywords) {
        $hit = $false
        if ($null -ne $kw.must -and $t -match $kw.must) { $hit = $true }
        # mustAll: All sub-patterns must match for it to be valid
        if ($hit -and $null -ne $kw.mustAll) {
            foreach ($m in $kw.mustAll) {
                if ($t -notmatch $m) { $hit = $false; break }
            }
        }
        # exclude: if hit, this rule does not trigger (to prevent false positives, such as jailbreak/LLM context, domain control/attack chain)
        if ($hit -and $null -ne $kw.exclude -and $t -match $kw.exclude) { $hit = $false }
        if ($hit) { [void]$sel.Add($id) }
    }
}

# --- Scoring: Multiple rules hit for the same ID will add points (same as the old version) ---
$scores = [ordered]@{}
foreach ($item in $sel) {
    if (-not $scores.Contains($item)) { $scores[$item] = 0 }
    $scores[$item] = $scores[$item] + 1
}

$uniq = New-Object System.Collections.Generic.List[string]
foreach ($d in $scores.Keys) { [void]$uniq.Add($d) }

# --- Priority self-check: The routing table and priority must correspond one-to-one, to prevent newly added routes from missing a priority ---
$routeIds = @($cfg.routes.PSObject.Properties | ForEach-Object { $_.Name })
$missingInPriority = @($routeIds | Where-Object { $_ -notin @($cfg.priority) })
$extraInPriority = @($cfg.priority | Where-Object { $_ -notin $routeIds })
if ($missingInPriority.Count -gt 0 -or $extraInPriority.Count -gt 0) {
    Write-Host 'WARN: routing.json routes/priority mismatch:' -ForegroundColor Yellow
    if ($missingInPriority.Count -gt 0) { Write-Host ("  routes not in priority: {0}" -f ($missingInPriority -join ', ')) -ForegroundColor Yellow }
    if ($extraInPriority.Count -gt 0) { Write-Host ("  priority not in routes: {0}" -f ($extraInPriority -join ', ')) -ForegroundColor Yellow }
}

# --- The one with the highest score in priority order is taken as PRIMARY (in case of a tie, the one with the higher priority wins) ---
$priority = @($cfg.priority)
$fallbackId = $cfg.meta.fallbackId
$primary = $null
$maxScore = -1
foreach ($p in $priority) {
    if ($scores.Contains($p)) {
        $score = $scores[$p]
        if ($score -gt $maxScore) {
            $maxScore = $score
            $primary = $p
        }
    }
}

$notes = New-Object System.Collections.Generic.List[string]
$confidence = 'low'
if ($null -eq $primary) {
    $primary = $fallbackId
    if ($t) { [void]$notes.Add('No strong keyword hit; open routing.md full matrix') }
    else { [void]$notes.Add('Empty hint; provide task text') }
} else {
    $confidence = if ($uniq.Count -eq 1) { 'high' } else { 'medium' }
}

# Defense: If priority contains ghost IDs other than routes (configuration error), fall back to fallback instead of crashing
if ($routeIds -notcontains $primary) {
    Write-Host ("WARN: primary id '{0}' not in routes; falling back to {1}" -f $primary, $fallbackId) -ForegroundColor Yellow
    $primary = $fallbackId
}

# Reuse the root analysis of the current mainline project work to avoid writing routing artifacts into the skill package.
$scriptDir = $PSScriptRoot
if (-not $scriptDir) { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$skillsRoot = Split-Path -Parent $scriptDir
$packageRoot = Split-Path -Parent $skillsRoot
. (Join-Path (Join-Path $scriptDir 'lib') 'WorkRoot.ps1')
$projectRoot = Resolve-ReverseProjectRoot -RequestedRoot $ProjectRoot

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $workRoot = Join-Path $projectRoot 'work'
    $OutDir = Join-Path $workRoot ("master-route-{0}" -f $stamp)
}

$primaryPath = $cfg.routes.$primary.skill
$primaryLabel = $cfg.routes.$primary.label
$skillAbs = Join-Path $skillsRoot ($primaryPath -replace '/', [IO.Path]::DirectorySeparatorChar)
if (-not (Test-Path -LiteralPath $skillAbs)) {
    Write-Host ("ERROR: PRIMARY skill missing: {0}" -f $skillAbs) -ForegroundColor Red
    exit 2
}

# --- Output directory (default caller project work\master-route-<ts>) ---
if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    if ($packageRoot -and (Test-Path -LiteralPath $packageRoot)) {
        $OutDir = Join-Path (Join-Path $packageRoot 'work') ("master-route-{0}" -f $stamp)
    } else {
        $tmpBase = if ($env:TEMP) { $env:TEMP } else { [System.IO.Path]::GetTempPath() }
        $OutDir = Join-Path (Join-Path $tmpBase 'reverse-skill-route') ("master-route-{0}" -f $stamp)
    }
}
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

# --- Write route-scope.md (format consistent with the old version, downstream scripts parse primary_skill / primary) ---
$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('# reverse-skill Master route (PRIMARY)')
[void]$sb.AppendLine(("- created: {0}" -f (Get-Date -Format 'o')))
[void]$sb.AppendLine(("- package: reverse-skill"))
$hintOneLine = (($Hint -replace '[\r\n]+', ' ').Trim())
[void]$sb.AppendLine(("- hint: {0}" -f $hintOneLine))
[void]$sb.AppendLine(("- primary: {0}" -f $primary))
[void]$sb.AppendLine(("- primary_label: {0}" -f $primaryLabel))
[void]$sb.AppendLine(("- primary_skill: references/{0}" -f $primaryPath))
[void]$sb.AppendLine(("- confidence: {0}" -f $confidence))
[void]$sb.AppendLine(("- project_root: {0}" -f $projectRoot))
$sec = New-Object System.Collections.Generic.List[string]
foreach ($d in $uniq) {
    if ($d -ne $primary) { [void]$sec.Add(("references/{0}" -f $cfg.routes.$d.skill)) }
}
$secText = if ($sec.Count -gt 0) { ($sec -join ', ') } else { '(none)' }
[void]$sb.AppendLine(("- secondary: {0}" -f $secText))
[void]$sb.AppendLine('')
[void]$sb.AppendLine('## MUST open next')
[void]$sb.AppendLine('')
[void]$sb.AppendLine('1. references/MASTER-ROUTING.md')
[void]$sb.AppendLine(("2. references/{0}" -f $primaryPath))
[void]$sb.AppendLine('')
[void]$sb.AppendLine('## Notes')
if ($notes.Count -eq 0) { [void]$sb.AppendLine('- (none)') }
foreach ($n in $notes) { [void]$sb.AppendLine(("- {0}" -f $n)) }

# UTF-8 with BOM for route-scope (Windows notepad-friendly)
$utf8 = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText((Join-Path $OutDir 'route-scope.md'), $sb.ToString(), $utf8)

Write-Host ("PRIMARY -> references/{0}" -f $primaryPath) -ForegroundColor Green
Write-Host ("Label: {0} | confidence: {1}" -f $primaryLabel, $confidence)
foreach ($n in $notes) { Write-Host ("NOTE: {0}" -f $n) -ForegroundColor Yellow }
Write-Host ("Wrote {0}\route-scope.md" -f $OutDir)
Write-Host 'ACTION: Open PRIMARY README.md now and execute ACTION REQUIRED.' -ForegroundColor Yellow
