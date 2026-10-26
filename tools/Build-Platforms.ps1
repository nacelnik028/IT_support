param([Parameter(Mandatory=$true)][string]$GodotPath)
$ErrorActionPreference = 'Stop'
$builder = Join-Path $PSScriptRoot 'build_platforms.py'
& python $builder --godot $GodotPath
if ($LASTEXITCODE -ne 0) { throw 'Export nebo ověření sestavení selhalo.' }
