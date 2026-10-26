param([Parameter(Mandatory=$true)][string]$GodotPath)
$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
foreach ($test in @('xr_modes','terminal_sessions','platform_context','console_ux','ui_design','world_ui','stage1','campaign','regression','extended','session_safety','save_safety','physical3d','world3d','door3d','world_playthrough','training_rooms','tutorial_first','tutorial_navigation','lessons','training_features','ui_safety','ui_smoke','training_ui','display_settings')) {
    $testArguments = @('--headless','--path',$projectRoot,'--script',"tests/$test.gd")
    if ($test -eq 'training_ui') { $testArguments += @('--','--all-modes') }
    # Capture native stderr too; print the complete failing suite before throwing.
    try {
        $ErrorActionPreference = 'Continue'
        $lines = & $GodotPath @testArguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally { $ErrorActionPreference = 'Stop' }
    $lines | ForEach-Object { Write-Output $_ }
    if ($exitCode -ne 0 -or (($lines -join "`n") -match '(?m)^(SCRIPT ERROR:|ERROR:|WARNING:)')) { throw "Test $test selhal." }
}
