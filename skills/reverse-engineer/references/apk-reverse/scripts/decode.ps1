#requires -Version 5

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ApkPath,

    [string]$Name,

    [string]$OutRoot,

    [switch]$SkipJadx,

    [switch]$SkipApktool,

    [switch]$Clean
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

. (Join-Path $PSScriptRoot '..\..\scripts\lib\ToolDiscovery.ps1')
. (Join-Path $PSScriptRoot '..\..\scripts\lib\HostRuntime.ps1')

function Get-SafeName {
    param([Parameter(Mandatory = $true)][string]$PathValue)

    $raw = [System.IO.Path]::GetFileNameWithoutExtension($PathValue)
    if ([string]::IsNullOrWhiteSpace($raw)) {
        $raw = 'apk'
    }
    return ($raw -replace '[^A-Za-z0-9._-]', '_')
}

function Get-DefaultOutRoot {
    param([Parameter(Mandatory = $true)][string]$ApkFilePath)

    $parent = Split-Path -Path $ApkFilePath -Parent
    if ([string]::IsNullOrWhiteSpace($parent)) {
        return [System.IO.Directory]::GetCurrentDirectory()
    }
    return $parent
}

function Get-ManifestPackage {
    param([Parameter(Mandatory = $true)][string]$ManifestPath)

    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        return ''
    }

    try {
        $xml = [xml](Get-Content -LiteralPath $ManifestPath -Raw -Encoding UTF8)
        return [string]$xml.manifest.package
    }
    catch {
        return ''
    }
}

if (-not (Test-Path -LiteralPath $ApkPath)) {
    throw "APK not found: $ApkPath"
}

$jadxSpec = $null
$apktoolSpec = $null
$bootstrapScript = Join-Path $PSScriptRoot '..\..\scripts\bootstrap-reverse.ps1'

function Invoke-ReverseBootstrap {
    # Runs the package bootstrapper in a child PowerShell process resolved to
    # the current host (pwsh/powershell), honoring the machine execution
    # policy — no -ExecutionPolicy Bypass pivot. The caller must still have
    # approved the disclosed install effects per RULES.md before invoking
    # this script.
    param([Parameter(Mandatory = $true)][string]$Capability)
    $hostExe = Resolve-ReverseHostExe
    & $hostExe -NoProfile -File $bootstrapScript -Capability @($Capability) -SkipRefresh
    if ($LASTEXITCODE -ne 0) {
        throw "Bootstrap failed for $Capability (exit $LASTEXITCODE). Review output above or install manually."
    }
}

if (-not $SkipJadx) {
    $jadxSpec = Resolve-ReverseToolSpec -Name 'jadx'
    if (-not $jadxSpec.Available) {
        Write-Host 'INFO: jadx not found, attempting auto-bootstrap...' -ForegroundColor Yellow
        Invoke-ReverseBootstrap -Capability 'jadx'
        $jadxSpec = Resolve-ReverseToolSpec -Name 'jadx'
        if (-not $jadxSpec.Available) {
            throw 'jadx still not available after bootstrap. Check installation at %USERPROFILE%\Tools\jadx\'
        }
        Write-Host 'INFO: jadx bootstrapped successfully.' -ForegroundColor Green
    }
}
if (-not $SkipApktool) {
    $apktoolSpec = Resolve-ReverseToolSpec -Name 'apktool'
    if (-not $apktoolSpec.Available) {
        Write-Host 'INFO: apktool not found, attempting auto-bootstrap...' -ForegroundColor Yellow
        Invoke-ReverseBootstrap -Capability 'apktool'
        $apktoolSpec = Resolve-ReverseToolSpec -Name 'apktool'
        if (-not $apktoolSpec.Available) {
            throw 'apktool still not available after bootstrap. Check installation at %USERPROFILE%\Tools\apktool\'
        }
        Write-Host 'INFO: apktool bootstrapped successfully.' -ForegroundColor Green
    }
}

function Assert-SafeDeletePath {
    # Containment guard: a path may only be recursively deleted if it resolves
    # to a non-root directory strictly beneath the resolved output root.
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$ResolvedOutRoot
    )

    $fullPath = [System.IO.Path]::GetFullPath($Path).TrimEnd('\', '/')
    $fullRoot = [System.IO.Path]::GetFullPath($ResolvedOutRoot).TrimEnd('\', '/')
    if ([string]::IsNullOrWhiteSpace($fullPath) -or $fullPath.Length -le $fullRoot.Length) {
        throw "Refusing to delete '$fullPath': must be strictly beneath '$fullRoot'."
    }
    if (-not ($fullPath.StartsWith($fullRoot + [System.IO.Path]::DirectorySeparatorChar) -or
              $fullPath.StartsWith($fullRoot + [System.IO.Path]::AltDirectorySeparatorChar))) {
        throw "Refusing to delete '$fullPath': outside output root '$fullRoot'."
    }
    $fsRoot = [System.IO.Path]::GetPathRoot($fullPath)
    if ($fullPath -eq $fsRoot.TrimEnd('\', '/')) {
        throw "Refusing to delete filesystem root '$fullPath'."
    }
}

$taskName = if ($Name) { $Name } else { Get-SafeName -PathValue $ApkPath }
$resolvedOutRoot = if ([string]::IsNullOrWhiteSpace($OutRoot)) { Get-DefaultOutRoot -ApkFilePath $ApkPath } else { $OutRoot }
$taskRoot = Join-Path $resolvedOutRoot $taskName
$jadxOut = Join-Path $taskRoot 'jadx'
$apktoolOut = Join-Path $taskRoot 'apktool'

if (-not (Test-Path -LiteralPath $resolvedOutRoot)) {
    New-Item -ItemType Directory -Path $resolvedOutRoot -Force | Out-Null
}

if ($Clean -and (Test-Path -LiteralPath $taskRoot)) {
    Assert-SafeDeletePath -Path $taskRoot -ResolvedOutRoot $resolvedOutRoot
    Remove-Item -LiteralPath $taskRoot -Recurse -Force
}

if (-not (Test-Path -LiteralPath $taskRoot)) {
    New-Item -ItemType Directory -Path $taskRoot -Force | Out-Null
}

$jadxExitCode = $null
if (-not $SkipJadx) {
    if (Test-Path -LiteralPath $jadxOut) {
        Assert-SafeDeletePath -Path $jadxOut -ResolvedOutRoot $resolvedOutRoot
        Remove-Item -LiteralPath $jadxOut -Recurse -Force
    }
    & $jadxSpec.Command @($jadxSpec.PrefixArgs + @('-d', $jadxOut, $ApkPath))
    $jadxExitCode = $LASTEXITCODE
}

$apktoolExitCode = $null
if (-not $SkipApktool) {
    if (Test-Path -LiteralPath $apktoolOut) {
        Assert-SafeDeletePath -Path $apktoolOut -ResolvedOutRoot $resolvedOutRoot
        Remove-Item -LiteralPath $apktoolOut -Recurse -Force
    }
    & $apktoolSpec.Command @($apktoolSpec.PrefixArgs + @('d', $ApkPath, '-o', $apktoolOut, '-f'))
    $apktoolExitCode = $LASTEXITCODE
}

$manifestPath = Join-Path $apktoolOut 'AndroidManifest.xml'
$packageName = if (-not $SkipApktool) { Get-ManifestPackage -ManifestPath $manifestPath } else { '' }
$javaCount = if ((Test-Path -LiteralPath $jadxOut)) { (Get-ChildItem -LiteralPath $jadxOut -Recurse -File -Filter '*.java' | Measure-Object).Count } else { 0 }
$smaliDirCount = if ((Test-Path -LiteralPath $apktoolOut)) { (Get-ChildItem -LiteralPath $apktoolOut -Directory -Filter 'smali*' | Measure-Object).Count } else { 0 }
$libCount = if ((Test-Path -LiteralPath $apktoolOut)) { (Get-ChildItem -LiteralPath $apktoolOut -Recurse -File -Filter '*.so' | Measure-Object).Count } else { 0 }
$resXmlCount = if ((Test-Path -LiteralPath $apktoolOut)) { (Get-ChildItem -LiteralPath $apktoolOut -Recurse -File -Filter '*.xml' | Measure-Object).Count } else { 0 }

"task_root=$taskRoot"
"jadx_out=$jadxOut"
"apktool_out=$apktoolOut"
"package=$packageName"
"jadx_exit_code=$jadxExitCode"
"apktool_exit_code=$apktoolExitCode"
"java_files=$javaCount"
"smali_dirs=$smaliDirCount"
"so_files=$libCount"
"xml_files=$resXmlCount"

if (($jadxExitCode -ne $null) -and ($jadxExitCode -ne 0)) {
    "warning=jadx returned non-zero exit code; inspect output but treat exported sources as usable if present"
}
