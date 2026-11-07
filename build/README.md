# Samostatné Windows EXE

`ITSupportSimulator.exe` ze 7. 11. 2026 obsahuje úpravy menu, úvodu, editoru,
orientace v budově a HUD. Herní data jsou vložená přímo do souboru.
Jde o Windows x86_64 Debug pod 100 MiB. Kontrolní součet je v `SHA256SUMS`.
[Snímky a protokol](../docs/ui-review/2026-11-06-usability/README.md).

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

Závěrečný běh `Test-All.ps1` pokrývá 52 sad včetně všech tří výukových režimů.
Nativní testy spustí samotné EXE z cizí složky s izolovaným uložením a nastavením.
Další testy ověřují pokračování, HUD a editor přímo nad vloženými herními daty.
Výsledky i inventář balíčku jsou v [protokolu](../docs/ui-review/2026-11-06-usability/verification/).

```powershell
python tools/test_usability_package.py --godot C:/Godot/Godot_console.exe
```

PICO APK v `pico4/` je starší vydání 1.5.0 / code 6. VR rozhraní a vstupy byly
ověřeny syntetickými ovladači v Godotu. Zkouška na fyzickém PICO zbývá.
