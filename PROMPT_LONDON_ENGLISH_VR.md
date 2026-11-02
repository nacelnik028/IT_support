# Zadání pro AI: English in London — nová místnost pro PC a VR / PICO 4

Jsi zkušený vývojář Godotu, návrhář výukových her a VR interakcí. V existujícím projektu **IT Support Simulator: Training academy** implementuj novou londýnskou místnost pro praktickou angličtinu. Hráč v ní uvidí prostorové London Eye a Elizabeth Tower a v angličtině si například koupí vstupenku na London Eye.

**Místnost musí plnohodnotně fungovat na klasickém Windows PC s myší a klávesnicí i ve VR na PICO 4.** Obě platformy mají stejný obsah, úkoly, pravidla a výsledky. PC není pouhý náhled VR scény a VR nesmí vyžadovat připojenou fyzickou klávesnici.

Proveď skutečnou implementaci, otestuj ji a připrav funkční sestavení. Nestačí plán, obrázek, izolovaná ukázková scéna ani nefunkční tlačítka. Tento soubor je zadání k realizaci; nepiš místo jeho splnění další prompt.

## 1. Nejdřív prozkoumej současný projekt

Přečti `AGENTS.md`, `PROGRESS.md`, `README.md`, aktuální testy a návody k sestavení. Navazuj na nejnovější existující stav; nezakládej novou hru a nevracej repozitář na historický commit.

Projekt již obsahuje serverovnu, IT tréninkovou akademii a samostatnou programovací učebnu s Pythonem a HTML/CSS/JS. Nová londýnská oblast bude čtvrtou částí akademie. Zachovej všechny současné funkce, 65 IT misí, 21 serverových lekcí, programátorský obsah a jejich režimy. Prvních 24 definic ani `data/missions/legacy_campaign.json` neměň.

Podstatné existující součásti:

- `scripts/world/GameShell.gd` — vstupy do místností, HUD, interakce a propojení desktopu s XR.
- `scripts/world/Datacenter3D.gd` a `scripts/world/Geometry.gd` — budova, procedurální modely, kolize a sdílení geometrie.
- `scripts/programming/AcademyRoom.gd` — příklad samostatné fyzické místnosti a její hranice. Zachovej nedávnou opravu překrývajících se zdí kolem jejích dveří.
- `scripts/core/GameModeManager.gd` a `scripts/core/GameManager.gd` — režimy a odložení kampaně.
- `scripts/progression/SaveManager.gd` a `SaveValidator.gd` — skutečné ukládání, validace a kompatibilita starších pozic.
- `scripts/ui/AcademyTheme.gd` — sdílené vizuální téma.
- `scripts/xr/XRPlayer.gd`, `VRMonitor.gd` a `VirtualKeyboard.gd` — OpenXR ovládání, paprsek, prostorový SubViewport a stávající vstup textu.
- `tools/Test-All.ps1`, `tools/test_all.py`, `tools/build_windows.py`, `tools/build_platforms.py`, `tools/test_windows.py` a `tools/test_pico.py` — testy a distribuce.

Používej dostupný Godot MCP a přímé změny souborů. Rozumné implementační detaily vyřeš samostatně podle projektu. Po dokončených etapách testuj, aktualizuj `PROGRESS.md` a vytvářej přehledné Git commity. Chraň případné cizí rozpracované změny.

## 2. Výsledek z pohledu hráče

Hráč vstoupí do označené místnosti **English in London / Angličtina v Londýně**. V prostoru rozpozná London Eye, Elizabeth Tower, nábřeží Temže a přepážku pro prodej vstupenek. Vybere si krátký úkol, přečte si zadání a promluví prostřednictvím anglických replik s prodavačem. Zvolí počet a druh lístků, čas a způsob platby, zkontroluje objednávku, provede simulovanou platbu a dostane odpovídající vstupenku. Tu může ukázat u vstupní kontroly. Další situace ho přivede k otázce na cestu k Elizabeth Tower.

Cílem je praktická komunikace a porozumění jednoduché angličtině přibližně na úrovni A1–A2. Vyšší obtížnost může přidat delší zdvořilé formulace a méně nápovědy. Nevytvářej kompletní jazykový kurz ani simulátor celého Londýna.

Výchozí ovládání dialogu bude **výběr krátkých anglických replik**. Pro tuto hru ho volíme kvůli dokončení úkolu běžnými VR ovladači bez neustálého psaní. Volba odpovědi musí skutečně ovlivnit objednávku a reakci NPC; nejde o dekorativní kvíz s tlačítkem „pokračovat“.

## 3. Nová fyzická místnost a londýnská scéna

Vytvoř skutečnou přístupnou 3D oblast navazující na stávající akademii. Konkrétní volné místo zvol po kontrole budovy a kolizí. Nepřesouvej kvůli ní současnou programovací učebnu, racky nebo funkční dveře.

Povinné vybavení:

1. **London Eye** jako rozeznatelné prostorové vyhlídkové kolo: obruč, paprsky, konstrukce a viditelné kabinky. Nestačí nápis nebo obrázek na stěně.
2. **Elizabeth Tower** jako prostorová věž s charakteristickou horní částí a hodinovými ciferníky. Vysvětluj správně, že Big Ben je název velkého zvonu ve věži.
3. Přiměřená stylizace londýnského nábřeží: Temže, zábradlí, lavička, orientační tabule a náznak mostu. Nemusí jít o přesnou mapu ani o město v reálném měřítku.
4. Přepážka **London Eye Tickets**, srozumitelná postava prodavače, jednoduchý ceník, výběr časů a terminál pro simulovanou platbu.
5. Místo pro kontrolu vstupenky a přehledně označený návrat do akademie.
6. Stanoviště pro úkol s dotazem na cestu k Elizabeth Tower, například informační bod s NPC a směrovými tabulemi.

Pojmi místnost jako prostorný výukový londýnský pavilon, který vytváří dojem návštěvy Londýna. Zmenšené modely a upravené vzdálenosti jsou v pořádku, pokud jsou památky dobře čitelné a pohyb zůstává přirozený. London Eye leží u jižního břehu Temže naproti parlamentu; viz zdroje na konci. Neprezentuj upravené vzdálenosti jako přesnou turistickou navigaci.

Vstup musí fungovat fyzicky přes dostupné dveře nebo zřetelný průchod. Doplň také rozumnou zkratku v menu a pauze, ale zkratka nesmí být jedinou implementací místnosti. Při prvním vstupu nabídni krátké přeskočitelné seznámení.

Používej současné materiály, procedurální geometrii, sdílené meshe a vhodné MultiMesh skupiny. Londýnská část může mít vlastní světlejší barevné akcenty, ale UI má patřit do téže hry. Dbej na skutečnou hloubku mezi zdí, rámem, tabulí a popisky. Společné zdi vytvářej jen jednou: neopakuj chybu s blikáním rovnoběžných překrytých ploch.

Můžeš přidat pomalé otáčení kola, pokud je levné a kabinky zůstávají správně orientované. Není povinná jízda v kabince, pohyblivá kamera ani animovaný přesun hráče. Odměnou za lístek může být otevření kontrolní branky a přístup k pevné vyhlídkové plošině; žádná automatická VR horská dráha.

## 4. PC a VR jsou dvě povinná plnohodnotná ovládání

### Windows PC

- Zachovej existující WASD pohyb, myš, klávesu E pro interakci a Esc pro návrat.
- Dialog se ovládá myší i klávesnicí: viditelný fokus, šipky/Tab a potvrzení Enter. Číselné zkratky 1–4 jsou vhodný doplněk, pokud nekolidují se současným ovládáním.
- Všechny úkoly jdou dokončit bez headsetu, VR ovladačů a mikrofonu.
- Otevřený dialog ani psaní nesmějí současně spouštět chůzi nebo interakci se světem za panelem.
- Rozhraní musí být čitelné a ovladatelné v 1280×720, 1920×1080 i 3840×2160 a při nastavení většího textu.
- Při zavření dialogu se korektně obnoví pohyb a režim kurzoru. Zachovej současné bezpečné pozastavení při ztrátě fokusu aplikace.

### VR / PICO 4

- Použij stávající OpenXR paprsek a trigger pro výběr skutečných ovládacích prvků. Zachovej použitelnost obou ovladačů a již existující rozlišení kliknutí od posuvu.
- Zobrazuj zpravidla 3–4 přehledné odpovědi současně. Delší obsah rozděl do jasných kroků; hlavní potvrzení nemá být schované pod dlouhým posuvem.
- Odpovědi mají velké zásahové plochy, rozestupy, čitelný text a jednoznačný hover/fokus. Stav nevyjadřuj pouze barvou.
- Panel ukotvi do světa u prodavače nebo přepážky, v pohodlné poloze pro sezení i stání. Nemá trvale lepit na obličej ani cestovat s každým malým pohybem hlavy. Nabídni existující způsob přemístění panelu před hráče.
- Respektuj teleport, snap turn, kalibraci výšky a ztrátu trackingu. UI nesmí vyžadovat natahování za přepážku ani přesné trefování drobných 3D písmen.
- Celý základní scénář jde dokončit samotnými ovladači. Pro nákup lístku nevyžaduj psaní věty na virtuální klávesnici.
- Přidržení triggeru, dvojklik nebo současný zásah dvěma paprsky nesmějí dvakrát odeslat repliku, strhnout peníze nebo vydat dvě odměny.

## 5. Anglické dialogy a vzdělávací režimy

Zadání, navigaci, technické chyby a nastavení piš česky. Samotný rozhovor s NPC a hráčovy odpovědi budou anglicky. Texty musí působit jako přirozený rozhovor na turistické přepážce.

Příklad základního průchodu, který obsahově implementuj, ne jen zobraz jako jeden text:

| Krok | Příklad anglické repliky nebo akce | Dopad ve hře |
|---|---|---|
| Prodavač zahájí rozhovor | “Hello! How can I help you?” | Čeká se na požadavek hráče. |
| Hráč objedná | “I'd like one adult ticket, please.” | Košík obsahuje jeden dospělý lístek. |
| Prodavač se zeptá na čas | “What time would you like to visit?” | Nabídnou se časy dané situace. |
| Hráč odpoví | “Three o'clock, please.” | Objednávka obsahuje 15:00. |
| Prodavač shrne objednávku | “One adult ticket at three o'clock. That's thirty pounds.” | Zobrazí se odpovídající kontrola počtu, času a ceny. |
| Hráč potvrdí a zvolí platbu | “That's right. Can I pay by card?” | Potvrzený košík čeká na simulovanou platbu kartou. |
| Hráč přiloží cvičnou kartu | Interakce s terminálem | Platba se zaznamená právě jednou. |
| Prodavač vydá lístek | “Here's your ticket. Enjoy your visit!” | Vznikne konkrétní platná vstupenka. |
| Hráč poděkuje | “Thank you. Have a nice day!” | Rozhovor se přirozeně ukončí. |

Přijímej více správných formulací: například “Can I have one adult ticket, please?” i “I'd like one adult ticket, please.” jsou vhodné žádosti. Správná odpověď nemusí být vždy nejdelší nebo jediná věta obsahující „please“.

Nabídni tyto režimy:

- **Učím se:** krátké vysvětlení cíle, volitelný český překlad aktuální věty a význam důležitých slov; po chybě vysvětlení a možnost opravy.
- **Procvičování:** nové kombinace počtů, časů a rozpočtů; bez předem zvýrazněné správné repliky. Hráč si může vyžádat nápovědu.
- **Zkouška:** zadání a rozhovor bez nápovědy, překladu a označení správné odpovědi. Na konci ukaž konkrétní chyby a užitečné formulace.

Zachovej příjemné tempo bez povinného časového limitu. V režimu Učím se chybná replika běžně vyvolá přirozené upřesnění NPC, ne okamžitý restart. Odlišuj jazykovou správnost, vhodnost repliky v rozhovoru a skutečné splnění zadání. Zdvořilá věta se špatným počtem lístků může být jazykově správně, ale neplní úkol.

Překlad nesmí být trvale přimíchaný ke každé odpovědi. V režimu Zkouška nesmí tooltip, barva ani jiná délka odpovědi prozrazovat řešení. Nesprávné možnosti mají být uvěřitelné, například jiný počet osob, druh vstupenky, čas nebo záměna dotazu na cenu za dotaz na místo.

## 6. Minimální obsah: šest samostatně dokončitelných situací

1. **One adult ticket:** nákup jednoho dospělého lístku na konkrétní dostupný čas a platba kartou.
2. **A family visit:** nákup pro jednoho dospělého a jedno dítě; správné rozlišení adult/child, množství a celkové ceny.
3. **How much is it?:** dotaz na cenu, kontrola rozpočtu a volba vhodné dostupné varianty. Hra nesmí přijmout platbu přesahující cvičný rozpočet.
4. **That time is sold out:** požadovaný čas se při dotazu ukáže jako vyprodaný. Hráč požádá o další dostupný čas nebo vybere vhodnou alternativu. Vyprodanou variantu nelze zaplatit; hráč ale musí mít možnost se na ni v dialogu nejprve zeptat.
5. **Let me change that:** před zaplacením se opraví objednávka, například z nesprávného počtu nebo času. Shrnutí, cena, platba i výsledný lístek musí vycházet z opravených údajů.
6. **Excuse me, where is Elizabeth Tower?:** dotaz informačnímu NPC na cestu, porozumění jednoduchým pokynům a skutečný příchod k označenému stanovišti věže nebo vyhlídce na ni. Samotné kliknutí na správnou repliku bez návštěvy cíle úkol nedokončí.

Každá situace má vlastní stabilní ID, české zadání, odpovídající anglické dialogy, počáteční stav, cíle, nápovědy a závěrečné vysvětlení. První situace musí obsahovat ucelený rozhovor od pozdravu přes nákup po poděkování. U ostatních použij rozsah přiměřený úkolu; obvykle stačí několik smysluplných výměn.

Ceny jsou **záměrně fiktivní výukové údaje**, nikoli aktuální nabídka London Eye. Pro základní příklady můžeš použít £30 za dospělého a £20 za dítě. Případné jiné ceny zapisuj do dat, ne do textových podmínek v kódu. V krátkém popisu scénáře označ, že jde o cvičné ceny. Neimplementuj skutečné platby, objednávky ani práci s reálnou platební kartou.

Přidej několik ověřených variant scénářů, které mění skutečné údaje a podmínky. Změna má být vidět v dialogu, ceníku, košíku i kontrole cíle. Nestačí změnit název stejného testu nebo náhodně promíchat tlačítka. Generované zadání vždy musí mít dosažitelné řešení.

## 7. Skutečný model rozhovoru, objednávky a vstupenky

Obsah ulož do samostatného datového katalogu, například `data/english/scenarios.json`. Vytvoř přehledný dialogový model s identifikátory uzlů a záměrů odpovědí. Nekóduj postup podle čísla tlačítka nebo přesného textu anglické repliky.

Odděl alespoň:

- Aktuální scénář, režim a varianta zadání.
- Stav rozhovoru a jeho stručná historie.
- Požadované množství adult/child, zvolený slot a dostupnost.
- Ceny, rozpočet a spočtený součet. Peníze počítej v celočíselných pencích.
- Rozpracovaný košík, potvrzení objednávky a stav platby.
- Vydanou vstupenku s vlastním ID, typem, počtem osob, časem a stavem kontroly.
- Skutečné cíle scénáře, chyby, použitou nápovědu a výsledek.

Vstupenka vzniká až po platné potvrzené objednávce a úspěšné cvičné platbě. Zamítnutá platba nesmí vytvořit lístek ani dokončit scénář. Vydaný lístek a účtenka přesně odpovídají košíku; nevkládej správné údaje automaticky podle zadání.

Lístek má být viditelný a použitelný u kontroly. Pro VR může být držený v ruce podle současného systému uchopení, nebo dostupný jako konkrétní předmět v malé peněžence. Na PC zajisti stejně plnohodnotnou akci přes E nebo jasné tlačítko „Předložit vstupenku“. Netvoř nepoužitelnou VR mechaniku, která nemá PC ekvivalent.

Kontrola musí odmítnout chybějící, neplatný nebo již spotřebovaný lístek. Zamez opakovanému vydávání výsledků a odměn stejným potvrzením. Po chybě zachovej srozumitelnou možnost opravy nebo restartu právě dané situace.

## 8. Volitelné rozšíření: vlastní psané odpovědi

Povinným základem zůstává dokončitelný výběr replik na PC i VR. Teprve po jeho dokončení můžeš přidat přepínač **Napsat vlastní odpověď**, zvlášť užitečný na PC. Toto rozšíření nesmí blokovat dodání základní funkční místnosti.

Pokud ho implementuješ:

- Na PC použij skutečné textové pole a fyzickou klávesnici. Ve VR znovu použij existující virtuální klávesnici a podporu fyzické/Bluetooth klávesnice, pokud je připojená.
- Umožni kdykoli přejít zpět na výběr replik bez ztráty košíku nebo celé relace.
- Podporuj jasně vymezené jazykové záměry, například požadavek na lístky, počet a typ osoby, čas, cenu, opakování otázky a platbu kartou/hotovostí.
- Uznávej běžné ekvivalentní formulace, velká/malá písmena, apostrofy, nadbytečné mezery a základní interpunkci. Například “3 pm”, “15:00” a “three o'clock” mohou v odpovídajícím kontextu označovat stejný čas.
- Neuznávej automaticky libovolný text obsahující „ticket“ nebo „please“. Nesprávný počet, nejasný čas, negace nebo rozporná objednávka nesmějí potají potvrdit jinou požadovanou variantu.
- U neznámé formulace napiš srozumitelně, že jí tento výukový režim nerozumí, a nabídni opakování či výběr replik. Netvrď, že jsi zhodnotil celou anglickou gramatiku.

Mikrofon, rozpoznávání řeči, generativní chat, cloudové API a placené služby nejsou součástí povinného zadání. Hra musí fungovat offline. Pokud nepřidáš skutečnou zvukovou stopu, nezobrazuj nefunkční tlačítko přehrávání ani nehodnoť poslech/výslovnost, které se netestovaly.

## 9. Režimy místností, uložený postup a ochrana stávající hry

Angličtina má vlastní stav a výsledky. Nesmí se tvářit jako serverová lekce, měnit IT infrastrukturu nebo používat programovací úlohu jen proto, aby se vešla do starého přepínače.

V `GameModeManager` přidej vlastní režim, například `ENGLISH_LONDON`. Zachovej současné číselné hodnoty MAIN=0, SERVER_TRAINING/TRAINING=1 a PROGRAMMING_ACADEMY=2; nový režim přidej za ně. Uprav skutečné kontroly dostupnosti, hranice místností, menu, HUD a interakce.

Zvlášť zkontroluj `GameShell`, `GameManager.reconcile_room()`, přechody mezi vzdělávacími režimy, `is_education()`, `leave_training()`, obnovu pozice a signál `room_changed(training_room: bool)`. Stávající booleany samy nerozlišují čtyři oblasti. Nesmí se stát, že odchod z angličtiny omylem spustí serverovou konzoli nebo obnoví programovací editor. Zvol malé a srozumitelné rozšíření existující architektury; nepřepisuj celou hru.

Požadované chování:

- Vstup do angličtiny bezpečně odloží rozpracovanou kampaň. NPC dialog a cvičná peněženka mění pouze stav anglické relace.
- Odchod fyzicky, teleportem, přechodem do jiné místnosti, hlavním menu nebo změnou scény zruší nedokončený rozhovor, košík, dočasnou vstupenku a jeho UI.
- Po odchodu se obnoví původní kampaň včetně skutečné infrastruktury, rozpracovaného ticketu a příslušného kontextu.
- Dokončené výsledky angličtiny, nejlepší skóre, používaná nápověda a přehled naučených frází zůstávají uložené.
- Nedokončený nákup se po restartu nevydává za zaplacený ani se sám neotevírá před hráčem.
- Opakovaný vstup do zóny nebo opakované signály z UI nespustí druhou souběžnou relaci.

Přidej souhrn postupu pro šest situací. Pokud přidáváš XP, použij stávající odměňování s omezením odměny podle stabilního ID a zlepšení výsledku; náhodné varianty nesmějí umožňovat neomezené získávání XP za tentýž klik.

Nová data ukládej například do volitelné validované větve `english` ve skutečném save. Zajisti bezpečné načtení dosavadních pozic bez této větve a ověř nové struktury v SaveValidator. Zachovej atomické ukládání a pravdivé oznámení chyby zápisu. Neměň schéma ani umístění save bez skutečné potřeby a kompatibilní migrace.

## 10. Architektura a rozumný rozsah

Vyčleň přirozené součásti, například:

- `scenes/english_london/EnglishLondon.tscn` — londýnská oblast.
- `scripts/english/EnglishRoom.gd` — stavba místnosti, NPC a stanovišť.
- `scripts/english/EnglishManager.gd` — relace, katalog a výsledky.
- `scripts/english/DialogueController.gd` — prezentace rozhovoru pro oba vstupy.
- `scripts/english/DialogueEvaluator.gd` — cíle a vyhodnocení konkrétní situace.
- `data/english/scenarios.json` — scénáře a výukové texty.

Jsou to návrhy umístění, nikoli povinnost vytvořit přesně tento počet tříd. Drž logiku rozhovoru oddělenou od tlačítek a 3D dekorací. Jediný skutečný model se používá na PC i VR; nevytvářej pro headset falešné výsledky nebo zvláštní obsah.

Pokud generuješ data nástrojem, udržuj zdroj generátoru a výsledný JSON konzistentní. Případné zapojení do `tools/build_content.py` nesmí přepsat či přeuspořádat původních 24 misí nebo změnit současné katalogy bez potřeby. Nové anglické úlohy mají vlastní identifikátory, nikoli recyklovaná IT čísla.

## 11. Výkon, kompatibilita a exporty

Standalone PICO používá existující Compatibility/OpenXR profil. Nepřidávej desktopové nativní knihovny, externí Python, webový prohlížeč ani síťovou službu jako podmínku hry. Neinstaluj Meta/Unity SDK do Godot projektu podle obecných UX odkazů níže; jsou pouze návrhovou inspirací.

Modely a materiály navrhuj úsporně, používej instancování a přiměřené kolize. Nezdvojuj skryté místnosti, monitory a světla. Animace neaktivní oblasti podle možností uspávej. Naměřené FPS na PC nevydávej za výkon PICO; cílových 72 Hz je požadavek profilu, ne potvrzený výsledek měření.

**Složku `build` zachovej. Složku `builds` neobnovuj.** Používej současné výstupy:

- `build/ITSupportSimulator.exe` — hlavní samostatné Windows EXE s vloženými daty.
- `build/pico4/ITSupportSimulator-PICO4.apk` — PICO sestavení.
- Příslušné BUILD_INFO, SHA256 a `build/VERIFICATION.json`.

Předem ověř prostorový rozpočet: výchozí EXE po poslední opravě mělo 104 748 344 B, tedy jen 109 256 B rezervu do GitHub limitu 100 MiB. Tato čísla znovu změř v aktuálním checkoutu. Preferuj procedurální modely a malé datové soubory; velké textury a nahrávky nesmí překvapit až při finálním pushi. Nepřekračuj limit přímého Git souboru a neobcházej ho úpravou PE, UPX nebo vynecháním slíbeného obsahu. Zachovej funkční dosavadní balíček, dokud nový export a jeho distribuce nejsou skutečně ověřené; nutnou změnu distribučního formátu řádně zdokumentuj.

Zkontroluj, že nové scénáře, modely a texty skutečně jsou uvnitř obou exportů a že do nich nebyly přibaleny build výstupy či testovací soubory. Aktualizuj balíčkové smoke kontroly, které dosud znají pouze IT a programování. Případnou změnu Android versionCode/verze udržuj konzistentní také s ověřováním balíčků.

## 12. Ověření, které musíš opravdu provést

Každý test musí nastavit `SaveManager.path_override` a vlastní nastavení ještě před konstrukcí GameManageru. Nepoužívej hráčův `academy_save.json`.

### Model a cíle

- Všech šest situací lze správným postupem dokončit; existují i negativní případy.
- Počet osob, adult/child, čas a součet na lístku odpovídají skutečně zvolené objednávce.
- Vyprodaný čas, překročený rozpočet, neúplná nebo nepotvrzená objednávka a chybějící platba nevydají platný lístek.
- Změna košíku před zaplacením aktualizuje cenu a zneplatní předchozí potvrzení.
- Opakovaný trigger/potvrzení nebo obě ruce zároveň nezpůsobí dvojí platbu, lístek ani odměnu.
- Jiná správná formulace funguje; náhodná pozice odpovědi nemění její význam.
- Příchod k věži a kontrola vstupenky ověřují skutečný světový stav.
- Generované varianty mají dosažitelné řešení a vzájemně konzistentní údaje.
- Při implementaci psaní otestuj i neznámé, rozporné, negované a sémanticky chybné vstupy.

### PC

- Skutečný průchod od vstupu do místnosti přes rozhovor, potvrzení nákupu, platbu a kontrolu lístku až zpět do serverovny.
- Výběr myší i klávesnicí, návrat přes Esc, korektní fokus a žádná chůze při dialogu či psaní.
- Grafická kontrola 720p, 1080p a 4K s běžným i zvětšeným textem.
- Samostatné nové Windows EXE spuštěné mimo projekt bez editoru a bez sousedního PCK.

### VR a PICO

- Skutečný ray klik v SubViewport, oba ovladače, jednoznačné stisknutí/uvolnění triggeru a práce s lístkem.
- Pohodlná výška dialogu, teleport, snap turn a zrušení rozhovoru při fyzickém opuštění místnosti i při teleportu.
- Pokud je připojený autorizovaný PICO, ověř instalaci, start, celý nákup a odchod na skutečném zařízení. Instaluj pouze na rozpoznaný PICO headset, ne na jiný připojený telefon.
- Bez headsetu označ syntetické XR testy a testy prostředků APK přesně tímto způsobem. Neprohlašuj tracking, Android spuštění ani FPS za ověřené jen na základě desktopového testu.

### Regrese a ukládání

- Obnova rozpracované kampaně po návštěvě angličtiny, beze změny IT infrastruktury.
- Přímé přechody mezi angličtinou, serverovou akademií a programovací učebnou; včetně odchodu s otevřeným dialogem.
- Zachování výsledků po novém spuštění; kompatibilita starého save bez angličtiny; pravdivá chyba při selhání zápisu.
- Testy dveří, kolizí, značení a geometrie nového vstupu. Žádná mezera do prázdna, blokovaný návrat nebo blikající překrytá zeď.
- Přidej relevantní nové regrese do současného testovacího běhu. Před finálním předáním spusť celou aktuální `tools/Test-All.ps1` a odpovídající kontroly obou skutečných exportů.

V reportu rozliš zdrojové testy, grafický desktop, skutečné Windows EXE, prostředky uvnitř APK a fyzický headset. Selhaný test nezamlčuj ani nepřejmenuj na PASS. Nejprve reprodukuj příčinu; opravuj související chování, ne snižováním nároků testu.

## 13. Doporučené pořadí práce

1. Zmapuj současné místnosti, přechody, save a exportní rozpočet. Ověř výchozí stav.
2. Přidej oddělený anglický režim a skutečnou místnost s funkčním vstupem/návratem a základními modely obou památek.
3. Dokonči jeden celý nákup od zadání po platný lístek a jeho kontrolu. Musí fungovat na PC i přes XR ovladače.
4. Doplň zbylých pět situací, režimy výuky, zpětnou vazbu, varianty a trvalé výsledky.
5. Uprav prostředí a pohodlí rozhraní podle skutečných snímků a měření. Volitelné psaní přidej až při hotovém základu.
6. Proveď regrese, sestav a ověř oba nové balíčky, aktualizuj README, dokumentaci angličtiny, TEST_REPORT a PROGRESS a vytvoř finální commit.

Neskonči po prvním prototypu nákupu ani po přidání památek. Základ je hotový teprve tehdy, když všechny povinné situace jdou dokončit na PC i prostřednictvím VR ovládání, výsledky se ukládají, stará hra zůstává funkční a exporty obsahují stejný nový obsah. Hardwarové omezení ověření popiš pravdivě.

## 14. Co předej

- Funkční čtvrtou londýnskou oblast a všech šest výukových situací.
- Přehledné ovládání na PC i ve VR, s výběrem anglických replik jako plně funkčním základem.
- Samostatný katalog, skutečnou objednávku/vstupenku, vyhodnocení a uložené výsledky.
- Opravené integrační body bez poškození kampaně, výukových relací a dosavadních dveří.
- Ověřené Windows EXE a PICO APK ve složce `build`, odpovídající hashe a pravdivý test report.
- Stručný závěrečný popis: kudy do místnosti, ovládání na PC a PICO, co bylo skutečně otestováno a případné konkrétní zbývající omezení.

## 15. Podklady k prostředí a návrhu interakcí

Geografické a názvoslovné podklady:

- [London Eye — oficiální umístění na South Bank a přepážka v County Hall](https://support.londoneye.com/hc/en-us/articles/212636869-Where-is-the-London-Eye-located).
- [UK Parliament — Elizabeth Tower, hodinové ciferníky a zvon Big Ben](https://www.parliament.uk/about/living-heritage/building/palace/architecture/palacestructure/towers-of-parliament/).

Obecná inspirace pro prostorové UI a vstupy:

- [Meta — pohodlí prostorových rozhraní](https://developers.meta.com/vr/design/comfort/).
- [Meta — virtuální a fyzické klávesnice a další vstupy](https://developers.meta.com/vr/design/interactions-input-peripherals/).

Výběr replik jako výchozího ovládání a rozsah úloh jsou návrhová rozhodnutí pro tento projekt. Odkazy na jiné platformy nejsou zárukou stejné systémové klávesnice či API na PICO. Implementaci opři o skutečný zdejší Godot/OpenXR kód a ověřené chování obou cílových platforem. Pro toto výukové zadání nepotřebuješ aktuální komerční ceny ani online rezervační systém London Eye.
