# Síťová učebna a tréninková dílna / 11. 11. 2026

Hráčský průchod a rozsah: [Síťová dílna](../../NETWORK_WORKSHOP.md).

## Výchozí stav a snímky

Před změnami prošel původní `network_lab` v Compatibility i Forward+ 862
kontrolami. Průchod otevřel učebnu severním portálem z haly, dokončil fyzickou
úlohu Od zásuvky až k webu a obnovil kampaň i souvislou směnu. Výchozí záběry
jsou v [before](before/), výsledné v [after](after/).

Stejná kamera pro srovnání výkonu a snímku: pozice (4, 0.02, −17.5), cíl
(1, 1.4, −22), 1920 × 1080, vypnutý vsync, 90 zahřívacích a 240 měřených
snímků. `tools/benchmark_network_workshop.py` načte předchozí zdroj do izolované
dočasné složky a porovná oba renderery stejným testovacím skriptem.

Výsledná obrazová matice obsahuje 1280 × 720, 1920 × 1080 a 3840 × 2160,
každé při 100 a 130 % textu, v Compatibility a Forward+. Záběry zahrnují
portál, servisní rack, terminál, demonstrační část, dveře dílny, cvičný rack,
diagnostiku a rozbor. VR používá skutečný SubViewport 1600 × 1200 při 100/130 %
a syntetické trackery obou rukou. **Fyzický headset není ověřený.**

## Reprodukce

```powershell
& $Godot --headless --path . --script tests/network_workshop.gd
& $Godot --path . --rendering-method gl_compatibility --script tests/network_workshop.gd -- --screenshots
& $Godot --path . --rendering-method forward_plus --script tests/network_workshop.gd -- --screenshots
& tools/Test-All.ps1 -GodotPath $Godot
python tools/build_network_workshop.py
python tools/benchmark_network_workshop.py --godot $Godot
```

Každý test používá `SaveManager.path_override` a vlastní soubory obou nastavení.
Výsledky v `verification/` jsou skutečné protokoly. Průběžné vývojové běhy jsou
v `test-output`; za rozhodující se považují až závěrečné úspěšné běhy.

## Pokrytí

- Každý z osmi ticketů: referenční oprava ve všech třech režimech a přesvědčivá
  chybná zkratka. Alternativní port VLAN 10, ochrana PC 02 a portu 05/VLAN 20.
- Všech osm ticketů přes skutečné ovládací prvky; H také souvislým fyzickým
  průchodem z haly a zpět k odložené kampani.
- Přesné porty, odmítnutí obsazeného portu, undo, neplatná konfigurace,
  izolovaná ukázka, zastaralé ověření a čerstvé důkazy.
- Selhání skutečného zápisu, bezpečné opakování bez duplicity, starší profil,
  validace poškozeného důkazu a restart bez obnovy dočasného pokusu.
- VR teleport, levý paprsek pro kabel, pravý pro konkrétní sousední port,
  obě ruce v panelu, původní viewport a návrat z pavilonu.
- Běžný Windows export má vlastní opt-in smoke kontrolu: fyzická cesta přes
  portál a dveře, oprava H, čtení rozboru a návrat do odložené směny.

## Závěrečný výsledek

- Celý [Test-All](verification/test-all-release.log): **54/54 PASS**, exit 0,
  54 startů Godotu bez chyb/varování. Výuka: 21 lekcí v každém režimu, 336 UI akcí.
- Po opravě návratu polohy prošly [další 5 cílené sady](verification/return-regression/).
- Dílna: [438 kontrol bez grafiky](verification/workshop-headless-mac.log).
  Grafická matice: [504 Compatibility](verification/workshop-compatibility-release.log) a
  [504 Forward+](verification/workshop-forward-release.log). Geometrie a rozhraní se
  po této matici neměnily; poslední oprava pouze sjednotila MAC v ARP a Ethernetu.
  Její dvě nové kontroly prošly také v přesném exportu.
- [Godot MCP](verification/mcp-current.json): fyzický průchod, ticket H a návrat do
  směny PASS. Žádná runtime chyba; osm původních statických varování mimo nové
  síťové skripty, žádné nové potlačení.
- [Katalog](verification/catalog.json): deterministický generátor, osm ticketů,
  původních 40 úloh a 23 karet, kampaň/legacy a chráněné generátory zachované.
- Windows EXE `d2617b6`, 104605624 B, SHA256 `11676710ad01a760c2ee5b0dd60687a251baa057d7d9ad74416a5fa58fd8bf11`.
  [Ověření exportu](verification/package/results.json): nativní start s grafikou i
  bez ní, fyzická cesta 05 → dílna → oprava H → rozbor → obnovená směna.
  Přesný pack: 855 původní laboratoř, 438 dílna bez grafiky,
  444 dílna s grafikou, 7687 obsah — vše PASS a bez varování.
- Benchmark stejného záběru: Compatibility **0,755 → 0,985 ms**,
  Forward+ **1,998 → 2,062 ms**. Nová místnost přidala 0,23 / 0,06 ms;
  jde o krátké měření na NVIDIA RTX 5060, nikoli odhad výkonu PICO.
- [143 snímků se skutečnými rozměry a SHA256](verification/screenshots.json).
  Prohlédnuté porovnávací sestavy pokrývají všech šest PC kombinací v obou
  rendererech; 720p/130 % a VR panely byly prohlédnuté také v plném rozlišení.

[Vstup 05](after/portal-1280-130-gl_compatibility.png) ·
[Cvičný rack](after/workshop-rack-1280-130-forward_plus.png) ·
[Diagnostika](after/workshop-diagnostics-1280-130-forward_plus.png) ·
[VR panel](after/workshop-vr-diagnostics-vr-1600x1200-130-gl_compatibility.png) ·
[Rozbor přímo ze samostatného EXE](verification/package/native-review.png).

Vývojové protokoly v `verification/development/` zahrnují opravený počet portálů,
chybu popisu zásahu, stabilizaci testovacího kurzoru a přesměrování výstupní
složky testů mimo read-only export. Nejsou závěrečným výsledkem. Předchozí
export před opravou MAC je archivovaný zvlášť.

PICO APK se nepřestavovalo. **Fyzický headset nebyl dostupný**; všechny zde
uvedené VR výsledky jsou syntetické.
