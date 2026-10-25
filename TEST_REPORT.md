# Ověření rozšířené hratelné verze

## Nové konzole, nastavení a validace platformy — 25. 10. 2026

Finální `tools/Test-All.ps1`: **21 sad PASS, exit 0, bez runtime chyb a varování**.
Všechny běhy používají izolované cesty SaveManager i DisplaySettings.

| Kontrola | Skutečný výsledek |
|---|---|
| Chyby platformy | 396 kontrol; odmítnutí Dynamic Memory i nativní migrace PVE VM, nezměněná infrastruktura |
| Konzole a průvodce | 60 kontrol headless i samostatný Windows EXE; skutečné kliknutí všemi 6 kroky, aktuální CPU/RAM, koncepty, posuv/fokus po chybě i úspěchu, VM101 v síti |
| 3D rozhraní | 27 kontrol headless, Forward+, Compatibility i zabalený EXE; modalita, psaní bez chůze, návrat nastavení do pauzy, HUD všech režimů, předvolby grafiky |
| Celá kampaň | 65/65 misí v simulaci i přes nové viditelné formuláře; shoda legacy24 |
| Výuka a uložený postup | 21 × 3 režimy, 1075 kontrol lekcí, 336 výukových UI akcí, 474 kontrol save, 124 relací, 68 kontrol oddělení místností |
| Obraz a přístupnost | 68 headless / 76 GPU kontrol nastavení; skutečný fullscreen a všech 6 rozlišení, timeout a chyby zápisu, vlastní klávesy a text |
| Ostrost | 8 GPU kontrol; skutečný 4K framebuffer, ostré fonty v menu/racku/terminálu, SVG textura 38 × 38 |
| Godot MCP | 79 objektů, raycast/E/konzole/save/návrat/dveře PASS, errors=[] |

Snímky nové konfigurace a nastavení v 720p, 1080p a 4K, všechny kroky průvodce,
130% text a zmenšený HUD byly skutečně prohlédnuté. Balíček EXE+PCK byl nově
sestaven a oba externí grafické testy skončily exit 0. Testy nejsou součástí PCK.

Logy v `test-output/`: `ux-test-all-final.log`, `ux-package-console.log`,
`ux-package-world-ui.log`, `ux-display-gpu-final.log`, `ux-render-quality.log`,
`ux-world-ui-gpu-final.log`, `ux-compatibility.log`; snímky mají prefix `ux-`.
Opakované generování katalogu zachovalo stejné hashe. Prvních 24 misí,
legacy definice a jejich referenční řešení zůstaly zachované.

## Oddělení místností — 25.10.2026

Nová sada `tests/training_rooms.gd` a scéna `tests/TrainingRoomsMCP.tscn`
ověřují stejné skutečné 3D prostředí.68 kontrol A–H prošlo headless,
graficky přes Godot MCP (Forward+/RTX5060, `errors=[]`) i ve Windows EXE+PCK.
Všechny testy používají vlastní `SaveManager.path_override` a config.

| Test | Ověření |
|---|---|
| A | Skutečná chůze dveřmi → TRAINING, pozastavená kampaň, funkční všechny3 režimy |
| B | Chůze zpět → MAIN, zrušená lekce, UI, šipky, kroky, dialogy a sandbox |
| C | Návrat do centra nabízí nový výběr bez automatického obnovení |
| D | Dokončená zkouška, nejlepší výsledek, statistiky a dříve získané kariérní XP přetrvají po načtení |
| E | Fyzické vytažení cvičného disku nemění produkční stav ani jeho LED |
| F | Start lekce/série a obnova tréninkové relace v MAIN jsou odmítnuté |
| G | Teleport před dalším fyzikálním snímkem, načtení vnější pozice, menu a zánik scény ukončí trénink |
| H | Opakované přechody i kolísání u dveří; právě jeden přechod na průchod |

Obnovená pracovní mise přijme produkční zásahy, dokončí se a udělí další XP.
Vizuálně prohlédnuty `test-output/training-room-{entry,lesson,exit}.png`.
Windows balíček: `test-output/training-package.log`,68 kontrol, exit0.
Původní obsah katalogů a legacy24 se neměnil. Všech18 sad Test-All PASS, exit0,
bez runtime chyb/varování:65 misí v modelu i UI,21×3 lekcí/1075 kontrol,
336 výukových UI akcí,474 kontrol save a68 nastavení. Poslední kontrola přímé
obnovy po teleportu doplňuje souhrnný běh samostatným headless/MCP ověřením.
Podrobnosti jsou v PROGRESS.md a `test-output/training-test-all.log`.

Datum: 24.10.2026. Engine: Godot4.7.2.stable.official.ed1daf0bf, Windows x86_64.

## Dveře a výrazné vylepšení vizuálu

Dva pevné nástěnné panely ovládají dveře i po zasunutí křídla do stěny.
Bezpečnostní čidlo odmítne zavření do hráče a při vstupu během zavírání znovu
otevře. `door3d.gd`:15/15 headless i samostatné Windows EXE PASS; ověřeno
zaměřením skutečného panelu a opakovaným E z obou stran, nikoli pouze přímým
voláním přepínače. Stejný otevřít/zavřít průchod proběhl přes Godot MCP, errors=[].

Prezentace nyní používá Forward+/Vulkan,4× MSAA, měkké lokální stíny,
SSAO/SSIL, SSR a statickou interiérovou radianci. Původní simulátory a obsah
zůstaly beze změny. Vlastní geometrie zahrnuje zaoblené kovové modely,
perforace, detaily disků, křivky kabeláže, jemné podlahové spáry, strop a stěny,
prosklený pohled do skutečné chodby a detailní pracovní místa. Všech6 monitorů
ve3D čte přímo aktuální GameManager a obnovuje přehled2× za sekundu.

Grafické ověření: servisní průchod39 kontrol PASS, nastavení76 PASS,
ostrost8 PASS včetně4K glyphů a38px SVG. Úsporný OpenGL renderer prošel
stejným34kontrolovým servisním průchodem. Nové Windows EXE+PCK zvládlo
samostatný grafický servis34 kontrol a dveře15 kontrol; oba procesy exit0.
MCP ověřil79 interaktivních objektů, původní konzoli, uložení a návrat.

Benchmark s vypnutým VSync na RTX5060, pohled na hlavní serverovnu:

| Rozlišení | Průměr snímku | FPS | Draw calls | Hlásená VRAM |
|---|---:|---:|---:|---:|
|1920×1080 |3,04ms |329 |282 |471MiB |
|3840×2160 |10,37ms |96 |282 |1390MiB |

Jde o konkrétní měření jedné scény, ne záruku výkonu na jiných počítačích.
Statické díly slučuje MultiMesh (1501 odstraněných samostatných instancí).
ReflectionProbe atlas není používán kvůli [ověřené chybě enginu](https://github.com/godotengine/godot/issues/122498);
odlesky zajišťují SSR a interiérová radiance. Finální grafické logy jsou bez
chyby atlasu a bez úniků GPU textur. Testovací průchod nechá doběhnout poslední
kliknutí ve zvukovém vlákně před ukončením, obdobně jako samotná hra.

Vizuálně prohlédnuty snímky `test-output/visual-server-room.png`,
`visual-rack-close.png`, `visual-nas-fault.png`, `visual-glass-office.png`,
`visual-door-controls.png`, `visual-door-open-control.png` a `visual-academy.png`.
LED vadného disku zůstává viditelná před novým rámečkem, panel dveří nabízí
Zavřít při otevřeném křídle a nová HUD výzva je celá v obraze.

Závěrečný Test-All: všech17 sad PASS, exit0, bez runtime chyb a varování.
Zahrnuje65/65 misí v modelu i UI,21 lekcí ve všech3 režimech (1075 kontrol),
336 výukových UI akcí,474 kontrol save a nové opakované ovládání dveří.
Úplný log je v `test-output/visual-test-all.log`.
Ostatní aktuální důkazy: `visual-capture-final.log`, `visual-benchmark.json`,
`visual-display.log`, `visual-fonts.log`, `visual-package.log`,
`visual-door-package.log`, `visual-compatibility.log` a `visual-build.log`.
Všechny běhy používají izolované SaveManager.path_override a config cesty.

## Přestavba do3D

Nová hlavní scéna `scenes/world/Game.tscn` integruje původní GameManager a UI
se skutečným CharacterBody3D světem. V projektu zůstaly všechny původní scény,
50 misí a21 lekcí; přidáno15 praktických misí51–65. Následující testy používají
výhradně SaveManager.path_override, grafické testy také vlastní konfiguraci.

| Ověření | Výsledek |
|---|---|
| První úplný Test-All po přidání misí |15 sad PASS;65/65 misí v modelu i původním UI;21×3 lekcí,1075 kontrol;336 výukových UI akcí |
| Závěrečný Test-All |Všech16 sad PASS, exit0, bez runtime chyb a varování;65 misí v modelu/UI,21×3 lekcí,474 kontrol uložení a původní regresní sady |
| Physical3D po závěrečném auditu |41 kontrol PASS: identita, backup, hot-swap, kapacita/rozhraní, vytažený slot/save/rebuild, selhání RAID10, síť, napájení, oddělení všech3 režimů |
| World3D |35 kontrol PASS: pohyb a kolize, raycast a skutečné E, dveře a chůze do akademie, režimy vedení, konzole, konkrétní disk a LED; identifikační značka nepřejde do nové relace |
| World playthrough |34 headless /39 GPU kontrol PASS: servisní mise přes skutečné3D cíle, formuláře a potvrzení, výběr náhrady, rebuild a dokončení; fyzický switch port; stěna blokuje interakci; UHD škálování; návrat do kampaně a přímý vstup do15 misí |
| Godot MCP |77 interaktivních objektů; raycast/E/detail/Proxmox formuláře/změna/save/návrat PASS; errors=[] |
| Nastavení obrazu |76 kontrol GPU PASS; všech6 rozlišení včetně4K a upozornění na save |
| Ostrost původního UI |8 kontrol GPU PASS; nativní glyphy a38×38px SVG ve4K |
| Generátory |build_content.py včetně build_extension/world_catalog vytvoří bajtově shodné JSON; původních24 definic a21 lekcí nezměněno |
| Windows balíček |Samostatné EXE+PCK graficky provedlo stejný34kontrolový3D průchod; exit0, log bez chyb |

Závěrečný Test-All se všemi16 sadami (včetně World playthrough) skončil úspěšně.
Poslední dvě opravy menu a izolace zvýraznění navíc ověřily cílené testy
World3D35 a World playthrough34/39 kontrol. Log: `test-output/3d-test-all-final.log`.
Další logy: `3d-test-all.log`, `3d-playthrough-gpu-final.log`, `3d-package.log`,
`3d-display-gpu.log`, `3d-quality-gpu.log` a `3d-build-final.log`.

Vizuálně prohlédnuty GPU snímky serverovny, akademie, administračního rozhraní
a servisního formuláře ve4K. Modely jsou vlastní procedurální geometrie;
žádné externí licence/assety nebyly přidány. Statické díly používají sdílené
materiály a MultiMesh (1005 sloučených instancí); interakce/kolize/LED zůstávají
samostatné. Výměna disku je změna simulace, nikoli jen animace. Obnova RAID je
záměrně zrychlený laboratorní čas po50%; síť zůstává připravenou topologií.

## Následná oprava prázdného Nastavení

Po otevření stránky se zobrazovala pouze hlavička: kořenový VBox stránky
neměl vertikální roztažení a jeho ScrollContainer dostával nulovou výšku.
Opraveno nastavením `SIZE_EXPAND_FILL` na kořeni stránky.

Regrese nyní kontroluje plochu ovládacích prvků, hranice viewportu a ořezání
všemi nadřazenými scroll kontejnery. Před opravou selhalo27 kontrol, po opravě
`display_settings.gd` prošel68/68 headless a76/76 na GPU. Zahrnuto všech6
rozlišení, otevření skutečným tlačítkem a kombinace se save upozorněním v720p/4K.
Graficky prohlédnuty snímky `settings-720p.png` a `settings-warning-3840.png`.
Znovu prošly `ui_safety.gd`31/31 a `render_quality.gd`8/8; glyph oversampling
i38×38px DPITexture ve4K zachovány. MCP otevřel Nastavení a vrátil `errors=[]`.
Save i config testů zůstaly oddělené od hráčových souborů. Níže uvedený úplný
Test-All je z předchozí etapy; tato úprava ověřuje rozložení cílenými testy.
Windows EXE+PCK v `build/` byly aktualizovány a samostatně graficky ověřeny:
skutečné tlačítko otevřelo viditelné ovládací prvky v720p, kód0, čistý log
`test-output/settings-package.log`; prohlédnut snímek `settings-packaged.png`.

## Opravy po auditu: relace, ukládání a formuláře

Samostatné auditovací reprodukce byly převedeny do standardních regresí
v `tests/`; všechny tři nové skripty spouští také `tools/Test-All.ps1`.
Ověřuje se skutečný úspěch zápisu, nejen úspěch operace v simulátoru.

| Kontrola aktuálních oprav | Výsledek |
|---|---|
| `session_safety.gd`: restart série, indexy, undo a kolize `vmbr0` | 112/112 PASS |
| `save_safety.gd`: chyby souborů, struktura, migrace, zápisy všech misí | 387/387 PASS |
| `ui_safety.gd`: skutečná tlačítka, koncepty a stav uložení | 31/31 PASS headless i GPU |
| `display_settings.gd` na GPU: všech6 rozlišení, fullscreen, F11 | 49/49 PASS |
| `render_quality.gd`: skutečné pixely textu a DPITexture ve4K | 8/8 PASS |
| Godot MCP: izolovaná testovací scéna | Spuštěna, debug `errors=[]` |
| Úplný závěrečný `Test-All.ps1` | 13/13 sad PASS, kód0, bez runtime chyb a varování |
| Všechny mise v modelu i přes formuláře | 50/50 PASS, shoda původních24 definic PASS |
| Všechny lekce ve všech3 režimech včetně zápisů | 1075/1075 kontrol PASS |
| Lekce přes UI ve všech3 režimech | 336 akcí,0 chyb |
| Generátor a dřívější regrese | 199 +88 +35 kontrol PASS |
| Nastavení obrazu headless | 41/41 PASS |
| Přegenerovaný Windows EXE+PCK, grafické spuštění bez editoru | PASS, kód0, čistý log |

Regrese přechodů zahrnují kampaň → sérii → lekci → změněnou kampaň → obnovenou
sérii → obnovenou lekci → kampaň, všechny3 režimy lekcí a opakované vytvoření
GameManageru jako po restartu aplikace. Testují i přímé obnovení relace mimo UI.
Restart druhé úlohy zachovává předchozí výsledek, frontu, pozici a odloženou
kampaň. Neplatné indexy ponechají paměť i uložený soubor beze změny.

Chyba zápisu je vyvolána adresářem v izolované cestě dočasného souboru.
Zásah i dokončení ticketu přesto uspějí v paměti, vracejí `saved=false`,
poslední platný soubor zůstane beze změny a opakování uloží aktuální stav.
UI nabídne opakování a zablokuje neúspěšný návrat s uložením i ukončení.
Vadné JSON a strukturální varianty (včetně `scores:null`, chybného ID,
indexu série, kroku lekce a chybějící větve) nevyvolají chybu startu a nejsou
automaticky přepsány. Výslovná obnova uchová přesné původní bajty v záloze.
Schema1 fixture včetně dodatečné VM bez nových polí ověřuje XP, normalizaci
skóre, infrastrukturu a přesnou migrační zálohu. Testují se i desetinné klíče
lekcí ze staršího schema2 a záloha posledního platného souboru.

Graficky prohlédnuty `test-output/safety-draft-720p.png`, `safety-draft-4k.png`,
`safety-save-failed.png` a `safety-invalid-save.png`: skutečná rozepsaná RAM6144,
správné zvýraznění pole, čitelné upozornění, opakování zápisu a posuvné menu.
Test ověřuje i odeslání zachovaného nepotvrzeného čísla, koncepty různých VM,
disky, nabídky, checkboxy a terminál. Ostrost hran zvětšeného/nativního atlasu:
menu0,197/0,402, rack0,180/0,412, terminál0,123/0,257; SVG má38×38px.

Hráčův save ani nastavení nebyly zapisovány. Testy používají vlastní
`SaveManager.path_override`; grafické testy a MCP i `DisplaySettings.path_override`.
Obsahové katalogy, generátory a původních24 misí zůstaly nezměněné.
Koncepty a undo jsou úmyslně pouze v paměti relace; po restartu aplikace
se obnovuje potvrzená konfigurace. Automatická oprava vadného souboru ani
simulace fyzického výpadku disku či napájení nejsou součástí těchto testů.

Úplný závěrečný log je v `test-output/fixes-test-all-final.log`, grafický běh
nových UI regresí v `fixes-ui-graphics.log`. Windows build je v `build/`;
samostatný balíček byl testován externím skriptem s vlastními save/settings
cestami, včetně restartu série a obnovení VLAN39 v kampani. Logy sestavení
a balíčku: `fixes-build.log`, `fixes-package-engine.log`; prohlédnut snímek
`package-safety.png`. Test-output i sestavené binární soubory jsou ignorované
Gitem; samotné regrese a jejich zapojení do Test-All jsou verzované.

Následují záznamy předchozích etap.

Oprava ostrosti4K: `tests/render_quality.gd` prošel8 grafickými kontrolami.
Test porovnává skutečně vykreslené pixely při3840×2160, nejen velikost okna
či framebufferu. Ukazatel kontrastu hran původního zvětšeného atlasu / nativního
vykreslení byl0,197/0,402 pro nadpis menu,0,180/0,412 pro popisky racku a přibližně
0,125/0,261 pro systémový font terminálu.16px SVG ikona dostala skutečnou GPU
texturu38×38 při měřítku2,4. Zachováno přepínání rozlišení a stav simulace.
Grafický test nastavení znovu49/49 PASS a první interaktivní VM lekce PASS.
Všech50 misí znovu prošlo UI smoke testem včetně potvrzovacích dialogů bez
chyb. Aktualizovaný Windows balíček spuštěn bez editoru, kód0, čistý log;
MCP hlásí prázdný seznam chyb. Výřezy porovnání jsou v místním test-output/.

Dodatečné ověření nastavení obrazu a ukončení: `tests/display_settings.gd`
prošel graficky49 kontrolami a headless41 kontrolami. Grafický test skutečně
vykreslil všech6 nabízených rozlišení až3840×2160, přepnul nativní fullscreen
i okno, ověřil F11, načtení uložených voleb a viditelnost výukového cíle ve4K.
Samostatný běh vyvolal skutečné tlačítko Ukončit hru a skončil s kódem0 bez
chyb i varování. Ověřeno zachování rozehrané konfigurace. Znovu prošla první
interaktivní VM lekce a všech88 regresních kontrol. Předchozí kompletní průchod
obsahu je uveden níže; toto je cílená kontrola změn obrazu a menu.

| Kontrola | Výsledek |
|---|---|
| Godot MCP: verze, metadata, tvorba scény centra a spuštění | Provedeno; monitor později vrací „No active Godot process“ |
| Přímý grafický start Godotu se skutečným menu | PASS, exit code0, bez chyb v samostatném logu |
| První kompletní mise před rozšiřováním | PASS |
| Stavové dokončení všech50 misí | 50/50 PASS |
| Shoda původních24 definic s výchozím checkpointem | PASS |
| UI: formuláře, rizikové dialogy, cíle a předání ticketu | 50/50 PASS |
| UI: dobrovolné otázky a navazující vysvětlení | 50/50 PASS |
| Lekce: Učím se / Procvičování / Zkouška | 21×3 PASS,949 kontrol |
| Lekce přes skutečné UI a navigaci | 21×3 PASS,336 akcí |
| První9kroková lekce, nesprávná RAM a obnova rozpracovaného kroku | PASS |
| Generátor, kombinace filtrů, migrace save a doporučení | 199 kontrol PASS |
| Obměny generátoru ve20 seeded sériích | 77 odlišných konfigurací |
| Regrese: cíle, RAID, sítě, parser, rizika, save/load a XP | 88 kontrol PASS |
| Rozšíření: LXC, VSS, VHDX, Replica, spare a kvóty | 35 kontrol PASS |
| Vizuální kontrola1440×900 a1280×720 | PASS |
| Samostatný Windows engine + PCK | PASS, exit code0 |
| Git whitespace check | PASS |

Automatické UI testy vyplňují skutečné Control formuláře a vyvolávají jejich
signály; rizikové operace procházejí potvrzovacími dialogy. Nejde o ruční
odehrání všech misí. Snímky skutečně renderovaných obrazovek jsou v místním
ignorovaném `test-output/`.

Vedená výuka byla zkontrolována při1280×720: rámeček a šipka míří na RAM
skutečného VM formuláře. Praktický i zkouškový režim nepoužívají overlay;
zkouška nemá přímé nápovědy. Ukládání schema1→2 zachovává XP, skóre, chyby,
achievementy, rozpracovaný ticket i jeho infrastrukturu a vytváří v1 zálohu.
Náhodná série se obnoví ve stejné pozici včetně rozehraného stavu.

Testy ověřují i chyby: RAID10 ve stejném páru, libovolné dvě chyby RAID6,
chybné VLAN/DNS, odlišné možnosti External/Internal/Private, plný pool,
nesprávný slot/serial, původní RAW disk, nechráněnou cache, multiwriter LUN,
konfliktní obnovu, chybějící fencing, zámek VM, selhání VSS a shell injection.
Save/load se zkouší v oddělených testovacích souborech.

Windows balíček není standardní export přes exportní šablonu. Používá
plný lokální Godot engine a vyexportovaný PCK. Rozsah laboratorní simulace
a neimplementované úplné průvodce Ceph/CSV popisuje README.md.

Opakování všech testů:

```powershell
./tools/Test-All.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
```
