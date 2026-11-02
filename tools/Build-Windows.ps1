param([string]$GodotPath = '', [string]$PythonPath = '', [string]$TemplatePath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not $GodotPath) {
    $candidate = Join-Path $PSScriptRoot '../../../Godot_v4.7.2-stable_win64.exe'
    if (Test-Path -LiteralPath $candidate) { $GodotPath = (Resolve-Path -LiteralPath $candidate).Path }
    else { throw 'Zadej -GodotPath s cestou ke spustitelnému Godotu 4.x.' }
}
$enginePath = (Resolve-Path -LiteralPath $GodotPath).Path
$builder = Join-Path $PSScriptRoot 'build_windows.py'
$buildArguments = @($builder, '--godot', $enginePath)
if ($TemplatePath) { $buildArguments += @('--template', (Resolve-Path -LiteralPath $TemplatePath).Path) }
if ($PythonPath) { & $PythonPath @buildArguments }
elseif (Get-Command python -ErrorAction SilentlyContinue) { & python @buildArguments }
elseif (Get-Command py -ErrorAction SilentlyContinue) { & py -3 @buildArguments }
else { throw 'Nainstaluj Python 3.12+ nebo zadej -PythonPath.' }
if ($LASTEXITCODE -ne 0) { throw 'Sestaveni samostatneho EXE selhalo; zkontroluj test-output/windows-build-*.log.' }
Write-Output "Hotovo: $projectRoot/build/ITSupportSimulator.exe (herni data jsou uvnitr EXE)."
