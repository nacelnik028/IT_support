# IT Support Simulator: Datacenter Academy

Český offline 3D simulátor IT administrátora z první osoby pro Godot4.x.
Vytvořeno a ověřeno v Godotu4.7.2.stable.official.ed1daf0bf.
Obsahuje65 praktických misí,21 interaktivních
lekcí ve třech režimech, náhodné procvičování, osobní přehled znalostí a50
studijních článků z poskytnutých Notion příruček. Původních24 misí zůstalo zachováno.

## Spuštění

**V Godotu:** importuj `project.godot` v této složce a stiskni **F5**.
Hlavní scéna je `scenes/world/Game.tscn`. Není třeba žádný plugin ani internet.

**Windows bez otevření editoru:** spusť `build/ITSupportSimulator.exe`.
Vedle něj ponech `ITSupportSimulator.pck`. Přenášej celou složku `build`.
Balíček obsahuje místní plný Godot engine a exportovaný PCK; běžné exportní
šablony nebyly nainstalované. Proto je EXE větší než standardní export.

## Ovládání a první směna

- **WASD** chůze, **myš** rozhlížení, **Shift** rychlá chůze, **E** interakce,
  **F** baterka, **Tab** zadání a skutečné cíle, **Escape** pauza či návrat od
  počítače. Citlivost myši nastavíš v pauze a zachová se pro příští spuštění.
- **Zahájit první směnu / Pokračovat** otevře skutečnou3D serverovnu.
  Přijdi k zařízení, zaměř jeho čelo a stiskni E. Tyrkysový rám označuje právě
  zaměřený objekt; paprsek neprochází stěnami a dosáhne3,2m.
- Počítače **ADMIN-01 / Proxmox** a **ADMIN-02 / Hyper-V** otevírají původní
  plně funkční konzole. Návrat přes Esc nebo **Zpět do3D prostředí** zachová
  rozepsané formuláře. Monitor za racky ukazuje skutečné VM, pole a kapacitu.
- **15 praktických úkolů ve3D** v menu zpřístupní mise51–65 ve volném tréninku.
  Kampaň zachovává postupné odemykání, skóre a XP. Nové mise vyžadují také
  skutečné fyzické kontroly, zapojení, servis a návštěvu monitoringu.
- **Servis disku:** podle LED najdi slot, v jeho detailu opiš serial, ověř
  nezávislou zálohu a potvrď vytažení. Ve skříni **SERVIS** vezmi kompatibilní
  náhradu (SAS pro NAS, SATA pro ZFS; alespoň původní kapacita), dones ji ke
  slotu a vlož. Dokonči rebuild/resilver posunem simulovaného času a ověř pole.
  Hardware bez hot-swap musí být vypnutý. Vytažení zdravého člena může skutečně
  vyřadit pole a aplikaci; selhané pole samotný rebuild neopraví.
- **Síť:** u konektoru vedle serveru můžeš kabel odpojit nebo uchopit. Potom
  dojdi ke **SW-CORE**, zaměř konkrétní port a stiskni E. Správný port určuje
  štítek. Obsazený port se nepřepíše; chybný port neobnoví službu.
- **IT Training Academy** leží ve vedlejší místnosti za posuvnými dveřmi
  napravo. Pevný panel na zdi z obou stran ovládá otevření i zavření přes E,
  také když je křídlo zasunuté. Čidlo brání zavření do hráče.
  Lze do ní dojít nebo vstoupit z menu/pauzy. U virtuálního instruktora
  či zkušebního počítače vyber lekci a režim. Učím se přidá zlatý rám,
  instrukce a směr/vzdálenost k zařízení. Procvičování a Zkouška řešení
  nezvýrazňují. Laboratorní stanice používají samostatnou relaci lekce.
  Vstup přepne režim na TRAINING a pozastaví pracovní ticket. Odchod ihned
  zruší rozpracovanou lekci, její UI i cvičnou infrastrukturu a obnoví MAIN.
  Totéž platí pro teleport, načtení pozice mimo centrum nebo změnu scény.
  Dokončené výsledky, zkoušky, statistiky a kariérní XP zůstanou uložené.

Původní administrátorské rozhraní zůstává dostupné na monitorech:

- Hlavní menu: **Nastavení** otevírá přepínač celé obrazovky a rozlišení16:9:
  1280×720,1600×900,1920×1080,2560×1440,3200×1800 a3840×2160 (4K UHD).
  Změnu potvrď tlačítkem **Použít nastavení**. **F11** přepíná celou obrazovku
  také během hraní. Rozhraní zachovává proporce a čitelnou velikost prvků.
- Vybrané rozlišení určuje skutečný počet vykreslovaných pixelů. V režimu okna
  se okno na menším monitoru vejde do pracovní plochy; vykreslovací rozlišení zůstává zvolené.
- Písmo v menu, konzolích, racku i terminálu se přepočítává pro zvolené rozlišení.
  Ikony ovládání používají vektorové SVG textury, které se také rasterizují
  podle velikosti na obrazovce. Ve4K se zachovává ostrost i poměr stran16:9.
- **Ukončit hru** v hlavním menu uloží rozehraný stav a zavře aplikaci.
  Stejné uložení probíhá při zavření okna křížkem.
- Myš: výběr serveru, panelu, polí a operací. Kolečko: posun obsahu konzole
  nebo ticketu v samostatných sloupcích. Tab: přesun mezi formulářovými poli.
- Menu → Zahájit směnu nebo Tickety → první laboratoř.
- **Tréninkové centrum** v hlavním menu nebo **Trénink** vlevo otevírá lekce,
  náhodné procvičování, Moje IT znalosti a interaktivní IT slovník.
- **Učím se** ukazuje aktuální krok, šipku a zvýraznění skutečného ovládacího
  prvku. Krok postupuje teprve po potvrzené události nebo odpovídajícím stavu.
  Pokud jsi v jiné konzoli, použij **Zobrazit potřebný panel**.
- **Procvičování** má zadání a dobrovolné nápovědy. **Zkouška** nezvýrazňuje
  řešení, nepovoluje přímou nápovědu a po dokončení rozebere chyby i doporučení.
- Během jedné návštěvy centra lze přepínat uložené kroky lekcí. **Vrátit se
  k uložené kampani** opustí centrum a obnoví původní ticket i konfiguraci.
  Odchod, návrat do menu nebo restart hry zruší dočasné výukové relace.
  Při příštím vstupu si zvolíš novou lekci; nic se samo nespustí.
- Náhodné procvičování nabízí oblast, obtížnost,1–20 úloh a nápovědu zapnutou/vypnutou.
  Generátor obměňuje skutečné parametry a před spuštěním ověřuje řešitelnost.
- Restart náhodné úlohy obnoví pouze aktuální scénář. Pozice série, výsledky
  a odložená kampaň zůstanou zachované. Obnovení uložené série nejprve odloží
  aktuální kampaň nebo lekci včetně posledních změn.
- Po otevření konzole levý panel otevírá Proxmox, Hyper-V, Storage,
  síťovou mapu, terminál, Akademii a statistiky.
- V konzoli vyber sekci v horní nabídce. **Podle ticketu** soustředí související
  operace; ostatní sekce dovolují širší experimentování.
- Strom Datacenter / Hostitel / VM umožňuje vybrat uzel a předvolit VMID ve
  formulářích. Hostitelské operace výslovně uvádějí cíl PVE-01 nebo HV-01.
- Nejprve prohlédni diagnostiku a živý stav. Potom uprav konkrétní parametry.
  V RAID konfigurátoru vybírej fyzické sloty; kapacita se počítá průběžně.
- Po změně použij **Ověřit infrastrukturu a aplikace**. Teprve potom uzavři
  ticket v pravém panelu. Samotné tlačítko pro uzavření nic neopravuje.
- Nápověda má tři úrovně. Po dokončení je dostupné dobrovolné krátké opakování.
  Chybná odpověď doporučí další praktický trénink; nezablokuje vyřešený ticket.
- Volný trénink otevírá všech65 situací. Umožňuje vrátit poslední zásah,
  restartovat laboratoř a používat i operace mimo příslušný ticket.
- Zrušit rizikový zásah lze v potvrzovacím dialogu. Chyby mají vysvětlení;
  původní datové disky nelze bezpečnostními zkratkami přepsat.
- Přepnutí zvuku, rozlišení a F11 zachová rozepsané formuláře, včetně
  nepotvrzeného čísla, nabídek a výběru disků. Každá VM má vlastní koncept.
  Koncepty jsou v paměti; změna mise, režimu, obnova či restart relace je vyčistí.

První mise vyžaduje VT-x/AMD-V, HBA pro ZFS, UPS, vzdálenou konzoli,
hostname `pve01.lab.example`, IP `192.168.10.10/24`, gateway `192.168.10.1`
a DNS `192.168.10.2`. IOMMU je pro passthrough; není podmínkou každé VM.

## Implementované systémy

- Samostatná produkční a cvičná instance infrastruktury; konzole, terminál,
  monitoring a cíle vždy používají příslušnou instanci.
- Proxmox: příprava a instalace, port8006, repozitáře, aktualizace, VM/CT,
  VirtIO, Guest Agent, bridge/VLAN, thin pool, PBS, test obnovy,
  ZFS mirror/resilver/scrub, omezené role/MFA/token a model HA s quorum/fencing.
- Hyper-V: firmware/role/restart/VMMS, External/Internal/Private, Gen2/UEFI,
  Dynamic Memory, Fixed/Dynamic/Differencing VHDX a nový guest volume,
  oddělené resize disku a filesystemu, VSS/Production/Standard checkpoint,
  bezpečný merge, Live Migration, export/import, Replica a izolovaný Test Failover.
- Storage: sloty/serial, RAID0/1/5/6/10, nejmenší člen, TB/TiB, kapacita bez
  spare, poruchy konkrétních párů, automatické převzetí hot spare a rebuild;
  ZFS/Spaces kapacitní varianty, foreign metadata, ochrana cache, GPT/NTFS/ReFS,
  SMB+ACL+Hard/Soft FSRM, iSCSI mapping, MPIO a test výpadku cesty.
- Síť: samostatné kontroly L2, IP, DNS a aplikačních dat, konflikty IP,
  omezení virtuálních switchů a cílené pravidlo HTTPS.
- 65 samostatných výchozích stavů, stavové cíle, tři nápovědy, deník a rozbor.
- 21 datových lekcí nad stejnými konzolemi:18 požadovaných + quorum/HA,
  iSCSI/MPIO a bezpečnost účtů. Podrobnosti a rozšiřování viz [TRAINING.md](TRAINING.md).
- Nové incidenty řeší DNS, RAM, boot order, VirtIO, CT bind data, nedostupný PBS,
  offline Hyper-V→PVE převod, generaci OS, VSS, AVHDX merge, RAW cestu, cache a SAN.
- Skóre0–100, XP, úrovně, postupné odemykání, achievementy, oborové statistiky
  a doporučený trénink podle chyb. Opakování stejného skóre nefarmí XP.
- Dark UI, česká diakritika, klikací racky, LED, přechody a generovaný zvuk.

## Terminál

Zvol cílový hostitel nad výpisem. `help` ukáže parserem podporované příkazy.
Enter odešle příkaz; šipky nahoru/dolů procházejí historii. Výpis lze označit.

PVE: `qm list`, `qm config 100`, `qm start 100`, `qm shutdown 100`,
`pct list`, `pvesm status`, `pveversion -v`, `zpool status`, `zpool list`,
`lsblk`, `df -h`, `lvs`, `ip -br address`, `ip route`, `pvecm status`.

Hyper-V: `Get-VM`, `Get-VMHost`, `Get-VMSwitch`, `Get-VMNetworkAdapter`,
`Get-VMHardDiskDrive`, `Get-VMMemory`, `Get-VMIntegrationService`,
`Get-VMSnapshot`, `Get-Disk`, `Get-Volume`, `Get-PhysicalDisk`,
`Get-Service vmms`, `Get-WinEvent`, `Start-VM -Name FS01`, `Stop-VM -Name FS01`.
Podporované dotazy na VM přijímají `-Name` / `-VMName` a jména v uvozovkách.

Parser nevytváří procesy. Bash/PowerShell nejsou skutečně spuštěny.
Řetězení, pipe, přesměrování a expanze jsou odmítnuty.

## Uložení

Volby obrazu se ukládají samostatně do `user://display_settings.cfg` a použijí
se při příštím spuštění. Nemění formát ani obsah uloženého herního postupu.

Po každém zásahu se atomicky ukládá rozehraná konfigurace, ticket, použitá
nápověda, skóre, XP a statistiky do `user://academy_save.json`.
Na tomto počítači odpovídá cesta adresáři
`%APPDATA%/Godot/app_userdata/IT Support Simulator- Datacenter Academy/`.
Před načtením se kontroluje struktura, typy, identifikátory, skóre, kroky lekcí
i pozice série. Vadný soubor se nenačte a automatické ukládání jej nepřepíše.
Upozornění je viditelné i v menu. **Zálohovat vadný soubor a uložit** výslovně
zahájí nový postup po zachování původních bajtů v `.invalid-*.bak`.
Testy používají oddělené `academy_test_*.json` i oddělená nastavení.
Schema2 načte původní schema1, zachová XP, skóre, achievementy i rozehranou
infrastrukturu. Před prvním přepsáním schema1 vytvoří `academy_save.json.v1.bak`.
Před nahrazením save se ověří dočasný soubor a zachová předchozí platná verze
v `.last-good.bak`. Při chybě zápisu zůstane zásah provedený v paměti a objeví
se **Změny čekají na uložení** s tlačítkem **Zkusit uložit znovu**.
Uložení a návrat do menu, odchod z lekce ani ukončení v takovém případě
neslibují úspěch. Po opakování zápisu se uloží poslední stav celé relace.
Výukové relace, odložená kampaň, série a historie výsledků mají oddělené datové větve.
Undo je lokální historie aktuální relace. Pracovní mise uchová konfiguraci i po
restartu programu; nedokončená výuka se při odchodu nebo restartu zruší. Přechod do jiné
mise či režimu a obnova relace undo vyčistí; prázdné undo má neaktivní tlačítko.

## Struktura

```text
scenes/world/Game.tscn              Vstupní3D hra a původní UI
scenes/world/Datacenter3D.tscn      Serverovna a připojená akademie
scenes/world/Player.tscn            CharacterBody3D, kamera, raycast, baterka
scripts/world/                     FPS, Interactable3D, prostředí a propojení UI
scripts/world/WorldVisuals.gd       Materiály, detailní modely, světla a obrazovky
scripts/world/MonitorDisplay.gd     Živý přehled na fyzických3D monitorech
assets/materials/                  Vlastní PBR shadery podlahy, kovu a odlesků
scenes/main_menu/Main.tscn          Zachované menu/konzole a původní testy
scenes/datacenter/Datacenter.tscn   Zachovaný2D přehled
scenes/consoles/                   Samostatné konzole Proxmox/Hyper-V/storage
scenes/results/Review.tscn         Kontextové opakování
scenes/training/TrainingCenter.tscn Tréninkové centrum
scripts/core/GameManager.gd        Mise, odemykání, skóre, relace
scripts/core/GameModeManager.gd    Jediný režim MAIN/TRAINING
scripts/world/TrainingZone.gd      Area3D, kontrola polohy a odchodu z místnosti
scripts/simulation/               Stav, síť, RAID a oborové operace
scripts/evaluation/               Vyhodnocení podmínek nad stavem
scripts/progression/SaveManager.gd Atomické uložení a načtení
scripts/ui/                       Adaptivní Control UI, formuláře a racky
scripts/training/                 Kroky, validátor, zvýraznění, generátor a profil
data/infrastructure/baseline.json  Výchozí společná infrastruktura
data/missions/campaign.json        65 datových misí (prvních24 nezměněno)
data/training/                    21 lekcí, slovník a validační recepty generátoru
data/actions.json                 Formuláře a vazby na operace
data/knowledge/                   Úplné zdroje a články Akademie
tests/                            Automatické testy a referenční postupy
tools/                            Obnova katalogu, testy a Windows balení
PROGRESS.md                       Stav pro pokračování vývoje
```

## Přidání mise

Přidej záznam do `data/missions/campaign.json`: `id`, `title`, `category`,
`server`, `topic`, `difficulty`, `priority`, `description`, `symptoms`,
`initial_state`, `available_actions`, `objectives`, `failure_conditions`,
`hints`, `explanations`, `rewards`; volitelně `review`.

`initial_state` se rekurzivně spojí s baseline; prázdný dictionary výslovně
vyprázdní danou větev. Každý cíl obsahuje `path`, `value`, `label`,
a volitelně `op`: `eq`, `gte`, `lte`, `contains`. Příklad:

```json
{"path":"vms.100.vlan","value":20,"label":"Správná VLAN","op":"eq"}
```

Přidej i ověřovací cíl, například `verified.service_pve == true`. Každá změna
konfigurace zneplatní předchozí ověření. Cíle nečtou seznam tlačítek.
`available_actions` pouze sestavuje doporučený panel; nevnucuje pořadí kroků.
Nové formuláře patří do `data/actions.json`, jejich chování do oborového
Operations skriptu. Operace vrací `{ok,text}` a mění společný stav.

`tools/build_content.py` a `tools/build_extension.py` obnovují nynější katalog.
Patnáct3D misí a výchozí fyzická infrastruktura jsou v `tools/world_catalog.py`,
který volá `extension_catalog.py`. Udržuj změny také v generátoru.
Rozšíření je v `tools/extension_catalog.py`; původní24 definice jsou zmrazené
v `data/missions/legacy_campaign.json` a testy kontrolují jejich shodu.
**Jeho spuštění přegeneruje JSON**; pokud ho chceš dále používat, prováděj
trvalé obsahové změny i v něm. Pro běžné nové mise samotný JSON stačí.
Referenční postup pro regresi přidej do `tests/solutions.json`.

## Ověření a sestavení

V PowerShellu s cestou ke console variantě Godotu:

```powershell
./tools/Test-All.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
./tools/Build-Windows.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
```

Ostrost skutečného obrazu ověřuje grafický test (vyžaduje grafickou kartu,
spouštěj bez `--headless`):

```powershell
Godot_console.exe --path . --script tests/render_quality.gd -- --screenshots
```

Porovnává pixelové hrany textu v menu, racku a terminálu ve4K proti zvětšenému
původnímu atlasu a kontroluje skutečnou GPU velikost SVG textury. Výřezy jsou
v `test-output/*-4k-native.png` a `*-4k-magnified.png`. Při úpravách UI zachovej
`oversampling_with_scale` na kořeni UIController a používej DPITexture pro ikony;
viz [dokumentace škálování Godotu](https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html#font-and-image-oversampling).

- `stage1.gd`: první mise, chyba, ověření a uložení.
- `campaign.gd`: všech65 misí proti skutečnému stavu a shoda původních24 definic.
- `physical3d.gd`: fyzické výměny, kompatibilita, selhání RAID, kabely,
  napájení, obnova ze save a oddělení kampaně od všech3 výukových režimů.
- `world3d.gd`: skutečný pohyb/kolize/raycast/E, dveře a chůze do akademie,
  všechny3 režimy vedení, návrat od počítače a LED konkrétních disků.
- `door3d.gd`: opakované otevření/zavření z pevných panelů na obou stranách,
  dostupný ovladač po zasunutí křídla a bezpečnostní čidlo během zavírání.
- `training_rooms.gd` / `TrainingRoomsMCP.tscn`: scénáře A–H, režimy místností,
  izolace infrastruktury, reset lekce/UI, trvalé výsledky a XP, teleport,
  načtení pozice, zánik scény a stabilita hranice dveří.
- `visual_capture.gd` a `visual_benchmark.gd`: grafické snímky místností,
  detailů a ovladačů, měření1080p/4K bez změny hráčova nastavení.
- `world_playthrough.gd`: kompletní servisní mise přes3D cíle a skutečné
  formuláře/dialogy, nošení náhrady, rebuild, předání ticketu a fyzické zapojení
  switch portu. Grafický běh `-- --screenshots` ověří také4K a uloží snímky.
- `regression.gd`:88 kontrol cílů, RAID, sítí, bezpečnosti, terminálu, save/load a XP.
- `extended.gd`:35 kontrol LXC, VSS, VHDX typů, Replica, hot spare a kvót.
- `ui_smoke.gd`: všechny mise přes skutečné formuláře, potvrzovací dialogy
  a kontextové otázky; přechody mezi všemi hlavními obrazovkami.
- `tutorial_first.gd`: všech9 kroků WEB01, chybná RAM a bezpečný návrat ke kampani.
- `lessons.gd`: všechny lekce v režimech Učím se / Procvičování / Zkouška.
- `training_features.gd`: parametrizace, všechny kombinace filtrů, obnova série,
  migrace původního save a doporučení slabých oblastí.
- `session_safety.gd`: restart série, odmítnutí indexů bez změn, přechody
  kampaně/lekcí/série se znovuspuštěním aplikace, izolace undo a kolize `vmbr0`.
- `save_safety.gd`: skutečné selhání zápisu a opakování, ochrana vadných souborů,
  strukturální validace, migrace a uložitelnost všech misí po každém zásahu.
- `ui_safety.gd`: skutečná tlačítka restartu/obnovy, koncepty formulářů,
  zvuk/F11/rozlišení, odeslání zachovaného čísla a hlášení chyb uložení.
  Grafický běh s `-- --screenshots` vytváří `test-output/safety-*.png`.
- `training_ui.gd -- --all-modes`: skutečné formuláře a navigace všech lekcí
  ve všech3 režimech, včetně kontroly, že zkouška nemá zvýraznění.
- Vizuální snímky vytvoří grafický běh
  `Godot_console.exe --path . --script tests/ui_smoke.gd -- --screenshots`.
  Přepínač `--small` testuje okno1280×720.

## Rozsah simulace a známá omezení

- 3D budova a zařízení jsou vlastní procedurální modely se stylizovaným technickým
  vzhledem. Statické díly využívají MultiMesh a sdílené materiály; žádné externí
  modely či velké textury nejsou potřeba. Renderování používá Godot4 Forward+
  (Vulkan),4× MSAA, měkké stíny, ambientní zastínění a odlesky. Monitory ve3D
  zobrazují skutečná data infrastruktury. Hra nevyžaduje ray tracing.
  Úspornější renderer lze spustit argumentem `--rendering-method gl_compatibility`;
  ten ponechá modely, interakce a materiály s omezenými obrazovými efekty.
- Poloha hráče, fyzické přívody, inventář a rozpracovaný servis patří do stavu
  aktuální relace. Poloha se ukládá také při přechodu do aplikace a periodicky
  během chůze. Změny poškozeného pole se nevracejí pouhou animací; pro opakování
  slouží restart laboratoře nebo undo ve volném tréninku.

- Jde o laboratorní model, nikoli úplný klon PVE nebo Windows Serveru.
  Instalace OS, přenosy, Verify, merge a obnova jsou zrychlené stavové operace.
  Rebuild/resilver se posouvá po50 % ručním posunem simulovaného času.
- Síť má připravené podsítě a službu HTTPS s datovým manifestem. Nesimuluje
  pakety, plné směrovací tabulky ani skutečný operační systém.
- Kampaně začínají nezávislou výchozí situací; infrastruktura se nepřenáší
  mezi misemi. Postup, nejlepší skóre a rozehraný ticket se přenášejí.
- Hostitelská příprava cílí PVE-01/HV-01, RAID řadič NAS-01. Druhé uzly slouží
  migraci, HA a Replica. Nejde o libovolně rozšiřitelnou topologii serverovny.
- Ceph, kompletní návrh Failover Clusteru/CSV, výměna bootovacího ZFS rpoolu
  a všechny varianty Storage Spaces nemají úplné samostatné průvodce.
  Offline převod Hyper-V→PVE je nově prakticky simulovaný včetně disků,
  firmware, ovladačů, izolovaného testu dat a přepnutí provozu.
- Backup job uchovává v modelu poslední bod každé VM a retenční politiku.
  Nesimuluje úplný kalendář deduplikovaných chunků PBS. Replica používá
  synchronizovaný stavový snímek; nejsou simulovány reálné intervaly přenosu.
- RAID výpočty jsou orientační před metadata/filesystemem. VHDX a kapacitní
  vrstvy pracují s výukovými jednotkami GB; TB/TiB je zvlášť v RAID kalkulátoru.
- Není vytvořen instalátor ani standardní template export. Windows balíček
  používá plný místní engine (přibližně181MB) vedle malého herního PCK.

## Primární studijní zdroje

Všechny tři příručky byly načteny přes Notion MCP a úplně uloženy pro offline
čtení. Odborné názvy a obsah jsou odvozené z nich:

- [Student IT support](https://app.notion.com/p/403bceb1e413801d98a5dfd2c1d9d8b9)
- [Proxmox](https://app.notion.com/p/403bceb1e413811cb04ef027bd9f8715)
- [Hyper-V](https://app.notion.com/p/403bceb1e413812a9c02f743f359b731)
- [RAID a disková pole](https://app.notion.com/p/403bceb1e41381a485bcc52395b7bd7e)

Doplňkově ověřeno proti [Hyper-V dokumentaci](https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/overview)
a [podpoře FSRM](https://learn.microsoft.com/en-us/windows-server/storage/fsrm/fsrm-overview).
Godot Engine používá MIT licenci; viz `GODOT-LICENSE.txt`.
