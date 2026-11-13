# Samostatné Windows EXE

`ITSupportSimulator.exe` z 13. 11. 2026 obsahuje servisní rozšíření A–E,
varianty ticketů, tester, zvuky a společné mise. Má lokální testovací podpis
Training academy Local Debug; SmartScreen může nadále upozorňovat.
Windows x86_64 Debug, vložená data, 104704152 B, herní zdroj `cc18d3a`.
Kontrolní součet je v `SHA256SUMS`.

## Sestavení a ověření

Použij Godot 4.7.2.stable.official.ed1daf0bf a shodnou oficiální Windows Debug šablonu.

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe' -SignDebug
python tools/test_windows_signing.py
```

Builder používá izolovanou kopii, bezeztrátovou kompresi katalogů a vložený
pack. Přejmenovaný EXE se spouští samostatně. Ověření projde portálem 05,
dveřmi, opraví H a obnoví směnu. Další externí testy čtou přesně tento pack.

Před podpisem prošlo všech 63 sad Test-All včetně všech tří režimů výuky
a 21 běhů nad přesným exportem. Podpis nezměnil herní data; po podpisu je
ověřená neporušenost a skutečný nativní start s grafikou i bez ní.
Všechna uložená data testů jsou izolovaná.

[Ovládání](../docs/NETWORK_WORKSHOP.md) · [Metadata](BUILD_INFO.md) ·
[Podpis a klíč](../docs/WINDOWS_DEBUG_SIGNING.md) ·
[Ověření a snímky](../docs/ui-review/2026-11-12-service-missions/README.md).
PICO APK se nepřestavovalo. VR ověřeno synteticky; fyzický headset nebyl dostupný.
