# Samostatné Windows EXE

`ITSupportSimulator.exe` je nové sestavení z 5. 11. 2026 a obsahuje kompaktní pauzu,
Kam jít i celé aktuální opravy. Herní data jsou vložená; stačí jediný EXE bez PCK,
editoru nebo instalátoru. Windows x86_64 Debug, méně než 100 MiB, bez LFS.
Hash ověř v SHA256SUMS. [Snímek skutečného EXE](../docs/ui-review/2026-11-05-exe-menu/README.md).

## Sestavení

Použij Godot 4.7.2.stable.official.ed1daf0bf a shodnou oficiální Windows Debug šablonu.
Z kořene projektu:

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe'
# nebo
python tools/build_windows.py --godot C:/Godot/Godot_console.exe
```

Builder exportuje v izolované dočasné kopii, bezeztrátově komprimuje katalogy,
kontroluje PE/vložený PCK/limit velikosti a spustí přejmenované EXE z cizí složky.
Teprve úspěšný výsledek nahradí distribuci. Zdrojové katalogy zůstávají beze změn.
Přesné výsledky a rozdílné zdroje Windows/PICO viz BUILD_INFO.md a VERIFICATION.json.

## Ověření této distribuce

Nativní EXE-only smoke a skutečné klikání ve spuštěném EXE: Esc, nová pauza,
Kam jít a Esc zpět. Nad přesným vloženým packem také pause_repair 217/239/239 PASS
ve všech PC velikostech/textu a syntetickém XR, audit obsahu 5674 PASS.
[Logy a snímky](../docs/ui-review/2026-11-05-exe-menu/README.md).

PICO APK v pico4/ je dosud starší vydání 1.5.0 / code 6, bez těchto UI změn.
Při této opravě Windows nebylo přestavěné. Fyzický PICO test neprovedený.
