# Zadání pro AI: praktická výuka a nové herní funkce pro PC a PICO 4 bez dostupného headsetu

Jsi vývojář Godotu, návrhář výukových her a VR interakcí. V existujícím projektu
**IT Support Simulator: Training academy** skutečně implementuj následující rozšíření:

1. Prověř a zlepši připravenost rozhraní a ovládání pro PICO 4 v rozsahu ověřitelném bez headsetu.
2. Doplň krátké interaktivní seznámení, ve kterém hráč ovládání skutečně používá.
3. Přidej souvislé pracovní směny s navazujícími incidenty nad společnou infrastrukturou.
4. Doplň srozumitelné vizuální vysvětlení síťových závad a porovnání stavu před opravou a po ní.
5. Přidej anglický poslech do existujícího Londýna pomocí skutečných mluvených nahrávek.

Nestačí plán, návrh obrazovek, nefunkční tlačítka nebo další prompt. Proveď změny
v současné hře, otestuj je, zdokumentuj a vytvoř Git commity. Na konci připrav
aktuální Windows EXE i PICO APK pomocí existujících build nástrojů.

## 1. Důležitá podmínka: uživatel teď nemůže hru zkusit na PICO

**Fyzický PICO 4 není pro tuto etapu dostupný.** Uživatel nemůže provádět ruční
zkoušky v headsetu. Nečekej na jeho připojení a nevyžaduj od uživatele test jako
podmínku dokončení práce, kterou lze provést na PC.

- Implementuj vše, co lze zodpovědně připravit a ověřit z kódu, na desktopu,
  v grafickém Godotu, se syntetickými XR vstupy a v exportovaných balíčcích.
- PC výsledek musí být skutečně hratelný. Ve VR prověř stejné funkce přes stávající
  SubViewport, paprsky, triggery, virtuální klávesnici a simulované XR trackery.
- Nepiš, že hra běží plynule na PICO, že bylo potvrzeno 72 FPS, optická čitelnost,
  tracking, pohodlí nebo délka hraní na zařízení. To bez zařízení nevíš.
- Výsledek označ **„Implementováno a ověřeno na PC a synteticky v XR;
  přímý test na PICO 4 čeká na dostupný headset.“**
- Připrav samostatný stručný postup budoucího hardwarového testu. Jeho položky
  ponech jako NEPROVEDENO; syntetické testy je nesmějí automaticky označit PASS.
- Není potřeba hledat headset opakovanými ADB dotazy. Neinstaluj aplikaci na
  telefon ani na jiné náhodně připojené Android zařízení.

Nepřítomnost headsetu je známé omezení ověření, nikoli důvod skončit u návrhu.

## 2. Nejdřív zjisti skutečný současný stav

Přečti `AGENTS.md`, nejnovější části `PROGRESS.md`, `README.md`, `TEST_REPORT.md`,
`docs/ACADEMY_HUB.md`, `docs/VR_TEST_REPORT.md`, `docs/ENGLISH_LONDON.md`,
`docs/PROGRAMMING_ACADEMY.md`, `NAVOD_PICO4.md` a `build/README.md`.

Starší `PROMPT_ACADEMY_HUB_PC_VR.md` a `PROMPT_LONDON_ENGLISH_VR.md` popisují
již implementovanou práci. Neprováděj jejich zadání znovu. Tento soubor je nové
zadání; nejnovější pravdivý stav vždy ověř v aktuálním kódu a reportech.

Výchozí projekt už obsahuje:

- Společný nástupní hub a čtyři skutečné fyzické cesty do místností.
- 65 IT misí, 21 IT lekcí ve třech režimech, náhodné série a vlastní výsledky.
- Programming Academy: 28 lekcí, 60 úloh a vlastní Python/Web prostředí.
- English in London: šest situací B1–B2, varianty, zákaznické dotazy, skutečný
  cvičný nákup a platbu, kontrolu lístku, příchod k věži a 20otázek London Quiz.
- PC i XR ovládání, teleport, snap turn, režim sezení/stání, kalibraci a pauzu
  při ztrátě focus/tracking. Tyto funkce neprezentuj jako nově vytvořené.
- Atomický SaveManager, validaci, zálohy, odloženou kampaň a přenos postupu.
- Úvodní menu s přesným podpisem **`Vytvořil: Vít Kellner a Codex`** vpravo dole.

Prohlédni zejména:

- `scripts/world/GameShell.gd`, `FirstPersonController.gd`, `Datacenter3D.gd`,
  `AcademyHub.gd`, `TrainingZone.gd`, `WorldVisuals.gd` a scény světa.
- `scripts/core/GameManager.gd`, `GameModeManager.gd`, `DisplaySettings.gd`.
- `scripts/xr/XRPlayer.gd`, `VRMonitor.gd`, `VRSettings.gd`, `VirtualKeyboard.gd`
  a `scenes/xr/academy_actions.tres`.
- `scripts/ui/UIController.gd`, `MenuPresentation.gd`, `AcademyTheme.gd`.
- `scripts/simulation/`, `scripts/evaluation/ObjectiveEvaluator.gd`,
  `scripts/progression/SaveManager.gd` a `SaveValidator.gd`.
- `scripts/english/`, `data/english/` a existující generátory Londýna.
- Relevantní testy v `tests/` a skutečný seznam v `tools/Test-All.ps1`.

Používej dostupný Godot MCP a přímé změny souborů podle potřeby. Pokud konkrétní
MCP operaci neumí, použij oficiální CLI a uveď skutečně použitou cestu ověření.
Nezakládej druhý projekt, nevracej repozitář na historický commit a chraň cizí
rozpracované změny. Ověř výchozí Git stav a případná existující selhání testů.

## 3. Neporušitelné požadavky

- Zachovej plnou funkčnost Windows PC i standalone PICO 4. Stejné herní cíle
  musí jít splnit na obou platformách, bez povinné fyzické klávesnice ve VR.
- Zachovej AcademyTheme, existující fonty, oversampling textu a DPITexture ikon.
- Podpis autorů zůstává přesný, čitelný a pouze v úvodním menu. Žádná nová volba
  ho nesmí překrývat ani měnit pořadí klávesového fokusu.
- Neměň prvních 24 misí, `legacy_campaign.json`, jejich referenční řešení ani
  význam stávajících ID. Nové směny nejsou přepsané staré mise.
- Neodstraňuj současné kurzy, místnosti, dekorace ani funkce kvůli výkonu či velikosti.
- Zachovej existující enum hodnoty režimů včetně hubu; případné rozšíření musí být kompatibilní.
- Testy musí nastavit `SaveManager.path_override` a vlastní konfigurace
  `DisplaySettings` / `VRSettings` **před vytvořením GameManageru nebo scény,
  která ho vytváří**. Nikdy nečti ani nepřepisuj hráčův `academy_save.json`.
- Nové ukládané větve musí mít skutečnou validaci. Staré platné save se načtou
  bez ztráty výsledků, XP, kampaně nebo rozehrané infrastruktury.
- Výuka, náhodná série, nový úvod, směna, programování ani Londýn nesmějí
  přepsat odloženou kampaň nebo cizí rozehranou relaci.
- Zachovej offline hraní. Žádná povinná registrace, server, cloudový účet,
  placené API, mikrofon nebo internetové připojení při hraní.
- Katalogy udržuj konzistentní s generátory. `tools/build_content.py`
  přegenerovává JSON, rozšíření používá `build_extension.py` / `extension_catalog.py`.
  Nezapisuj změny jen do vygenerovaného souboru, pokud ho generátor příště přepíše.

## 4. PICO připravenost, ovládání a diagnostika bez headsetu

Navazuj na existující úsporný profil: Compatibility, sdílené materiály a modely,
MultiMesh, omezení stínů a screen-space efektů. Nevyměňuj renderer ani OpenXR
plugin bez konkrétního reprodukovaného důvodu a následné regrese.

### Rozhraní a interakce

- Prověř všechny nově upravované obrazovky uvnitř stávajícího VR monitoru
  1600×1200, včetně prostoru virtuální klávesnice. Nezvyšuj bez měření rozlišení
  všech SubViewportů a nepřidávej zbytečně další živé obrazovky.
- Zkontroluj ořezání textu, posuv, malé cíle, překrývající se prvky, fokus,
  čitelné hover/pressed stavy a chování úplného press/release triggeru.
- Levá i pravá ruka musí umět ovládat celé nové UI. Stisk na jednom tlačítku
  a uvolnění mimo něj nesmí spustit akci. Současné triggery nesmějí zdvojit operaci.
- Zachovej drag, scroll, přemisťování panelu A/X a zavírání B/Y.
  Systémové tlačítko PICO nepřebírej.
- Přidej do stávajícího komfortního nastavení možnost přizpůsobit velikost
  a vzdálenost pracovního panelu, pokud taková volba dosud chybí. Preferuj
  rozumně omezené hodnoty, obnovení výchozího nastavení a trvalé uložení.
- Při změně fyzické velikosti panelu musí odpovídat i převod 3D paprsku na
  pixely, kurzor a virtuální klávesnice. Nestačí změnit jen mesh obrazovky.
- Výchozí komfortní hodnoty zachovej, pokud nemáš prokazatelnou závadu.
  Nové volby lze technicky ověřit; pohodlí v optice headsetu zůstává neověřené.
- Vše musí mít desktopové ovládání myší, klávesnicí a viditelný fokus.

### Měření a diagnostika

- Přidej volitelný, výchozím stavem vypnutý diagnostický panel. Ukaž skutečná
  dostupná měření: FPS, čas snímku, renderer, renderovací rozlišení a dostupné
  engine statistiky vykreslování/paměti. Vysvětli jednotky a případné odhady.
- CPU a GPU časy uváděj pouze tehdy, pokud je opravdu měříš. Z hodnoty 1/FPS
  neodvozuj domnělý GPU čas. Nezaměňuj požadovanou obnovovací frekvenci za FPS.
- Diagnostika se aktualizuje střídmě, nevytváří další náročný viewport,
  neblokuje paprsek a při vypnutí nemá významnou režii.
- Pro případné optimalizace porovnej před/po při stejné scéně, pohledu,
  rozlišení a kvalitě. Uveď PC hardware a podmínky měření. Výkon RTX/PC není
  důkaz výkonu PICO. Nedělej plošné vizuální degradace bez naměřeného důvodu.

## 5. Skutečný interaktivní úvod

Současné seznámení je převážně textové. Rozšiř existující systém tak, aby hráč
postupoval vlastními akcemi a mohl si úvod kdykoliv zopakovat ze stávající pauzy.
Nevytvářej dvě soupeřící onboardingová menu.

Připrav krátký, přibližně 3–5minutový úvod se srozumitelnými kroky:

1. Rozhlédnutí a orientace podle značení hubu.
2. Přesun na označené místo: PC chůzí, VR teleportem nebo zvolenou plynulou chůzí.
3. Použití ovladače dveří a skutečný průchod otevřeným vstupem.
4. Zaměření a otevření pracovního monitoru.
5. Aktivace skutečného UI prvku; ve VR paprskem a triggerem.
6. Uchopení jednoznačně označeného cvičného náhradního dílu a jeho bezpečné vrácení.
7. Otevření pauzy, pokračování a zakončení úvodu s vysvětlením dalšího vstupu do akademie.

Rozvržení můžeš přizpůsobit současné budově. Použij existující místnosti,
interakce a bezpečný dočasný výukový stav; nepřestavuj kvůli tomu celý hub.

- Krok se dokončí až po správné skutečné akci nad správným cílem. Samotný klik
  na „Další“, přítomnost libovolného objektu v inventáři nebo stisk klávesy nestačí.
- Chybné zařízení krok nesplní. Staré události před začátkem kroku se nepočítají.
- PC a VR mají stejné cíle, ale správné popisky ovládání podle aktivní platformy.
- Hráč vidí jeden aktuální úkol, svůj postup a případnou krátkou nápovědu.
  Zvýraznění není přes celou obrazovku a nezůstává na objektech po ukončení.
- Úvod musí jít přeskočit, zrušit a zopakovat. Ovládání a kurzor se vždy korektně obnoví.
- Přerušený úvod nesmí ponechat nesený cvičný předmět, otevřenou modalitu,
  změněné produkční zařízení nebo rozehranou výukovou relaci.
- Odlož a po skončení obnov předchozí kampaň či směnu včetně infrastruktury.
  Neprováděj reset hráčova postupu. Úvod neuděluje opakovaně farmitelné XP.
- Ukládej pouze potřebnou preferenci dokončení/přeskočení. Nepřepisuj první
  starou misi a nevkládej do hráčova save pracovní testovací scénáře.
- První spuštění může úvod nabídnout; nesmí bez možnosti odmítnutí přerušovat
  zkušeného hráče nebo opakovaně začínat po každém návratu z místnosti.

## 6. Souvislé pracovní směny

Přidej samostatnou volbu **Souvislé směny**, přehledně dostupnou z nabídky
pracovní serverovny. Nepřetěžuj hlavní menu další velkou sadou tlačítek.

Připrav alespoň **tři skutečně hratelné směny, každou nejméně se třemi navazujícími
tickety**. Použij stabilní nová ID a vlastní katalog. Příklady zaměření:

- Síť a dostupnost: ověření fyzického připojení, oprava konfigurace a následné
  ověření služby nebo operace závislé na funkční síti.
- VM a provoz: oprava existující VM, konfigurace prostředků a navazující
  záloha nebo obnova podle skutečně podporovaných operací.
- Storage a servis: diagnostika, bezpečná práce s konkrétním diskem, dokončení
  obnovy pole a závěrečné ověření provozu.

Zadání sestav podle reálných možností simulátoru. Nevymýšlej VPN, nové servery
nebo servisní úkony, které současný model neumí, pokud je sám plně neimplementuješ.

### Pravidla směny

- Směna má jeden počáteční stav infrastruktury. Přijetí dalšího ticketu nesmí
  znovu načíst baseline a smazat hráčovy předchozí konfigurace, hardware či inventář.
- Nové incidenty aktivuj explicitně a cíleně. Rozliš plánovanou poruchu od
  resetu celé infrastruktury a chraň nesouvisející předchozí změny.
- Návaznosti jsou skutečné: například úspěšná záloha vyžaduje dostupnou službu
  a platnou síť. Vyhodnocení čte model, nikoli pořadí odklikaných obrazovek.
- Hráč může provádět smysluplné akce i jiným správným pořadím. Ošetři situaci,
  kdy některou podmínku dalšího ticketu opravil ještě před jeho přijetím.
- Předání ticketu vyžaduje konkrétní ověření výsledku. Předčasné předání se
  srozumitelně odmítne. Dokončení ani odměna se nesmějí započítat dvakrát.
- Ukaž aktuální ticket, frontu/navazující práci, splněné podmínky a závěrečný
  rozbor celé směny. Nepřekrývej tím běžný pohyb a práci na monitoru.
- Rozliš úspěšnou akci v paměti od úspěšného uložení. Chyba zápisu má
  trvalé upozornění a opakování, stejně jako současná hra.
- Nabídni výslovný restart aktuální směny s upozorněním na ztrátu její
  rozpracované práce. Restart nemaže historii výsledků ani kampaň.
- Po chybách musí být jasné, zda lze situaci opravit, nebo je nutný restart.
  Nesmí vzniknout tichý deadlock nebo předstírané úspěšné dokončení.

### Ukládání a přechody

- Dej směnám vlastní validovanou větev relace/výsledků. Nezneužívej starou
  kampaň nebo náhodnou sérii tak, že přepíšeš jejich data.
- Ulož definici/ID a verzi směny, pořadí a stav ticketů, skutečný stav světa,
  potřebné ověřovací události, výsledky a ochranu před dvojím započtením.
- Rozpracovaná směna musí přežít skutečné ukončení a nové vytvoření aplikace.
- Zahájení směny odloží kampaň. Výslovná volba Kampaň obnoví původní kampaň;
  volba Pokračovat ve směně obnoví poslední směnu. Tyto akce nesmějí být zaměnitelné.
- Odchod do hubu, IT výuky, programování nebo Londýna bezpečně odloží směnu.
  Návrat do pracovního prostoru obnoví správnou dříve zvolenou pracovní relaci;
  přechody mezi kurzy ani restart aplikace nesmějí zničit kampaň nebo směnu.
- Restart směny, nové spuštění jiné směny a obnovení kampaně čistí lokální
  undo a koncepty podle příslušné relace. Nelze vrátit událost z cizí směny.
- Historie a odměny směn mají jasná pravidla, omezenou velikost a validaci.
  Neměň zpětně staré skóre a neodemykej původní kampaň pouhým opakováním směny.
- Zachovej migraci a validovaný export/import postupu. Pokud save rozšíříš,
  uprav související validátor a testy; neodmítej dříve platné staré soubory.

## 7. Vizuální vysvětlení síťových závad

Do současné diagnostiky doplň přehled, který vysvětlí alespoň tyto tři případy:
odpojený nebo nesprávně připojený kabel, chybnou VLAN a chybnou IP/bránu.
Pokryj odpovídající existující úlohy a nové směny, kde se tyto závady vyskytují.

- Zobraz srozumitelnou cestu, například **VM → síťové rozhraní → switch → brána
  → cílová služba**, pouze pokud tyto části opravdu odpovídají danému modelu.
- Použij skutečné názvy a ID aktuální VM, hostitele, portu a cíle. Diagram
  nesmí ukazovat PVE-01 při diagnostice jiného hostitele jen kvůli výchozímu výběru.
- Stav uzlů a hran odvoď ze stejného modelu a ověřovacích pravidel jako hra.
  Nevytvářej druhou nezávislou logiku, která může tvrdit opak vyhodnocení mise.
- Rozliš funkční, vadné a dosud neověřené místo. Zelená nesmí znamenat jen to,
  že hráč otevřel nastavení nebo že v modelu existuje nějaký kabel.
- Přidej stručné „Co bylo zjištěno“, „Dopad na službu“ a srovnání důležitých
  hodnot před opravou a po ní. Ukaž jen informace potřebné pro daný problém.
- Diagram vysvětluje stav modelu. Netvrď, že simuluje skutečné pakety,
  plný síťový provoz nebo reálný operační systém.
- Učím se může ukázat příčinu a navrhnout další krok. Procvičování poskytne
  výsledky provedených kontrol a dobrovolnou nápovědu. Zkouška nesmí před
  odevzdáním automaticky odhalit přesnou chybu nebo správné nastavení.
- Stav se korektně obnoví po změně hostitele, undo, restartu, změně relace,
  načtení save a fyzickém odchodu. Žádný starý diagram z předchozí mise.
- Použij lehké Control/SVG/procedurální prvky ve stávajícím panelu, čitelné
  na PC i ve VR. Barvu doplň textovým stavem; žádné náročné částicové animace.

## 8. Poslech angličtiny v existujícím Londýně

Rozšiř LON01–LON06 o skutečný mluvený zvuk. Zachovej úroveň B1–B2, ceny,
počty osob, Standard/Flex, varianty, dotazy zákazníka a současné vyhodnocování.

- Pro první hotovou verzi namluv nejméně dvě klíčové repliky každé situace,
  celkem alespoň 12 různých přirozeně pronesených anglických replik. Zahrň
  smysluplně NPC odpovědi i zákaznické otázky; samotné namluvené názvy nestačí.
- Hráč musí mít možnost poslouchat, zopakovat repliku a přehrát ji pomaleji
  s dobrou srozumitelností. Pomalá varianta nesmí být jen nepřirozeně hlubší hlas.
- Text zůstává viditelný. Běžné dialogové volby fungují i se ztlumeným zvukem.
  Přehrání audia nesmí samo vybrat odpověď, provést platbu nebo udělit výsledek.
- Automatické přehrávání je volitelné. Hlasitost respektuje stávající zvukové
  nastavení; přiměřeně odděl řeč od krátkých UI zvuků.
- Při rychlém přepínání replik se stará řeč zastaví. Žádné souběžné dialogy
  po odchodu do jiné místnosti, ukončení lekce, otevření jiné situace či zániku scény.
- Při pauze nebo ztrátě focus/tracking se zvuk bezpečně pozastaví nebo zastaví.
  Obnovení nesmí spustit jinou repliku nebo několik nahrávek současně.
- Zvuk musí odpovídat přesně aktuálnímu textu, mluvčímu a variantě. Nikdy
  nepřehraj jiný počet osob, cenu či čas než ten, který nabízí skutečný dialog.
- Stabilní fráze lze sdílet. Dynamická replika bez odpovídající nahrávky
  zůstane textová a přehrání není nabízené jako funkční. Nepoužívej nesouhlasnou
  univerzální nahrávku a nepředstírej pokrytí všech vět, pokud je jen částečné.
- Použij distribuovatelné nahrávky nebo předem vygenerovanou řeč. Zapiš zdroj,
  licenci, způsob vytvoření a mapování ID/text → soubor. Nezaváděj povinné
  runtime TTS API, instalaci Pythonu ani závislost na systémovém hlasu Androidu.
- Hraní i přehrávání musí fungovat offline na PC a v prostředcích Android exportu.
  Použij přiměřeně komprimovanou řeč, načítej ji podle potřeby a nevytvářej
  velké nekomprimované WAV balíky či trvale rozbalenou knihovnu všech dialogů.
- Nová tlačítka obslouží myš, klávesnice i oba XR paprsky. Respektuj stávající
  režimy výuky a zkoušky; neprozrazuj řešení pomocí audio metadat nebo popisků.

Pokud prostředí neposkytuje použitelný způsob získání legálně distribuovatelné
řeči, nepřidávej tiché soubory, pípání ani simulované „přehrávání“. Dolož konkrétní
pokus a překážku, dokonči ostatní části a jasně označ chybějící mluvené nahrávky.
Samotný připravený audio přehrávač pak neoznačuj za dokončený anglický poslech.

## 9. Implementuj po ověřitelných etapách

Doporučené pořadí: výchozí regrese a VR diagnostika → interaktivní úvod →
souvislé směny a save → síťové vysvětlení → poslech → celková regrese a exporty.

Sdílej modely a současné interakce; nové části rozděl do přehledných komponent,
nepřidávej vše do jednoho obřího GameShellu nebo UIControlleru. Nerefactoruj
nesouvisející subsystémy bez potřeby. Běžné technické volby řeš samostatně.

Po funkční etapě spusť odpovídající testy, aktualizuj PROGRESS.md a commituj.
Není potřeba žádat o potvrzení každé etapy. Zastav a přesně popiš jen skutečný
externí blokátor; nepřítomnost headsetu jím pro desktopovou práci není.

## 10. Povinné ověření

Spusť celý aktuální `tools/Test-All.ps1` přes skutečný Godot. Nové smysluplné
regrese přidej do stejného runneru. Použij současný počet sad, ne historický
počet z reportu; žádné vynechání testu jen proto, aby vyšel zelený výsledek.

Příklad spuštění, cestu enginu ověř podle prostředí:

```powershell
./tools/Test-All.ps1 -GodotPath '../../Godot_v4.7.2-stable_win64_console.exe'
```

Kromě původních testů pokryj zejména:

- Úvod skutečnými vstupy a fyzikou na PC, synteticky ve VR, nesprávný cíl,
  přeskočení, zrušení, opakování a obnova upravené kampaně/směny.
- Všechny nové směny od začátku do konce přes skutečné operace. Prokaž
  přetrvání konkrétních hodnot mezi tickety a vliv jejich změny na vyhodnocení.
- Předčasné/dvojí odevzdání, dvojí trigger, alternativní správné pořadí,
  restart směny, selhání zápisu a jeho opakování bez dvojí odměny.
- Save a nové vytvoření GameManageru: správný ticket, stav infrastruktury,
  inventář, výsledky a oddělená kampaň. Test pouhého překreslení UI nestačí.
- Přechody směna ↔ hub ↔ IT výuka ↔ programování ↔ Londýn ↔ kampaň;
  ve všech třech IT výukových režimech a přes více než jeden přechod.
- Staré save, validaci nové větve, odmítnutí vadných ID/pořadí/hodnot a
  zachování původního souboru při selhání. Ověř také import/export postupu.
- Síťové diagramy pro každý požadovaný typ závady, správné/neověřené stavy,
  různá zařízení, opravu, undo a omezení nápovědy při zkoušce.
- Audio soubory, import a dekódování, nenulovou délku, mapování textu/variant,
  opakování, pomalou variantu, hlasitost a zastavení při změně relace/pauze.
  Odliš kontrolu souboru od skutečného poslechu a poslech na PC od headsetu.
- Velikost/vzdálenost VR panelu a správný ray → pixel převod po změně,
  oba ovladače, drag/scroll, uvolnění mimo tlačítko a virtuální klávesnici.

Nové integrační testy nesmějí ověřovat jen existenci uzlů a nápisů nebo splnit
úkol ručním nastavením výsledku. Doplň skutečné kliky, události, operace modelu
a negativní případy. U syntetických kliků používej úplný press/release a
souřadnice správného viewportu; respektuj měřítko při posuvu v malém okně.

### Grafické kontroly

- PC matice **1280×720, 1920×1080, 3840×2160 × text 100 % a 130 %**.
- Prohlédni skutečné snímky menu, úvodu, směny, diagnostiky a londýnského audio UI.
  Zachovej podpis autorů a dosažitelnost všech důležitých tlačítek.
- Nové UI ověř také v reálném obsahu VR SubViewportu 1600×1200 při obou
  velikostech textu, s otevřenou i zavřenou virtuální klávesnicí.
- Proveď grafickou kontrolu Compatibility pro PICO prostředky a běžného
  desktopového rendereru. Screenshot na monitoru není ověření optiky headsetu.
- Použij relevantní `ui_workflow`, `ui_design`, `ui_design_world` / DesignMCP,
  `world_ui`, `xr_modes`, `academy_hub`, `english_world`, `english_model`,
  `session_safety`, `save_safety` a nové testy podle skutečných změn.
- Nové chyby oprav. Předchozí selhání a statická varování odděl od nových;
  nemaž kontroly ani plošně nepotlačuj logy, aby se problém skryl.

## 11. Oba exporty a jejich skutečný obsah

Po dokončení zdrojů sestav a ověř **oba současné distribuční balíčky**:

- `build/ITSupportSimulator.exe`
- `build/pico4/ITSupportSimulator-PICO4.apk`

Použij `tools/build_windows.py`, `tools/build_platforms.py`, příslušné PowerShell
wrappery a `tools/test_windows.py` / `tools/test_pico.py`. Nejprve zkontroluj
jejich aktuální parametry. Nevytvářej znovu kořenovou složku `builds/`.

- Windows musí zůstat samostatné EXE s vloženými daty, spustitelné z cizí
  pracovní složky bez zdrojového projektu, sousedního PCK nebo instalovaného Godotu.
- Aktuální Windows pipeline vyžaduje **méně než 104 857 600 B (100 MiB)**;
  poslední distribuční verze měla jen malou rezervu. Před přidáním řeči skutečně
  spočítej velikostní rozpočet a ověř ho na výsledném exportu.
- Neobejdi limit vypnutím kontroly, odstraněním starého obsahu, UPX nebo ručními
  zásahy do PE. Použij úsporné audio a legitimní možnosti současné exportní pipeline.
- Pokud export narazí na reálný limit nebo chybějící nástroj, neopisuj nový
  hash k neověřenému starému souboru. Zachovej poslední platnou distribuci,
  uveď přesný problém a neoznačuj neprovedený export za hotový.
- PICO zůstává ARM64/OpenXR se současným identifikátorem balíčku a stejným
  podepisovacím certifikátem pro aktualizaci. Korektně zvyš verzi/versionCode.
- Ověř podpis, CRC, skutečný manifest, přibalené zdroje a skutečné audio soubory.
  Žádné testovací save, privátní klíče, pracovní adresáře nebo zbytečné WAV kopie.
- Ověř nové funkce proti skutečně zabaleným datům, ne pouze proti pracovnímu
  stromu. Doplň jejich kontrolu do existujících balíčkových testů/smoke testu.
- Přímý Windows smoke musí nastavit testovací save/config před GameManagerem.
- Testy prostředků vytažených z APK v desktopovém Godotu nejsou Android native
  start, fyzický tracking ani měření PICO výkonu. V reportu to výslovně rozliš.
- Aktualizuj SHA256SUMS, BUILD_INFO, VERIFICATION a odpovídající dokumentaci
  jen podle skutečně dokončených exportů. Uveď zdrojový commit nebo přesný
  deterministický manifest použitých zdrojů a soulad obsahu EXE/APK.

## 12. Dokumentace pro budoucí test na headsetu

Připrav krátký `docs/PICO4_HARDWARE_CHECKLIST.md`, pokud obdobný dokument už
neexistuje; jinak vhodně rozšiř stávající. Obsahuje konkrétní kroky a místo
pro budoucí skutečný výsledek:

- Instalace/aktualizace na běžném PICO 4, verze APK a PICO OS, spuštění z knihovny.
- Stereo, sledování hlavy a obou ovladačů, recenter, ztráta/obnova focus a tracking.
- Úvod, teleport, dveře, kolize, snap turn a sezení/stání.
- Čitelnost všech nových panelů, pohodlná velikost/vzdálenost a klávesnice.
- Nová směna, skutečné fyzické úkony, přechody mezi kurzy a obnova po restartu.
- Anglický poslech, správná replika, opakování, pomalá varianta a hlasitost.
- Měření FPS, dostupných časů snímku a paměti v konkrétních náročných místech
  i během delší relace. Uveď způsob měření, ne předvyplněné úspěšné hodnoty.
- Pohodlí uživatele a případná nevolnost jako pozdější subjektivní zjištění.

Všechny hardwarové položky nyní označ **NEPROVEDENO – headset není dostupný**.
Uživatel je v této etapě nemusí vyplňovat ani provádět.

## 13. Dokončení a předání

Aktualizuj PROGRESS.md, README, TEST_REPORT, VR report, popis nových směn,
poslechu a obou distribucí podle skutečného výsledku. Přidej trvalé snímky do
nové datované složky v `docs/ui-review/`; nespoléhej jen na ignorovaný test-output.

Vytvoř přehledné Git commity po funkčních etapách. **Push není součástí tohoto
zadání**, pokud ho uživatel následně výslovně nepožádá. V závěru stručně uveď:

1. Co bylo skutečně implementováno a kudy se k tomu hráč dostane.
2. Jak se ovládá úvod, směny, síťový přehled a poslech na PC i ve VR.
3. Které testy proběhly, jejich skutečné výsledky a odkazy na logy/snímky.
4. Jak byla ověřena ochrana kampaně, směn a starých save.
5. Které zdrojové commity a skutečné EXE/APK byly vytvořeny, jejich velikosti a SHA256.
6. Co je ověřené na PC, co synteticky v XR, co jen v APK datech a co čeká na headset.
7. Případné konkrétní blokátory nebo nedodělané části, včetně audia či exportu.

Implementaci neposuzuj jako hotovou podle počtu přidaných souborů. Rozhoduje
skutečný průchod hráče, konzistentní model a uložení, funkční PC rozhraní,
ověřené syntetické VR vstupy a poctivě popsané meze ověření bez PICO.
