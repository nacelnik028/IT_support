# Training academy — Windows EXE 9. 11. 2026

`ITSupportSimulator.exe` obsahuje opravený rozcestník a pohled na vstup
do programování ze serverovny. Součástí je síťová učebna 05 / Počítačové sítě
se 40 úlohami. Herní zdroj je `91d1776dd12652646b45bc7aeadd1ec6af070fb2`.
Windows x86_64 Debug s vloženým PCK, Godot 4.7.2.stable.official.ed1daf0bf,
verze hry 1.5.0.

- Velikost **104558176 B**, rezerva **299424 B** pod 100 MiB.
- SHA256 `4771d16d73f1b9414cc997aa69a5cc73f3d4da56d523961d88a124606768a808`.
- Prošlo všech 53 sad ze seznamu `Test-All.ps1` včetně výuky ve všech třech režimech.
- Samostatný soubor se spustil nativně ve Windows s grafikou i bez ní.
- Snímky z vloženého balíčku v Compatibility potvrdily čitelnost obou tabulí.
  Test přístupu do programovací učebny prošel 116 kontrolami.
- Přímo nad vloženým balíčkem prošlo 855 kontrol laboratoře bez
  grafiky, 862 s grafikou a 6724 kontrol obsahu. Grafický
  test zahrnoval 720p při 130 % textu a syntetický VR viewport 1600 × 1200.

[Učebna a zdroje úloh](../docs/NETWORK_LAB.md).
Úplná metadata jsou v `BUILD_INFO.json` a `VERIFICATION.json`.

PICO APK je starší vydání 1.5.0 / code 6 ze zdroje
`a6d58e3caf4072defac47d03d98abfb4fbd97be8` se SHA256
`bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`.
Fyzické ověření na PICO zbývá. VR matice používá syntetické ovladače v Godotu.
