# Training academy / Rozcestník — PC a PICO 4

Nová hra i běžný vstup z hlavního menu začínají v samostatné severní hale,
na volné podlaze (4, 0.02, -11), s pohledem na orientační tabuli. Samotný hub
nezahajuje lekci, nákup ani IT úlohu a neuděluje XP. Prostor má lavičky,
čtyři barevně rozlišené portály a vlastní světla; nepřesouvá žádné pracoviště.

| Průchod | Skutečná fyzická cesta od hubu |
|---|---|
| 01 / Serverovna | Jižní otvor vlevo, x=-6, z=-7. Do volné severní servisní uličky. |
| 02 / IT trénink | Jižní otvor vpravo, x=16, z=-7. Mezi cvičné racky. |
| 03 / Programování | Západní otvor x=-9, z=-12. Do dosavadní západní učebny. |
| 04 / English in London | Východní portál x=21, z=-11.5, chodba x=23 jižně, pak vpravo západním směrem do otvoru x=21, z=9.5. |

Hala zabírá x=-9…21, z=-16…-7. Londýnská chodba x=21…25, z=-16…11.5.
Všechny cesty mají souvislou podlahu, kolize, skutečné průchozí otvory a zpětné
značení. Nové portály jsou otevřené průchody. Původní posuvné dveře serverovna ↔
IT a serverovna ↔ programování nadále fungují oběma směry s bezpečnostními čidly.
Přímý jižní vstup ze serverovny do Londýna je na žádost uživatele zazděný, včetně kolize. Londýn zůstává přístupný východní chodbou rozcestníku.

PC: WASD, myš, E, Shift, Tab a Esc; přemapování zůstává v Nastavení.
PICO: teleport klikem levého sticku, snap pravým, oba paprsky a trigger;
B/Y zavře panel, A/X jej přemístí. Teleportovací meze zahrnují celou halu
i chodbu, cílovou kapsli kontroluje fyzika a paprsek oblouku zastaví překážky.
Řeka mimo most, stropy, prázdno a vybavení nejsou platnými cíli.

## Pokračování a uložený postup

- **Menu → Rozcestník akademie** a start VR: vždy nástupní bod v hale.
- **Pauza → Pokračovat** nebo Esc od počítače: aktuální poloha a rozpracovaná
  práce zůstávají v živé relaci podle stávajících pravidel.
- **Pauza → Kam jít → Rozcestník akademie**: návrat na nástupní bod, odložení kampaně.
- Fyzický návrat z místnosti: zůstáváš u jejího portálu, kamera se sama neotáčí.
- Při návratu do serverovny se obnoví skutečný ticket, infrastruktura, inventář
  a postup; první nová směna vznikne až vstupem do serverovny.
- Odchod z výuky či Londýna ruší dočasnou relaci a její UI. Permanentní výsledky
  zůstávají. Programovací zdrojové koncepty a samostatný snímek IT lekce se nyní ukládají pro výslovné pokračování ve správné učebně; živé cvičení se při odchodu dál vyčistí. [Pravidla](WORK_PERSISTENCE.md).

`HUB=4` zachovává hodnoty 0/1/2/3. `is_education()` vyjmenovává výukové režimy,
`is_away()` zahrnuje i hub. Čidlo haly doplňuje dosavadní prostorové sondy.
Hub není cvičná infrastruktura, kterou by bylo možné uložit přes odloženou kampaň.
Save zachovává schéma 2 a atomický zápis. Validátor přijímá skutečné nové polohy,
původní povolené pozice i staré soubory. Migrace staré severní učebny opravuje
pouze nepoužitelnou polohu; netýká se nových severních prahů. Selhání zápisu
zůstává viditelné a lze je zopakovat z pauzy i anglického panelu.

Geometrii tvoří `AcademyHub.gd`; test `academy_hub.gd` používá skutečné WASD
vstupy a kolize, ne nastavování pozice pro každou cestu. XR hardwarový komfort
a skutečný výkon PICO vyžadují headset; syntetické kontroly je nenahrazují.

## Souvislé směny — 3. 11. 2026

Při aktivní souvislé směně návrat do serverovny obnoví právě směnu, včetně
inventáře a rozpracovaného ticketu. Kampaň se obnovuje výslovnou volbou Kampaň.
Hub ani přechody přes více učeben obě větve nepřepíší. [Pravidla směn](CONTINUOUS_SHIFTS.md).
