# Použitelnost akademie — 6. 11. 2026

Navazuje na zdroj `601fa0d`. Dřívější nepřidaná složka `2026-11-05-alex-portals-editor` není součástí této práce.

## Změny

1. **Praktický úvod:** nový profil má výraznou dobrovolnou nabídku a přeskočení. Stávající cvičné prostředí vede od pohybu a zaměření přes zásah až k výslovnému ověření výsledku na monitoru. Zrušení i opakování obnoví původní práci a obrazovku, bez XP; chyba zápisu spuštění zastaví. Pokyny respektují PC předvolby a VR.
2. **Menu a pokračování:** dvě hlavní potřeby, čtyři číslované učebny, menší vedlejší volby. Existující přehled Pokračování nově uvádí skutečné názvy a stav kampaně, směny, výuky i programovacích konceptů. Vybraná položka obnoví vlastní stav a režim. Prohlížení nic nespouští, nehodnotí ani nepřepisuje. Prázdné pokračování je neaktivní; Esc a B/Y se vracejí stejně.
3. **Editor:** sbalení levého seznamu přidá přes 280 logických pixelů šířky. Zachovává kód, soubory, vstupy, výstup, ověření, pokus, koncept, dělicí lištu a prostor klávesnice. Titul, režim, spuštění, ověření, zadání a nápověda zůstávají viditelné. Nástroje využívají původní nabídky; před otevřením dialogu nejprve předají fokus.
4. **Budova:** stávající cedule mají větší názvy a leží pod stropními lamelami. Čísla, názvy a čtyři barevné akcenty odpovídají menu i orientační tabuli. Světla byla přemístěna a upravena, jejich počet zůstává 34. Průchody, kolize, čidla, dosah interakcí ani zazděný přímý průchod serverovna–Londýn se nemění.
5. **HUD:** po zaučení krátké připomenutí, celé ovládání na F1 nebo přes Nastavení. Kontext uvádí konkrétní akci a skutečnou klávesu nebo trigger. Cíl, zkouška, nesený předmět, blokované dveře a chyba uložení zůstávají čitelné. VR používá existující náramek a kontext obou paprsků.

## Důkazy a reprodukce

- [Před](before/) a [po](after/): stejné kamery a stav, menu nového i vracejícího se profilu, rozcestník a čtyři příchody, editor, HUD. Oba renderery, 1280×720 / 130 %. Snímek `editor-collapsed` ukazuje získaný prostor.
- [Matice](matrix/): editor v 720p/1080p/4K × 100/130 %, úspěch/chyba/zastaralost/podrobnosti, skutečný SubViewport 1600×1200, oba syntetické paprsky a otevřená virtuální klávesnice. Reprezentativní snímky byly otevřeny a prohlédnuty; větší názvy byly po kontrole šikmého příchodu ještě sníženy pod lamely.
- [Godot MCP](mcp/): izolovaná skutečná scéna, nabídka, návrat z úvodu, sbalený editor s ověřením a HUD. Bez runtime chyby. Osm původních statických varování v nezměněných částech, žádné nové potlačení.
- `tests/usability.gd`: nové/starší profily, nula/jedna/více prací, skutečné myší/XR kliky, obnova infrastruktury i souborů, všechny tři živé IT režimy, čisté prohlížení, selhání zápisu, kontext, blokované dveře, předvolby, F1 a návraty.
- `tests/editor_repair.gd`: porovnání skutečných dat před/po sbalení, rozměry, minimálně pět celých řádků, resize, záložky, posuv, tažení a oba ovladače. `programming_integration` navíc píše fyzickou i virtuální klávesnicí a mění soubory se sbaleným seznamem.
- Nové testy vždy nastavují `SaveManager.path_override`, samostatné DisplaySettings i VRSettings. Testovací PNG a logy nepocházejí z hráčova profilu.
- `tests/usability_capture.gd -- --screenshots`: srovnávací snímky a tři opakování měření stejného 1080p záběru. `--baseline` byl použit před úpravami.
- Grafické matice: `tests/usability.gd` a `tests/editor_repair.gd -- --screenshots --review-usability`. Matice používá profil Vyvážená; srovnávací snímky/benchmarky výchozí Vysoká. Syntetický VR ověřuje rozložení a vstupy, nikoli fyzické PICO nebo jeho výkon.

Závěrečné logy, souhrn regrese a ověření nového Windows EXE jsou ve [verification](verification/). Vývojové neúspěšné běhy nejsou vydávány za finální výsledky. Katalogy, generátory a prvních 24 definic zůstávají beze změn. PICO APK se v tomto zadání nepřestavuje.
