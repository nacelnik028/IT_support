# Training academy — Windows EXE 13. 11. 2026

`ITSupportSimulator.exe` obsahuje servisní rozšíření A–E: původní A–H a 24
skutečných obměn, přenosný 3D tester, prostorové zvuky, English support a dvě
společné mise propojující síť, Python a předání. Vstup: Rozcestník → 05 →
Tréninková dílna → Servisní stůl. Tři režimy, odložení společné mise a pokračování.

Herní zdroj `cc18d3adec9bedd1494ff9ea1a09ce7f91fb831d`, Godot 4.7.2.stable.official.ed1daf0bf, hra 1.5.0.
Windows x86_64 Debug, samostatné EXE s vloženými daty, bez sousedního PCK.

- Velikost podepsaného EXE **104704152 B**, rezerva **153448 B** pod 100 MiB.
- SHA256 `6ae0ab799bfb42d65ea39c79e51eeff5ceabc35afacace5654eb92851be99dee`.
- Vlastní testovací podpis **Training academy Local Debug**, RSA 3072 / SHA256.
  Neposkytuje důvěru vydavatele ani záruku odstranění SmartScreen. Klíč zůstává
  v osobním úložišti Windows; [postup a ověření](../docs/WINDOWS_DEBUG_SIGNING.md).
- Po podpisu ověřené CMS, skutečný PE digest, identita herního packu, zachycení
  dodatečné změny a nativní start s grafikou i bez ní včetně servisních misí/zvuku.
- Celý přísný Test-All před podpisem: **63/63 sad PASS**, bez runtime chyb a varování;
  21 lekcí v každém ze tří režimů, 336 akcí výukového rozhraní.
- Grafická matice misí: **696 Compatibility + 696 Forward+**, 720p/1080p/4K,
  text 100/130 %, skutečný VR viewport 1600×1200, oba syntetické paprsky a klávesnice.
- Samotný EXE v oddělené složce prošel nativním startem s grafikou i bez ní,
  původní dílnou a návratem ke směně, oběma servisními misemi a dekódováním 7 PCM.
- Přesný vložený pack před podpisem: **21 kontrolních běhů PASS** (2 nativní,
  16 headless sad a 3 grafické). Každý JSON odpovídá zdroji, každý ze sedmi
  importovaných QOA datových bloků zdrojovému Godot importu; autorské WAV mají
  samostatně ověřený SHA256. Skutečné dekódování/přehrávání také PASS.
- Manifest všech **331 herních souborů** odpovídá pracovnímu zdroji.
  Původních 24 misí, legacy, 40 síťových úloh/23 karet a základy A–H jsou zachované.

[Ovládání dílny](../docs/NETWORK_WORKSHOP.md) · [Společné mise](../docs/SERVICE_MISSIONS.md) ·
[Snímky a protokoly](../docs/ui-review/2026-11-12-service-missions/README.md).
Metadata: `BUILD_INFO.json`, `VERIFICATION.json`, `SHA256SUMS`.

Godot MCP: obě mise a PCM PASS, bez runtime chyby a nových statických varování;
osm původních statických varování je zdokumentovaných v surovém protokolu.

PICO APK nebylo přestavěné, nadále 1.5.0 / code 6 ze zdroje
`a6d58e3caf4072defac47d03d98abfb4fbd97be8`, SHA256
`bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`. Servisní rozšíření je ověřené v novém Windows EXE a zdroji.
Fyzický headset a subjektivní lidský poslech nejsou ověřené. Bez push/publikování.
