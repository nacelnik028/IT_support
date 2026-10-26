param([string]$GodotPath = '', [string]$PythonPath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not $GodotPath) {
    $candidate = Join-Path $PSScriptRoot '../../../Godot_v4.7.2-stable_win64.exe'
    if (Test-Path -LiteralPath $candidate) { $GodotPath = (Resolve-Path -LiteralPath $candidate).Path }
    else { throw 'Zadej -GodotPath s cestou ke spustitelnému Godotu 4.x.' }
}
$enginePath = (Resolve-Path -LiteralPath $GodotPath).Path
$builder = Join-Path $PSScriptRoot 'build_windows.py'
if ($PythonPath) { & $PythonPath $builder --godot $enginePath }
elseif (Get-Command uv -ErrorAction SilentlyContinue) { & uv run --no-project --python 3.14 python $builder --godot $enginePath }
else { & python $builder --godot $enginePath }
if ($LASTEXITCODE -ne 0) { throw 'Sestaveni samostatneho EXE selhalo; zkontroluj test-output/windows-build-*.log.' }
Write-Output "Hotovo: $projectRoot/build/ITSupportSimulator.exe (herni data jsou uvnitr EXE)."
