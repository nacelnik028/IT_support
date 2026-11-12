# Training academy — Windows EXE 12. 11. 2026

`ITSupportSimulator.exe` obsahuje přepracovaný pracovní panel síťové dílny:
Ticket, Diagnostika, Opravy, Analyzátor a Rozbor, stálé spodní akce a samostatnou
historii. Tabule, dveře a GSM mají upravené prostorové uspořádání. Původních
40 úloh, 23 karet a osm ticketů A–H je zachovaných.

Herní zdroj `fdcbe4b6fdfed21b0494442d1a8e29470f615b0e`, Godot 4.7.2.stable.official.ed1daf0bf, hra 1.5.0.
Windows x86_64 Debug, vložená data, bez sousedního PCK.

- Velikost **104616280 B**, rezerva **241320 B** pod 100 MiB.
- SHA256 `78453fc4a61f05f537e28b2661aa07507cb267dc6420e8210db6d0b342fd23ba`.
- Celý Test-All: **55/55 sad PASS**, bez runtime chyb a varování; 21 lekcí
  v každém ze tří režimů, 336 akcí výukového rozhraní.
- Finální cílené kontroly: 493 dílna, 293 nové rozložení bez grafiky.
  Matice rozložení: 805 Compatibility a 805 Forward+ při 720p/1080p/4K,
  100/130 % textu a VR 1600 × 1200, oba syntetické paprsky, klikání a posun.
- Samotný přejmenovaný EXE v oddělené složce prošel startem s grafikou i bez ní,
  fyzickou cestou přes portál a dveře, opravou H a návratem do odložené směny.
- Přesný vložený pack: 855 učebna, 493 dílna bez grafiky, 499 dílna graficky,
  405 nové rozložení graficky a 7687 obsah. Vše PASS bez chyb a varování.
- Manifest všech 299 herních souborů souhlasí s pracovními zdroji.

[Ovládání](../docs/NETWORK_WORKSHOP.md) ·
[Snímky a protokoly](../docs/ui-review/2026-11-11-workshop-layout/README.md).
Metadata: `BUILD_INFO.json`, `VERIFICATION.json`, `SHA256SUMS`.

Godot MCP potvrdil finální zdroj bez runtime chyby; zbývá osm původních statických
varování v dřívějších částech. Nový panel nemá statické varování.

PICO APK nebylo přestavěné, nadále 1.5.0 / code 6 ze zdroje
`a6d58e3caf4072defac47d03d98abfb4fbd97be8`, SHA256
`bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`.
Fyzický headset není ověřený; VR kontroly jsou syntetické.
