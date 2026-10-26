# Programming Academy

Třetí oblast existující hry obsahuje 30 Python úloh PY01–PY30, 30 webových úloh WEB01–WEB30, 15 Python a 13 webových lekcí a 12 opravovacích variant DBG01–DBG12. Původní IT katalogy zůstávají samostatné.

## Použití

Učebna je severně od serverovny za dveřmi u SW-CORE. Ovladač funguje z obou stran přes E; alternativou je Pauza → Programming Academy. Python Lab, Web Development Lab, Examination Zone, Ada i tabule otevírají skutečný editor. Web Lab zahrnuje HTML/CSS/JS.

Vyber lekci, úlohu či opravu a režim. Učím se obsahuje výklad a samostatně otevřenou ukázku. Vyžaduje úpravu, spuštění, další úpravu a spuštění a potom úspěšný test zadání. Procvičování má volitelné nápovědy. Zkouška blokuje nápovědy i ukázku. CodeEdit má odsazení, syntax highlighting, výběr textu, číslování řádků, desktopový clipboard/undo/redo a zoom A−/A+.

Python input() čte řádky virtuální vstupní konzole. Spustit používá první datovou sadu, Otestovat všechny sady. Dodaná data zůstávají v pojmenovaných proměnných; například logs pro závěrečnou analýzu serveru PVE-01. Web přepíná index.html/style.css/script.js; Spustit obnoví interaktivní náhled. Odkazy na sekce, formuláře a podporované DOM kliknutí reagují.

Generátor nabízí Python/HTML/CSS/JavaScript/smíšený trénink, začátečníka/pokročilého/zkoušku a 1–20 úloh. Mění skutečné vstupy a výsledky; webové varianty dostanou další strukturální požadavek. Před spuštěním ověří každou variantu referenčním řešením. Další úloha je dostupná po úspěšném testu. Základní JS událost je dostupná na obou obtížnostech s měněným doplňujícím požadavkem.

## Rozsah a izolace

[Úplný podporovaný rozsah](../data/programming/LIMITS.txt) je také v editoru. Jde o výukovou podmnožinu, nikoli CPython nebo úplný prohlížeč. PythonParser vytváří AST a PythonRuntime vyhodnocuje povolené operace s limity kroků, času, alokací, rekurze a výstupu. Hráčův kód se nepředává hostitelskému Pythonu, Expression, GDScript loaderu nebo OS. VFS je nová paměťová mapa každého běhu, bez souborů zařízení. Exception nepřekoná limity či sandbox.

HTML se analyzuje strukturálně, CSS podle selektorů a JavaScript vlastním omezeným parserem DOM kliknutí/textContent. Náhled používá Godot Controls na obou platformách. Síťové adresy ani zdroje nespouští externí aplikace. Odeslání formuláře je místní simulace. Výsledek není testem plné kompatibility s prohlížečem; pokročilé Python konstrukce, closures a neuvedené knihovny nejsou podporované.

## Architektura, data a save

GameModeManager má MAIN / SERVER_TRAINING (zpětný alias TRAINING) / PROGRAMMING_ACADEMY. GameManager rozhoduje podle polohy a zachovává odloženou kampaň i při přímém přechodu mezi oběma centry. AcademyRoom tvoří scénu/hranici, AcademyManager řídí cvičení/statistiky, CodeEditorController prezentaci, CodeEvaluator testy, WebDocument a LearningJavaScript model a WebPreviewController náhled.

Původní SaveManager/schema 2 přijímá staré soubory bez nové větve programming. Ta obsahuje dokončené lekce, nejlepší výsledky, zkoušky, historii, chyby, XP, odemčené oblasti a velikost písma. Kariérní XP se aktualizují stejnou transakcí. Odměňuje se jen zlepšení již zaplaceného úspěšného skóre základní úlohy, včetně generovaných a opravovacích variant.

Odchod, teleport, menu či změna scény zruší lekci/sérii/editor a zachová výsledky. Kód a aktivní cvičení se automaticky neobnovují. Koncepty zdrojových souborů se trvale neukládají. Původní import/export save přenáší také programming.

`python tools/build_programming.py` deterministicky sestaví data/programming/catalog.json. Stejný generátor volá build_content.py po původním build_extension.py a nemění legacy24. Každá mise má metadata, počáteční soubory, testovací vstupy/výsledky, cíle, nápovědy, výklad, časté chyby, ukázku a odměnu.

Načtené Notion příručky jsou v data/knowledge/programming_notion_*.md: [hlavní stránka](https://app.notion.com/p/405bceb1e4138096aa61c91a2e13c3cf), [Python](https://app.notion.com/p/405bceb1e4138119bc9ad0c218037325), [HTML](https://app.notion.com/p/405bceb1e413819ab91ac29b51c88dae). Ověřovací podklady: [Python výrazy](https://docs.python.org/3/reference/expressions.html), [HTML syntaxe](https://html.spec.whatwg.org/multipage/syntax.html), [Godot CodeEdit](https://docs.godotengine.org/en/stable/classes/class_codeedit.html).

## VR a testy

Stejný editor používá VR SubViewport monitor. Ray/trigger ovládají CodeEdit, soubory, run/test a náhled; drag vybírá, joystick posouvá, A/X přemístí monitor. Virtuální klávesnice má programátorskou interpunkci, odsazení a Enter. A−/A+ nastavují 16–36 bodů, fyzická/Bluetooth klávesnice posílá vstupy stejnému poli.

Test-All.ps1 obsahuje programming_runtime (výpočty/chyby/izolace), programming_catalog (všechny správné/chybné úlohy a ekvivalentní řešení), programming_academy (stanice/editor/hranice/save/XP/kampaň) a programming_integration (28 lekcí × 3 režimy, skutečné DOM kliknutí a CSS render, generátor, syntetická XR klávesnice/zoom/soubory). Všechny herní testy používají SaveManager.path_override a vlastní CFG. Grafický integration s `-- --screenshots` uloží snímky do test-output.

Fyzický PICO 4 zatím nebyl připojen. Syntetické XR testy neověřují tracking, dlouhodobý komfort, konkrétní Bluetooth klávesnici ani 72 FPS na zařízení.
