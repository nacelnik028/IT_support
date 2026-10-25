# Datacenter Academy — stav vývoje

## Oprava tutoriálu v novém UI (2026-10-25)
- Reprodukovány tři chyby skutečným klikáním (před opravou 3 selhání ze 6 kontrol): klik na již vybraného hostitele neemitoval item_selected; kontext instruktora měl nulovou výšku; Zobrazit potřebný panel kontext nezavřelo, takže formulář zůstával skrytý. Předchozí testovací adaptér první problém obcházel ručním emitováním signálu stromu.
- Strom nyní potvrdí výběr také opětovným kliknutím nebo Enterem. Kontext instruktora i ticketu vyplní dostupnou výšku. TutorialPresentation směruje skutečné cíle do sekcí a operací nového UI; návrat od instruktora otevře konfiguraci a obnovení posledního kroku VM otevře shrnutí se Start/Ověřit.
- Nad formulářem zůstává kompaktní aktuální instrukce a chyba kroku. Zvýrazňuje se konkrétní operace nebo sekce; krátké dorovnání po dokončení layoutu neschová cíl obnoveným posuvem a dále nechává uživateli volný posuv. Koncepty mají přednost a samotná navigace neprovádí operace ani nepotvrzuje výukové kroky. Vedení platí pouze pro Učím se.
- Nový tutorial_navigation.gd: 700 kontrol PASS headless, všech 21 vedených lekcí bez open_action či nastavování page/tab v testu; skutečné vstupy do stromu, sekcí a formulářů, potvrzení přes skutečné tlačítko dialogu. Zahrnuje Enter, chybnou RAM, obnovu posledního kroku, koncept, posuv, 720p/1080p/4K, zákaz vedení v dalších režimech a zachovanou kampaň. Součást Test-All, aktuálně 22 sad PASS (exit 0, bez runtime chyb/varování), včetně 65 misí, 21×3 režimů, 336 výukových UI akcí a 474 kontrol save. Log tutorial-test-all.log.
- Doplněný Godot MCP test prošel raycast/E na skutečný cvičný server, otevření managementu, klik na předvybraný uzel, instruktora a návrat k viditelnému průvodci; errors=[]. Snímky tutorial-recovered-identity-720.png, tutorial-summary-720.png a tutorial-world-recovered-720.png skutečně prohlédnuty. GPU a samostatný balíček se doověřují před závěrečným záznamem.
- README/TRAINING popisují nové ovládání. Definice misí/lekcí, generátory ani legacy soubory se nemění. Všechny běhy mají oddělené save i nastavení.

## Závěrečné ověření a Windows balíček (2026-10-25)
- Aktuální tools/Test-All.ps1: všech 21 sad PASS, exit 0, bez runtime chyb a varování. Nové sady platform_context 396, console_ux 60 a world_ui 27 kontrol. Zachováno 65/65 misí v modelu i UI, 21 lekcí ve všech 3 režimech (1075 kontrol a 336 UI akcí), 474 kontrol save, 124 relací, 68 oddělení místností a ostatní regrese. Log test-output/ux-test-all-final.log.
- Graficky: display_settings 76 PASS včetně skutečného fullscreen a všech 6 rozlišení, render_quality 8 PASS včetně skutečného 4K framebufferu, ostrosti fontů a SVG 38×38. Zdrojové console_ux 58 GPU a world_ui 27 GPU PASS; konečnou 60kontrolovou variantu konzolí navíc ověřil zabalený EXE. Snímky konzole/nastavení/ovládání v 1280×720, 1920×1080 a 3840×2160, všech kroků průvodce, 130% textu a HUD skutečně prohlédnuté. Logy ux-graphical-final.log, ux-display-gpu-final.log, ux-render-quality.log, ux-world-ui-gpu-final.log.
- Godot MCP: 79 interaktivních objektů, raycast/E/detail/konzole/změna/save/návrat a opakované otevření/zavření dveří PASS, errors=[]. Kompatibilní renderer: world_ui 27 PASS (ux-compatibility.log).
- Aktualizovány build/ITSupportSimulator.exe + PCK. Samostatné grafické spuštění balíčku z build/ pomocí externích izolovaných testovacích skriptů: console_ux 60/60 a world_ui 27/27, oba exit 0 a čisté logy ux-package-console.log / ux-package-world-ui.log. EXE používá jen prostředky PCK; testovací skripty nejsou součástí distribuce. Zachováno zdokumentované balení plným enginem.
- Finálně znovu ověřena reprodukovatelnost build_content, shoda prvních 24 definic proti původnímu 47ea9fa a nezměněný legacy_campaign.json. Všechny běhy mají SaveManager.path_override i oddělený DisplaySettings.path_override; hráčův save/config se nepoužily. README/TRAINING odpovídají novému ovládání, TEST_REPORT obsahuje výsledky. Požadované funkční opravy a nové ovládání jsou dokončené.

## Výuka, HUD, přístupnost a katalogy – etapa P2 (2026-10-25)
- HUD odvozuje název a režim z aktivní relace, velikost stavového/instruktorského panelu z textu. Oznámení vstupu se nezobrazuje přes aplikaci ani aktivní lekci. Společné nastavení se vrací do pauzy; Escape zavírá nejprve dialog, potom kontext a konzoli. Psaní nepohybuje hráčem, HUD respektuje vlastní klávesy a velikost textu.
- První směna má přeskočitelné čtyřkrokové seznámení; znovu je dostupné z pauzy. Menu má jednu hlavní akci. Mise/lekce mají hledání a stavový filtr, články/slovník hledání. Chyba nabízí vysvětlení a související lekci. Zkouška zůstává bez zvýraznění řešení.
- Úspěch, provozní upozornění a odmítnutí mají odlišný textový stav. Sloty rozlišují člena pole, hot spare, volný a vadný disk. Operace nad prázdným uzlem nepředvolí VM jiného hostitele; pevné hostitelské cíle nabízejí přepnutí.
- Generátory nyní upravují mezery pouze v lidských textech nového obsahu. RAM je GiB/MiB se skutečným převodem 1024; diskové kapacity zůstávají laboratorní GB. Zdrojové texty a JSON jsou konzistentní, opakované build_content má stejné hashe; prvních24 misí i legacy soubor zůstaly shodné.
- console_ux rozšířen na60 kontrol (headless PASS), world_ui27 headless/Forward+/Compatibility PASS, ostrost a závěrečný celek se ověřují před balením. Snímky konzole, nastavení a ovládání v720p/1080p/4K i krátkého HUD byly skutečně prohlédnuté. MCP79 objektů, raycast/E/konzole/save/návrat/dveře PASS, errors=[]. MCP test drží kameru nezávislou na přesunech desktopového kurzoru.
- První úplný Test-All21 sad prošel. Při opakování se jednou objevil pouze výstupní audio leak v ui_safety; čtyři verbose opakování byla čistá, cleanup nově čeká také120ms nástěnného času jako ostatní audio testy. Závěrečný běh používá aktuální zdroje a odmítá každé runtime varování.
- Měřeny skutečné předvolby v1920×1080 na RTX5060/Forward+, bez VSync/limitu: přibližně110/75/55 FPS pro Úsporná/Vyvážená/Vysoká v konkrétním pohledu. Nejde o srovnatelný obecný benchmark předchozí etapy ani záruku pro jiné počítače. Log/JSON ux-world-ui-gpu.log / ux-quality-benchmark.json.

## Konzole, průvodce a společné nastavení – etapa P1/P2 (2026-10-25)
- Konzole mají pevný strom, viditelné sekce a výběr jedné operace. Kontext ticketu/instruktora se přepíná tlačítkem nahoře. Navigace, hodnoty formulářů, pracovní kontext a nastavení jsou vyčleněné do komponent.
- Průvodce VM má šest skutečných kroků s uložením do existující simulace, Zpět/Další, shrnutím, instalací, startem a ověřením. Zachované události výuky, žádné skryté souběžné formuláře. Testovací adaptéry ovládají sekce a výběr operací.
- Zachovaný posuv/fokus/kurzor, koncepty po VM/hostiteli/relaci a nepotvrzená čísla. CPU/RAM, Dynamic Memory a síť čtou konfiguraci cíle. Nabídky VM ukazují existující kompatibilní ID/název/hostitele. Formátová validace nemění hodnocení. Potvrzení mají čitelný souhrn.
- Nastavení Obraz/Zvuk/Ovládání/Rozhraní: persistentní hlasitost/ztlumení, citlivost, klávesy s kolizemi a resetem, text 100/115/130 %, potvrzení obrazu do 15 s s návratem. Přidané skutečné grafické předvolby, VSync a FPS limit; navazuje ověření ve 3D.
- Síťový přehled iteruje všechny existující VM, včetně VM101; editace vybírá konkrétní platformu/hostitele/VM.
- Ověřeno: všech 65 misí přes nové formuláře, 336 UI operací všech 21 lekcí ve všech 3 režimech, tutorial_first, ui_safety 32 a display_settings 68 PASS. Nový console_ux: 56 kontrol PASS headless i Forward+/RTX5060, včetně skutečných kliknutí všemi šesti kroky, RAM, fokusu, posuvu po odmítnutí, timeoutu obrazu, konceptů, kláves a VM101 v síti. Izolované save/config.
- Snímky konzole, nastavení a ovládání pořízené v 720p/1080p/4K; 720p a kroky průvodce prohlédnuté, následuje zbývající vizuální a celková regrese. Windows balíček se aktualizuje po závěrečném ověření.

## Kontext operací – etapa P0 (2026-10-25)
- Sdílený OperationContext ověřuje skutečnou platformu zdrojového hostitele u operací Hyper-V i PVE a kompatibilní odlišný cíl migrace/Replica. Obecné napájení, síť a zálohy zůstávají společné; offline převod má samostatnou validaci exportu. Dynamic Memory používá rozpočet skutečného hostitele.
- Nový platform_context.gd: 396 kontrol PASS včetně obou přesných reprodukcí a neměnnosti infrastruktury při odmítnutí. campaign.gd: všech 65 misí PASS, legacy24 beze změny. Izolované save/config cesty. Následuje přepracování prezentace konzolí.
## Audit a zadání dalších úprav (2026-10-25)
- Na žádost uživatele provedena kontrola dokumentace, UI, simulace, výuky, nastavení, 3D ovládání, testů a distribuce. Připraveno samostatné zadání `PROMPT_PRO_AI.md` s prioritami P0–P3. Tato etapa mění pouze dokumentaci; opravy hry jsou zadáním pro navazující implementaci.
- Na izolovaném modelu reprodukovány chybějící kontroly platformy: Hyper-V `memory` přijme vypnutou PVE VM100 a `live_migrate` ji přesune přímo z PVE-01 na HV-02. Seznamy VM a zachovaný `selected_vm` dovolují nesprávný kontext také v UI. Zadání obsahuje přesné reprodukce a požadavky na negativní regrese.
- Graficky ověřen dlouhý průvodce (6 formulářů, výška obsahu2498 / dostupná615 jednotek UI), reset posuvu1400→0 po `draw_ui()`, nabídky konzolí, Storage, menu, pauza, nastavení a výuka. Zaznamenán také zavádějící HUD „vyber si lekci“ při aktivní lekci, oznámení překrývající nabídku lekcí a pevný seznam VM100/200 v síťovém přehledu. Návrhy vzhledu/přístupnosti jsou v zadání odlišené od reprodukovaných chyb.
- Celý `tools/Test-All.ps1`: všech18 sad PASS, exit0, bez runtime chyb/varování;65/65 misí v modelu i UI,21×3 lekcí (1075 kontrol),336 výukových UI akcí,474 kontrol save a ostatní regrese. Log `test-output/review-test-all.log`. Současné testy uvedené nové chyby platformy nezachycují.
- Godot MCP / `WorldMCP.tscn`:79 interaktivních objektů, raycast/E/konzole/změna/uložení/návrat a opakované ovládání dveří PASS, `errors=[]`. Vlastní grafický audit běžel přes Forward+/RTX5060 v720p; další dřívější snímky byly prohlédnuty jako doplňkový podklad. Nové4K testování ani benchmark se v tomto auditu neprováděly.
- Pomocný skript, snímky a reprodukční log jsou v ignorovaném `test-output/review_capture.gd`, `review-*.png`, `review-capture.log`. Všechny běhy používaly `SaveManager.path_override`; grafické běhy/MCP i oddělený config. Herní kód, katalogy ani Windows balíček nebyly změněny.

## Oddělení serverovny a tréninkové místnosti (2026-10-25)
- `GameModeManager` udržuje jediný režim MAIN/TRAINING. Existující posuvné dveře a oba ovladače zůstaly; nová `TrainingZone` má Area3D/BoxShape3D, prostorovou toleranci hranice 16 cm a průběžnou kontrolu skutečné polohy i před zásahy. Teleport, načtení vnější pozice, menu a zánik scény ukončí trénink.
- `GameManager` má samostatné `main_sim` a `training_sim`. Vstup odloží pracovní ticket, výběr lekce používá sandbox. Produkční i cvičné racky, LED, ventilátory a živé monitory čtou svou instanci. Produkční interakce a dokončení pracovních misí jsou v centru blokované; všechny tři režimy lekcí i náhodné série vyžadují TRAINING.
- Odchod ruší tutorial, kroky, zvýraznění/šipky, otevřené dialogy, koncepty, nesený konektor, undo, závady a dočasné relace. Obnovuje původní ticket včetně konfigurace a fyzického stavu. Výsledky `education.lessons/attempts`, výsledky série, XP, achievementy a kariérní skóre zůstávají. Nová návštěva ani restart hry automaticky neobnoví nedokončenou lekci.
- Přidány požadované české zprávy při vstupu/odchodu a stav „Tréninkové centrum – vyber si lekci“. README/TRAINING popisují nové chování. Katalogy, všech65 misí,21 lekcí i legacy24 zůstaly beze změny; generátory nebylo třeba měnit.
- Nová společná sada `training_rooms.gd` / `TrainingRoomsMCP.tscn`:68 kontrol A–H PASS headless i graficky přes Godot MCP (Forward+/RTX5060, errors=[]). Obsahuje skutečnou chůzi dveřmi oběma směry, všechny3 režimy, poškození cvičného disku a nezávislé LED, uložené výsledky/XP, odmítnutí mimo centrum, načtení vnější pozice i odmítnutí obnovy bezprostředně po teleportu, zánik scény, menu a opakované přechody se stabilitou hranice. Obnovená pracovní mise se opravdu dokončí a udělí další XP. Snímky `test-output/training-room-{entry,lesson,exit}.png` vizuálně prohlédnuty.
- Finální Test-All: všech18 sad PASS, exit0, bez runtime chyb/varování.65/65 misí v modelu i původních formulářích,21×3 lekcí (1075 kontrol),336 výukových UI akcí,474 kontrol save,124 relací,41 fyzických kontrol,35 World3D,15 dveří,34 servisního průchodu,199 generátoru,32 UI safety a68 nastavení PASS. Log `test-output/training-test-all.log`; doplněná poslední kontrola obnovy po teleportu má samostatný headless/MCP průchod68/68. Testy výslovně vstupují do TRAINING; v rámci jedné návštěvy nadále ověřují přepínání relací, po odchodu jejich zrušení.
- Zánik UI nyní výslovně uvolní WAV a přehrávač; headless servisní test nechá zvukovému vláknu80ms skutečného času (simulační čas zde běží rychleji). Podrobný log potvrdil odstranění úniku AudioStreamWAV/Playback. Test-All vypíše kompletní výstup selhávající sady a odmítá také runtime varování.
- Windows EXE+PCK v `build/` aktualizované; stejná sada A–H ověřuje balíček externím izolovaným skriptem, log `test-output/training-package.log`. Dokumentace je přibalená. Všechny běhy používají `SaveManager.path_override` a vlastní config, hráčův save nebyl použit.

## Výrazná vizuální úprava serverovny a akademie — dokončeno (2026-10-24)
- Přechod na Godot4 Forward+/Vulkan,4× MSAA, lokální měkké stíny, SSAO/SSIL a SSR. Nová statická interiérová radiance doplňuje odlesky kovu; [chyba enginu ReflectionProbe #122498](https://github.com/godotengine/godot/issues/122498) se obchází bez alokace problematického atlasu. Žádné potlačování chyb v logu.
- Vlastní zaoblené ArrayMesh modely, kovové mikrodetaily z jedné256px normal mapy, perforované panely, servisní úchyty, šrouby, větráky, reálné křivky napájecích/síťových kabelů, podlahové spáry a materiály, stropní konstrukce a nástěnné panely. Prosklená stěna má skutečnou hloubku chodby s teplým světlem.
- Pracoviště mají detailní klávesnice, myši, židle a počítačové skříně.6 skutečných3D monitorů zobrazuje živá data stejného GameManager přes SubViewport (obnova2× za sekundu), původní administrační aplikace zůstávají celé funkční. LED disků jsou před novým rámečkem, aby zůstaly viditelné.
- Upraven HUD: čitelné panely, kontextová výzva uprostřed dole a zaměřovač s odezvou. Označení pracovišť je fyzicky připevněné ke stěnám. Přidané detaily nevytvářejí kolize v původních uličkách; dveře mají stále pevné panely z obou stran.
- Průběžně ověřeno: door3d15 PASS, world3d35 PASS, world_playthrough34 headless/39 GPU PASS. GPU snímky `test-output/visual-{server-room,rack-close,glass-office,door-controls,academy}.png` prohlédnuty. Opraveny také rozměry nové HUD značky a výzvy po vizuální kontrole.
- Benchmark na místní RTX5060, bez VSync: přibližně329fps v1080p a96fps ve4K při pohledu na hlavní serverovnu;282 draw calls,1501 sloučených statických instancí. Jde o měření konkrétní scény a sestavy, ne obecnou záruku FPS. Skript `tests/visual_benchmark.gd`, log/JSON v test-output.
- MCP79 objektů, konzole/save/návrat a opakované E na pevném ovladači otevřít/zavřít PASS, errors=[]. Nové EXE+PCK v build/ zvládlo34kontrolový servisní průchod i15kontrolový test dveří; exit0, čisté GPU logy. Nastavení76 GPU a ostrost8 GPU PASS. OpenGL varianta také34 PASS. Poslední kliknutí v testu se nechává doběhnout ve zvukovém vlákně před ukončením.
- Finální Test-All: všech17 sad PASS, exit0, bez runtime chyb/varování.65/65 misí v modelu i UI,21 lekcí ve všech3 režimech (1075 kontrol),336 výukových UI akcí a474 kontrol save. Log `test-output/visual-test-all.log`. Aktuální dokumentace je zkopírovaná do build/; EXE+PCK obsahují nový vizuál i opravu dveří.
- Katalogy ani původní mise/lekce nebyly měněny. Všechny běhy měly izolované save/config cesty. Spouštění zůstává F5 nebo build/ITSupportSimulator.exe. Pro další vizuální práci navazovat na WorldVisuals/Geometry/MonitorDisplay a grafické visual_capture/visual_benchmark; ovládání dveří hlídá door3d.gd.

## Oprava opakovaného ovládání dveří (2026-10-24)
- Dveře akademie mají dva pevné nástěnné ovladače: v serverovně i uvnitř akademie. Křídlo se může zasunout do stěny, ovládání zůstává přístupné přes raycast/E a nabízí otevření nebo zavření podle aktuálního stavu.
- Bezpečnostní čidlo kontroluje skutečný prostor průchodu; hráč vedle tlačítka už zavření neblokuje. Obsazený průchod ukáže vysvětlení a vstup do průchodu během zavírání dveře znovu otevře.
- Nový `tests/door3d.gd`:15 kontrol PASS (oba směry, opakované E, pevná poloha ovladačů, čidlo před zavřením i během pohybu). Test zahrnutý v Test-All. Následuje požadované výrazné vylepšení vizuálu, bez změn simulačního obsahu a katalogů.

## Přestavba do3D — dokončené etapy1–9 (2026-10-24)
- Etapy1–9 implementované, otestované a uložené v Gitu. Finální scéna `scenes/world/Game.tscn`; zachováno původních50 misí/21 lekcí a doplněno15 praktických misí. Procedurální serverovna i akademie jsou skutečné3D, administrace používá původní UI a společný model.
- Akademie má nyní také vlastní funkční fyzický switch, servisní skříň a ZFS sloty. V produkční3D hře fyzické zásahy vyžadují přístup k zařízení; pomocné nové formulářové popisy zůstávají jen v samostatném původním UI pro ověření všech akcí.
- Závěrečný audit: změna konfigurace zneplatní předchozí přejímku, odpojený PBS kabel blokuje backup/restore, odpojený uplink dovolí lokální start VM a výpadek se projeví při síťovém ověření. Start/restart HV respektuje automatické spuštění hypervisoru.
- Physical3D41 PASS; World3D35 PASS; World playthrough34 headless/39 GPU PASS. MCP77 objektů, raycast/E/Proxmox/save/návrat PASS, errors=[]. GPU nastavení76 PASS a ostrost8 PASS. EXE+PCK v build/ provedlo externí izolovaný34kontrolový průchod graficky, exit0, čistý log `test-output/3d-package.log`.
- Doplňkové regrese závěrečného auditu: identifikační značka disku se nepřenáší do nové lekce (včetně zkoušky); tlačítko Kampaň po volném tréninku obnoví běžné odemykání a XP. Porovnání proti862f8da potvrdilo shodu všech původních50 misí, jejich50 referenčních řešení i21 lekcí.
- Závěrečný Test-All: všech16 sad PASS, exit0, žádné runtime chyby ani varování.65/65 misí v modelu i UI,21 lekcí ve všech3 režimech (1075 kontrol),336 výukových UI akcí,474 kontrol save a původní regrese. Log `test-output/3d-test-all-final.log`; následné cílené testy posledních dvou oprav35/34 headless a39 GPU PASS. Hráčův save ani config nebyly použity.
- Windows EXE+PCK v `build/` jsou aktualizované, samostatně ověřené a doplněné aktuální dokumentací. Spuštění: F5 v původním projektu nebo `build/ITSupportSimulator.exe`. Menu nabízí pokračování ve3D i přímý přístup k15 novým úkolům ve volném tréninku.
- Pro další obsah navazovat na `tools/world_catalog.py` → extension_catalog/build_extension/build_content; katalogy byly ověřeny jako reprodukovatelné. Při změnách3D spouštět také world3d/physical3d/world_playthrough a grafický průchod. Známé meze: vlastní stylizované procedurální modely, připravená topologie, laboratorně zrychlený rebuild. Žádný známý blokátor hraní.

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

## Přestavba do 3D — etapy 4–5 (2026-10-24)
- Čtyři racky,6 zařízení se skutečnými ID, NAS s8 sloty,2 ZFS sloty, SW-CORE s12 fyzickými porty, napájecí a síťové konektory, servisní skříň,2 počítače, monitoring VM/polí/kapacity. Vlastní sdílené procedurální modely, kovové materiály, perforace, kabelové žlaby, ventilátory a chlazení.
- Nové PhysicalOperations mění společný model: bezpečné napájení, kabely/obsazenost portů, kontrola identity/backup/hot-swap, vytažení, nošení a vložení kompatibilního disku. Vytažení zdravých členů opravdu snižuje redundanci či vyřadí pole. Náhrada používá StorageOperations.replace_disk a původní RAIDSimulator/rebuild, včetně uložených50/100% kroků.
- Síťové sondy a start VM respektují fyzické připojení a dostupnost NAS. LED zařízení i jednotlivých disků se synchronizují; prázdné sloty mají změněnou geometrii. Konektor lze odnést ke konkrétnímu portu switche.
- Stav fyzických zařízení, inventář, rozpracovaná výměna a poloha hráče jsou součástí každé uložené relace. SaveValidator kontroluje jejich strukturu/ID/rozsahy. Starší save získává výchozí hodnoty bez změny schématu2. Generátor `tools/world_catalog.py` je zapojený do build_extension/extension_catalog.
- `tests/physical3d.gd`:38 PASS, včetně malého/nesprávného disku, hot-swap, obnovy prázdného slotu i rebuild po restartu, skutečného selhání RAID10, síťového výpadku a oddělení všech3 režimů lekcí od kampaně. `tests/world3d.gd`:12 PASS. Grafický start/GPU a MCP ověřeny na první etapě; zaznamenané nepoužité destination už má návaznost a bude směrovat do akademie.

## Přestavba do 3D — etapa 6 (2026-10-24)
- Připojena skutečná samostatná místnost IT Training Academy, posuvné dveře s kolizí, tři laboratorní racky, RAID stanoviště se stejnými sloty, cvičné počítače, místo pro zkoušky a virtuální instruktor. Vstup pěšky i z hlavního menu/pauzy.
- Všech21 definic lekcí a dosavadní výsledky zůstaly původní. Fyzický příchod se validuje vzdáleností hráče, E na správném serveru předává původní server_selected. Výběr uzlu a konfigurace se nadále ověřují skutečnými událostmi a stavem konzolí.
- Učím se má zlatý 3D rám, směr/vzdálenost a instrukce. Procvičování a Zkouška neukazují správný cíl; zkouška zachovává původní zákaz nápovědy. Laboratorní stanice vyžadují samostatnou výukovou relaci, takže návštěva místnosti nezačne měnit kampaň.
- `tests/world3d.gd`:31 PASS: původní FPS kontroly, zaměření dveří, otevření přes E a skutečná chůze do sousední místnosti, všechny3 režimy, validace příchodu/serveru, návrat z konzole, cílení konkrétního disku a synchronizace LED. Původní baseline Test-All doběhl bez chyb (50 misí/21×3 lekcí); log `test-output/3d-baseline.log`.

## Přestavba do 3D — etapa 7 (2026-10-24)
- Přidáno15 praktických misí51–65 v `tools/world_catalog.py`: inventář racku, identifikace LED/serial, RAID hot-swap, odpojený kabel, konkrétní switch port, VLAN v UI, vypnutý hostitel, SATA náhrada ZFS, storage obchůzka, instalace PVE, bezpečný restart, nová VM a fyzický monitoring, kapacitní incident, výpadek napájení a přejímka.
- Cíle kontrolují stav zařízení a služeb; monitoring ukládá skutečně přečtené VM a jejich stav. Přidány referenční postupy včetně administrátorských formulářů. Generování navazuje na oba původní generátory. Definice21 lekcí, legacy24 i jejich řešení zůstaly beze změny.
- Menu umožňuje přímo vybrat15 nových situací přes volný trénink a filtr3D praxe; kampaň zachovává postupné odemykání a XP. Nové fyzické testy jsou součástí Test-All.
- Campaign65/65 PASS; Save safety474 kontrol PASS včetně každého kroku všech65 misí. Physical3D38 PASS, World3D31 PASS. Kompletní Test-All dále běží do původních výukových/UI sad; průběžný log `test-output/3d-test-all.log`.

## Přestavba do 3D — etapa 8 (2026-10-24)
- Dolaďeno rozmístění svítidel, materiály, kontrastní lišty, ventilace, kabelové trasy a detaily racků. Zapnuto4× MSAA pro3D. Vlastní modely nevyžadují externí assety ani stahování.
- Statická opakovaná geometrie se seskupuje do MultiMesh podle modelu/materiálu/místnosti; odstraněno1005 samostatných instancí. Interaktivní zařízení, kolize, LED, dveře, disky a ventilátory zůstávají nezávislé. Jediné stínující směrové světlo,5 místních světel bez dynamických stínů; žádné velké textury.
- Hráč vidí nesený disk; HUD ukazuje jeho serial, kabel a neuložené změny. Citlivost se ukládá do stejné oddělené konfigurace jako obraz. HUD a servisní formuláře zachovávají oversampling i4K měřítko.
- Nový `tests/world_playthrough.gd`:31 headless /36 GPU kontrol PASS: raycast+E, fyzická kontrola, serial a potvrzení, vytažení/3D prázdný slot, skříň/náhrada/rebuild/ověření a skutečné dokončení mise53; uchopení HV kabelu, E na port3 a obnovená služba. Ověřena stěna blokující interakci a skutečné4K škálování. Test přidán do Test-All.
- GPU snímky `test-output/world-academy.png`, `world-console.png`, `world-service-4k.png`, `world-disk-removed.png` a `world3d-stage2.png` vizuálně prohlédnuty. V plné sadě zatím prošlo všech65 misí také skutečnými původními formuláři.

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
