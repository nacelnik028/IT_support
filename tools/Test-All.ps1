param([Parameter(Mandatory=$true)][string]$GodotPath)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
foreach ($test in @('stage1','campaign','regression','extended','session_safety','save_safety','physical3d','world3d','tutorial_first','lessons','training_features','ui_safety','ui_smoke','training_ui','display_settings')) {
    $testArguments = @('--headless','--path',$projectRoot,'--script',"tests/$test.gd")
    if ($test -eq 'training_ui') { $testArguments += @('--','--all-modes') }
    $lines = & $GodotPath @testArguments 2>&1
    $exitCode = $LASTEXITCODE
    $lines | ForEach-Object { Write-Output $_ }
    if ($exitCode -ne 0 -or (($lines -join "`n") -match '(?m)^(SCRIPT ERROR:|ERROR:)')) { throw "Test $test selhal." }
}
