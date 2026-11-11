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

Závěrečné počty kontrol, benchmarky a verze EXE budou doplněné po dokončení
regrese a exportu. Tento protokol zatím neoznačuje vydání za ověřené.
