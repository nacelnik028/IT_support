# Opravené Windows EXE — 5. 11. 2026

Příčina hlášeného původního menu: předchozí push obsahoval zdrojové úpravy,
ale soubor `build/ITSupportSimulator.exe` zůstal z vydání 4. 11. Nové EXE nyní
obsahuje celé aktuální zdroje včetně kompaktní pauzy a podnabídky Kam jít.

- Runtime zdroj: `a403a406865f8849e209a66918330eb7b951d5e0`. Godot 4.7.2.stable.official.ed1daf0bf, Windows x86_64 Debug, vložený PCK.
- EXE: **104480112 B**, rezerva **377488 B** pod 100 MiB.
- SHA256: `831f5540f0e18a8427cf19eb412cd1cedaf355a1582067b1e0b676b30dd8e170`.
- Nativní EXE-only smoke z cizí složky PASS; žádný projekt nebo vnější PCK.
- Přímá kontrola skutečného EXE přes Windows UI: vstup do hry, Esc → kompaktní
  pauza, Kam jít a Esc zpět; ukončení se zachováním izolovaného testovacího save.
- Testy nad přesným vloženým EXE obsahem: pause_repair **217 headless / 239 Compatibility / 239 Forward+ PASS**;
  všech šest PC rozlišení/textu a skutečný XR viewport. Audit balíčku **5674 PASS**, 292 souborů,
  275 materiálů, bez chybějících materiálů nebo změněných hodnot katalogů.
- Herní zdroje se neměnily; platí již provedený celý 51sadový source runner.
  Hráčův save ani nastavení se v testech nepoužily.

[Skutečná pauza v EXE](native-exe-pause.png), [Kam jít v EXE](native-exe-destinations.png),
[strojové výsledky](verification/results.json), [celý zdrojový protokol](../2026-11-04-interface/README.md).
Původní distribuční metadata zůstávají oddělená ve verification/previous-distributions.json.

PICO APK nebylo při této opravě Windows EXE přestavěné. Zůstává starší 1.5.0 / code 6;
shodu jeho starého zdroje s novým Windows EXE netvrdíme. Fyzický headset nebyl testovaný.
