# Samostatné Windows EXE

`ITSupportSimulator.exe` z 12. 11. 2026 obsahuje přehlednější pracovní panel
síťové dílny, oddělené opravy a měření, zachování fokusu a rozpracovaných voleb
a opravený prostor tabule, dveří a GSM. Původní katalogy zůstávají.
Windows x86_64 Debug, vložená data, 104616280 B, zdroj `fdcbe4b`.
Kontrolní součet je v `SHA256SUMS`.

## Sestavení a ověření

Použij Godot 4.7.2.stable.official.ed1daf0bf a shodnou oficiální Windows Debug šablonu.

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe'
python tools/test_workshop_package.py --godot C:/Godot/Godot_console.exe
```

Builder používá izolovanou kopii, bezeztrátovou kompresi katalogů a vložený
pack. Přejmenovaný EXE se spouští samostatně. Ověření projde portálem 05,
dveřmi, opraví H a obnoví směnu. Další externí testy čtou přesně tento pack.

Prošlo všech 55 sad Test-All včetně všech tří režimů výuky. Přesný export
prošel 855 kontrolami učebny, 493/499 dílny, 405 nového rozložení a 7687 obsahu.
Samostatný EXE prošel nativně s grafikou i bez ní. Všechna uložená data testů
jsou izolovaná.

[Ovládání](../docs/NETWORK_WORKSHOP.md) · [Metadata](BUILD_INFO.md) ·
[Ověření a snímky](../docs/ui-review/2026-11-11-workshop-layout/README.md).
PICO APK se nepřestavovalo. VR ověřeno synteticky; fyzický headset nebyl dostupný.
