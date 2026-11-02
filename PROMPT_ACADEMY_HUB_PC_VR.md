# Zadání pro další AI: rozcestník, oprava textur, angličtina B1–B2 a otázky na Londýn — PC a VR / PICO 4

Jsi vývojář Godotu a návrhář prostorového prostředí a VR interakcí. V existujícím
projektu **IT Support Simulator: Training academy** skutečně implementuj čtyři věci:

1. Samostatný přehledný nástupní rozcestník, kde se hráč objeví a odkud fyzicky
   odejde do čtyř stávajících místností.
2. Prohlédni **všechny textury, materiály a související povrchy v celém projektu**
   a oprav všechny nalezené vadné. Uživatel výslovně upozornil na rozbitý vzhled
   dveří / vstupu do Londýna. Neomezuj opravy na tento příklad ani na nový hub.
3. Přepracuj všechny londýnské anglické situace na cílovou úroveň **B1–B2**.
   Změň skutečná zadání, dialogy, možnosti, podmínky a vyhodnocení. Nejde o
   přejmenování současných A1–A2 cvičení ani o přepsání IT/programovacích katalogů.
   Výslovně přidej otázky, které pokládá hráč jako zákazník, když si chce koupit
   lístky na London Eye, a skutečné reakce prodavače na tyto dotazy.
4. Přidej skutečně hratelné **otázky na Londýn**, tedy samostatný znalostní kvíz
   v angličtině B1–B2 s vysvětlením odpovědí a uloženým postupem.

Vše musí plnohodnotně fungovat na Windows PC i samostatném PICO 4 se stejnými
funkcemi a obsahem. Proveď implementaci, testy a oba nové exporty. Nestačí plán,
audit bez oprav, obrázek nové haly ani další prompt místo vykonání práce.

## 1. Navazuj na skutečný aktuální projekt

Nejdřív přečti `AGENTS.md`, nejnovější části `PROGRESS.md`, `README.md`,
`TEST_REPORT.md`, `docs/ENGLISH_LONDON.md`, `docs/PROGRAMMING_ACADEMY.md`,
`docs/VR_TEST_REPORT.md`, `NAVOD_PICO4.md` a `build/README.md`.

`PROMPT_LONDON_ENGLISH_VR.md` je předchozí zadání již implementovaného londýnského
pavilonu. Použij ho jako kontext a regresní požadavky; nevytvářej Londýn znovu.
Primárním zadáním této etapy je tento soubor. Nejnovější pravdivý stav zjisti
z kódu a reportů, nikoli z historických částí PROGRESS.

Projekt má čtyři oblasti:

- Serverovna / pracovní směna: 65 IT misí a skutečný model infrastruktury.
- IT tréninková akademie: 21 lekcí, tři režimy a náhodné série.
- Programming Academy: 28 lekcí a 60 úloh, Python a HTML/CSS/JS.
- English in London: LON01–LON06, nákup lístků, cvičné platby, kontrola vstupenky
  a skutečný příchod k Elizabeth Tower; tři režimy a uložené vlastní výsledky.

Používej dostupný Godot MCP a přímé úpravy souborů. Nezakládej druhou hru,
nevracej repozitář na historický commit a chraň cizí rozpracované změny. Změř
výchozí stav a po dokončených etapách testuj, aktualizuj PROGRESS a commituj.
Git push ani publikaci mimo repozitář nepovažuj automaticky za součást zadání.

## 2. Výsledek z pohledu hráče

Po spuštění klasické 3D hry nebo VR se hráč objeví v klidné nástupní hale
**Training academy / Rozcestník**. Rozhlédne se, přečte jasné označení a běžnou
chůzí nebo VR teleportem dojde ke vstupu do vybrané místnosti. Vstupy budou mít
číslo, název, krátký český popis a jednoznačný vizuální motiv:

| Oblast | Co má hráč pochopit před vstupem |
|---|---|
| 01 / Serverovna | Pracovní směna, incidenty a kampaň. |
| 02 / IT trénink | Lekce administrace a procvičování na cvičné infrastruktuře. |
| 03 / Programování | Python a tvorba webu, vlastní kód a praktické úlohy. |
| 04 / English in London | Praktická angličtina B1–B2, repliky a situace v Londýně. |

Hub není pátý kurz ani obrazovka s nabídkou čtyř teleportů. Musí to být skutečný
3D prostor se skutečnými průchozími vstupy, případně s krátkými jasnými chodbami.
Nestačí vložit tabuli doprostřed serverovny a přejmenovat současný spawn.
Menu zkratky mohou zůstat užitečným doplňkem, nikoli jedinou cestou.

V hale má být jasné, že jde o společnou akademii. Nezahlcuj ji velkým množstvím
tlačítek, technickým stavem simulace, monitory s automaticky běžícími úlohami
nebo nefunkčními dekorativními volbami. Nezahajuj lekci ani nákup pouhým průchodem.

## 3. Nejprve skutečně zmapuj budovu

Prohlédni zejména:

- `scripts/world/Datacenter3D.gd`, `WorldVisuals.gd`, `Geometry.gd` a scény světa.
- `scripts/world/GameShell.gd`, `FirstPersonController.gd`, `TrainingZone.gd`.
- `scripts/programming/AcademyRoom.gd`, `AcademyVisuals.gd` a scénu učebny.
- `scripts/english/EnglishRoom.gd`, `EnglishManager.gd`, `DialogueController.gd`.
- `scripts/core/GameModeManager.gd`, `GameManager.gd` a `DisplaySettings.gd`.
- `scripts/progression/SaveManager.gd`, `SaveValidator.gd`.
- `scripts/xr/XRPlayer.gd`, `VRMonitor.gd`, `VRSettings.gd` a OpenXR akční mapu.
- `scripts/ui/MenuPresentation.gd`, `UIController.gd`, `AcademyTheme.gd`.

Změř skutečné globální souřadnice místností, průchody, dveře, jejich ovladače,
kolize, uložené polohy a teleportovatelné podlahy. Nákres si vytvoř podle kódu,
ne podle domnělých souřadnic z tohoto promptu. Současná programovací učebna leží
západně od serverovny, serverová akademie východně a Londýn jižně.

Preferuj doplnění haly a potřebných průchodů bez přesouvání stávajících místností,
racků a stanovišť. Pokud je pro skutečný společný hub nutná změna dispozice,
proveď ji promyšleně jako transformaci celé oblasti včetně kolizí, světel,
popisků, čidel, interakcí, cílových bodů a obnovovaných pozic. Nevytrhávej pouze
viditelné modely ze starých souřadnic. Zachovej logické vztahy a dosažitelnost úloh.

Sdílenou zeď vytvářej jen jednou. Existuje nedávná oprava blikajících překrytých
zdí u západního vstupu do programovací učebny; tuto chybu nesmíš obnovit.

## 4. Dispozice, navigace a spawn

- Hala musí poskytovat dost místa pro otočení a pohyb ve VR, včetně sezení.
- Hráč se objeví na pevném volném místě na podlaze, mimo kolize, zavřené dveře,
  dosah NPC a spouštěče lekcí. Pohled při spawnu míří na srozumitelnou orientaci.
- Cesty mají být krátké, viditelné a přirozené. Dveře mají běžně rozpoznatelný
  rám, křídlo, případně správně označený otevřený průchod. Značení musí odpovídat
  skutečné trase, nikoli ukazovat na neprostupnou stěnu.
- Z každé ze čtyř místností musí existovat jasná fyzická cesta zpět do hubu.
- Doplň zkratku **Rozcestník akademie** v pauze a vhodný vstup v hlavním menu.
- První vstup může nabídnout krátké přeskočitelné seznámení s rozdělením výuky.
- Nová hra i běžný vstup z menu mají hráče přivést do hubu. Kampaň lze zachovat
  načtenou nebo bezpečně odloženou, ale nesmí se kvůli spawnu restartovat.
- Po návratu z místnosti se hráč objeví nebo fyzicky ocitne u odpovídajícího
  východu, aby neztrácel orientaci. Neotáčej mu bez potřeby VR kameru během chůze.
- Úmyslně odliš pokračování rozpracované úlohy, návrat do menu a nové spuštění.
  Definuj a zdokumentuj, kdy se obnovuje poloha a kdy se používá nástupní místo.

Neukládej neplatné polohy do staré struktury world.player. SaveValidator má
pro historické polohy omezené souřadnice; nové souřadnice a případné rozlišení
oblasti skutečně validuj. Zachovej kompatibilitu starých pozic. Zastaralou polohu
oprav jen bezpečnou migrací / výchozím bodem, nikoli smazáním postupu.

## 5. Režimy a ochrana všech čtyř vzdělávacích oblastí

Hala je neutrální místo. Nesmí být omylem vyhodnocena jako IT lekce, programovací
úloha nebo anglická situace. Nejprve zjisti, zda potřebuje vlastní režim či
samostatné rozlišení fyzické oblasti. Zvol malé čitelné rozšíření architektury.

Současné hodnoty režimů zachovej: MAIN=0, SERVER_TRAINING/TRAINING=1,
PROGRAMMING_ACADEMY=2, ENGLISH_LONDON=3. Pokud přidáš HUB=4, uprav skutečnou
logiku `is_education()`, `main_available()`, `reconcile_room()`,
`leave_training()`, `resume_campaign()` a přechody. Současné `is_education()`
rozlišuje main proti ostatním; pouhé přidání dalšího enumu není dostatečné.
Boolean `room_changed(training_room)` sám nerozliší všechny oblasti.

Požadované chování:

- Nástup do hubu nezahájí úlohu ani neudělí XP.
- Při odchodu z kampaně se zachová skutečná infrastruktura, rozpracovaný ticket,
  chyby, dokončení, kontext a inventář podle dosavadních pravidel.
- Návrat do serverovny obnoví stejnou kampaň, nikoli kopii cvičné infrastruktury.
- Přechod přes hub nesmí přepsat odloženou kampaň jinou vzdělávací relací.
- Programovací koncepty a permanentní výsledky zůstávají podle současných
  pravidel; editor se v hubu sám neotevře.
- Odchod z angličtiny zruší dočasný rozhovor, košík, platbu a vstupenku v relaci,
  ale ponechá uložené nejlepší výsledky, pokusy, pomoc a naučené fráze.
- Při vstupu do Londýna nebo učebny se nesmí otevřít serverová konzole.
- Opakované čidlo, stojící hráč v prahu, teleport a dva souběžné vstupy nesmějí
  založit dvě relace ani střídavě přepisovat stav místnosti.
- Menu, změna scény, fyzický odchod i VR pohyb s otevřeným monitorem provedou
  skutečné zrušení nepatřičného UI a bezpečné převedení stavu.
- Zachovej atomické ukládání, pravdivé oznámení chyby a možnost zkusit zápis znovu.

## 6. Povinný úplný audit textur a materiálů — následovaný opravami

Uživatel výslovně požaduje, abys **prošel všechny textury a opravil špatné**.
Nevyřeš to jen novým materiálem pro dveře Londýna. Audit pokryje serverovnu,
serverovou akademii, programovací učebnu, celý Londýn, všechny vstupy i nový hub.

V tomto projektu je mnoho povrchů procedurálních. Slovo textura proto zahrnuje
také materiály, shadery, UV, průhlednost, normály, orientaci textů a správné
přiřazení materiálu k meshům. Jednobarevný záměrný materiál není sám o sobě chyba.
Nerozbij zavedené vizuální téma slepým nahrazením všech materiálů novými obrázky.

Nejdřív vytvoř přehled použitých a chybějících textur, materiálů a shaderů,
jejich umístění a použití. Pak skutečně spusť hru a systematicky prohlédni
všechny prostory z různých stran a vzdáleností. U každé chyby urč příčinu,
proveď opravu a ověř výsledek ve stejné scéně. Výstupem nejsou pouze doporučení.

Zkontroluj a podle nálezu oprav zejména:

- Dveře / vstup do Londýna: uživatelem hlášený rozbitý vzhled. Prohlédni rám,
  práh, překlad, stěnu nad vstupem, boční plochy, popisky, materiály i kolize.
  Zjisti, zda je současným záměrem otevřený průchod nebo skutečné křídlo dveří,
  a udělej konzistentní viditelný výsledek. Nezakrývej problém tabulí.
- Všechny ostatní dveře, jejich strany, animace a ovladače, nikoli jen nástupní
  pohled. Při otevření nesmějí vznikat díry, blikání, průniky nebo černé plochy.
- Chybějící textury, rozbité cesty, neplatné importy, nekompatibilní shader nebo
  odkazy na soubory, které jsou pouze v lokální .godot cache.
- Překrývající se / koplanární plochy a z-fighting, nevhodné depth nastavení,
  nesprávné pořadí průhlednosti, backface culling a převrácené normály.
- Protažené, překlopené, zrcadlené nebo nesmyslně opakované textury; špatné UV,
  triplanar, měřítko texelu, filtry a mipmapy. Prohlédni i pohled zblízka.
- Podlahy, rohy stěn, stropy, sokly, společné zdi, chodby, prahy a přechody
  mezi rozdílnými povrchy. Kolizní podlaha musí odpovídat viditelné.
- Racky, perforované panely, servisní skříně, disky, kabely, pracovní stoly,
  monitory a povrchy programovacích stanovišť. Zachovej stavové LED a highlight.
- Londýnské modely: kabinky a obruče kola, věž a ciferníky, most, řeku,
  zábradlí, postavy, přepážku, ceník, terminál, kontrolní stanoviště a závoru.
- Nepřirozeně černé, přepálené, průsvitné nebo nesprávně lesklé plochy;
  nesprávně použité normal mapy a barevné prostory; chybné emise a odrazy.
- Cedule a 3D text: správný směr, čitelnost, velikost, kontrast, hloubka vůči
  podkladu, žádná zrcadlená zadní strana coby hlavní značení. Čeština s diakritikou
  i angličtina musí správně fungovat v Android exportu s dostupnými fonty.
- UI plochy a skutečné SubViewport monitory: bez rozmazaného nečitelného obsahu,
  nechtěného opakování viewport textury nebo záměny za nefunkční obrázek.

Zásahy do sdíleného `Geometry.material()` a cache materiálů ověř ve všech
místnostech. Neopravuj jeden objekt nechtěnou změnou všech shodně sdílených ploch.
Zachovej vhodné MultiMesh skupiny a dynamické označení pohyblivých částí.

Pro každou skutečně nalezenou závadu uveď v reportu místo, příčinu, opravovaný
soubor, způsob ověření a snímek před/po. Pokud určitý typ závady nenajdeš,
nevymýšlej ho. Neprohlašuj samotný bezchybný import za vizuální kontrolu všeho.

## 7. Povinně přepracuj anglické úlohy na B1–B2

Dosavadní Londýn je A1–A2. Uživatel požaduje, aby další etapa změnila všechny
anglické úlohy na **B1–B2**, nejen označení místnosti nebo pár slov v popisu.
Ponech šest témat a stabilní ID LON01–LON06, ale přepracuj jejich obsah a cíle:

1. **Objednání vstupenky:** hráč vysvětlí plán návštěvy, uvede podmínky, doptá
   se na potřebné informace a přesně potvrdí nabídku. Nestačí jedna věta s please.
2. **Rodinná návštěva:** řešení složení skupiny, dětských a dospělých variant,
   porozumění několika výslovně uvedeným podmínkám a zdůvodněná volba. Případné
   věkové hranice a pravidla jsou fiktivní údaje scénáře, ne tvrzení o London Eye.
3. **Cena a rozpočet:** porovnání nejméně dvou skutečných dostupných možností,
   dotaz na to, co cena zahrnuje, vyhodnocení cvičného příplatku nebo slevy, pokud
   jsou v dané variantě, a výběr řešení splňujícího všechny podmínky rozpočtu.
4. **Vyprodaný termín:** přirozené vyjednání dostupné alternativy při omezeném
   čase, porozumění nabízeným možnostem a případné zdvořilé odmítnutí nevhodné
   nabídky. Nestačí automaticky zvolit první dostupný čas bez ohledu na zadání.
5. **Oprava objednávky:** upřesnění nedorozumění, vysvětlení přesné změny a
   ověření aktualizovaného shrnutí. Model musí změnit skutečný košík, přepočítat
   cenu a zrušit staré potvrzení; nepřepisuj jen konverzační text.
6. **Orientace v Londýně:** delší pokyny s orientačními body, zdvořilé žádosti
   o zopakování či upřesnění a ověření porozumění; případná uzavírka nebo jiná
   trasa musí odpovídat skutečnému světu. Dokončení vyžaduje reálnou návštěvu cíle.

Používej přirozenou angličtinu přiměřenou B1–B2: souvislejší výměny, vysvětlení
důvodu, zdvořilé žádosti a upřesnění, porovnávání, vyjádření preference a podmínky,
opravu nedorozumění. Volby mohou používat například I was wondering whether…,
Would it be possible to…?, I'd prefer… because…, If that slot isn't available…,
Could you clarify what… includes? Neplň dialog mechanicky idiomy ani dlouhými
souvětími. Správná odpověď nemusí být nejdelší ani jediná zdvořilá.

Každá situace má mít jasné konkrétní komunikační cíle, několik smysluplných
výměn, uvěřitelné distraktory, více vhodných formulací a nejméně několik obsahově
odlišných dosažitelných variant. Varianty mění skutečné údaje a podmínky v datech,
NPC, ceníku, košíku, platbě a vyhodnocení; pouhé zamíchání odpovědí nestačí.
Nepředstírej jazykovou obtížnost složitou větou nad totožným jednoduchým klikem.

### Otázky hráče při nákupu lístků na London Eye

Uživatel výslovně chce přidat otázky do situace, **kdy on sám chce koupit lístky
na London Eye**. Tento bod nenahrazuj obecným znalostním kvízem o městě: hráč
je zákazník, ptá se prodavače a podle odpovědí rozhoduje o vlastní objednávce.
Nabídni smysluplné dotazy před objednáním, při výběru času i při potvrzení.
Součástí mohou být například tyto anglické formulace:

- What ticket options are available for this afternoon?
- How much would it cost for two adults and one child?
- Is there a family option, and what does it include?
- Does that price include everything, or are there any extra charges?
- Which time slots are still available?
- If the three o'clock slot is sold out, what would you recommend instead?
- Could we choose a later time without exceeding our budget?
- Would it be possible to change the number of tickets before I pay?
- Could you confirm the total price and the time of our visit?
- Can I pay by card, and where should I show the tickets afterwards?
- I'm not sure I understood that. Could you explain it again, please?

Jsou to návrhy komunikačních záměrů, nikoli povinný seznam vždy zobrazený naráz.
Přizpůsob je scénáři, úrovni B1–B2, skutečné skupině, času a rozpočtu. Vytvoř
větvení, kde odpověď NPC poskytne potřebnou informaci a hráč podle ní vybere,
upřesní, odmítne nebo opraví nabídku. Některá zadání mají výslovně vyžadovat
správný dotaz a porozumění jeho odpovědi, nikoli jen konečný správný košík.

NPC musí uvádět skutečné cvičné ceny, součty, dostupnost, položky a podmínky
dané varianty. Rodinnou slevu, příplatek nebo právo na změnu smí nabídnout jen
tehdy, když je skutečně definovaný a podporovaný modelem. Nevymýšlej skutečné
obchodní podmínky London Eye a nedělej reálné objednávky či platby.

Dotaz na informace nesmí sám potají objednat či zaplatit vstupenku, vymazat košík
nebo potvrdit cizí počet osob. Hráč musí mít možnost se doptat a vrátit se
k objednávce. Změna objednávky musí naopak správně přepočítat cenu a zrušit
staré potvrzení. Záměry vyhodnocuj podle stabilních ID a stavu, nikoli podle
pozice tlačítka či libovolného výskytu slova ticket.

Pro VR může tlačítko typu **Zeptat se na nabídku…** otevřít přehledný výběr
3–4 dotazů a další stránku; po odpovědi NPC se lze vrátit do nákupu. Totéž musí
fungovat na PC myší i klávesnicí. Otestuj účinek každého dotazu, zachování košíku,
konzistenci odpovědi, požadované komunikační cíle a celou navazující platbu.

Zachovej oddělení jazykové vhodnosti, splnění komunikačního cíle a splnění
věcných podmínek. Zdvořilá replika se špatným termínem či rozpočtem musí mít
odpovídající důsledek. Hráč má rozumět konkrétní chybě a způsobu opravy. V režimu
Zkouška se podrobná nápověda a řešení zobrazí až ve výsledku, ne barvou či tooltipem.

Povinným základem na PC i PICO zůstává plně dokončitelný výběr replik. Nabízej
zpravidla 3–4 odpovědi v jednom kroku, velká tlačítka a přiměřené členění. Delší
rozhovor rozděl do kroků, neshrň celý B2 dialog na jeden přeplněný VR panel.
Zadání, navigace a technické chyby zůstávají česky; dialogy a repliky anglicky.
Režim Učím se může nabídnout překlad a slovní oporu na vyžádání, Procvičování
nové kombinace a Zkouška stejný plný model bez pomoci. Zachovej příjemné tempo.

Uprav samostatný `data/english/scenarios.json`, skutečný EnglishManager a
příslušné UI. Peníze dál počítej v pencích. Lístek musí odpovídat skutečné nově
zvolené variantě a vzniká až po potvrzení a jediné platbě. Staré reference nebo
testy nepřepisuj na automatické dokončení z definice scénáře.

Uložené A1–A2 výsledky nesmějí automaticky znamenat zvládnutí nových B1–B2 úloh.
Navrhni kompatibilní verzování anglických výsledků nebo jejich čitelné archivní
označení a skutečně ho validuj. Nesmaž hráči starý postup bez náhrady. ID situací
zůstávají stabilní, změnu obsahu a interpretace skóre vysvětli v dokumentaci.

Hra je offline. Nevyžaduj mikrofon, cloud, placené API ani fyzickou klávesnici.
Bez skutečně implementovaného zvuku nehodnoť poslech či výslovnost. Výsledek
označ jako procvičení situací zaměřených na B1–B2; několik dialogů nedokládá
kompletní úroveň CEFR a nesmí automaticky vydávat jazykový certifikát.

## 8. Přidej samostatné otázky na Londýn

Uživatel dále požaduje otázky na Londýn. Připrav nejméně **20 kvalitních otázek**
v samostatném datovém katalogu se stabilními identifikátory, například LONQ01–LONQ20.
Nejde o pouhé informační cedule a nejde jen o přejmenování šesti nákupních situací.
Kvíz musí být dostupný z londýnské oblasti například přes Alexe nebo označenou
znalostní tabuli a plně dokončitelný myší/klávesnicí i VR paprskem a triggerem.

Pokryj několik smysluplných témat:

- Památky: London Eye, Elizabeth Tower, Big Ben jako zvon, Westminster a další
  ověřené londýnské památky. Nezaměňuj například Tower Bridge a London Bridge.
- Temže, nábřeží, mosty a základní orientace ve městě.
- Doprava a běžné návštěvnické situace: porozumění značkám, pokynům a informacím
  o dopravě, bez závislosti na aktuálních cenách jízdného či právě platných uzavírkách.
- Základní kulturní a historické souvislosti a praktický život ve městě.

Faktické odpovědi skutečně ověř z vhodných primárních / oficiálních zdrojů,
například UK Parliament, London Eye, Transport for London, příslušné muzeum či
oficiální instituce památky. Ke každé otázce ulož zdroj a srozumitelné vysvětlení.
Nehádej data, jména ani polohu. U nejednoznačné otázky uprav formulaci nebo ji
vyřaď. Fiktivní ceny z nákupního tréninku nikdy nevydávej za skutečné londýnské
reálie. Ověřování zdrojů patří do vývoje; hotová hra funguje plně offline.

Jazyk otázek a odpovědí směřuj k B1–B2. Kombinuj stručné přímé otázky s několika
krátkými texty, z nichž hráč vyvodí odpověď, porovná dvě možnosti nebo porozumí
praktickému pokynu. Nezvyšuj obtížnost jen dlouhou větou nebo náhodnou vzácnou
historickou znalostí. Ověřuj srozumitelný obsah o Londýně a porozumění angličtině.

Nabízej zpravidla 3–4 uvěřitelné možnosti. Správná odpověď nesmí být pořád na
stejném místě ani jako jediná dlouhá či zdvořilá. Pořadí promíchej bez záměny
významu. Otázky mohou mít tematické sady a několik variant zadání. Jeden běh
může nabídnout kratší sérii; všech dvacet musí být skutečně dostupných.

Učím se poskytuje vysvětlení, volitelný český překlad a možnost opravy,
Procvičování promíchává obsah a Zkouška skrývá pomoc do konečného výsledku.
Zobraz postup sérií, konkrétní chyby, správná vysvětlení a možnost opakování.
Nevytvářej falešné hodnocení poslechu, pokud otázka obsahuje jen text.

Otázky mají vlastní uložené výsledky / nejlepší skóre, stav procvičení a historii
podle stabilního ID. Nekolidují s LON01–LON06 ani IT misemi; rozšiř skutečnou
validaci a kompatibilní save, ne jen UI seznam. Při odchodu se zruší neodevzdaný
pokus, permanentní výsledky zůstanou. Žádné neomezené XP za opakování téhož kliku.
Otestuj všechny otázky, jednoznačnost správných odpovědí, záměnu pořadí,
vyhodnocení, opravy, režimy, restart, uložení i dokončení oběma způsoby ovládání.

## 9. PC a VR jsou dvě povinné plnohodnotné platformy

### PC

- Zachovej WASD, rozhlížení myší, E, Esc a uživatelské přemapování kláves.
- Hráč se musí ze spawn bodu fyzicky dostat do každé místnosti a zpět.
- Při otevřeném UI se nesmí pohybovat; při zavření se obnoví kurzor a ovládání.
- Zachovej bezpečnou pauzu a uvolnění kláves při ztrátě fokusu aplikace.
- Menu a značení mají fungovat v 1280×720, 1920×1080 a 3840×2160, včetně 130 % textu.
- V Londýně musí stále fungovat myš, šipky/Tab, Enter a repliky 1–4.

### VR / PICO 4

- Zachovej OpenXR akční mapu, oba ovladače, trigger, rozlišení kliknutí a posuvu,
  teleport, snap turn, kalibraci výšky, režim vsedě i vestoje.
- Nový hub, chodby a vstupy zahrň do skutečných pravidel teleportu. Současné
  `can_teleport()` kombinuje původní meze a čidla učebny/Londýna; nestačí přidat
  novou podlahu mimo tyto meze. Řeka mimo most zůstává zakázaným cílem.
- Teleport neprochází zavřenými dveřmi, zdmi nebo vybavením; cílová kapsle musí
  mít prostor. Nesmí se cílit do prázdna, nad strop či dovnitř objektu.
- Dveře a navigaci lze používat vsedě bez natahování za kolize. Žádné drobné
  zásahové plochy místo řádných ovladačů. Menu panel lze přes A/X přemístit.
- Světově ukotvené UI zachovává pohodlnou výšku a nesleduje každý pohyb hlavy.
- Fyzický room-scale odchod i teleport s otevřeným panelem správně změní oblast.
- Přidržení triggeru a obě ruce nezpůsobí dvojí akci, platbu nebo odměnu.
- Ztráta trackingu nebo focus pozastaví interakce podle současného chování.
- Žádná automatická jízda kamery ani povinná fyzická klávesnice v headsetu.

## 10. Vizuální kvalita, výkon a rozpočet distribuce

Použij společné AcademyTheme a dosavadní jazyk prostředí, ale hub udělej
přehledný a příjemný. Pro nové modely preferuj úspornou procedurální geometrii,
sdílené materiály a vhodné dávkování. Neduplikuj skryté místnosti a celé scény.
Nezvyšuj počet monitorů, shaderových efektů a světel bez ověření dopadu.

Zkontroluj Forward+ na PC i **Compatibility / OpenXR profil PICO**. Materiál,
který vypadá dobře jen s desktopovým SSAO či odrazy, není dostatečně opravený.
PICO používá ARM64, OpenGL Compatibility, multiview a vlastní vendor plugin;
nepřidávej desktopové závislosti nebo síťovou službu jako podmínku hry.

Předem změř velikosti aktuálních artefaktů. Při napsání tohoto zadání mělo hlavní
EXE 104 786 904 B, tj. jen 70 696 B rezervy do přímého GitHub limitu 100 MiB.
Tato čísla musíš znovu ověřit. Větší textury nebo nové fonty nemohou být přidávány
bez rozpočtu. Zvaž sdílení, vhodné rozlišení a oficiální exportní kompresi.
Nepoužívej UPX, ruční úpravy PE, LFS pointer místo slíbeného EXE nebo vynechání
stávajícího obsahu. Nutnou změnu distribučního formátu musíš skutečně ověřit
a přesně zdokumentovat; do té doby zachovej poslední funkční balíčky.

Složku **build/** zachovej, **builds/** neobnovuj. Cílové výstupy:

- `build/ITSupportSimulator.exe` — samostatný Windows EXE s vloženými daty.
- `build/pico4/ITSupportSimulator-PICO4.apk` — podepsaný PICO build.
- BUILD_INFO, SHA256 a aktuální `build/VERIFICATION.json`.

Použij stávající nástroje build_windows.py / Build-Windows.ps1,
build_platforms.py / Build-Platforms.ps1, test_windows.py a test_pico.py.
Zachovej identifikátor Android balíčku a kompatibilní podpis pro aktualizaci.
Změnu verze / versionCode udržuj shodnou s verifikačními skripty a návody.
Žádný debug screenshot, testovací scéna nebo starý build nesmí zbytečně zvětšit
export. Prohlédni skutečný obsah obou nových balíčků.

## 11. Povinné testy a skutečné ověření oprav

Každý nový test nastaví `SaveManager.path_override` a vlastní nastavení **před**
vytvořením GameManageru. Nikdy nepoužívej hráčův academy_save.json. Při souběžných
procesech používej odlišná jména včetně PID. Staré sady s pevnými cestami nespouštěj
současně nad stejným uživatelským adresářem.

Přidej relevantní regresní testy a proveď přinejmenším:

1. Nový i starý save, start PC, start VR, opakovaný vstup z menu a bezpečný spawn.
2. Skutečnou chůzi hub → každá ze čtyř oblastí → hub. Oba směry dveří, ovladače,
   kolize, prahy, obsazený průchod, zavírání a zákaz teleportu skrz zavřené dveře.
3. Žádné mezery do prázdna a žádné nové překryté plochy. Geometrickou kontrolu
   doplň vizuálními snímky, ne jen počítáním objektů.
4. Kampaň s upraveným skutečným stavem → hub → všechny vzdělávací oblasti →
   serverovna. Porovnej skutečnou infrastrukturu, ticket a rozpracovaný postup.
5. Všechny tři IT režimy a náhodná série, programovací editor s konceptem a běžící
   náhled, anglický dialog s košíkem i vydaným lístkem. Při odchodu nesmí zůstat
   nepatřičné UI ani se přepsat odložená kampaň.
6. Všech šest LON situací na PC i přes skutečné ray kliky do SubViewportu;
   platební terminál a kontrola lístku zůstávají na správných světových místech.
   Otestuj všechny nové B1–B2 varianty včetně nesplněné podmínky, nepochopené
   nabídky, opravy nedorozumění, chybného součtu a kompatibility starých výsledků.
   Otestuj také všech nejméně 20 londýnských otázek a jejich zdroje, jednoznačné
   odpovědi, skutečný kvíz přes PC i VR, souhrn chyb a uložené výsledky.
7. Oba XR ovladače, press/release, současné paprsky, teleport, snap turn,
   sezení/stání a fyzický odchod s otevřeným panelem. Syntetické vstupy přesně
   označ jako syntetické, nikoli jako hardwarovou zkoušku.
8. Uložení a restart, staré polohy, poškozená nová větev, odmítnutí neplatných
   hodnot a pravdivá chyba zápisu s možností opakování.
9. Prohlídku všech místností a materiálů v Compatibility i Forward+, různou
   vzdálenost a stranu pohledu, otevřené/zavřené dveře a 720p/1080p/4K + větší text.
10. Celou aktuální `tools/Test-All.ps1`, nikoli starší pevný seznam sad.
11. Nové samostatné EXE mimo projekt, bez editoru a sousedního PCK; nativní start
    i ověření přesně zabalených prostředků. Nové APK: podpis, CRC, manifest,
    ARM64/OpenXR a skutečné katalogy i opravené materiály uvnitř.

Je-li připojený autorizovaný PICO headset, instaluj jen na rozpoznaný PICO,
spusť a fyzicky projdi hub, vstupy a Londýn; neměň připojený telefon. Pokud
headset chybí, desktopové testy prostředků APK ani cílových 72 Hz nevydávej za
ověření Android spuštění, trackingu, komfortu nebo naměřených FPS na PICO.

Selhání nezamlčuj a neopravuj snižováním požadavků testu. Reprodukuj příčinu,
oprav chování a zopakuj související ověření. Automatický test UI nepotvrzuje
bezchybný vzhled všech povrchů; audit textur vyžaduje skutečnou vizuální kontrolu.

## 12. Co nesmíš poškodit a co předat

Neměň prvních 24 definic ani `data/missions/legacy_campaign.json`. Nepřečísluj
IT mise, lekce, programovací úlohy ani LON01–LON06. Existující generátory
`tools/build_content.py`, `build_extension.py` a `extension_catalog.py` zachovej
konzistentní; hub a grafické opravy nejsou důvodem k přepsání katalogů.

Předej skutečně hratelný hub, dokončené opravy všech nalezených vadných povrchů,
všech šest přepracovaných B1–B2 situací s vyhodnocením, londýnský kvíz s nejméně
20 ověřenými otázkami, fungující fyzické vstupy i návraty, správný spawn pro
PC/VR a zachovaný save.
Aktualizuj README, návody obou platforem, test report, vizuální audit,
PROGRESS a build manifesty. Přilož rozumné snímky před/po mimo herní export.
Vytvoř přehledné commity a uveď konkrétní provedené testy a hardwarová omezení.

Závěrečná odpověď má stručně říct, kde se hráč objeví, kudy jde do jednotlivých
místností, co bylo opraveno na texturním / materiálovém vzhledu a co nově
procvičují B1–B2 úlohy a kde se spouští londýnský kvíz, jak ovládat PC a PICO
a kde jsou nové balíčky. Neskonči
po návrhu dispozice, první místnosti nebo jediné opravě londýnských dveří.
