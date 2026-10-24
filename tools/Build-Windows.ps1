param([string]$GodotPath = '')
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not $GodotPath) {
    $candidate = Join-Path $PSScriptRoot '../../../Godot_v4.7.2-stable_win64.exe'
    if (Test-Path -LiteralPath $candidate) { $GodotPath = (Resolve-Path -LiteralPath $candidate).Path }
    else { throw 'Zadej -GodotPath s cestou ke spustitelnému Godotu 4.x.' }
}
$enginePath = (Resolve-Path -LiteralPath $GodotPath).Path
$buildPath = Join-Path $projectRoot 'build'
New-Item -ItemType Directory -Force -Path $buildPath | Out-Null
$packPath = Join-Path $buildPath 'ITSupportSimulator.pck'
& $enginePath --headless --path $projectRoot --export-pack 'Windows Desktop' $packPath
if ($LASTEXITCODE -ne 0) { throw 'Vytvoreni PCK selhalo.' }
# Portable engine + PCK works without installed export templates.
$desktopEngine = $enginePath -replace '_console.exe$', '.exe'
if (-not (Test-Path -LiteralPath $desktopEngine)) { $desktopEngine = $enginePath }
Copy-Item -LiteralPath $desktopEngine -Destination (Join-Path $buildPath 'ITSupportSimulator.exe') -Force
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination (Join-Path $buildPath 'README.md') -Force
foreach ($document in @('TRAINING.md','TEST_REPORT.md')) {
    $documentPath = Join-Path $projectRoot $document
    if (Test-Path -LiteralPath $documentPath) { Copy-Item -LiteralPath $documentPath -Destination $buildPath -Force }
}
Copy-Item -LiteralPath (Join-Path $projectRoot 'GODOT-LICENSE.txt') -Destination $buildPath -Force
Write-Output "Hotovo: $buildPath/ITSupportSimulator.exe (ponech vedle nej soubor PCK)."
