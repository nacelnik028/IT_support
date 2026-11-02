# English in London

Čtvrtý pavilon je jižně od serverovny, za třímetrovým průchodem označeným
**04 / Angličtina v Londýně**, vedle prosklené stěny. Zkratka **English in London**
je v hlavním menu i v pauze. Programovací učebna a původní dveře zůstávají na místě.

U přepážky **London Eye Tickets / Sam** vyber situaci a režim. První návštěva
nabídne přeskočitelné seznámení. Zadání, košík, rozpočet a skutečná cena jsou
viditelné po celou dobu nákupu. Rozhovor používá anglické repliky a cvičné ceny
£30 adult / £20 child, nikoli současnou komerční nabídku. Hra funguje offline.

PC používá WASD, myš a E. Dialog: myš, šipky nebo Tab, Enter a číselné zkratky
1–4 pro repliky. Esc zavře panel a obnoví pohyb. Otevřené UI blokuje chůzi.
Na PICO fungují oba paprsky a trigger. B/Y zavře panel, A/X jej přemístí před
aktuální pohled; potom zůstává ukotvený ve světě. Výšku, snap turn a způsob
pohybu nastavuje stávající Komfort VR. Levý stick klik nabízí teleport při
zavřeném panelu. Řeka odmítá teleport mimo most.

Po potvrzení objednávky zavři dialog, dojdi k terminálu vlevo od Sama a stiskni E
nebo použij paprsek. **Přiložit CVIČNOU KARTU** zaplatí přesný součet jednou.
Poděkuj anglickou replikou. Konkrétní vstupenka s ID, počty, časem a zaplacenou
částkou je v peněžence v dialogu. U označeného vstupu poblíž kola ji přes E nebo
trigger předlož. Použitý lístek se podruhé nepřijme; platný lístek otevře závoru.

Šest samostatných situací má ID LON01–LON06:

1. One adult ticket — dospělý, čas, karta a poděkování.
2. A family visit — v základu dospělý a dítě; procvičování mění počty na
   dva dospělé a dítě nebo dospělého a dvě děti, včetně správné ceny a rozpočtu.
3. How much is it? — otázka na cenu a nákup v rozpočtu.
4. That time is sold out — nejprve otázka na vyprodaný čas, potom alternativa.
5. Let me change that — oprava dvou dospělých na jednoho před platbou.
6. Excuse me, where is Elizabeth Tower? — rozhovor s Alexem u INFORMATION,
   porozumění směru a skutečný příchod přes most na stanoviště u věže; E ověří cíl.

Učím se nabízí překlad na vyžádání, slovní pomoc a opravu. Procvičování střídá
skutečné časy a rozpočty. Zkouška skrývá pomoc a ukáže chyby až ve výsledku.
Pořadí odpovědí se mění, záměry mají stabilní identifikátory. Existují dvě
ekvivalentní správné žádosti. Jazykově přijatelná věta se špatným počtem nebo časem
nesplní zadání. Chybný zaplacený nákup lze restartovat přes Situace / restart.

Moje výsledky uchovávají přehled šesti situací, nejlepší skóre, počet dokončení,
použitou pomoc, poslední pokusy a procvičené formulace. Angličtina nepřidává XP.
Dočasný nákup a vstupenka se neukládají. Odchod fyzicky, teleportem, zkratkou,
do menu nebo změnou scény zruší relaci a obnoví odloženou kampaň. Starší save
bez volitelné větve `english` zůstává kompatibilní se schématem 2. Selhání zápisu
zobrazuje NEULOŽENO s opakováním skutečného atomického zápisu.

Procedurální kolo má dvojitou obruč, paprsky, konstrukci a 24 kabinek. Věž má
čtyři ciferníky a horní střechu; Big Ben je jméno velkého zvonu. Pavilon má Temži,
most, zábradlí a lavičky. Vzdálenosti jsou upravené pro výuku. Geografické podklady:
[London Eye / South Bank](https://support.londoneye.com/hc/en-us/articles/212636869-Where-is-the-London-Eye-located),
[UK Parliament / Elizabeth Tower](https://www.parliament.uk/about/living-heritage/building/palace/architecture/palacestructure/towers-of-parliament/).

Model je v `scripts/english/EnglishManager.gd`, sdílené PC/XR UI v
`DialogueController.gd`, geometrie v `EnglishRoom.gd`, data v
`data/english/scenarios.json`. Katalog se negeneruje existujícím IT generátorem;
staré mise, lekce a legacy24 se nemění. Nový režim má hodnotu 3, původní 0/1/2
zůstávají. Boolean `room_changed` zůstává kompatibilní; skutečnou oblast určuje
GameModeManager a nové prostorové čidlo.

Volitelné vlastní psaní, zvuk, mikrofon ani hodnocení výslovnosti nejsou součástí
implementace. Všech šest situací lze dokončit výběrem replik bez klávesnice ve VR.
Výkon a tracking fyzického PICO vyžadují připojený autorizovaný headset.
