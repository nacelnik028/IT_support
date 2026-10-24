param([Parameter(Mandatory=$true)][string]$GodotPath)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
foreach ($test in @('stage1','campaign','regression','extended','ui_smoke')) {
    $lines = & $GodotPath --headless --path $projectRoot --script "tests/$test.gd" 2>&1
    $exitCode = $LASTEXITCODE
    $lines | ForEach-Object { Write-Output $_ }
    if ($exitCode -ne 0 -or (($lines -join "`n") -match '(?m)^(SCRIPT ERROR:|ERROR:)')) { throw "Test $test selhal." }
}
