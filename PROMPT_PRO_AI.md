# Zadání pro AI: opravy a přepracování ovládání Datacenter Academy

Pracuj jako zkušený Godot vývojář a UX designér výukových simulátorů. Uprav existující projekt IT Support Simulator: Datacenter Academy. Hlavním cílem je výrazně přehlednější konfigurace serverů, VM, sítí a úložišť, správný kontext všech operací a pohodlné ovládání pro začátečníka i zkušenějšího hráče. Proveď skutečnou implementaci a ověření.

Nejdřív přečti AGENTS.md, PROGRESS.md a README.md. Používej dostupný Godot MCP a přímé úpravy souborů. Navazuj na současnou 3D hru, společnou simulaci a hotový obsah. Zachovej její tmavý technický vzhled; největší změnu potřebuji v uspořádání a chování konfigurace.

Níže jsou oddělené skutečně reprodukované chyby a návrhy na zlepšení. Opravy prováděj v uvedeném pořadí po dokončených a otestovaných etapách.

## 1. Priorita P0: oprav platformu a identitu cíle operace

Při auditu 25. 10. 2026 byly na izolovaném stavu potvrzené tyto chyby:

- Formulář Hyper-V Dynamic Memory nabízí také VM100 z PVE-01. `selected_vm` může zůstat nastavené na100 i po přechodu do Hyper-V.
- Po `sim.reset({"vms":{"100":{"status":"Off"}}})` přijme `sim.act("memory", {"vm":"100","dynamic":true,"minimum":2,"ram":6,"maximum":8})` změnu s `ok=true`. Proxmox VM dostane Dynamic Memory z Hyper-V formuláře.
- Po `sim.reset({"migration":{"cpu_compatible":true}})` přijme `sim.act("live_migrate", {"vm":"100","target":"HV-02","auth":"Kerberos","storage":true})` změnu s `ok=true` a přesune VM100 z PVE-01 na HV-02 jako nativní Live Migration.

Zkontroluj zejména `scripts/simulation/HyperVOperations.gd` větve `memory` a `live_migrate`, návazné platformní operace a `UIController.gd` funkce `draw_form`, `draw_tree`, `navigate` a `open_app` v GameShell.

Platformní operace musí kontrolovat skutečný zdrojový i cílový hostitel v modelu. Pouhé filtrování seznamu v UI nestačí. Rozliš obecné operace použitelné pro obě platformy a operace konkrétní platformy. Zachovej existující zvláštní postup offline Hyper-V→PVE převodu.

Výběry běžně zobrazují existující kompatibilní objekty s ID, názvem a hostitelem. Rezervace nového ID zůstane samostatná. Záměrně chybné didaktické volby mohou zůstat tam, kde je učí daná úloha; musí mít správnou validaci. Po změně platformy nesmí zůstat skrytý nekompatibilní výběr. Výběr hostitele ve stromu musí odpovídat cíli akce. Operace omezené modelem na PVE-01/HV-01 tuto mez jasně ukážou.

Doplň negativní regrese obou uvedených případů. Odmítnutá operace nesmí změnit infrastrukturu; záznam odmítnutí a příslušné hodnocení chyby jsou v pořádku.

## 2. Priorita P1: zásadně přepracuj nabídku konfigurace

Současné `draw_console()` skládá výběr sekce, strom zařízení, živý stav a všechny formuláře pod sebe do jednoho dlouhého sloupce. Sekce jsou schované v rozbalovací nabídce. Proxmox má 44 akcí mimo fyzický servis ve 12 sekcích, Hyper-V 31 v 8 sekcích a Storage 29 v 7 sekcích. Průvodce VM zobrazuje šest formulářů najednou; při auditu měl obsah výšku 2498 proti 615 dostupným jednotkám UI.

Navrhni a implementuj toto uspořádání:

- Kompaktní globální navigace a trvale srozumitelná informace, zda spravuji hlavní serverovnu, nebo cvičnou infrastrukturu.
- Strom zařízení s jasně vybraným hostitelem, VM/CT nebo úložištěm. Nemá odjíždět s dlouhým formulářem.
- Přehledné viditelné sekce příslušného objektu, například Přehled, Hardware, Síť, Disky, Zálohy a Události. Konkrétní sekce odvoď od platformy a dostupných funkcí. Velký dropdown nahraď vhodnou navigací.
- Uprostřed zobraz detail vybraného objektu a jeden zvolený formulář nebo ucelenou skupinu souvisejících nastavení. Přehled živého stavu má vlastní místo a nevytlačuje každou operaci pod obrazovku.
- Ticket nebo instruktor má sbalitelný kontextový panel. Při1280×720 musí být konfigurace pohodlně ovladatelná; použij přepínatelné panely tam, kde se několik sloupců nevejde.
- „Podle ticketu“ zachovej jako zkratku k souvisejícím činnostem. Zachovej také širší experimentování. Zkouška nesmí dostat přímé zvýraznění řešení.
- „Create VM — průvodce“ změň na skutečný postup Identita → ISO → CPU/RAM → Disk → Síť → Shrnutí/instalace, s kroky Zpět/Další a zachováním údajů. Použij existující skutečné operace a tutoriálové události. Nevytvářej paralelní falešný model VM. Otevření průvodce nesmí být dominantní akcí při nesouvisející přípravě hostitele.

Dosavadní testy sahají přímo na `form_controls`, `form_buttons` a `ui_targets`. Při změně prezentace uprav jejich adaptéry a navigaci tak, aby ověřovaly nové skutečné ovládání a tutoriály. Nedrž všech šest formulářů neviditelně aktivních jen kvůli starému testu.

## 3. Priorita P1: zachovej pracovní kontext a správně předvyplňuj hodnoty

Potvrzená chyba: po nastavení posuvu formulářů na 1400 a zavolání `draw_ui()` je nový posuv 0. `clear_ui()` znovu vytváří celé rozhraní. Překreslení například po provedení akce vrací uživatele na začátek.

Zachovej posuv, vybraný objekt, sekci, fokus a pozici kurzoru podle kontextu obrazovky. Po chybě zůstaň u daného formuláře a ukaž konkrétní problém. V režimu Učím se smí navigace cíleně přejít k dalšímu skutečnému kroku. Po změně mise nebo relace nadále správně vyčisti dočasné koncepty.

Při úpravě existující konfigurace načítej aktuální hodnoty vybraného objektu. Mnoho polí nyní používá statický `default`; například `pve_resources` má CPU 2 / RAM 4 a `memory` minimum 2 / startup 4 / maximum 8 bez vazby na stav vybrané VM. Výchozí hodnoty pro vytvoření nového objektu odděl od editace existujícího. Koncept rozepsaný hráčem má při návratu přednost před opětovným předvyplněním. Zachovej i dosud nepotvrzené číslo ve SpinBoxu a oddělení konceptů podle VM, hostitele a relace.

## 4. Priorita P1: srozumitelné formuláře a výsledky operací

Každá akce má mít jednoznačný cíl a účel. Bool přepínače nemají používat univerzální popisek „Zapnuto / potvrzeno“; pojmenuj skutečný význam. Zobrazuj jednotky přímo u hodnot, konzistentně rozlišuj GB/GiB/MiB a nabídni pomocné vysvětlení. Nesrovnávej pouze přepsané štítky s původními daty; převody musí být správné.

Základní formátovou validaci zobraz u polí. Text má říct, co je chybně a jak to uživatel opraví. Samotná editace formuláře nemá měnit infrastrukturu ani přidávat chyby do hodnocení. Skutečné odborně chybné odeslané zásahy nadále vyhodnocuje model.

Úspěch, provozní varování a chyba mají odlišný stav i text. Místo velkého panelu opakovaně vytlačujícího obsah použij kompaktní zpětnou vazbu u akce; podrobný deník otevři na vyžádání. Zachovej trvalé upozornění na neuložené změny.

Rizikové potvrzení přelož z JSON parametrů do lidsky čitelného souhrnu: zařízení/VM, hostitel, co se změní, případná odstávka a dopad na data. Technický detail může být rozbalitelný. Zrušení zachová formulář. Obecné varování před zničením dat nepřidávej k bezpečným akcím.

## 5. Priorita P2: sjednoť nastavení a přístupnost

V hlavním Nastavení jsou nyní jen fullscreen a rozlišení, citlivost myši je v pauze a zvuk v postranní navigaci. Zvuk se mezi spuštěními neukládá. Sjednoť nastavení do Obraz / Zvuk / Ovládání / Rozhraní, dostupných z menu i pauzy. Návrat respektuje místo otevření.

Implementuj hlasitost a ztlumení, citlivost, změnu kláves s kontrolou kolizí a obnovením výchozích hodnot, velikost textu a případně samostatné měřítko HUD. Zachovej ostré fonty, `oversampling_with_scale`, DPITexture, F11 a všech šest současných rozlišení.

Přidej potvrzení změny obrazu s odpočtem a návratem k poslední potvrzené konfiguraci, pokud uživatel změnu nepotvrdí. Ověř skutečné chování fullscreen a chyb ukládání. Rozlišení renderování a velikost textu musejí být srozumitelně oddělené.

Ověř ovládání formulářů klávesnicí, viditelný fokus, čitelnost popisků a stavů v 720p, 1080p a 4K. Stav nerozlišuj pouze barvou. Escape nejprve zavírá aktivní dialog, potom panel a následně otevírá pauzu. Psaní do polí a terminálu nesmí ovládat chůzi ani zařízení za formulářem.

## 6. Priorita P2: uprav první spuštění, výuku a HUD

Hlavní menu má několik podobně výrazných vstupů: směna, kampaň, tréninkové centrum, volný trénink a dalších 15 úkolů ve3D. Vyjasni hierarchii: Pokračovat/Zahájit směnu jako hlavní akce, dále Kampaň, Výuka a Volný trénink s krátkým vysvětlením. Patnáct 3D misí zpřístupni jako srozumitelnou podkategorii nebo filtr.

Přidej krátké přeskočitelné seznámení s pohybem, E, monitorem a zadáním přes Tab při první směně. Nezasahuj do obsahu prvních 24 misí. V běžné kampani neprozrazuj automaticky postup řešení.

Potvrzený problém HUD: i při aktivní lekci ukazuje vlevo „Tréninkové centrum – vyber si lekci“. Stav odvoď od aktivní relace a ukaž název lekce/režim. Velké panely přizpůsob délce textu; instruktor s jednou větou nepotřebuje trvale zabírat velkou část obrazovky. Oznámení vstupu nyní překrývá i již otevřenou nabídku lekcí; změň jeho umístění nebo dobu zobrazení podle kontextu.

U lekcí vysvětli rozdíl Učím se / Procvičování / Zkouška a zřetelně ukaž přerušení cvičení při odchodu z místnosti. Tlačítko „Uložit a opustit lekci“, které vede na nabídku v téže návštěvě, pojmenuj podle skutečného chování. Zachovej obnovu v rámci návštěvy a zrušení nedokončené výuky po skutečném odchodu, menu či restartu.

Do seznamu 65 misí, 21 lekcí, slovníku a studijních článků přidej použitelné vyhledávání a vhodné filtry stavu/oblasti. Vzájemně propoj konkrétní chybu, vysvětlení a relevantní lekci. Zkouška nesmí mít nápovědu ani zvýrazněné správné řešení.

## 7. Priorita P2: propojuj přehledy se skutečným stavem

`draw_network()` má napevno VM 100 a 200, takže nově vytvořená VM101 nemá vlastní záznam. Přehled generuj z existujících VM a příslušných sítí/hostitelů. Akce „Upravit síť“ musí otevřít správnou platformu a přímo konkrétní VM.

V síťové mapě zřetelně ukaž návaznost hostitel/uplink → virtuální switch/bridge → VLAN → VM → gateway/DNS/aplikace a dostupná skutečná měření. Nepředstírej plnou paketovou simulaci. Zachovej omezení připravené topologie. Ve Storage přehledně odděl existující pole, nový konfigurátor, fyzické sloty, kapacitu a servis. U disků odliš člen pole, hot spare, volný a vadný disk; nekompatibilní výběr vysvětli před potvrzením zásahu.

Sjednoť češtinu ovládacích textů a překládej interní hodnoty `true/false`, `Off`, `Running` či `Healthy` do srozumitelných popisků. Běžné odborné názvy Proxmox/Hyper-V ponech. Neupravuj přitom interní enumy, ID a příkazy parseru. Oprav mezery v textech typu „WEB01(VMID101;Debian,2vCPU...)“. Kde text pochází z generátoru, oprav jeho zdroj.

## 8. Priorita P3: údržba, výkon a distribuce

`UIController.gd` má přes 1200 řádků a vytváří mnoho částí celé aplikace. Při implementaci vyčleň přirozené komponenty, zejména navigaci konzole, formulář, nastavení a kontextový panel. Zachovej oddělení UI, simulace a vyhodnocení. Nedělej plošný přepis enginu ani obsahu.

Zachovej současné procedurální 3D modely, MultiMesh, sdílené materiály, živé monitory a skutečné fyzické interakce. Výkon optimalizuj podle měření. Výsledek benchmarku na RTX 5060 nepovažuj za záruku pro školní počítače. Po hlavních opravách doplň skutečně funkční předvolby grafiky, VSync a limit FPS; srovnej výkon i čitelnost a ověř dostupný kompatibilní renderer. Samotné vizuální volby bez účinku se za implementaci nepovažují.

Po dokončení aktualizuj přenositelný Windows balíček a ověř jeho samostatné spuštění. Současné použití plného enginu a velké EXE je zdokumentované omezení; přechod na standardní export je až následné zlepšení, pokud jsou dostupné odpovídající šablony. Neblokuj tím předchozí opravy.

## Povinné zachování chování a způsob ověření

- Zachovej všech 65 misí, 21 lekcí a všechny 3 výukové režimy. Prvních 24 definic, `legacy_campaign.json` a legacy referenční postupy neměň bez výslovného požadavku.
- Výuka a náhodné série nesmějí přepsat odloženou kampaň. Zachovej samostatné `main_sim`/`training_sim`, reset cvičení po odchodu a trvalé výsledky/XP/skóre. Zachovej save migrace, atomické ukládání a ochranu poškozeného souboru.
- Všechny testy nastaví `SaveManager.path_override` před vytvořením GameManager a také samostatné `DisplaySettings.path_override`. Nikdy nepoužívej hráčův `academy_save.json` ani jeho konfiguraci.
- Trvalé změny formulářových definic udržuj současně v odpovídajících zdrojích generování. `tools/build_content.py` přegenerovává JSON; rozšíření navazuje na `tools/build_extension.py`, `tools/extension_catalog.py` a pro 3D obsah na `tools/world_catalog.py`. Zjisti správného vlastníka každé upravené definice a ověř reprodukovatelnost.
- Po funkční etapě spusť příslušné kontroly, aktualizuj PROGRESS.md a vytvoř Git commit. Na závěr spusť celý `tools/Test-All.ps1` včetně všech 3 výukových režimů a grafické kontroly související s úpravami. Aktualizuj README/TRAINING tam, kde se změnilo ovládání.
- Stávajících 18 sad při auditu prošlo bez runtime chyb a varování, přesto obě platformní chyby zůstaly. Doplň cílené negativní testy a několik průchodů přes skutečné vstupy a viditelné prvky. Přímé `.pressed.emit()` na formuláři samo neověří dosažitelnost kliknutím nebo klávesnicí.
- Konkrétně ověř: odmítnutí obou platformních chyb; změnu hostitele a VM; předvyplnění aktuální RAM/CPU; posuv a fokus po chybě/úspěchu; zachování konceptů při F11 a změně nastavení; všech 6 kroků průvodce; VM101 v síti; modalitu dialogů; samostatný Windows balíček; přechody kampaně a všech 3 výukových režimů bez poškození uložené kampaně.
- Pořiď a skutečně prohlédni snímky nové konfigurace a nastavení v 1280×720, 1920×1080 a 3840×2160. Zkontroluj čitelnost, překryvy a dosah na potvrzovací tlačítka. Pouhá existence Control v testu nestačí.

Na konci stručně napiš, co se změnilo, jak se nové rozhraní ovládá, jaké kontroly opravdu proběhly a co případně zůstává nedokončené. Prioritně dokonči funkční chyby a konfiguraci; další etapy nesmějí zůstat jen v plánu.

Podklady z auditu v tomto pracovním adresáři: `test-output/review-capture.log`, `test-output/review-test-all.log`, `test-output/review_capture.gd` a snímky `test-output/review-*.png`. Tyto dočasné podklady jsou ignorované Gitem; výše uvedené reprodukce jsou součástí zadání i bez nich. Godot MCP při auditu ověřil raycast/E, otevření konzole, změnu stavu, izolované uložení a návrat, včetně opakovaného ovládání dveří; `errors=[]`.
