# Datacenter Academy — stav vývoje

## Přestavba do 3D — etapa 1 (2026-10-24)
- Výchozí čistý commit `862f8da`; záložní Git tag `pre-3d-20261024` zachovává celou funkční 2D hru.
- Prozkoumány všechny scény a rozhraní GameManager, InfrastructureSimulator, RAIDSimulator, síť, ukládání, tutoriály a generátory obsahu. Konzole jsou Control prezentace nad společným RefCounted modelem; budou vloženy do nové 3D herní scény bez nahrazování simulátorů.
- Plán: CharacterBody3D + RayCast3D, opakovatelné interakce a procedurální prostředí, stejné konzole na monitorech, fyzické operace přes společný model, samostatná místnost akademie a 15 doplňkových misí. Původní scény i prvních24 definic zůstanou zachované.
- Godot MCP ověřil projekt 4.7.2 a vytvořil základ scény `scenes/world/Datacenter3D.tscn`. Veškeré běhy a testy budou používat SaveManager.path_override a oddělenou konfiguraci.

## Přestavba do 3D — etapy 2–3 (2026-10-24)
- Nová vstupní scéna `scenes/world/Game.tscn` integruje původní UI a stejný GameManager. Původní `scenes/main_menu/Main.tscn` a všechny konzole zůstávají funkční a samostatně testovatelné.
- CharacterBody3D: WASD, Shift, myš s omezením náklonu, kolize, RayCast3D do3,2m, E, zvýraznění cíle, baterka F. Esc pauza/citlivost/volný kurzor; Tab stavové cíle. Při práci na monitoru je chůze vypnutá, návrat zachovává formulářové koncepty.
- Skutečná procedurální serverovna, první rack/PVE-01, pracovní stůl s Proxmox konzolí a monitor VM. Vše čte společnou infrastrukturu; nevzniká kopie simulace.
- Import Godot4.7.2 bez chyb. `tests/world3d.gd`:12 kontrol PASS včetně fyzikální chůze a kolizí, skutečného raycastu a vstupu E, otevření původních formulářů, zásahu a uložení. Testovací scéna `tests/WorldMCP.tscn` nastaví obě izolované cesty ještě před vytvořením GameManager.

Datum: 2026-10-24. Nový projekt Godot 4.7.2, pracovní adresář IT_support.

## Viditelnost obsahu Nastavení po otevření (2026-10-24)
- Opravena regrese z úpravy kontejnerů: kořen stránky `draw_settings()` se v nadřazeném VBox neroztahoval na dostupnou výšku. ScrollContainer měl nulovou výšku a zobrazovala se jen hlavička. Stránka nyní používá `SIZE_EXPAND_FILL`.
- `tests/display_settings.gd` nově ověřuje skutečnou plochu a ořezání přepínače fullscreen, rozlišení a potvrzovacího tlačítka, nikoli jen existenci Control. Kontroly běží při otevření, ve všech6 rozlišeních a s upozorněním na save v720p i4K. Před opravou27 selhání, po opravě68/68 headless a76/76 GPU PASS.
- Graficky prohlédnut obsah v `test-output/settings-720p.png` a `settings-warning-3840.png`. Test zachování konceptů `ui_safety.gd`31/31 PASS; pixelový `render_quality.gd`8/8 PASS. MCP otevřel Nastavení skutečným tlačítkem a ověřil viditelnost panelu, `errors=[]`. Použity výhradně testovací save/config cesty.
- Windows EXE+PCK v `build/` přegenerovány. Samostatný balíček otevřel Nastavení tlačítkem a ověřil všechny3 viditelné ovládací prvky v720p, kód0; prohlédnut `test-output/settings-packaged.png`, log `settings-package.log` bez chyb.

## Cílené opravy ochrany postupu (2026-10-24)
- Restart je řízen typem relace přes `restart_current()`. Náhodná úloha obnoví jen svůj scénář; fronta, pozice, dosavadní výsledky i odložená kampaň zůstávají zachované. Neplatný index mise se odmítá před změnou paměti i souboru.
- Přechody používají společné odložení kampaně, lekce či série. `resume_random()` i přímé `restore_session()` nejprve zachovají aktuální relaci. Opakovaný návrat do již aktivní kampaně ji nerestartuje.
- Undo se čistí při startu, obnovení a změně režimu. Prázdné undo je v UI neaktivní. Historie se mezi misemi a relacemi nepřenáší.
- `apply()` a `complete()` rozlišují úspěch zásahu (`ok`) a zápisu (`saved`, `save_error`). Ostatní operace zveřejňují společný stav ukládání. Trvalé upozornění s opakováním zápisu funguje i v menu; návrat s uložením a ukončení při chybě nepokračují.
- Nový `SaveValidator.gd` kontroluje větve, typy, ID, skóre, kroky lekcí, indexy série a shodu scénáře s frontou. Zachována schema1/schema2 včetně starších desetinných klíčů lekcí a skóre. Platné uložené relace mají cache s kontrolou hluboké shody; autosave zbytečně znovu neprochází celé archivované lekce.
- Vadný save se nenačte ani automaticky nepřepíše. Výslovné tlačítko obnovy nejprve zachová původní bajty v `.invalid-*.bak`. Zápis kontroluje chybu po flush i znovunačtený dočasný soubor, ponechává `.last-good.bak` a při selhání nahrazení zkouší obnovit původní soubor. Migrační `.v1.bak` zůstává zachovaná.
- Hyper-V odmítá jméno síťového objektu jiné platformy, konkrétně `vmbr0`; síť a VM zůstávají při odmítnutí beze změny.
- Koncepty formulářů jsou oddělené podle relace, konzole, hostitele, VM a akce. Zvuk, rozlišení a F11 zachovají text, nepotvrzená čísla, nabídky, checkboxy a disky; zachované číslo se při odeslání použije. Zahrnut i rozepsaný terminál a nastavení série. Potvrzený formulář a nová/obnovená relace koncept vyčistí.
- UI má výrazné a srozumitelné hlášení ukládání, bezpečnou obnovu a posuvné menu při chybě načtení. Zachovány oversampling písma, DPITexture ikony, měřítko i původní vzhled.
- Nové standardní regrese: `session_safety.gd` 112 kontrol PASS, `save_safety.gd` 387 PASS, `ui_safety.gd` 31 PASS headless i graficky. Test-All je obsahuje; původní testy misí/lekcí nyní ověřují také úspěšné ukládání.
- Graficky: `display_settings.gd` 49 PASS; `render_quality.gd` 8 PASS, SVG ve4K skutečně38×38px. Prohlédnuty snímky výukové RAM6144 v720p/4K, chyby zápisu i vadného save v menu. MCP spustil izolovanou testovací scénu a vrátil `errors=[]`.
- Úplný závěrečný `tools/Test-All.ps1` PASS, kód0, všech13 sad bez runtime chyb a varování:50/50 misí v modelu i UI,21×3 lekcí (1075 kontrol),336 výukových UI akcí,199 kontrol generátoru,88+35 původních regresí,112+387+31 nových kontrol a41 kontrol nastavení headless. Závěrečný log: `test-output/fixes-test-all-final.log`.
- Windows balíček v `build/` přegenerován. Samostatné EXE+PCK přes externí izolovaný ověřovací skript graficky spustilo konzoli, sérii, restart a návrat ke kampani; uložená VLAN39 zachována, kód0, čistý log. Prohlédnut i snímek balíčku. Build a jeho ověřovací logy jsou v `test-output/fixes-build.log` a `fixes-package-engine.log`.
- Všechny testy používají `SaveManager.path_override`; grafické testy a MCP i vlastní cestu nastavení. Hráčův save ani jeho nastavení nebyly zapisovány. Žádné změny katalogů ani generátorů; prvních24 definic a legacy soubory zůstávají původní.
- Meze: koncepty a undo se neukládají přes restart aplikace. Vadná data se automaticky neopravují; obnova s novým postupem vyžaduje výslovné tlačítko a zálohu. Selhání zápisu je reprodukované skutečnou překážkou v testovací cestě, nikoli zaplněním hráčova disku.

## Ostrá grafika a textury ve4K (dokončeno)
- Opravena příčina rozmazání: framebuffer již měl4K, ale transformace Control zvětšovala malý fontový atlas. Na kořeni UIController je nyní zapnutý oversampling_with_scale; glyphy se rasterizují podle skutečné velikosti na obrazovce včetně racků a samostatného systémového fontu terminálu.
- Nový scripts/ui/VectorIcons.gd dodává škálovatelné SVG/DPITexture ikony pro přepínače, checkboxy, seznamy, SpinBox, Tree a PopupMenu. Nahrazují drobné bitmapové ikony výchozího tématu. Detaily racků mají vyhlazené hrany.
- Poměr16:9, rozlišení1280×720 až3840×2160, fullscreen/F11, save i mise jsou zachovány. Běžná grafika panelů a racků se kreslí z vektorů přímo do cílového rozlišení.
- Nový tests/render_quality.gd testuje skutečné pixely přes GPU: menu/rack/terminál mají oproti zvětšenému atlasu více než dvojnásobný ukazatel kontrastu hran;16px SVG má ve4K vlastní38×38px texturu.8 kontrol PASS. Test vyžaduje grafický renderer, bez --headless; volitelně -- --screenshots.
- Grafický tests/display_settings.gd:49 kontrol PASS; první9kroková lekce tutorial_first PASS. Testy používají oddělené save a config soubory.
- tests/ui_smoke.gd znovu dokončil všech50 misí přes skutečné formuláře a potvrzovací dialogy bez chyb. Aktualizovaný Windows balíček v build/ spuštěn bez editoru: kód0, bez chyb v logu. Godot MCP spuštění a debug errors=[].
- Soubory: UIController.gd, RackView.gd, nový VectorIcons.gd a render_quality.gd, README.md a TEST_REPORT.md. Pro pokračování používat původní projekt, zachovat fontové oversampling a DPITexture; nepřevádět UI na malé rastrové obrázky.

## Nastavení obrazu a ukončení (dokončeno)
- Hlavní menu má tlačítka Nastavení a Ukončit hru. Ukončení i zavření okna nejdříve ukládá rozehraný stav; při chybě uložení zůstává hra otevřená.
- Nastavení: celá obrazovka / okno, F11 a šest rozlišení16:9 od1280×720 do3840×2160 (4K UHD). Volby v samostatném user://display_settings.cfg; hráčův save se nemigruje.
- Viewport skutečně renderuje zvolené rozlišení i ve fullscreen; rozhraní škáluje z1600×900. Okno se na menším monitoru přizpůsobí pracovní ploše.
- Opraveno škálování TutorialOverlay a automatické posouvání ke zvýrazněnému poli. Změna rozlišení zachovává stav mise i lekce.
- Soubory: scripts/core/DisplaySettings.gd, scripts/ui/UIController.gd, scripts/training/TutorialOverlay.gd, project.godot, tests/display_settings.gd, tools/Test-All.ps1, README.md a TEST_REPORT.md.
- Testy: grafický display_settings49 kontrol PASS (všech6 skutečných GPU rozlišení, fullscreen/okno/F11, uložené volby, 4K výukový cíl a skutečné ukončení tlačítkem); headless41 kontrol PASS. tutorial_first PASS a regression88/88 PASS.
- Vizuálně ověřeno menu, nastavení a výukový rámeček ve4K. Testy používají oddělené save/config soubory a nemění hráčovy volby.
- Windows balíček v build/ přegenerován; grafické spuštění EXE bez editoru skončilo s kódem0 bez chyb. Finální start přes Godot MCP má prázdný seznam errors.
- Pokračování: funkce jsou hotové; při dalších změnách obrazu spustit tests/display_settings.gd graficky i headless. Nový test je součástí Test-All.ps1.

## Rozšíření — Tréninkové centrum (dokončeno)
- Výchozí checkpoint:57aa41f; původní24 definice a referenční řešení zmrazeny v legacy_campaign.json / legacy_solutions.json.
- Přidána samostatná scéna centra, TutorialManager/Validator/Overlay a první9kroková lekce vytvoření WEB01.
- Průvodce ukládá skutečnou VM101 postupně: identita, ISO, CPU/RAM, disk, síť, instalace, start a ověření.
- Zvýraznění/šipka, registr UI prvků, přechody rack→uzel→formuláře, obnova cílového panelu.
- Režimy learn/practice/exam; zkouška blokuje nápovědu. Kampaň je odložená zvlášť, kroky i stav lekce jsou uložené.
- Save schema2 přijímá schema1 a před prvním přepisem vytváří zálohu.v1.bak. Číselná ID jsou normalizovaná, aby JSON1002.0 nevytvářelo jiné klíče pokroku.
- Klíčové soubory: scripts/training/*, scripts/simulation/EducationOperations.gd, tools/build_extension.py, data/training/lessons.json, tests/tutorial_first.gd, GameManager.gd, UIController.gd, SaveManager.gd.
- Katalog nyní obsahuje50 misí a21 lekcí (18 povinných + quorum/HA, iSCSI/MPIO a bezpečnost). Původních24 definic zůstává přesně shodných s legacy snapshotem.
- tests/campaign.gd:48/48 PASS. tests/lessons.gd: prvních18 lekcí ve všech3 režimech,838 kontrol PASS;2 bonusové lekce čekají na ověření.
- tests/training_ui.gd: prvních18 vedených lekcí přes101 skutečných formulářových akcí PASS.
- Generátor mění VMID/CPU/RAM/disk/storage, síťové chyby i RAID parametry; scénář vždy nejdřív přehraje v izolovaném modelu a ověří cíle.142 kontrol,71 různých konfigurací PASS.
- Přidány kategorie centra,3 režimy, Moje IT znalosti, doporučení, poslední zkoušky, slovník15 termínů a uložení náhodné série.
- Nové operace zahrnují offline převodHyper-V→PVE, správnou novou Gen2 konfiguraci, CT bind data, boot/ovladače, VSS/AVHDX, bezpečný RAW postup, cache a SAN.
- Ověřeno všech48 základních misí přes UI a20 lekcí ve všech3 režimech přes327 akcí v1280×720. Aktuálně přidány2 bonusové mise49/50 a bezpečnostní lekce1021;50/50 misí prochází stavovým testem.
- Přibylo ověření všech28 kombinací oblasti/obtížnosti, zachování samostatného stavu série a doporučení síťové lekce po chybách VLAN. tests/training_features.gd:199 kontrol PASS.
- README.md aktualizováno; TRAINING.md dokumentuje všechny21 lekce, datový formát kroků, migraci save a generátor.
- Poslední kompletní Test-All.ps1 prošel:50/50 misí v modelu i UI,21 lekcí ve všech3 režimech (949 kontrol),336 výukových UI akcí,199 kontrol generátoru/save,88+35 původních regresí. Vše bez runtime chyb.
- Generátor byl ověřen na77 různých konfiguracích a všech28 kombinacích oblasti/obtížnosti. Návrat ze série/lekce zachovává odloženou kampaň.
- Vizuálně zkontrolováno centrum, profil i skutečné zvýraznění RAM v1280×720; zkouška bez zvýraznění a nápovědy.
- README.md, TRAINING.md a TEST_REPORT.md obsahují aktuální ovládání, rozšiřování, testy a meze simulace.
- Windows PCK byl přebalen s50 misemi a21 lekcemi; samostatné EXE spuštěno bez editoru, exit code0 a prázdný chybový log. Balíček zahrnuje README, TRAINING a TEST_REPORT.
- Rozšíření je funkční; nezbývá známý herní blokátor. MCP umí scénu vytvořit a start vyvolat, ale jeho procesní monitor v tomto prostředí po startu neudržuje aktivní proces. Grafický start i úplné testy jsou navíc ověřené přímo Godotem.
- Při dalším vývoji navazovat na tools/build_extension.py + extension_catalog.py a EducationOperations.gd. Původních24 misí neměnit; jejich shodu hlídá campaign.gd. Testovat přes tools/Test-All.ps1, testovací save musí zůstat oddělené.

## Zdroje a nástroje
- Godot MCP ověřen: 4.7.2.stable.official.ed1daf0bf; create_scene, add_node, run_project, get_debug_output, stop_project.
- Všechny čtyři Notion stránky načteny; úplné lokální kopie v data/knowledge/notion_*.md.
- Skripty a data se upravují soubory, scény a běh se průběžně ověřují přes MCP.

## Hotovo a ověřeno — etapa 1
- Menu, stylizovaná klikací serverovna, ticket s cíli a stavové konzole.
- Oddělený model infrastruktury, bezpečná validace a ukládání do user://.
- Mise 1: firmware, HBA, UPS, konzole, management síť, diagnostika a ověření.
- Godot headless import bez chyb; tests/stage1.gd PASS včetně odmítnutí nesprávného postupu.
- Projekt spuštěn přes Godot MCP; čtení debug výstupu.

## Hotovo a ověřeno — etapa 3
- 88 regresních kontrol cílů/RAID/sítě/terminálu/bezpečnosti/save/load/XP a 35 dalších kontrol: celkem123 PASS.
- 24 misí znovu přes UI včetně24 dobrovolných kontextových otázek, všechny PASS.
- Vizuální průchod skutečně renderovaným menu, konzolemi, serverovnou a mapou při1440×900 i1280×720.
- Opravena chyba exkluzivních oken při přechodu z otázky do vysvětlení; opakovaný průchod bez runtime chyb.
- 50 článků Akademie z úplných zdrojů, dynamický výběr vlastních VMID/switchů a strom hostitelů/VM.
- Přidána Replica, všechny tři VHDX alokace, příprava datového disku uvnitř VM, skutečné chování kvót a automatický hot spare.
- README.md popisuje ovládání, architekturu, přidání mise, testy, sestavení a konkrétní limity simulace.
- Windows: exportní šablony nejsou nainstalované. Funkční přenosný balíček tvoří plný místní engine + PCK v build/; spuštění bez editoru ověřeno.

## Závěrečné ověření
- Poslední kompletní Test-All.ps1: první etapa PASS, všech24 misí PASS, 88 regresí PASS, 35 rozšířených kontrol PASS a všech24 misí + otázek přes UI PASS; bez runtime chyb.
- ObjectiveEvaluator používá bezpečné typové porovnání; počáteční Array proti cílovému String už nezpůsobí pád. Pět nových regresních kontrol ověřeno.
- Finální Windows PCK přegenerován; build/ITSupportSimulator.exe spuštěn samostatně bez editoru, exit code0, bez chyb v logu.
- Projekt znovu spuštěn přes Godot MCP. Git diff --check bez chyb.
- Vývojová pozice z první etapy byla rozpoznána a archivována jako academy_development_stage1.json; žádný test nepřepisuje hráčův postup.

## Hotovo a ověřeno — etapa 2
- 24 konkrétních datových misí (8 Proxmox, 8 Hyper-V, 8 storage).
- Sdílené konfigurace VM, síť L2/IP/DNS/aplikace, PBS backup/restore, QDevice/fencing/HA.
- Hyper-V role, VMMS, tři typy switchů, Gen2, Dynamic Memory, VHDX/guest FS, checkpoint/merge, migrace.
- Fyzické sloty/serial, výběr členů RAID, kapacity RAID0/1/5/6/10, ZFS/Spaces, rebuild, Disk Management, SMB/FSRM a iSCSI/MPIO.
- Bezpečný parser Linux/PowerShell příkazů, 50 článků z úplných Notion příruček, statistiky, XP, trénink a undo.
- tests/campaign.gd: všech 24 misí PASS; tests/ui_smoke.gd: všech 24 misí přes formuláře a dialogy PASS.
- Testy UI ukládají do odděleného academy_test_ui.json, ne do hráčovy pozice.

## Zbývá
- Žádná blokující práce pro hraní24 misí. Omezení a náměty dalšího rozšíření jsou uvedené níže a v README.

## Možné další rozšíření (není součást hotového laboratorního modelu)
- Kompletní konfigurační průvodci Ceph, Failover Cluster/CSV a převod VM mezi platformami.
- Plná kalendářová historie PBS chunků/retence a periodické síťové přenosy Replica.
- Libovolná topologie serverovny a obecný síťový zásobník; nyní jsou podsítě a hostitelé záměrně pevní.
- Standardní Windows template export a instalátor; přenosné EXE nyní používá plný181MB engine.

## Pokračování
Nejdřív přečíst tento soubor, README a existující skripty. Nevytvářet projekt znovu.
