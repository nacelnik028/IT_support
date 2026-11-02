# English in London — B1–B2

Do existujícího londýnského pavilonu vede portál 04 z rozcestníku a východní
chodba. Zůstal také jižní průchod ze serverovny, zkratka v menu a pauze.
London Eye, věž, Temže, široký most, Sam, Alex, terminál i kontrola jsou na svých
dosavadních místech. Zjednodušené vzdálenosti a 24 kabinek herního modelu
nepředstavují turistickou mapu; skutečné kolo má 32 kabinek.

## Nákup a komunikace

U Sama / London Eye Tickets stiskni E nebo použij paprsek. Vyber situaci a režim.
**Zeptat se na nabídku…** otevírá po třech zákaznických dotazech a další stránku.
Po odpovědi prodavače vyber, co jsi pochopil/a; lze žádat upřesnění a vrátit se
do objednávky. Dotaz nemění košík, potvrzení ani platbu.

Hráč se ptá na nabídku, rodinné podmínky, zahrnuté služby, dostupné časy,
doporučení alternativy, opravu objednávky, součet a platbu. Odpovědi čerpají
ze skutečných údajů aktuální varianty. Některé dotazy a jejich porozumění jsou
povinnými komunikačními cíli. Správný počet lístků sám o sobě nestačí.

| Cvičná nabídka | Dospělý | Dítě | Podmínky scénáře |
|---|---:|---:|---|
| Standard | £30 | £20 | Pevný čas po potvrzení; lze znovu vybrat nabídku. |
| Flex | £40 | £25 | Změna času před platbou; každá změna ruší potvrzení. |

Obě nabídky obsahují jednu vyhlídkovou návštěvu bez plavby a bez povinného
poplatku. Rodinná sleva zde není. Cvičné dětské rozmezí je 6–15 let s dospělým.
Vše jsou **fiktivní výuková pravidla a ceny**, nikoli obchodní podmínky London Eye.
Peníze se počítají v celočíselných pencích, včetně příplatku Flex.

Po výběru počtů, produktu a času ověř součet. Potvrzená objednávka pokračuje
u označeného terminálu vedle přepážky: **Přiložit CVIČNOU KARTU**. Platba
proběhne jednou a vydá konkrétní lístek s ID, produktem, počty, časem a částkou.
Poděkuj a u vstupní kontroly předlož lístek. Použitou vstupenku nelze použít znovu.
Nákup neprovádí skutečnou platbu. Zaplacenou chybnou objednávku opakuj novým pokusem.

## Šest situací, tři varianty a tři režimy

| ID | Komunikační a věcný cíl |
|---|---|
| LON01 | Vysvětlit plán a důvod, zjistit nabídku i služby, vybrat čas v omezeném rozmezí. |
| LON02 | Porozumět věku a doprovodu, zvolit skutečné druhy a počty, zkontrolovat celou rodinu. |
| LON03 | Porovnat dvě dostupné nabídky, zohlednit příplatek/potřebu flexibility a rozpočet, ověřit součet. |
| LON04 | Zjistit vyprodaný termín, vyjednat dostupnou a časově vhodnou alternativu; třetí varianta odmítá i dostupných 15:00 a potřebuje 16:00. |
| LON05 | Vysvětlit nedorozumění a konkrétní změnu, změnit košík i cenu, znovu ověřit a potvrdit. |
| LON06 | Delší pokyny s lavičkami, frontou a mostem, vlastní žádost o zopakování, ověření porozumění a skutečný příchod k věži. |

Učím se nabízí český překlad a oporu na vyžádání. Procvičování obměňuje skutečné
počty, časy, rozpočty a potřebné produkty. Zkouška skrývá pomoc a konkrétní chyby
do výsledku. Formulace mají stabilní záměry a promíchané pořadí; více správných
žádostí vysvětluje skutečný důvod. Jazykově vhodná odpověď může věcně nesplnit
podmínky. Vyhodnocení rozlišuje chyby v porozumění a věcné cíle.

## Otázky na Londýn

**London Quiz** je na označené tabuli vedle Alexe (LONDON-QUIZ, x=3, z=12.5),
dostupný také z přehledu situací. Nabízí všech 20 otázek LONQ01–LONQ20 nebo
krátkou sérii pěti. Témata: památky, Big Ben jako zvon, Temže a břehy, mosty,
doprava, orientace a kultura. Otázky kombinují přímé dotazy a krátké pokyny.

Učím se nabízí vysvětlení, překlad a opravu chybné odpovědi. První odpověď určuje
skóre a oprava je samostatně zaznamenaná. Procvičování míchá otázky i odpovědi.
Zkouška neukazuje řešení do odevzdání série. Souhrn obsahuje každou vlastní
odpověď, konkrétní vysvětlení a zdroj. Výsledky, nejlepší skóre, procvičení a
historie jsou uloženy podle stabilního ID. Odchod neodevzdá rozpracovaný pokus.

Každá otázka obsahuje oficiální URL a datum ověření 2026-11-02. Zdroje: UK
Parliament, London Eye, TfL, City Bridge Foundation a National Gallery.
Katalog je offline; hru nepodmiňuje síť ani otevření webového odkazu.
`tools/build_london_quiz.py` deterministicky vytváří pouze tento samostatný katalog.

## Ovládání a kompatibilita

PC: WASD, myš, E; dialog a kvíz také šipky/Tab, Enter a repliky 1–4.
Esc vrací pohyb. Dlouhý souhrn posouvej kolečkem; fokus sleduje posuv.
PICO: oba paprsky a trigger, pravý stick pro posuv, B/Y zavře, A/X přemístí
ukotvený panel. Žádná situace nevyžaduje fyzické psaní ani mikrofon.

`english.content_version=2` označuje nové B1–B2 výsledky. Původní výsledky,
pokusy a fráze A1–A2 se beze ztráty přesunou do čitelného `english.archive`;
neznamenají automatické zvládnutí nových úloh. Kvíz má větev `english.quiz`.
Obě větve validuje stávající SaveValidator, atomický save zachovává schéma 2.
Žádné XP za opakované klikání. Selhání zápisu lze pravdivě opakovat v panelu.
Dočasný rozhovor, košík a lístek se mezi návštěvami neukládají. Kampaň se bezpečně
odkládá i při přechodu přes hub nebo jinou vzdělávací oblast.

Jde o procvičení textových situací zaměřených na B1–B2, nikoli hodnocení celé
CEFR úrovně, poslechu či výslovnosti nebo jazykový certifikát. Syntetické XR
testy ověřují vstupy a UI; skutečný tracking a výkon PICO vyžadují hardware.
