# IT Support Simulator: Datacenter Academy

Český offline 3D simulátor IT administrátora z první osoby pro Godot4.x.
Vytvořeno a ověřeno v Godotu4.7.2.stable.official.ed1daf0bf.
Obsahuje65 praktických misí,21 interaktivních
lekcí ve třech režimech, náhodné procvičování, osobní přehled znalostí a50
studijních článků z poskytnutých Notion příruček. Původních24 misí zůstalo zachováno.

## Spuštění

**Windows:** rozbal celý `builds/ITSupportSimulator-Windows.zip` a spusť
`ITSupportSimulator.exe`. Připravené EXE je také v
`builds/windows/ITSupportSimulator.exe` s vloženým PCK. PC OpenXR je součást Godotu;
Android vendor plugin se přibaluje pouze do APK.
Menu **HRÁT V KLASICKÉM 3D** otevře původní FPS hru a načte místní postup.
**HRÁT VE VR / PICO 4 · OpenXR** uloží postup a spustí stejnou hru s OpenXR.
Pro PC VR připoj headset přes funkční PC VR streaming a nastav kompatibilní aktivní
OpenXR runtime. Nedostupný runtime/headset zobrazí chybu a menu pro klasické 3D.
Z VR lze přes pauzu → hlavní menu zvolit klasické 3D se stejným GameManagerem/save.

**PICO 4:** `builds/pico4/ITSupportSimulator-PICO4.apk` je podepsaný sideload
Debug APK pro ARM64, běžný PICO 4, Android min 29 / target 34. Spouští VR přímo.
Zapni vývojářský režim a USB debugging, připoj USB a v headsetu povol počítač:

```powershell
adb devices -l
adb install -r builds/pico4/ITSupportSimulator-PICO4.apk
adb shell am start -n cz.academy.itsupport/com.godot.game.GodotAppLauncher
```

Hru lze spustit také z knihovny aplikací PICO. **Fyzický PICO 4 nebyl při vývoji
připojen; tracking, komfort a stabilních 72 FPS zatím nejsou ověřené na zařízení.**
APK není vydání pro obchod. V repozitáři jsou zdroje, hotový Windows ZIP,
PICO APK a `builds/VERIFICATION.json`. EXE rozbal ze ZIPu; samotný Release EXE
překračuje limit GitHubu 100 MiB pro jeden soubor, proto se přímo do Gitu neukládá.

**V Godotu:** importuj `project.godot` a stiskni **F5**. Hlavní scéna je
`scenes/world/Game.tscn`. Součástí projektu je OpenXR Vendors **5.1.0-stable**
(minimum Godot 4.6), včetně nativních knihoven a licencí. Editor je Godot 4.7.2.

## VR ovládání a komfort

- Levý joystick: pohyb po zapnutí plynulé chůze. Výchozí teleport: drž klik
  levého joysticku, namiř oblouk na volnou podlahu a uvolni. Neprochází zavřenými
  dveřmi ani racky; cílová kapsle musí mít prostor.
- Pravý joystick: snap turn (výchozí 30°, také 15/45°); nad otevřeným monitorem
  nahoru/dolů posouvá obsah. Smooth chůze má rychlost 0,8–2,5 m/s.
- Trigger: ray interakce se zařízeními a skutečná tlačítka monitoru; držení
  dovoluje táhnout posuvníky. Levý paprsek lze použít také pro kliknutí.
- Grip nablízko: uchopení konkrétní náhrady ze servisní skříně; disk sleduje
  grip pose ovladače. Po uvolnění zůstává v inventáři u pasu, u skříně se vrátí,
  u slotu se otevře bezpečné vložení. Vytažení/vložení zachovává kontrolu serial,
  zálohy, hot-swap a potvrzení. Grip kabelu vezme konektor, trigger zvolí port.
- Menu podle profilu nebo **B/Y**: pauza/návrat. **A/X**: mise; při otevřeném
  monitoru jej přemístí před aktuální pohled. Systémové tlačítko PICO se nepřebírá.
- Pauza → **Komfort VR / výška / pohyb**: teleport/plynulá chůze, snap,
  rychlost, vsedě/vestoje a kalibrace výšky. Při ztrátě focus nebo tracking se
  interakce pozastaví. Fyzický odchod z akademie se sleduje i s otevřeným monitorem.
- Administrace je původní UI na světově ukotvené obrazovce 1,76 × 1,32 m,
  SubViewport 1600×1200. Po zaměření textového pole se objeví virtuální klávesnice
  s českými znaky, Shift, Backspace, Enter a Tab. Formuláře VM/CPU/RAM, VLAN/IP,
  disky, zálohy, RAID, Hyper-V, ticket i simulovaný terminál používají původní model.

Standalone profil používá OpenGL Compatibility, multiview OpenXR, 2× MSAA,
sdílené modely/materiály/MultiMesh, bez stínů a screen-space efektů. Neotáčí
ventilátory. Žádá 72 Hz, pokud runtime tuto frekvenci nabízí; není to výsledek
měření FPS. Nevyžaduje Enterprise, sledování očí/obličeje ani optické ruce.
Vendor plugin zůstává samostatný, takže další PICO varianty lze doplnit později.

## Přenos uloženého postupu mezi PC a PICO

PC i PICO mají vlastní lokální `user://academy_save.json`; PC 3D/VR ho sdílí.
XP, mise, výsledky lekcí/zkoušek a infrastruktura zůstávají v původním schématu 2.
Obraz, klávesy a VR komfort mají vlastní lokální CFG; automatická synchronizace není.
Pauza → **Přenos uloženého postupu** → **Exportovat postup** vytvoří validovaný
`user://academy-transfer.json`. **Importovat postup** ověří strukturu, zálohuje
dosavadní save a vrátí hru do menu. Dočasné lekce se po načtení neobnovují.

Na PC je uživatelská složka
`%APPDATA%/Godot/app_userdata/IT Support Simulator- Datacenter Academy/`.
Debug APK dovoluje přístup přes `run-as`; pro přenos spusť hru, vrať ji do menu
a z adresáře s přenosovým souborem použij např.:

```powershell
adb push academy-transfer.json /data/local/tmp/academy-transfer.json
adb shell run-as cz.academy.itsupport cp /data/local/tmp/academy-transfer.json files/academy-transfer.json
```

Pro opačný směr: `adb exec-out run-as cz.academy.itsupport cat files/academy-transfer.json`
ulož beze změny UTF-8 (např. přesměrováním v `cmd.exe` nebo Pythonem;
starý Windows PowerShell může změnit kódování). Potom proveď import ve hře.

## Sestavení obou platforem

Nainstaluj oficiální export templates **4.7.2.stable** (shodné s editorem),
JDK 17 a Android SDK. Skutečná přiložená 4.7.2 šablona používá compile SDK 36,
Build Tools 36.1.0, NDK 29.0.14206865 a Gradle 8.11.1. SDK min/target APK jsou 29/34.
`tools/build_platforms.py` nastaví cesty SDK/JDK, rozbalí Android build template,
exportuje Windows Release + PICO signed Debug, ověří podpis/manifest/architekturu,
spustí skutečné Windows EXE mimo projekt a vytvoří kompletní ZIP a
`builds/VERIFICATION.json` s SHA256. Při připojeném autorizovaném PICO se pokusí
o instalaci a spuštění; to stále nenahrazuje ruční test tracking/FPS.

```powershell
python tools/build_platforms.py --godot 'C:/cesta/Godot_console.exe' --sdk "$env:LOCALAPPDATA/Android/Sdk" --jdk 'C:/cesta/jdk-17'
python tools/test_windows.py --godot 'C:/cesta/Godot_console.exe'
```

Oficiálně ověřené podklady: [Godot XR Android](https://docs.godotengine.org/en/stable/tutorials/xr/deploying_to_android.html),
[inicializace OpenXR](https://docs.godotengine.org/en/stable/tutorials/xr/setting_up_xr.html),
[Vendors 5.1.0](https://github.com/GodotVR/godot_openxr_vendors/releases/tag/5.1.0-stable),
[konfigurace Vendors](https://godotvr.github.io/godot_openxr_vendors/getting-started/installation.html).

## Ovládání a první směna

- **WASD** chůze, **myš** rozhlížení, **Shift** rychlá chůze, **E** interakce,
  **F** baterka, **Tab** zadání a skutečné cíle, **Escape** pauza či návrat od
  počítače. Citlivost, klávesy a zvuk nastavíš ve společném Nastavení z menu i pauzy.
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

Administrátorské konzole jsou dostupné na monitorech. První směna nabízí krátké přeskočitelné seznámení; znovu ho otevřeš z pauzy:

- Vstupní hra zůstává plně 3D: chůze po serverovně, fyzické interakce,
  dveře i samostatná tréninková místnost. Konzole se otevírají nad tímto světem.
- Sdílené téma rozlišuje grafitové pracovní plochy, tyrkysovou potvrzovací
  akci a zlatého instruktora. Výběr navigace má vlastní zvýraznění.
  Chyby, dokončení i neaktivní možnosti mají také textový stav.
- Záhlaví konzole ukazuje platformu, hostitele a skutečný cíl formuláře,
  včetně VM předvolené bez kliknutí do stromu. Pole jsou seskupená a
  potvrzení zůstává v pevné spodní části, zatímco formulář lze posouvat.
  Formátová chyba se objeví přímo u pole a předá mu fokus; nezmění skóre.
- Filtry misí a lekcí zůstávají nad posuvným seznamem. Stav dokončení je
  označený textem a symbolem. Podrobnosti zkráceného popisu lekce zobrazí tooltip.
- HUD kampaně ukazuje počet splněných cílů, další nesplněný cíl a klávesu zadání.

- Hlavní menu: **Nastavení** otevírá přepínač celé obrazovky a rozlišení16:9:
  1280×720,1600×900,1920×1080,2560×1440,3200×1800 a3840×2160 (4K UHD).
  Po **Použít nastavení** nebo **F11** potvrď obraz do 15 sekund. Bez potvrzení
  se vrátí poslední potvrzené zobrazení. Nastavení se při chybě zápisu neuloží.
- **Zvuk** ukládá hlasitost a ztlumení; **Ovládání** citlivost a vlastní klávesy
  s kontrolou kolizí a obnovením výchozích. Escape a F11 zůstávají vyhrazené.
  **Rozhraní** mění text na 100/115/130 % nezávisle na rozlišení renderování.
- Předvolby **Úsporná / Vyvážená / Vysoká** skutečně mění stíny, MSAA a obrazové
  efekty. VSync a limit 30/60/120/144 FPS jsou samostatné volby. Kompatibilní
  renderer se stále spouští parametrem `--rendering-method gl_compatibility`.
- Vybrané rozlišení určuje skutečný počet vykreslovaných pixelů. V režimu okna
  se okno na menším monitoru vejde do pracovní plochy; vykreslovací rozlišení zůstává zvolené.
- Písmo v menu, konzolích, racku i terminálu se přepočítává pro zvolené rozlišení.
  Ikony ovládání používají vektorové SVG textury, které se také rasterizují
  podle velikosti na obrazovce. Ve4K se zachovává ostrost i poměr stran16:9.
- **Ukončit hru** v hlavním menu uloží rozehraný stav a zavře aplikaci.
  Stejné uložení probíhá při zavření okna křížkem.
- Myš: výběr serveru, panelu, polí a operací. Kolečko: posun obsahu konzole
  a sekcí. Ticket nebo instruktor se otevírá tlačítkem vpravo nahoře. Tab: přesun mezi formulářovými poli.
- Menu → Zahájit směnu nebo Tickety → první laboratoř.
- **Tréninkové centrum** v hlavním menu nebo **Trénink** v horní navigaci otevírá lekce,
  náhodné procvičování, Moje IT znalosti a interaktivní IT slovník.
- **Učím se** ukazuje aktuální krok, šipku a zvýraznění skutečného ovládacího
  prvku. Krok postupuje teprve po potvrzené události nebo odpovídajícím stavu.
  Instrukce zůstávají nad konfigurací. **Zobrazit krok** otevře správnou sekci,
  operaci i krok průvodce; podrobnosti otevře **Instruktor / zadání**.
  Z něj se tlačítkem **Zobrazit potřebný panel** vrátíš přímo k formuláři.
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
- Horní navigace otevírá Proxmox, Hyper-V, Storage, síť, terminál a studijní přehledy.
  Záhlaví vždy rozlišuje hlavní a cvičnou infrastrukturu.
- Vlevo zůstává strom zařízení a seznam sekcí; vpravo vyber jednu operaci.
  **Přehled** ukazuje živý stav. **Podle ticketu** soustředí související činnosti;
  ostatní sekce dovolují experimentování. Ve zkoušce tato zkratka není dostupná.
- **Create VM — průvodce** má kroky Identita → ISO → CPU/RAM → Disk → Síť →
  Shrnutí/instalace. Každé **Uložit a Další** provede skutečný zásah. **Zpět**
  zachová rozepsané hodnoty; závěr nabízí instalaci OS, start a ověření služby.
- Ticket a instruktor se přepínají tlačítkem nahoře. **← Konfigurace** vrátí
  rozpracovaný formulář. Seznamy misí a lekcí mají hledání i filtr dokončení;
  hledat lze také ve slovníku a článcích.
- Strom Datacenter / Hostitel / VM umožňuje vybrat uzel a předvolit VMID ve
  formulářích. Nabídky ukazují ID, název i skutečného hostitele. Operace omezené
  na PVE-01/HV-01 nabídnou přepnutí na tento uzel. Hyper-V nepřijme PVE VM ani
  nativní migraci mezi platformami; k tomu zůstává samostatný offline převod.
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
- Nastavení, rozlišení a F11 zachovají formuláře, posuv, fokus a kurzor včetně
  nepotvrzeného čísla, nabídek a výběru disků. Editace čte aktuální konfiguraci;
  rozepsaný koncept má přednost. Síťový přehled zahrnuje také nově vytvořené VM. Každá VM má vlastní koncept.
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
Diagnostika čte vybraného hostitele. Start a vypnutí přes terminál používají
stejné hodnocení, události výuky a ukládání jako formuláře. Ve volném tréninku
a výukových režimech s povoleným undo je lze vrátit jako poslední zásah;
diagnostické dotazy historii zásahů nemění.

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

## Ověření

V PowerShellu s cestou ke console variantě Godotu:

```powershell
./tools/Test-All.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
```

Pro oba nové exporty používej `tools/build_platforms.py` nebo
`tools/Build-Platforms.ps1`. Staré `build_windows.py` / `Build-Windows.ps1`
popisují předchozí balení do `build/`; nové balíčky jsou v `builds/`.
`tools/test_windows.py` ověřuje aktuální kompletní Windows distribuci i její PCK.

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

- `terminal_sessions.gd`: skutečné UI terminálu, správný hostitel, undo,
  ukládání a jeho selhání, kroky/hodnocení všech tří výukových režimů a ochrana kampaně.
- `xr_modes.gd`: 69 syntetických kontrol společného desktop/VR stavu, PICO profilu,
  controller inputs, pohybu/grip, SubViewport kliků/klávesnice, komfortu,
  zrušení výuky při fyzickém odchodu s otevřenou konzolí a při teleportu ve všech
  třech režimech, validovaného exportu/importu. Nenahrazuje skutečný headset.
- `platform_context.gd`: odmítnutí nesprávné platformy a neplatných cílů bez změn infrastruktury.
- `console_ux.gd`: skutečná kliknutí šesti kroky, kontext, posuv, fokus,
  formuláře, VM101 v síti, timeout obrazu a preference; `-- --screenshots` pořídí snímky.
- `ui_design.gd`: 162 kontrol rozhraní v 1280×720, 1920×1080 a 3840×2160,
  pokaždé s textem 100 % i 130 %. Skutečné klikání navigací, místní validace,
  editace klávesnicí, kontext VM a zachování fokusu při hledání.
  Grafický běh `-- --screenshots` ukládá `test-output/design-final-*.png`.
- `DesignMCP.tscn` / `ui_design_world.gd`: grafická matice skutečné hlavní
  3D scény, HUD, konzole, nastavení a výuky ve stejných šesti kombinacích.
  Lze spustit přes Godot MCP; `-- --quit-after-design` ukončí samostatný běh.
  Používá vlastní save i nastavení, jako ostatní testy.
- `world_ui.gd`: seznámení, pauza/nastavení, modalita, psaní bez chůze,
  chyby ukládání, skutečné předvolby a HUD všech režimů; `-- --screenshots --benchmark`.
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
- `tutorial_navigation.gd`: všech21 vedených lekcí přes skutečné klikání v novém UI,
  opětovná volba předvybraného hostitele/Enter, instruktor a správné formuláře,
  obnova posledního kroku VM, koncepty a zvýraznění po obnovení posuvu.
  `-- --screenshots` pořídí snímky v720p/1080p/4K; test se spouští i v Test-All.
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
- Není vytvořen instalátor. Samostatné Windows EXE používá oficiální Release
  šablonu a vložený PCK. PICO APK je podepsané
  Debug sestavení pro sideload, s lokálními uloženými daty.

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
