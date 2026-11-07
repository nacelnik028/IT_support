# Training academy — Windows EXE 7. 11. 2026

`ITSupportSimulator.exe` obsahuje síťovou učebnu 05 / Počítačové sítě
a 40 úloh pro oba ročníky. Herní zdroj je `dcb54fca8d173351f1490e5ea955a26012640920`.
Windows x86_64 Debug s vloženým PCK, Godot 4.7.2.stable.official.ed1daf0bf,
verze hry 1.5.0.

- Velikost **104558112 B**, rezerva **299488 B** pod 100 MiB.
- SHA256 `67c7604edb2c9e9b369f478135e9ef7fc787c0521ae4bcc54b68137e40334410`.
- `Test-All.ps1` prošel všemi 53 sadami včetně výuky ve všech třech režimech.
- Samostatný soubor se spustil nativně ve Windows s grafikou i bez ní.
- Přímo nad vloženým balíčkem prošlo 855 kontrol laboratoře bez
  grafiky, 862 s grafikou a 6724 kontrol obsahu. Grafický
  test zahrnoval 720p při 130 % textu a syntetický VR viewport 1600 × 1200.

[Učebna a zdroje úloh](../docs/NETWORK_LAB.md).
Úplná metadata jsou v `BUILD_INFO.json` a `VERIFICATION.json`.

PICO APK je starší vydání 1.5.0 / code 6 ze zdroje
`a6d58e3caf4072defac47d03d98abfb4fbd97be8` se SHA256
`bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`.
Fyzické ověření na PICO zbývá. VR matice používá syntetické ovladače v Godotu.
