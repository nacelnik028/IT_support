# Samostatné Windows EXE

`ITSupportSimulator.exe` z 11. 11. 2026 obsahuje síťovou učebnu 05 se 40 úlohami
a samostatnou tréninkovou dílnu s osmi tickety A–H. Data jsou vložená do souboru.
Jde o Windows x86_64 Debug pod 100 MiB, zdroj `d2617b6`. Kontrolní součet je v
`SHA256SUMS`. [Cesta do dílny](../docs/NETWORK_WORKSHOP.md).

## Sestavení a ověření

Použij Godot 4.7.2.stable.official.ed1daf0bf a shodnou oficiální Windows Debug šablonu.

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe'
python tools/test_workshop_package.py --godot C:/Godot/Godot_console.exe
```

Builder exportuje v izolované dočasné kopii, bezeztrátově komprimuje katalogy,
ověří PE, vložený pack a velikost a spustí přejmenovaný EXE v oddělené složce.
Smoke test projde portálem 05 a dveřmi dílny, opraví H a obnoví směnu.
Zdrojové katalogy zůstávají zachované.

Celý Test-All prošel 54 sadami včetně všech tří režimů výuky. Přesný pack nového
EXE prošel 855 kontrolami laboratoře, 438 kontrolami dílny bez grafiky,
444 s grafikou a 7687 kontrolami obsahu. Samotný EXE prošel nativním startem
i fyzickým průchodem s grafikou a bez ní. Save a nastavení jsou izolované.

Podrobnosti: [BUILD_INFO.md](BUILD_INFO.md) a [protokoly](../docs/ui-review/2026-11-11-network-workshop/README.md).
PICO APK je starší 1.5.0 / code 6; VR bylo ověřené synteticky, fyzické PICO zbývá.
