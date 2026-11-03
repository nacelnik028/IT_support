# Zadání pro AI: pokračování práce, hlubší směny, poslech a společný přehled znalostí

Pracuj v existujícím projektu **IT Support Simulator: Training academy**.
Jsi vývojář Godotu a návrhář výukových her. Níže uvedené změny skutečně
implementuj, otestuj a dokonči v současné hře. Nestačí návrh, nové nápisy,
nefunkční tlačítka nebo další prompt. Nevytvářej druhý projekt.

## 1. Výsledek této etapy

Dokonči těchto šest oblastí:

1. Trvalé ukládání rozepsané práce, srozumitelný stav uložení a výslovné pokračování ve výuce.
2. Konzistentní hodnocení nápověd, chyb a rizik, zejména v souvislých směnách.
3. Nejméně dvě pokročilé směny s několika současnými incidenty, rozhodováním a skutečnými následky.
4. Konkrétní závěrečné vysvětlení příčin, provedených zásahů a ověřeného výsledku.
5. Samostatné poslechové úlohy v Londýně nad existujícími nahrávkami.
6. Společný přehled znalostí a doporučeného dalšího kroku pro IT, programování a angličtinu.

Zachovej PC i standalone PICO. PICO 4 nyní fyzicky není dostupný. Nečekej na
jeho připojení a nepožaduj po uživateli hardwarový test jako podmínku práce na PC.
Prováděj skutečné desktopové a grafické testy, syntetické XR vstupy a kontroly
skutečných exportovaných prostředků. Android native start, fyzický tracking,
stereo, optickou čitelnost, komfort, FPS a paměť na PICO označ jako neověřené.

## 2. Nejdřív zjisti aktuální stav

Přečti AGENTS.md, nejnovější části PROGRESS.md a README.md. Potom přečti:

- TEST_REPORT.md a build/BUILD_INFO.md, oba BUILD_INFO.json a build/VERIFICATION.json;
- docs/CONTINUOUS_SHIFTS.md, docs/LONDON_AUDIO.md a docs/ENGLISH_LONDON.md;
- docs/PROGRAMMING_ACADEMY.md, docs/ACADEMY_HUB.md a docs/VR_TEST_REPORT.md;
- docs/PICO4_HARDWARE_CHECKLIST.md, NAVOD_PICO4.md a build/README.md;
- skutečný seznam testů v tools/Test-All.ps1 a relevantní implementaci.

Předchozí prompty v repozitáři zachycují předchozí etapy. Neimplementuj je znovu.
Při nesouladu dokumentace a kódu nejprve ověř skutečné chování a nesoulad popiš.

Výchozí stav v době zadání:

- Společný hub a čtyři existující místnosti, PC/XR ovládání, praktický úvod.
- 65 IT misí, 21 IT lekcí ve třech režimech a náhodné procvičování.
- Programming Academy: 60 základních úloh, 28 lekcí a opravovací/generované varianty.
- Londýn: šest situací B1–B2, nákup, kvíz a 12 vybraných mluvených replik s pomalými variantami.
- Tři souvislé směny, každá se třemi navazujícími tickety nad společným stavem.
- Síťové vysvětlení, přizpůsobení VR panelu a volitelná diagnostika.
- Validovaný atomický save, odložená kampaň, vlastní větev směn a import/export.
- Poslední doložený celý Test-All měl 39 sad PASS. Ověř skutečný nynější počet.
- Poslední předání bylo bdae3ec; skutečný výchozí commit zjisti přes Git.

Hlavní místa implementace:

- scripts/core/GameManager.gd, GameModeManager.gd a DisplaySettings.gd;
- scripts/progression/SaveManager.gd a SaveValidator.gd;
- scripts/programming/AcademyManager.gd a CodeEditorController.gd;
- scripts/ui/UIController.gd, WorkingContext.gd, FormValues.gd a MenuPresentation.gd;
- scripts/shifts/ShiftManager.gd, ShiftPresentation.gd a GameplaySmoke.gd;
- scripts/training/TutorialManager.gd a KnowledgeProfile.gd;
- scripts/english/EnglishManager.gd, DialogueController.gd, LondonSpeech.gd a LondonQuiz.gd;
- scripts/world/GameShell.gd a PracticalIntroduction.gd;
- scripts/xr/XRPlayer.gd, VRMonitor.gd, VRSettings.gd a VirtualKeyboard.gd;
- scripts/simulation/, scripts/evaluation/ a příslušné katalogy/generátory.

Zkontroluj Git stav a chraň existující cizí změny. Používej dostupný Godot MCP
a přímé úpravy souborů. Co MCP neumí, ověř skutečným Godot CLI.

## 3. Podmínky, které nesmíš porušit

- Neměň prvních 24 misí, legacy_campaign.json, jejich referenční řešení ani význam starých ID.
- Zachovej všechny nynější kurzy, místnosti, obsah, dostupné operace a autorský podpis.
- Podpis menu musí zůstat přesně `Vytvořil: Vít Kellner a Codex`, čitelný a pouze v menu.
- Zachovej AcademyTheme, fonty, oversampling textu a DPITexture ikon.
- Zachovej enum hodnoty režimů včetně HUB=4 a existující prostorové hranice místností.
- PC i VR musí umožnit splnit stejné cíle. Ve VR nevyžaduj fyzickou klávesnici.
- Nezaváděj povinný cloud, účet, internet, placené API, mikrofon ani runtime TTS.
- Hráčův kód nadále běží ve stávajícím omezeném interpretu, nikoli přes OS nebo skutečný Python.
- Kampaň, směna, výuka, programování a Londýn se navzájem nesmějí přepisovat.
- Staré platné save musí zůstat načitatelné. Migrace sama nesmí přidat XP ani odemknout úlohy.
- Nové větve save validuj včetně obsahu, limitů a návaznosti na existující ID/verze.
- Testy nastaví SaveManager.path_override i vlastní DisplaySettings/VRSettings před GameManagerem.
- Testy nesmějí číst nebo přepisovat hráčův academy_save.json. Používej oddělené cesty, ideálně s PID.
- Katalogy udržuj konzistentní s jejich generátory. build_content.py přegenerovává existující data.
- Neodstraňuj kontroly ani plošně nepotlačuj logy, aby testy vypadaly úspěšně.

## 4. Nejdřív vyřeš velikostní rozpočet distribuce

Poslední Windows EXE má **104 826 336 B**, limit současné pipeline je
**méně než 104 857 600 B**. Rezerva je pouze **31 264 B**. Tyto hodnoty si
znovu skutečně změř před rozšiřováním kódu a prostředků.

- Zjisti, co tvoří velikost EXE, vloženého packu a jednotlivých prostředků.
- Připrav proveditelný způsob, jak zachovat prostor pro tuto etapu. Nespoléhej na odhad.
- Použij legitimní nastavení exportu, bezeztrátové balení a případně ověřenou odpovídající exportní šablonu.
- Pokud zvažuješ vlastní sestavení šablony s omezením nepotřebných modulů, dolož původ/verzi a proveď celou regresi PC i OpenXR. Neodstraň potřebné funkce.
- Nepředpokládej, že Release šablona je menší; porovnej skutečné velikosti.
- Neobcházej limit jeho vypnutím, UPX, ručními zásahy do PE, odstraněním starého obsahu, fontů nebo autorského podpisu.
- Zachovej hlavní Windows distribuci jako samostatný EXE s vloženými daty, bez sousedního PCK, instalovaného Godotu nebo povinného ZIP.
- Nezaváděj LFS, jiný způsob hlavní distribuce ani povinné stahování obsahu bez výslovného pokynu uživatele.
- Existující komprimované audio znovu nepřeváděj do velkých WAV. Pro poslech nejprve využij nynějších 24 MP3 souborů.

Při skutečném chybějícím nástroji nebo neřešitelném limitu zachovej poslední
platné balíčky. Uveď přesný pokus, naměřenou velikost a překážku. Neoznačuj
starý soubor novým hashem jako dokončený export. Dokonči nezávislou práci.

## 5. Trvalé ukládání rozepsané práce

### 5.1 Programovací soubory

Po ukončení aplikace a novém vytvoření GameManageru musí jít obnovit skutečně
rozepsaný kód. Nestačí uchovat buffer při překreslení editoru.

- Ukládej zdrojové texty všech souborů aktuální úlohy, aktivní soubor a potřebný kontext.
- Zahrň Python i HTML/CSS/JS, základní úlohy, lekce, opravovací a generované varianty.
- Koncept identifikuj stabilním ID, verzí obsahu, režimem a přesnou variantou/parametry. Nestačí samotné PY01 nebo název souboru.
- U série zachovej potřebný seed, pořadí a parametry, aby se kód neobnovil do jiného zadání.
- Learn/practice/exam nesmějí omylem sdílet rozepsané řešení nebo stav nápovědy. Režim obnovuj výslovně a beze změny podmínek zkoušky.
- Zachovej kurzor, výběr a posuv, pokud je lze bezpečně obnovit. Neplatné pozice omez na skutečný text.
- Nativní undo/redo zachovej v živém editoru. Netvrď, že je trvale obnovené, pokud ho neukládáš.
- Editace obnoveného kódu musí zneplatnit staré ověření. Uložený koncept není úspěšné řešení.
- Nabídni Obnovit rozepsanou práci, Začít znovu a Smazat koncept s jasným dopadem.
- Reset příkladu nebo nové spuštění jiné varianty nesmí přepsat jiný koncept pod stejným klíčem.

Používej průběžný zápis s krátkým odkladem po psaní, například kolem jedné
sekundy; nezapisuj celý save každý snímek. Před opuštěním editoru, změnou úlohy
a běžným ukončením aplikace vyprázdni čekající změny. Při chybě zápisu označ
koncept jako neuložený a dovol opakování.

### 5.2 Nepotvrzené IT formuláře

- Uchovej skutečné rozepsané hodnoty formulářů včetně textu neodeslaného čísla.
- Klíč konceptu musí obsahovat relaci, hostitele, VM/zařízení, operaci a verzi formuláře.
- Koncept jiné VM nebo směny se nesmí objevit na právě vybraném cíli.
- Obnova konceptu nesmí sama provést operaci ani změnit simulaci.
- Neobnovuj potvrzený destruktivní dialog jako souhlas hráče. Rizikový zásah vždy znovu potvrď.
- Neplatná nebo již neexistující VM/operace musí vést k bezpečnému odmítnutí konceptu s vysvětlením.
- Zachovej rozlišení: rozepsáno ve formuláři → použito v modelu → úspěšně uloženo na disk.

### 5.3 Dobrovolné pokračování výuky

Současné opuštění učebny ruší živý výukový stav. Rozšiř ho o samostatný uložený
snímek pro výslovné pokračování; nesmíš tím zrušit oddělení místností.

- Po odchodu vyčisti živou modalitu, šipky, highlight, nesené předměty a cvičný model stejně bezpečně jako nyní.
- Nabídni dobrovolné pokračování v nedokončené IT lekci po restartu aplikace.
- Obnovení je možné teprve ve správné učebně, ve správném režimu a pro platnou definici.
- Zachovej krok, skutečný stav sandboxu, chyby, nápovědy a další údaje potřebné pro férové dokončení.
- Nedokončenou zkoušku nelze obnovit jako learn nebo získat pomoc přepnutím režimu.
- Poškozený či zastaralý snímek nesmí ohrozit kampaň, směnu nebo trvalé výsledky. Nabídni bezpečný nový pokus.
- Náhodné IT série nesmějí změnit seed/zadání při obnově; pokud obnovu rozšíříš i na ně, validuj celou vazbu série.
- Praktický úvod nadále neukládej jako rozehranou pracovní nebo výukovou relaci.

### 5.4 Přehled pokračování a stav zápisu

- Přehledně rozliš Pokračovat v kampani, Pokračovat ve směně a Obnovit výuku/koncept.
- Použij stávající menu nebo kompaktní společný přehled; nezaplav menu desítkami tlačítek.
- Zobraz skutečný stav Ukládám / Uloženo / Neuloženo a čas posledního úspěšného zápisu.
- Čas Uloženo nesmí pocházet z pokusu o zápis, který selhal.
- Selhání má trvalé upozornění a opakování; úspěšná akce pouze v paměti není uložený výsledek.
- Zachovej atomický zápis, zálohy, ochranu poškozeného původního souboru a validovaný import/export.
- Nastav rozumné limity počtu konceptů, délky souborů a celkové uložené velikosti. Při překročení vysvětli problém; žádné tiché zkracování kódu.
- Ukládej jen povolené logické názvy souborů. Koncept nesmí být cestou k libovolnému souboru zařízení.

## 6. Sjednoť hodnocení a oprav nápovědy směn

Ověř tuto konkrétní nesrovnalost: UIController.hint() hlásí odečet čtyř bodů
za nápovědu, ale ShiftManager.complete() v dosavadní verzi počítá skóre
jen z chyb a rizik; activate() navíc resetuje hints_used.

- Reprodukuj chování skutečným tlačítkem a novým načtením aplikace. Potom ho oprav.
- Pro nové pokusy směn dodrž deklarovanou penalizaci nápovědy a jednoznačně popiš ostatní penalizace.
- Rozliš nápovědu od přečtení zadání nebo pouhého otevření panelu.
- Počítadla relevantní pro skóre přežijí save, přechod místnosti a restart aplikace.
- Jedna nápověda nebo předání nesmí být započtené dvakrát kvůli oběma triggerům či starému callbacku.
- Definuj, zda se chyby vztahují k aktuálnímu ticketu, nebo celé směně. Starou chybu neodečítej opakovaně v každém ticketu bez jasného pravidla.
- Závěr ukaž jako srozumitelný rozpis: základ, nápovědy, chyby, rizika, výsledné skóre a skutečně přidané XP.
- Rozděl výpočet a prezentaci tak, aby nezávislé UI obrazovky nepočítaly různé výsledky.
- Neměň zpětně uložená skóre původní kampaně, dokončených lekcí ani historie směn.
- Verzuj novou metodiku. U starých rozpracovaných pokusů zachovej známé výsledky a neodhaduj ztracenou historii nápověd.
- Migrace ani změna verze skórování nesmí sama udělit XP. Uchovej ochranu před opakovanou odměnou přes restart, varianty a import.
- Při selhání zápisu se musí opakovat zápis existujícího výsledku, nikoli znovu přidělit odměna.

## 7. Pokročilé směny s prioritami a následky

Zachovej současná SHIFT-NET, SHIFT-VM a SHIFT-DISK i jejich obnovitelnost.
Přidej alespoň **dvě nové pokročilé směny**, každou s **4–6 tickety**.
Alespoň část každé nové směny musí nabídnout dva současně otevřené incidenty,
mezi kterými hráč rozhoduje podle priority a provozních závislostí.

Použij skutečné současné operace. Příklady vhodných témat jsou obnova služby
přes síť/VM a následné zajištění nezávislé zálohy, nebo bezpečný storage servis
při zachování provozu a následné ověření aplikací. Nevymýšlej plný OS, VPN,
nové hypervisory nebo skutečné síťové pakety, pokud je zároveň plně neimplementuješ.

- Každá směna má jeden počáteční svět; přepnutí ticketu nesmí znovu načíst baseline.
- Fronta ukáže prioritu, dopad, blokující závislost a stav ticketu.
- Dokončení ověřuje skutečný model a aktuální důkazy, nikoli pořadí otevřených obrazovek.
- Umožni více správných pořadí oprav a zohledni opravu provedenou před přijetím ticketu.
- Nové incidenty spouštěj explicitními deterministickými pravidly. Každý má stabilní ID a ochranu proti opakované aktivaci.
- Plánovaná porucha musí být rozlišitelná od resetu světa. Neměň skrytě nesouvisející konfiguraci nebo inventář.
- Důsledky musejí být skutečné: například dostupnost služby, dostupnost platné zálohy nebo riziko výměny dalšího zdravého disku.
- Pouhá návštěva monitoru, kliknutí na prioritu nebo uplynutí animace nesmí opravit zařízení.
- Rozhodnutí musí alespoň v jednom testovaném případě změnit skutečný průběh či provozní dopad. Nestačí rozdílný závěrečný text nad stejným výsledkem.
- Předčasné předání vysvětli konkrétní nesplněnou podmínkou. Neopravitelná ztráta dat má jasný servisní postup nebo výslovný restart.
- Nevyžaduj stresující časový limit pro základní průchod. Případný výpadek měř explicitním simulovaným časem, ne FPS nebo rychlostí počítače.
- Pauza a ztráta focus/tracking nesmějí zhoršovat provozní skóre.
- Ulož incidenty, aktivované události, stavy ticketů, zvolený kontext a potřebné časové údaje.
- Undo a restart musejí konzistentně zacházet i s plánovačem incidentů. Nesmí obnovit starou odměnu nebo dvakrát spustit poruchu.
- Opuštění do hubu, IT výuky, programování a Londýna zachová směnu i odloženou kampaň.
- Nový obsah udržuj ve vlastním katalogu/generátoru s verzí. Proveď migraci existující větve shifts bez ztráty historie.

## 8. Konkrétní závěrečné vysvětlení

Rozšiř existující deník, síťové vysvětlení a vyhodnocení o přehled pro hráče:

1. Co bylo příčinou a které zařízení/službu to zasáhlo.
2. Co hráč skutečně změnil a jaké hodnoty byly před a po.
3. Co změna obnovila a co ještě vyžadovalo samostatnou kontrolu.
4. Kterým ověřením byl výsledek potvrzen a zda je stále aktuální.
5. Jaký další trénink doporučuje zaznamenaná chyba.

Příklad významu: kabel fungoval, VLAN byla chybná; oprava VLAN obnovila L2,
ale chybná brána stále blokovala službu; teprve další oprava a kontrola potvrdila HTTPS.
Text musí odpovídat skutečnému pokusu, nikoli univerzálnímu úspěšnému příběhu.

- Podstatné události zaznamenávej strukturovaně se správnými ID, relací a revizí.
- Nepokoušej se spolehlivě odvozovat celý stav pouhým parsováním lidského textu deníku.
- Odliš koncept, použitou změnu, diagnostiku, ověření a skutečně předaný ticket.
- Neuváděj staré ověření po změně konfigurace jako důkaz aktuální funkčnosti.
- Pokryj alespoň síť, VM/prostředky/start, storage/servis a zálohy.
- U programování ukaž konkrétní chybný test nebo známou chybu soubor/řádek; neslibuj neprovedenou analýzu algoritmu.
- Použij deterministické lokální vysvětlení nad modelem; nevyžaduj runtime AI/API.
- Historii omez, neukládej celý svět po každém stisku klávesy.
- Hotový rozbor musí zůstat dostupný po restartu nebo být z uložených dat věrně rekonstruovatelný.
- Ve zkoušce přesnou příčinu/řešení odhal až po odevzdání.
- Přidej jednu krátkou dobrovolnou otázku ověřující pochopení. Nezruš jí již dosažený výsledek a neuděluj opakovatelná XP za stejné klikání.

## 9. Samostatné poslechové úlohy v Londýně

V existujícím pavilonu přidej přehledně dostupné **Poslechové procvičování**.
Použij stávající nahrávky z data/english/audio.json a LondonSpeech.
Připrav alespoň **12 úloh**, každou se skutečně dostupným klipem a otázkou
na význam, záměr nebo praktické porozumění repliky.

- Poslech má vlastní stabilní ID a výsledky. Není to přepsání LON01–LON06 nebo London Quiz.
- Základní průchod: vybrat úlohu → poslechnout → zvolit pochopený význam → získat vysvětlení.
- Přesný přepis je nejprve skrytý. V learn/practice ho lze zobrazit na vyžádání.
- Respektuj přístupnost: při použití přepisu či ztlumeném zvuku lze cvičení dokončit, ale nesmí být vydáváno za samostatně ověřený poslech bez pomoci.
- Ve zkoušce nastav jasná pravidla přepisu/nápovědy a zachovej je i po obnově relace.
- Odpovědi mají stabilní sémantická ID, smysluplné chyby a promíchané pořadí bez prozrazení správné odpovědi.
- Název souboru, tooltip, barva ani metadata zobrazená před odpovědí nesmějí prozradit výsledek.
- Zopakováním, pomalou variantou nebo koncem audia se nesmí sama zvolit odpověď.
- Použij samostatnou pomalou nahrávku; playback pitch zůstává 1.0.
- Zachovej volitelnou automatiku, Speech/Master hlasitost a ztlumení.
- Při nové úloze, rychlém přepínání, pauze, změně místnosti, ztrátě focus/tracking nebo zániku scény se stará řeč zastaví.
- Návrat z pauzy nesmí spustit cizí klip nebo několik souběžných nahrávek.
- Poslech nesmí změnit košík, platbu, vstupenku ani neodevzdaný výsledek původního dialogu/kvízu.
- Vysvětlení po odpovědi porovná skutečný význam klipu s vybranou odpovědí. Nepřisuzuj nahrávce údaje, které v ní nezazněly.
- Uchovej oddělené výsledky, použitou pomoc a omezenou historii; opakování stejného výsledku nesmí farmit XP.
- Nepřidávej nové audio jen kvůli počtu úloh. Pokud ho přesto potřebuješ, zachovej přesný text, licenci, offline balení a velikostní rozpočet.

Ovládání musí fungovat myší, Tab/Enter i oběma XR paprsky a úplným trigger
press/release, bez mikrofonu a fyzické klávesnice.

## 10. Společný přehled znalostí

Rozšiř existující přehled znalostí o programování, londýnské situace, kvíz
a nový poslech. Nevytvářej nesouvisející paralelní kariérní systém.

- Ukaž přehled podle oblastí a skutečných dovedností, například sítě/zálohy,
  Python/HTML/CSS/JS a porozumění anglické replice.
- Rozliš Nezkoušeno, Procvičeno, Dokončeno s pomocí a Doloženo bez pomoci,
  pouze pokud takové tvrzení podporují zaznamenané výsledky.
- Skóre 100 z IT úlohy není totéž jako 100 v jazykovém kvízu. Nevyráběj zavádějící celkovou CEFR úroveň nebo certifikát.
- Zobraz zdroj výsledku, režim, použitou pomoc a případně datum posledního pokusu.
- Doporuč konkrétní existující úlohu/lekci podle zaznamenaných chyb nebo chybějícího procvičení.
- Nezkoušenou oblast neoznačuj jako neúspěch. Odděl historický nejlepší výsledek od posledního pokusu.
- Doporučení počítej lokálně a deterministicky; nemají vyžadovat síť nebo AI službu.
- Tlačítko doporučení musí otevřít správnou skutečnou oblast, platné ID a vhodný režim.
- Přechod musí bezpečně odložit kampaň/směnu a nabídnout zachování relevantního rozepsaného konceptu.
- Nespouštěj operace modelu jen otevřením doporučení. Nenutíš hráče nechtěně restartovat uložený pokus.
- Starší anglické A1–A2 výsledky ponech v archivu; nesmějí potvrzovat zvládnutí nového B1–B2 nebo poslechu.
- Profil odvozuj ze stávajících ověřených výsledků, kde to jde; zbytečně neduplikuj data do několika nekonzistentních větví.
- Otevření profilu ani změna doporučení neuděluje XP.

## 11. PC a VR rozhraní

Nové části rozděl do přehledných komponent. Nerozšiřuj vše do jednoho obřího
GameShellu nebo UIControlleru a nerefactoruj nesouvisející subsystémy.

- Navazuj na stávající navigaci a skutečné místnosti; nepřidávej kvůli přehledu další budovu.
- Zachovej podpis a dosavadní klávesový fokus menu.
- Ověř dostupnost tlačítek, scroll, hover/pressed stavy, dlouhé texty a srozumitelné chybové zprávy.
- PC matice: **1280×720, 1920×1080, 3840×2160 × text 100 % a 130 %**.
- VR: skutečný SubViewport **1600×1200**, oba textové rozměry, klávesnice otevřená i zavřená.
- Prověř aktuální minimum/maximum fyzické velikosti a vzdálenosti panelu; ray/pixel, kurzor a klávesnice musejí zůstat konzistentní.
- Ověř obě ruce, drag/scroll, uvolnění mimo tlačítko, opakovaný trigger a současné triggery.
- Zachovej A/X pro přemístění panelu, B/Y pro návrat/pauzu a ochranu při focus/tracking.
- Nezvyšuj plošně rozlišení viewportů a nepřidávej další náročné živé obrazovky.
- Prohlédni skutečné snímky v Compatibility i běžném desktopovém rendereru. Snímek na monitoru není důkaz optické čitelnosti PICO.

## 12. Povinné funkční a integrační testy

Nejprve ověř výchozí regresi. Nové smysluplné sady přidej do tools/Test-All.ps1
a na závěr spusť celý aktuální runner přes skutečný Godot. Použij skutečný
nynější počet sad, nikoli počet z historického reportu.

Příklad, skutečnou cestu enginu ověř:

```powershell
./tools/Test-All.ps1 -GodotPath '../../Godot_v4.7.2-stable_win64_console.exe'
```

### Ukládání a izolace

- Rozepsat skutečný Python i webový kód, včetně syntax error, změn ve více souborech a kurzoru.
- Ukončit původní scénu/GameManager a vytvořit nový; ověřit přesnou obnovu, ne jen překreslení.
- Stejné ID v jiném režimu/variantě, dvě různé úlohy, generovaná série a opravovací úloha.
- Obnovení konceptu nesmí samo spustit kód, aplikovat IT operaci nebo udělit úspěch.
- Nepotvrzené číslo v IT formuláři, jiná VM/hostitel, neexistující cíl a zamítnuté rizikové potvrzení.
- Výslovné obnovení IT lekce ve všech třech režimech; mimo správnou učebnu odmítnout bez změny relace.
- Přechody kampaň ↔ směna ↔ hub ↔ IT ↔ programování ↔ Londýn, opakovaně a po restartu aplikace.
- Chyba zápisu a opakování, poslední úspěšný čas, poškozený save, limity konceptu a neplatné logické cesty.
- Migrace skutečných starých platných save, export/import nových větví a ochrana původního souboru při odmítnutí.

### Skóre a nové směny

- Nápověda skutečným tlačítkem sníží nové skóre přesně podle deklarovaných pravidel.
- Počítadla přežijí přechod ticketu i nové vytvoření GameManageru; repaint nic nepřičítá.
- Dvojí trigger, starý token, předčasné/dvojí předání a save failure/retry bez dvojí odměny.
- Staré výsledky a XP se nezmění migrací nebo pouhým otevřením historie.
- Každá nová pokročilá směna od začátku do konce přes skutečné operace.
- U každé alespoň dvě platná pořadí práce a jeden chybný nebo předčasný postup s reálným dopadem.
- Prokaž konkrétní přetrvání konfigurace, servisního inventáře a stavu mezi současnými tickety.
- Ověř podmíněný incident, jeho jedinou aktivaci, obnovu, undo, restart a pauzu/focus.

### Rozbor, poslech a profil

- Rozbor odpovídá skutečným hodnotám před/po, správnému zařízení a aktuálnímu ověření.
- Zamítnutá operace není vykázaná jako oprava; undo a změna relace neukážou cizí historii.
- Všechny nové poslechové úlohy: skutečný klip, otázka a ručně stanovená očekávaná odpověď.
- Odpovědi nemají odhalené řešení před odevzdáním; přepis a pomoc jsou správně zaznamenané.
- Opakování/pomalá varianta nemění odpověď, původní nákup ani výsledek jiné anglické aktivity.
- Ověř hash skutečných audio dat, dekódování, nenulovou délku/vzorky, hlasitost a stop při všech přechodech.
- Odliš dekódování a spuštění přehrávače od subjektivního lidského poslechu. Netvrď, že jsi slyšel zvuk, pokud to prostředí neumožňuje.
- Profil: nový hráč, starý save, smíšené výsledky, použitá pomoc, archiv, neplatná doporučení, správný skutečný vstup do doporučené úlohy.
- Otevření profilu, přehrání audia nebo opakované zobrazení rozboru neuděluje XP.

Testy musejí používat skutečné vstupy, formuláře, události a model. Nesplňuj
úlohu ručním nastavením finished, XP nebo cílového výsledku. Testovací počáteční
podmínky jasně odděl od akcí hráče. U kliků použij úplný press/release,
správný viewport a skutečné měřítko při posuvu v malém okně.

Použij relevantní existující sady, zejména gameplay, gameplay_review, shifts,
save_safety, session_safety, programming_*, english_*, london_quiz, xr_modes,
ui_workflow, ui_design, world_ui, training_rooms, lessons, tutorial_navigation
a training_ui se všemi režimy. Nová regrese není důvod starou kontrolu smazat;
při záměrné změně kontraktu uprav očekávání a zachovej původní záruky bezpečnosti.

## 13. Oba exporty a jejich skutečný obsah

Po dokončení zdrojů sestav a ověř:

- `build/ITSupportSimulator.exe`
- `build/pico4/ITSupportSimulator-PICO4.apk`

Použij aktuální tools/build_windows.py, tools/build_platforms.py, příslušné
PowerShell wrappery a tools/test_windows.py, tools/test_pico.py a
tools/test_gameplay_packages.py. Nejdřív přečti jejich aktuální parametry.

- Nevytvářej znovu kořenovou složku builds/.
- Windows ověř jako samotný přejmenovaný EXE v cizí pracovní složce bez projektu/PCK/editoru.
- Ověř skutečný limit pod 100 MiB po všech změnách; nepostačí rozpočet před implementací.
- APK zůstane ARM64/OpenXR, se stejným identifikátorem a původním podepisovacím certifikátem.
- Zvyš version/name i versionCode oproti skutečně současnému vydání; poslední doložené bylo 1.4.0 / code 5.
- Ověř podpis, CRC, skutečný manifest, katalogy a skutečně přibalené audio.
- Žádný testovací save, privátní klíč, pracovní model TTS nebo zbytečný WAV v distribuci.
- Rozšiř balíčkové testy o novou obnovu práce, metodiku skóre, nové směny, poslech a profil.
- Přímý export smoke musí nastavit testovací save/config před GameManagerem.
- Testuj proti přesným zabaleným datům, ne jen proti pracovnímu stromu.
- Po změně hashů neopisuj staré PASS výsledky. Výsledky musejí patřit skutečnému EXE/APK.
- Zapiš SHA256, velikosti, zdrojový commit nebo přesný deterministický manifest a soulad obsahu obou platforem.
- Aktualizuj BUILD_INFO, SHA256SUMS a VERIFICATION jen podle skutečně dokončených kroků.
- Nepřipojuj opakovaně ADB a neinstaluj aplikaci na náhodné Android zařízení; headset je pro tuto etapu nedostupný.
- Desktopové spuštění APK prostředků není Android native start ani ověření fyzického tracking/FPS.

## 14. Postup po funkčních etapách

Doporučené pořadí:

1. Výchozí audit/regrese a proveditelný exportní rozpočet.
2. Koncepty, stav uložení, migrace a výslovné pokračování výuky.
3. Oprava hodnocení a důkaz jediné odměny při selhání zápisu.
4. Nové pokročilé směny a jejich skutečné alternativní průchody.
5. Konkrétní rozbor výsledku a otázka na pochopení.
6. Poslechové úlohy a oddělené výsledky.
7. Společný přehled znalostí a navigace doporučení.
8. Celková regrese, grafická kontrola a oba ověřené exporty.

Po funkční etapě spusť odpovídající testy, aktualizuj PROGRESS.md a vytvoř
přehledný Git commit. Běžné technické volby řeš samostatně. Není potřeba žádat
o potvrzení každé etapy; pokračuj v už autorizované práci. Zastav a přesně popiš
jen skutečný externí blokátor. Nepřítomnost PICO není blokátorem desktopové práce.

## 15. Dokumentace a předání

Aktualizuj README, PROGRESS, TEST_REPORT, VR report, dokumentaci ukládání,
směn, programování, poslechu a obou distribucí. Rozšiř stávající
docs/PICO4_HARDWARE_CHECKLIST.md o nové průchody. Všechny hardwarové položky
zůstanou **NEPROVEDENO – headset není dostupný**.

Přidej skutečné trvalé snímky do nové datované složky docs/ui-review/.
Uchovej přehledné logy konečných testů, přesná čísla a odkazy; nespoléhej
výhradně na ignorovaný test-output. Výchozí selhání a stará statická varování
odděl od nových chyb, nic plošně neskrývej.

V závěru stručně a konkrétně uveď:

1. Co je skutečně implementované a kde to hráč najde.
2. Jak se ovládá pokračování, priority směn, rozbor, poslech a profil na PC i ve VR.
3. Co se ukládá, co se obnovuje jen výslovně a co zůstává dočasné.
4. Výsledky celé regrese, nových integračních testů a grafické matice; odkazy na snímky/logy.
5. Ověření starých save, původní kampaně, směn a ochrany proti dvojí odměně.
6. Zdrojové commity/manifest, skutečné EXE/APK, velikosti a SHA256.
7. Co bylo ověřeno na PC, co synteticky v XR a co jen v APK prostředcích.
8. Konkrétní neověřené hardwarové body a případné skutečné nedokončené části.

**Git push není součástí tohoto zadání. Proveď ho až na následný výslovný pokyn uživatele.**

Dokončení posuzuj podle funkčního průchodu hráče, skutečného obnovení práce
po novém spuštění, férového a konzistentního hodnocení, smysluplných rozhodnutí
nad modelem a ověřených balíčků. Počet přidaných souborů není důkaz funkčnosti.
