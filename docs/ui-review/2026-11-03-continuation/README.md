# Pokračování, pokročilé směny, poslech a profil

Skutečné snímky z 3.–4. listopadu 2026. Nová matice obsahuje 196 PNG: sedm
obrazovek × šest PC kombinací plus 56 VR snímků na každý renderer, tedy
98 Compatibility a 98 Forward+. K tomu samostatný snímek zazděného průchodu.

PC: 1280×720, 1920×1080 a 3840×2160, text 100/130 %. VR: skutečný SubViewport
1600×1200, obě velikosti textu, panel 80/140 %, vzdálenost 0,9/2 m, klávesnice
zavřená/otevřená. Vložené dialogy jsou na finálních snímcích viditelné současně
s klávesnicí. Grafické běhy 298 PASS na renderer; headless 200 PASS.

Názvy: code = skutečný editor a obnova konceptu, continuation = Pokračování,
shift = fronta pokročilé směny, review = uložený konkrétní rozbor, listening =
skrytý přepis a sémantické odpovědi, listening-result = význam/vysvětlení/pomoc,
profile = společných 13 dovedností. Částky/čas v úloze se nevymýšlejí.

Prohlédnuté reprezentativní originály: malý PC poslech, 4K obnova a profil,
VR rozbor s klávesnicí, poslech po odpovědi a souvislá stěna. Kontaktní listy
qa-contact slouží ke kontrole celé matice, nikoli jako náhrada originálů.
Dialogy po zjištění malého 4K měřítka opravené; bez useknutých hlavních ovladačů,
dlouhý obsah má posuv a klávesový fokus. Viditelnost kontrol má toleranci půl
fyzického pixelu kvůli zaokrouhlení přesného okraje viewportu.

[Trvalé logy](verification) oddělují jednotlivé funkční etapy a konečné běhy.
Godot MCP mcp-final.json: 31 PASS, osm původních statických varování; nové
shadow/static-instance varování odstraněné. Žádné plošné potlačení chyb.

Počáteční neúplné celé běhy se nevykazují jako PASS: tři testové inline
inicializátory při izolaci VR configu, migrace cizí trace identity a skutečný
dvojí zápis terminálu byly opravené. Původní garance testů zůstaly zachované.
Při grafickém vývoji opravené i čekání na fyzikální frame pro tracking a
generační token dokončení audia. Přesné aktuální výsledky: [TEST_REPORT](../../../TEST_REPORT.md).

PC render a syntetické XR nejsou optická čitelnost ani tracking PICO.
**Hardware NEPROVEDENO – headset není dostupný.** Audio hash/dekódování/PCM/
přehrávač nejsou subjektivní lidský poslech. Bez ADB dotazů nebo nasazení.
