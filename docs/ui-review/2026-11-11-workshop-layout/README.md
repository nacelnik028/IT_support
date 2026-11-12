# Pracovní panel dílny a dveře / 11.–12. 11. 2026

Zadání navazuje na zdroj `91c0ab4`. Ovládání a pravidla pokusů jsou v
[NETWORK_WORKSHOP.md](../../NETWORK_WORKSHOP.md).

## Změna

Pět záložek odděluje ticket, diagnostiku, opravy, analyzátor a rozbor. Výběr
ticketů a historie mají vlastní tlačítka, spodní akce jsou mimo posouvaný obsah.
Měření uvádějí skutečný zdroj a cíl, aktuálnost i stručný výsledek. Detaily jsou
rozbalovací. Opravy mají sedm samostatných skupin a potvrzení resetu. Fokus,
posun a rozpracované volby přežijí překreslení i návrat do 3D.

Tabule topologie má společné lokální souřadnice a končí před obložkou dveří.
GSM sestava se posunula jako celek včetně fyzických cílů a kolizí. Pohyb dveří
odhalil původní kolizi křídla s pravým rámem; odsazení závěsu za obložku ji
odstranilo bez změny typu dveří, vypínání kolizí nebo čidel. Celé snímky HUD
žádné skutečné oříznutí levého horního rohu neukázaly.

## Reprodukce

```powershell
& $Godot --headless --path . --script tests/network_workshop.gd
& $Godot --headless --path . --script tests/workshop_layout.gd
& $Godot --path . --rendering-method gl_compatibility --script tests/workshop_layout.gd -- --screenshots
& $Godot --path . --rendering-method forward_plus --script tests/workshop_layout.gd -- --screenshots
& tools/Test-All.ps1 -GodotPath $Godot
python tools/build_windows.py --godot $Godot
python tools/test_workshop_package.py --godot $Godot
```

Testy nastavují `SaveManager.path_override` i samostatné cesty obou nastavení
před vznikem hry. Měření, zápis i jeho skutečné selhání používají izolovaná data.

## Obrazové důkazy

[before](before/) zachycuje původní stav, [after](after/) nový. Stejný testovací
skript a kamery pokrývají diagnostiku, opravy, běžný příchod, otevřené dveře a
ovladač, návrat z dílny i celou tabuli s GSM. Výchozí Opravy jsou spodní část
původní Diagnostiky. Nová matice obsahuje 720p/1080p/4K při 100 a 130 % textu
v obou rendererech. Skutečný VR SubViewport má 1600 × 1200, obě velikosti textu,
syntetické kliky obou paprsků a posouvání. Fyzický headset není ověřený.

Nová sada navíc ověřuje 11 zdrojů měření, navigaci bez vedlejších účinků,
zastaralé důkazy, uzavřenou zkoušku, A–H ve volném tréninku bez historie,
bezpečné opakování zápisu, stabilní fokus a posun, rozbalení, potvrzení resetu,
Tab/šipky/Enter/Esc/B/Y, 90 fyzikálních kroků pohybu křídla, oba ovladače,
obousměrnou chůzi a fyzickou SIM s předáním hovoru mezi BTS.

## Závěrečný výsledek

- [Celý Test-All](verification/test-all.log): **55/55 PASS**, exit 0, bez chyb a
  varování. 21 lekcí v každém ze tří režimů a 336 akcí UI. [Souhrn](verification/regressions.json).
- [Finální dílna](verification/workshop-headless.log): **493 PASS**.
  [Nové rozložení](verification/layout-headless.log): **293 PASS** včetně fyzického
  kontextu AP/portu a ochrany nové špičky dveří.
- Matice rozložení: [805 Compatibility](verification/layout-compatibility.log) a
  [805 Forward+](verification/layout-forward.log). Po ní se měnila pouze ochranná
  oblast křídla a kontext otevření skupiny ze 3D; jejich finální podoba znovu
  prošla v přesném exportu včetně grafického 720p/130 % a skutečného VR panelu.
- [Godot MCP finálního zdroje](verification/mcp-final.json): fyzický průchod,
  H a návrat do směny PASS, žádná runtime chyba. Osm původních statických
  varování mimo nový panel je zachovaných; nová varování nejsou potlačená.
- [Chráněný obsah](verification/catalog.json): původních 40 úloh, 23 karet,
  osm ticketů, kampaň/legacy, modely a generátory shodné s původním Git obsahem.
  Záznam rozlišuje CRLF pracovních souborů od LF v Gitu; obsah se neměnil.
- Windows EXE: zdroj `fdcbe4b6fdfed21b0494442d1a8e29470f615b0e`, **104616280 B**,
  SHA256 `78453fc4a61f05f537e28b2661aa07507cb267dc6420e8210db6d0b342fd23ba`.
  [Nativní a pack ověření](verification/package/results.json): samostatný EXE
  s grafikou/bez ní, 855 učebna, 493 dílna headless, 499 dílna graficky,
  405 nové rozložení graficky, 7687 obsah; vše PASS bez chyb a varování.
  Exportní manifest všech 299 herních souborů souhlasí s pracovními zdroji.
- [166 skutečných PNG, rozměry a SHA256](verification/screenshots.json).
  Prohlédnuté porovnávací sestavy pokrývají šest PC kombinací v obou rendererech,
  navíc plné 720p/130 % a VR panely. Prohlédnuté jsou také nové panely z přesného
  packu a rozbor přímo ze samostatného EXE.

[Diagnostika](after/diagnostics-1280-130-forward_plus.png) ·
[Opravy](after/repairs-1280-130-forward_plus.png) ·
[VR panel](after/vr-repairs-vr-1600x1200-130-forward_plus.png) ·
[Příchod ke dveřím](after/door-approach-1280-130-forward_plus.png) ·
[Otevřené dveře a ovladač](after/door-open-control-1280-130-forward_plus.png) ·
[Návrat z dílny](after/return-classroom-1280-130-forward_plus.png) ·
[Celá topologie](after/topology-full-1280-130-forward_plus.png) ·
[GSM](after/gsm-workplace-1280-130-forward_plus.png) ·
[Rozbor přímo z EXE](verification/package/native-review.png).

PICO APK se nepřestavovalo a jeho SHA256 souhlasí s původním vydáním.
**Fyzický headset nebyl dostupný**; všechny VR výsledky jsou syntetické.
Vývojové neúspěšné běhy zůstávají mimo závěrečné protokoly v `test-output`.
Vše je lokální, bez push nebo publikování.
