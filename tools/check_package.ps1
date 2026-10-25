param(
    [Parameter(Mandatory=$true)][string]$SceneConfig,
    [Parameter(Mandatory=$true)][string]$ThermalConfig
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SceneConfig)) { throw "Scene config not found: $SceneConfig" }
if (-not (Test-Path -LiteralPath $ThermalConfig)) { throw "Thermal config not found: $ThermalConfig" }

$scene = Get-Content -LiteralPath $SceneConfig -Raw -Encoding utf8
$thermal = Get-Content -LiteralPath $ThermalConfig -Raw -Encoding utf8

$requiredScene = @('scene:', 'drone:', 'sensors:', 'prim_path:', 'body_path:', 'camera_path:', 'thermal_config:')
foreach ($key in $requiredScene) {
    if ($scene -notmatch [regex]::Escape($key)) { throw "Scene config is missing required field: $key" }
}

foreach ($key in @('defaults:', 'targets:', 'bindings:')) {
    if ($thermal -notmatch [regex]::Escape($key)) { throw "Thermal config is missing required section: $key" }
}

if ($thermal -notmatch 'temperature_c:') { throw 'Thermal config has no temperature_c entry' }
if ($thermal -notmatch 'material:') { throw 'Thermal config has no material entry' }
if ($thermal -notmatch 'prim_path:') { throw 'Thermal config has no prim_path binding' }

Write-Output 'Basic package check: PASS'
Write-Output "Scene config: $SceneConfig"
Write-Output "Thermal config: $ThermalConfig"
Write-Output 'This check does not open Isaac Sim; use the RGB + Thermal preview next.'
