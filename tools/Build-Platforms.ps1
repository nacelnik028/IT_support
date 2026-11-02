param([Parameter(Mandatory=$true)][string]$GodotPath, [switch]$PicoOnly, [switch]$WindowsOnly)
$ErrorActionPreference = 'Stop'
$builder = Join-Path $PSScriptRoot 'build_platforms.py'
if ($PicoOnly -and $WindowsOnly) { throw 'Vyber pouze jednu platformu, nebo obě bez přepínače.' }
$platformArguments = @('--godot', $GodotPath)
if ($PicoOnly) { $platformArguments += '--pico-only' }
if ($WindowsOnly) { $platformArguments += '--windows-only' }
& python $builder @platformArguments
if ($LASTEXITCODE -ne 0) { throw 'Export nebo ověření sestavení selhalo.' }
