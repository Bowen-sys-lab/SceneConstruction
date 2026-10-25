param(
    [Parameter(Mandatory=$true)][string]$SceneConfig,
    [string]$ProjectRoot = 'D:\IsaacSim_Demo',
    [string]$IsaacSimPython = 'D:\isaacsim\python.bat',
    [int]$Width = 160,
    [int]$Height = 128
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SceneConfig)) { throw "Scene config not found: $SceneConfig" }
$launcher = Join-Path $ProjectRoot 'scripts/start_crazyflie_dual_camera_view.py'
if (-not (Test-Path -LiteralPath $launcher)) { throw "Project preview launcher not found: $launcher" }
if (-not (Test-Path -LiteralPath $IsaacSimPython)) { throw "Isaac Sim Python launcher not found: $IsaacSimPython" }

$preflight = Join-Path $PSScriptRoot 'preflight_environment.ps1'
& $preflight -ProjectRoot $ProjectRoot -IsaacRoot (Split-Path -Parent $IsaacSimPython) -SceneConfig $SceneConfig
if ($LASTEXITCODE -ne 0) { throw 'Environment preflight failed; preview was not started.' }

Write-Host 'Starting RGB + Thermal preview.'
Write-Host 'The preview window intentionally shows only the two images.'

& $IsaacSimPython $launcher `
    '--config' $SceneConfig `
    '--width' $Width `
    '--height' $Height

if ($LASTEXITCODE -ne 0) { throw "Preview exited with code $LASTEXITCODE" }
