# Training academy — Windows EXE 7. 11. 2026

`ITSupportSimulator.exe` obsahuje nové menu, praktický úvod, sbalitelný seznam
editoru, čitelnější rozcestník a kontextový HUD. Herní zdroj je
`b9f442039abe519b0015f8bfa8f30df1f172feae`. Windows x86_64 Debug s vloženým PCK,
Godot 4.7.2.stable.official.ed1daf0bf, verze hry 1.5.0.

- Velikost **104489040 B**, rezerva **368560 B** pod 100 MiB.
- SHA256 `58b1da8be57867d5d1c3a58924233b15c7c6b163d71b4a9f639f89f874347ecd`.
- `Test-All.ps1` prošel všemi 52 sadami včetně všech tří režimů výuky.
- Nativní běhy samotného EXE s obrazem i bez něj potvrdily nové menu a sbalení editoru.
- Nad vloženým packem prošlo 263 kontrol použitelnosti, 1 354 kontrol editoru a
  5 864 kontrol obsahu. Audit zahrnul 292 souborů a 284 materiálů.

[Snímky a protokol](../docs/ui-review/2026-11-06-usability/README.md).
Úplná metadata jsou v `BUILD_INFO.json` a `VERIFICATION.json`.

PICO APK je starší vydání 1.5.0 / code 6 ze zdroje
`a6d58e3caf4072defac47d03d98abfb4fbd97be8` se SHA256
`bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`.
Fyzické ověření na PICO zbývá. VR matice používá syntetické ovladače v Godotu.
