# IT Support Simulator: Datacenter Academy

Česká offline výuková 2D hra pro Godot 4.x. Vytvořeno a ověřeno v Godotu
4.7.2.stable.official.ed1daf0bf. Obsahuje 50 praktických misí,21 interaktivních
lekcí ve třech režimech, náhodné procvičování, osobní přehled znalostí a50
studijních článků z poskytnutých Notion příruček. Původních24 misí zůstalo zachováno.

## Spuštění

**V Godotu:** importuj `project.godot` v této složce a stiskni **F5**.
Hlavní scéna je `scenes/main_menu/Main.tscn`. Není třeba žádný plugin ani internet.

**Windows bez otevření editoru:** spusť `build/ITSupportSimulator.exe`.
Vedle něj ponech `ITSupportSimulator.pck`. Přenášej celou složku `build`.
Balíček obsahuje místní plný Godot engine a exportovaný PCK; běžné exportní
šablony nebyly nainstalované. Proto je EXE větší než standardní export.

## Ovládání a první směna

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
- Odchod do centra uloží krok i infrastrukturu. **Vrátit se k uložené kampani**
  obnoví původní ticket a jeho konfiguraci. Režimy lekce mají vlastní uložené relace.
- Náhodné procvičování nabízí oblast, obtížnost,1–20 úloh a nápovědu zapnutou/vypnutou.
  Generátor obměňuje skutečné parametry a před spuštěním ověřuje řešitelnost.
- Serverovna: klikni na rack. Levý panel otevírá Proxmox, Hyper-V, Storage,
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
- Volný trénink otevírá všech50 situací. Umožňuje vrátit poslední zásah,
  restartovat laboratoř a používat i operace mimo příslušný ticket.
- Zrušit rizikový zásah lze v potvrzovacím dialogu. Chyby mají vysvětlení;
  původní datové disky nelze bezpečnostními zkratkami přepsat.

První mise vyžaduje VT-x/AMD-V, HBA pro ZFS, UPS, vzdálenou konzoli,
hostname `pve01.lab.example`, IP `192.168.10.10/24`, gateway `192.168.10.1`
a DNS `192.168.10.2`. IOMMU je pro passthrough; není podmínkou každé VM.

## Implementované systémy

- Jeden sdílený model infrastruktury pro konzole, terminál, monitoring a cíle.
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
- 50 samostatných výchozích stavů, stavové cíle, tři nápovědy, deník a rozbor.
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

Po každém zásahu se atomicky ukládá rozehraná konfigurace, ticket, použitá
nápověda, skóre, XP a statistiky do `user://academy_save.json`.
Na tomto počítači odpovídá cesta adresáři
`%APPDATA%/Godot/app_userdata/IT Support Simulator- Datacenter Academy/`.
Poškozený JSON je ošetřen. Testy používají oddělené `academy_test_*.json`.
Schema2 načte původní schema1, zachová XP, skóre, achievementy i rozehranou
infrastrukturu. Před prvním přepsáním schema1 vytvoří `academy_save.json.v1.bak`.
Výukové relace, odložená kampaň, série a historie výsledků mají oddělené datové větve.
Undo je lokální historie aktuální tréninkové relace; po restartu programu
zůstává uložena konfigurace, nikoli zásobník předchozích zásahů.

## Struktura

```text
scenes/main_menu/Main.tscn          Vstupní scéna
scenes/datacenter/Datacenter.tscn   Interaktivní racky
scenes/consoles/                   Samostatné konzole Proxmox/Hyper-V/storage
scenes/results/Review.tscn         Kontextové opakování
scenes/training/TrainingCenter.tscn Tréninkové centrum
scripts/core/GameManager.gd        Mise, odemykání, skóre, relace
scripts/simulation/               Stav, síť, RAID a oborové operace
scripts/evaluation/               Vyhodnocení podmínek nad stavem
scripts/progression/SaveManager.gd Atomické uložení a načtení
scripts/ui/                       Adaptivní Control UI, formuláře a racky
scripts/training/                 Kroky, validátor, zvýraznění, generátor a profil
data/infrastructure/baseline.json  Výchozí společná infrastruktura
data/missions/campaign.json        50 datových misí (prvních24 nezměněno)
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

- `stage1.gd`: první mise, chyba, ověření a uložení.
- `campaign.gd`: všech50 misí proti skutečnému stavu a shoda původních24 definic.
- `regression.gd`:88 kontrol cílů, RAID, sítí, bezpečnosti, terminálu, save/load a XP.
- `extended.gd`:35 kontrol LXC, VSS, VHDX typů, Replica, hot spare a kvót.
- `ui_smoke.gd`: všechny mise přes skutečné formuláře, potvrzovací dialogy
  a kontextové otázky; přechody mezi všemi hlavními obrazovkami.
- `tutorial_first.gd`: všech9 kroků WEB01, chybná RAM, obnovení kroku i kampaně.
- `lessons.gd`: všechny lekce v režimech Učím se / Procvičování / Zkouška.
- `training_features.gd`: parametrizace, všechny kombinace filtrů, obnova série,
  migrace původního save a doporučení slabých oblastí.
- `training_ui.gd -- --all-modes`: skutečné formuláře a navigace všech lekcí
  ve všech3 režimech, včetně kontroly, že zkouška nemá zvýraznění.
- Vizuální snímky vytvoří grafický běh
  `Godot_console.exe --path . --script tests/ui_smoke.gd -- --screenshots`.
  Přepínač `--small` testuje okno1280×720.

## Rozsah simulace a známá omezení

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
