# Training academy — Windows EXE 11. 11. 2026

`ITSupportSimulator.exe` obsahuje rozšířený pavilon 05: síťovou učebnu se
40 původními úlohami a samostatnou tréninkovou dílnu s osmi tickety A–H.
Herní zdroj je `d2617b6cde53af3184328dd24f7d76d5863c6a9c`. Windows x86_64 Debug s vloženými daty,
Godot 4.7.2.stable.official.ed1daf0bf, verze hry 1.5.0.

- Velikost **104605624 B**, rezerva **251976 B** pod 100 MiB.
- SHA256 `11676710ad01a760c2ee5b0dd60687a251baa057d7d9ad74416a5fa58fd8bf11`.
- Celý Test-All: **54/54 sad PASS**; 21 lekcí v každém ze tří režimů,
  336 akcí výukového rozhraní. Po opravě návratů zopakováno dalších pět sad.
- Cílená dílna: 438 kontrol bez grafiky; grafická matice 504 kontrol v každém
  rendereru. Poslední oprava ARP přidala kontrolu nové MAC v rámci i TCP cestě;
  původní LabNetwork a jeho 40 úloh zůstaly zachované.
- Samotný EXE se spustil v oddělené složce bez PCK s grafikou i bez ní.
  Skutečná chůze přes portál 05 a dveře, oprava H, rozbor a obnovení směny PASS.
- Přesný vložený balíček: 855 kontrol původní laboratoře,
  438 kontrol dílny bez grafiky, 444 s grafikou a
  7687 kontrol obsahu; vše bez chyb a varování.

[Cesta do dílny a tickety](../docs/NETWORK_WORKSHOP.md) ·
[Protokoly a snímky](../docs/ui-review/2026-11-11-network-workshop/README.md).
Metadata: `BUILD_INFO.json`, `VERIFICATION.json`, `SHA256SUMS`.

PICO APK je starší 1.5.0 / code 6 ze zdroje `a6d58e3caf4072defac47d03d98abfb4fbd97be8`.
Jeho SHA256 je `bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`. Nebylo přestavěné; fyzický headset nebyl ověřený.
VR testy používají skutečný viewport 1600 × 1200 a syntetické paprsky obou rukou.
