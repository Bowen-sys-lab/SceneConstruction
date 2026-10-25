param(
    [string]$ProjectRoot = 'D:\IsaacSim_Demo',
    [string]$IsaacRoot = 'D:\isaacsim',
    [string]$SceneConfig = '',
    [switch]$SkipImportCheck
)

$ErrorActionPreference = 'Stop'
$failures = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Check-Path($Path, $Label, $Required = $true) {
    if (Test-Path -LiteralPath $Path) {
        Write-Host "PASS  $Label : $Path"
    } elseif ($Required) {
        $failures.Add("Missing $Label : $Path")
        Write-Host "FAIL  $Label : $Path" -ForegroundColor Red
    } else {
        $warnings.Add("Missing optional $Label : $Path")
        Write-Host "WARN  $Label : $Path" -ForegroundColor Yellow
    }
}

Write-Host 'SceneConstruction environment preflight'
Write-Host "ProjectRoot = $ProjectRoot"
Write-Host "IsaacRoot   = $IsaacRoot"

Check-Path $ProjectRoot 'project root'
Check-Path $IsaacRoot 'Isaac Sim root'
$pythonBat = Join-Path $IsaacRoot 'python.bat'
Check-Path $pythonBat 'Isaac Sim Python launcher'
Check-Path (Join-Path $ProjectRoot 'scripts/start_crazyflie_dual_camera_view.py') 'RGB + Thermal preview launcher'
Check-Path (Join-Path $ProjectRoot 'scripts/run_isaac_with_clean_env.ps1') 'clean Isaac environment launcher'
Check-Path (Join-Path $ProjectRoot 'third_party/isaac-thermal-camera-simulation/src') 'irsim source directory'
Check-Path (Join-Path $ProjectRoot 'configs') 'project configs directory'

$usdMatches = @(Get-ChildItem -LiteralPath (Join-Path $IsaacRoot 'extscache') -Directory -Filter 'omni.usd.libs-*' -ErrorAction SilentlyContinue)
if ($usdMatches.Count -gt 0) {
    Write-Host "PASS  USD runtime extension: $($usdMatches[0].FullName)"
} else {
    $failures.Add("Missing USD runtime extension under $IsaacRoot/extscache")
    Write-Host 'FAIL  USD runtime extension' -ForegroundColor Red
}

if ($SceneConfig) {
    Check-Path $SceneConfig 'scene config'
    if (Test-Path -LiteralPath $SceneConfig) {
        $sceneText = Get-Content -LiteralPath $SceneConfig -Raw -Encoding utf8
        foreach ($key in @('scene:', 'drone:', 'sensors:', 'prim_path:', 'body_path:', 'camera_path:', 'thermal_config:')) {
            if ($sceneText -match [regex]::Escape($key)) { Write-Host "PASS  config field: $key" }
            else { $failures.Add("Scene config missing field: $key"); Write-Host "FAIL  config field: $key" -ForegroundColor Red }
        }
        $configDir = Split-Path -Parent (Resolve-Path -LiteralPath $SceneConfig).Path
        $refs = [regex]::Matches($sceneText, '(?m)^\s*(stage|thermal_scene|sensor_config|thermal_config|display_config):\s*([^#\r\n]+)')
        foreach ($m in $refs) {
            $raw = $m.Groups[2].Value.Trim().Trim('"', "'")
            if ($raw -match '^\w+://') { continue }
            $candidate = if ([IO.Path]::IsPathRooted($raw)) { $raw } else { Join-Path $configDir $raw }
            if (Test-Path -LiteralPath $candidate) { Write-Host "PASS  referenced $($m.Groups[1].Value): $candidate" }
            else { $warnings.Add("Referenced path not found (may be resolved by project runtime): $candidate"); Write-Host "WARN  referenced $($m.Groups[1].Value): $candidate" -ForegroundColor Yellow }
        }
    }
}

if (-not $SkipImportCheck -and (Test-Path -LiteralPath $pythonBat) -and (Test-Path -LiteralPath (Join-Path $ProjectRoot 'third_party/isaac-thermal-camera-simulation/src'))) {
    $env:PYTHONPATH = "$ProjectRoot;$(Join-Path $ProjectRoot 'third_party/isaac-thermal-camera-simulation/src')"
    $importOutput = & $pythonBat -B -c "import irsim; print('irsim import PASS')" 2>&1
    if ($LASTEXITCODE -eq 0) { Write-Host ($importOutput -join "`n") }
    else { $warnings.Add('irsim import check failed; run the clean Isaac launcher or inspect the output above'); Write-Host ($importOutput -join "`n") -ForegroundColor Yellow }
}

Write-Host ''
if ($failures.Count -gt 0) {
    Write-Host "PREFLIGHT: FAIL ($($failures.Count) required checks)" -ForegroundColor Red
    $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}
Write-Host 'PREFLIGHT: PASS'
if ($warnings.Count -gt 0) {
    Write-Host "Warnings: $($warnings.Count)"
    $warnings | ForEach-Object { Write-Host "- $_" -ForegroundColor Yellow }
}
exit 0
