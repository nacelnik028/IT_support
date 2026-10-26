"""Deterministic Programming Academy content. Independent of frozen IT catalogs.

Only authored reference solutions are stored here; student source is interpreted
inside Godot and is never passed to Python/exec or the operating system.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]


def output(text, inputs=None, initial=None, **extra):
    return dict(output=text, inputs=inputs or [], globals=initial or {}, **extra)


PY_LESSONS = [
    ("Výpis, komentáře a vstup", "print() vypisuje hodnoty oddělené mezerou. Text patří do uvozovek. Závorky předávají argumenty funkci. # zahajuje komentář. input() vrací text z virtuální konzole.", 1),
    ("Proměnné a datové typy", "Přiřazení = uloží hodnotu pod jméno. int je celé číslo, float desetinné číslo, str text a bool pravdivostní hodnota. None vyjadřuje nepřítomnost hodnoty. input() vrací str; pro výpočet jej převeď.", 4),
    ("Aritmetické a logické operátory", "+ - * / počítají, // dělí se zaokrouhlením dolů, % vrací zbytek a ** mocninu. == porovnává, = přiřazuje. and/or vyhodnocují zleva s krátkým vyhodnocením; not obrací pravdivost.", 6),
    ("Řetězce, metody a f-stringy", "Řetězce jsou neměnné. strip() vrátí text bez krajních mezer, lower()/upper() mění velikost písmen. Indexy začínají nulou, -1 označuje poslední znak. Výřez [start:stop] nezahrnuje stop. f-string vkládá výrazy ve složených závorkách.", 9),
    ("Seznamy a indexování", "List je měnitelná uspořádaná kolekce. append přidá jednu hodnotu, extend kolekci hodnot. sort() mění původní seznam a vrací None; sorted() vytváří nový seznam. Comprehension vytvoří hodnotu pro každou položku vstupu.", 12),
    ("Slovníky, n-tice a množiny", "Slovník přiřazuje klíčům hodnoty; get umí výchozí hodnotu. Tuple je neměnná posloupnost. Set obsahuje unikátní položky bez garantovaného pořadí. Prázdný set se vytváří set(), {} je slovník.", 15),
    ("Podmínky if, elif, else", "Podmínka vybírá větev programu. Vyhodnotí se první pravdivá větev, další se přeskočí. Za if/elif/else patří dvojtečka. Blok odsaď čtyřmi mezerami a stejné úrovně zarovnej.", 17),
    ("Cykly for a while", "for prochází kolekci. range(start, stop, step) nezahrnuje stop. while opakuje blok, dokud je podmínka pravdivá. Měň řídicí hodnotu. continue přeskočí zbytek iterace, break ukončí nejbližší cyklus.", 19),
    ("Funkce, parametry a return", "def definuje opakovaně volaný blok. Parametry přijímají argumenty; mohou mít výchozí hodnoty. return vrací hodnotu volajícímu. print výsledek pouze vypisuje. Funkce bez return vrací None.", 22),
    ("Vestavěné funkce", "len vrací délku, sum součet, min/max krajní hodnoty a sorted nový seřazený seznam. abs vrátí absolutní hodnotu. round používá zaokrouhlení půlek k sudému. enumerate poskytuje index a hodnotu, zip dvojice hodnot.", 24),
    ("Moduly math a random", "import zpřístupní modul pod jeho jménem. math.sqrt počítá odmocninu a math.pi obsahuje číslo pí. random.randint(a,b) zahrnuje obě meze, random.choice vybírá položku. Výukový runtime povoluje jen dokumentované členy těchto dvou modulů.", 25),
    ("Ošetření chyb", "try spustí rizikovou operaci, except ValueError zachytí neplatný převod čísla. Zachycuj očekávanou chybu, neopisuj poškozený vstup jako správný výsledek. Chyby limitů a izolace nelze zachytit.", 27),
    ("Čtení a zápis souborů", "with open(name, mode, encoding='utf-8') automaticky zavře soubor. w přepisuje, a přidává, r čte. write zapisuje text a read čte zbývající obsah. V této učebně jde vždy o virtuální soubory v paměti daného běhu.", 28),
    ("Projekt Hádání čísla", "Spoj input, převod na int, podmínky a cyklus. Porovnej tip s tajným číslem, poraď směr a při úspěchu skonči. Omez počet pokusů na pět. Pro automatické testy dostaneš tajné číslo jako proměnnou tajne.", 29),
    ("Závěrečné procvičování Pythonu", "Zpracuj skutečná data, ne předem spočítanou odpověď. Projdi serverové logy, zjisti úroveň každého záznamu a zvyš odpovídající čítač. Změna počtu nebo pořadí událostí musí automaticky změnit výsledek.", 30),
]


def python_tasks():
    tasks = []
    def add(title, description, solution, tests, lesson, constructs=(), starter=None):
        number = len(tasks) + 1
        topic, explanation, _ = PY_LESSONS[lesson - 1]
        tasks.append(dict(id=f"PY{number:02}", title=title, description=description,
            category="python", difficulty=1 if number < 17 else 2,
            starter={"main.py": starter if starter is not None else "# " + description + "\n"},
            tests=tests, constructs=list(constructs), lesson=f"PYL{lesson:02}", topic=topic,
            objectives=[description, "Ověřit řešení pro všechny testovací vstupy"],
            hints=[explanation, "Prohlédni výsledek Spustit a řádek chyby. " + description],
            explanation=explanation, errors="Zkontroluj dvojtečky, uvozovky, odsazení a datové typy. = přiřazuje, == porovnává; první index je 0.",
            example={"main.py":solution+"\n"}, reward=100 if number < 29 else 250))
    add("Ahoj, světe", "Pomocí print() vypiš přesně Ahoj, světe!", 'print("Ahoj, světe!")',
        [output("Ahoj, světe!\n")], 1, ["print"])
    add("Komentáře", "Přidej komentář a vypiš jen Aktivní kód. Text komentáře se nesmí vykonat.", '# print("Toto je komentář")\nprint("Aktivní kód")',
        [output("Aktivní kód\n")], 1, ["comment","print"])
    add("Představ se", "Načti jméno přes input() a vypiš Ahoj, JMÉNO!", 'jmeno = input()\nprint(f"Ahoj, {jmeno}!")',
        [output("Ahoj, Eva!\n", ["Eva"]), output("Ahoj, Adam!\n", ["Adam"])], 1, ["input"])
    add("Moje proměnné", "Vytvoř vek=15, cena=19.5, jmeno='Eva', student=True, vysledek=None a vypiš jmeno a vek.",
        'vek = 15\ncena = 19.5\njmeno = "Eva"\nstudent = True\nvysledek = None\nprint(jmeno, vek)',
        [output("Eva 15\n", vars=dict(vek=15,cena=19.5,jmeno="Eva",student=True,vysledek=None))], 2, ["assign"])
    add("Převod věku", "Načti věk jako text, převeď na int a vypiš věk za rok.", 'vek = int(input())\nprint(vek + 1)',
        [output("16\n",["15"]),output("42\n",["41"])],2,["int","input"])
    add("Kalkulačka", "Načti dvě celá čísla. Na čtyřech řádcích vypiš součet, rozdíl, součin a podíl.",
        'a = int(input())\nb = int(input())\nprint(a + b)\nprint(a - b)\nprint(a * b)\nprint(a / b)',
        [output("13\n7\n30\n3.33333333333333\n",["10","3"]),output("10\n6\n16\n4.0\n",["8","2"])],3)
    # Use exactly representable quotients for portable console formatting.
    tasks[-1]["tests"][0] = output("12\n4\n32\n2.0\n", ["8","4"])
    add("Sudé nebo liché", "Načti celé číslo a pomocí modulo vypiš sude nebo liche.",
        'n = int(input())\nif n % 2 == 0:\n    print("sude")\nelse:\n    print("liche")',
        [output("sude\n",["12"]),output("liche\n",["7"]),output("sude\n",["0"])],3,["if","%"])
    add("Logické podmínky", "Pro dodané a,b vypiš hodnotu a > 5 and not b == 0 or a == 0.",
        'print(a > 5 and not b == 0 or a == 0)',
        [output("True\n",initial=dict(a=10,b=2)),output("False\n",initial=dict(a=10,b=0)),output("True\n",initial=dict(a=0,b=0))],3,["and","or"])
    add("Úprava textu", "Načti text. Vypiš jej bez krajních mezer nejprve malými a pak velkými písmeny.",
        'text = input().strip()\nprint(text.lower())\nprint(text.upper())',
        [output("python\nPYTHON\n",[" Python "]),output("server\nSERVER\n",[" SERVER "])],4,["strip","lower","upper"])
    add("Textový profil", "Načti jméno a věk. Pomocí f-stringu vypiš JMÉNO: VĚK let.",
        'jmeno = input()\nvek = int(input())\nprint(f"{jmeno}: {vek} let")',
        [output("Eva: 16 let\n",["Eva","16"]),output("Jan: 20 let\n",["Jan","20"])],4,["format"])
    add("Práce s indexy", "Pro dodaný text vypiš první znak, poslední znak a výřez [1:4], každý na řádku.",
        'print(text[0])\nprint(text[-1])\nprint(text[1:4])',
        [output("P\nn\nyth\n",initial=dict(text="Python")),output("S\nr\ner v\n".replace("er v","erv"),initial=dict(text="Server"))],4,["index","slice"])
    add("Nákupní seznam", "Do dodaného seznamu nakup přidej 'disk' pomocí append a vypiš celý seznam.",
        'nakup.append("disk")\nprint(nakup)',
        [output("['kabel', 'disk']\n",initial=dict(nakup=["kabel"])),output("['RAM', 'SSD', 'disk']\n",initial=dict(nakup=["RAM","SSD"]))],5,["append"])
    add("Seřaď čísla", "Seřaď dodaná cisla metodou sort. Vypiš seznam a na druhém řádku minimum, maximum a součet.",
        'cisla.sort()\nprint(cisla)\nprint(min(cisla), max(cisla), sum(cisla))',
        [output("[1, 2, 5, 9]\n1 9 17\n",initial=dict(cisla=[5,2,9,1])),output("[-3, 0, 8]\n-3 8 5\n",initial=dict(cisla=[8,-3,0]))],5,["sort","min","max","sum"])
    add("Dvojnásobky", "Použij list comprehension a vypiš dvojnásobky dodaného seznamu cisla.",
        'print([x * 2 for x in cisla])', [output("[2, 4, 6]\n",initial=dict(cisla=[1,2,3])),output("[-4, 0, 10]\n",initial=dict(cisla=[-2,0,5]))],5,["comprehension"])
    add("Hráčský profil", "Načti jméno, vytvoř slovník hrac s klíči jmeno a skore=10, zvyš skóre o 5 a vypiš jméno a skóre.",
        'hrac = {"jmeno": input(), "skore": 10}\nhrac["skore"] += 5\nprint(hrac["jmeno"], hrac["skore"])',
        [output("Eva 15\n",["Eva"]),output("Jan 15\n",["Jan"])],6,["dict"])
    add("Unikátní položky", "Z dodané polozky vytvoř set a vypiš jeho délku. Vytvoř tuple (10,20) a vypiš jeho druhou položku.",
        'unikatni = set(polozky)\nsouradnice = (10, 20)\nprint(len(unikatni))\nprint(souradnice[1])',
        [output("3\n20\n",initial=dict(polozky=[1,1,2,3])),output("1\n20\n",initial=dict(polozky=[4,4]))],6,["set","tuple"])
    add("Věkové kategorie", "Načti věk. Vypiš dospely pro 18+, student pro 15–17, jinak dite. Použij if/elif/else.",
        'vek = int(input())\nif vek >= 18:\n    print("dospely")\nelif vek >= 15:\n    print("student")\nelse:\n    print("dite")',
        [output("dospely\n",["18"]),output("student\n",["16"]),output("dite\n",["10"])],7,["if"])
    add("Kontrola hodnot", "Pro dodané teplota a volne vypiš OK, pokud teplota < 80 a volne > 10, jinak ALARM.",
        'if teplota < 80 and volne > 10:\n    print("OK")\nelse:\n    print("ALARM")',
        [output("OK\n",initial=dict(teplota=50,volne=20)),output("ALARM\n",initial=dict(teplota=90,volne=20)),output("ALARM\n",initial=dict(teplota=50,volne=5))],7,["if"])
    add("Sudá čísla", "Pomocí for vypiš sudá čísla 2 až 20, každé na vlastním řádku.",
        'for n in range(2, 21, 2):\n    print(n)',[output("\n".join(map(str,range(2,21,2)))+"\n")],8,["for"])
    add("Odpočítávání", "Načti celé kladné číslo. Pomocí while odpočítej k 1 včetně, každý údaj na řádku.",
        'n = int(input())\nwhile n > 0:\n    print(n)\n    n -= 1',
        [output("3\n2\n1\n",["3"]),output("5\n4\n3\n2\n1\n",["5"])],8,["while"])
    add("Zastav cyklus", "Procházej čísla 1–10. Pomocí continue přeskoč 3, pomocí break skonči před 7. Zbytek vypiš po řádcích.",
        'for n in range(1, 11):\n    if n == 3:\n        continue\n    if n == 7:\n        break\n    print(n)',[output("1\n2\n4\n5\n6\n")],8,["for","break","continue"])
    add("Obsah obdélníku", "Napiš funkci obsah_obdelniku(sirka, vyska), která vrátí obsah. Výpis nestačí.",
        'def obsah_obdelniku(sirka, vyska):\n    return sirka * vyska',
        [dict(call=dict(name="obsah_obdelniku",args=[a,b],value=a*b)) for a,b in [(5,4),(10,2),(3,7)]],9,["def"])
    add("Vlastní pozdrav", "Funkce pozdrav(jmeno='světe') vrátí text Ahoj, JMÉNO! Přijmi i volání bez argumentu.",
        'def pozdrav(jmeno="světe"):\n    return "Ahoj, " + jmeno + "!"',
        [dict(call=dict(name="pozdrav",args=[],value="Ahoj, světe!")),dict(call=dict(name="pozdrav",args=["Eva"],value="Ahoj, Eva!"))],9,["def"])
    add("Analýza čísel", "Pro dodaná cisla vypiš na řádcích len, sum, min, max a sorted.",
        'print(len(cisla))\nprint(sum(cisla))\nprint(min(cisla))\nprint(max(cisla))\nprint(sorted(cisla))',
        [output("3\n9\n1\n5\n[1, 3, 5]\n",initial=dict(cisla=[5,1,3])),output("4\n6\n-2\n4\n[-2, 1, 3, 4]\n",initial=dict(cisla=[4,-2,1,3]))],10,["len","sum","min","max","sorted"])
    add("Matematický pomocník", "Importuj math, načti číslo a vypiš jeho odmocninu pomocí math.sqrt.",
        'import math\nn = float(input())\nprint(math.sqrt(n))',
        [output("9.0\n",["81"]),output("12.0\n",["144"])],11,["import","sqrt"])
    add("Hrací kostka", "Importuj random a napiš funkci hod(), která vrací náhodnou hodnotu 1–6. Testy ověří více hodů a variabilitu.",
        'import random\ndef hod():\n    return random.randint(1, 6)',
        [dict(rolls=dict(name="hod",minimum=1,maximum=6,count=16),seed=seed) for seed in [1,42,97]],11,["import"])
    add("Nesprávný vstup", "Načti vstup a vypiš celé číslo za rok; ValueError zachyť a vypiš Zadej číslo.",
        'try:\n    vek = int(input())\n    print(vek + 1)\nexcept ValueError:\n    print("Zadej číslo")',
        [output("16\n",["15"]),output("Zadej číslo\n",["abc"]),output("Zadej číslo\n",["3.5"])],12,["try"])
    add("Poznámkový blok", "Načti text, přes with jej zapiš do poznamky.txt, soubor znovu otevři a načtený obsah vypiš.",
        'text = input()\nwith open("poznamky.txt", "w", encoding="utf-8") as f:\n    f.write(text)\nwith open("poznamky.txt", "r") as f:\n    print(f.read())',
        [output(text+"\n",[text],written={"poznamky.txt":text}) for text in ["Server funguje","Záloha hotova"]],13,["with","write","read"])
    add("Hádej číslo", "Máš proměnnou tajne (1–10). Načítej nejvýše 5 tipů. Vypiš vyssi/nizsi podle směru; po uhodnutí spravne a skonči, jinak po pátém tipu konec.",
        'pokusy = 0\nwhile pokusy < 5:\n    tip = int(input())\n    pokusy += 1\n    if tip < tajne:\n        print("vyssi")\n    elif tip > tajne:\n        print("nizsi")\n    else:\n        print("spravne")\n        break\nif pokusy == 5 and tip != tajne:\n    print("konec")',
        [output("vyssi\nnizsi\nspravne\n",["3","9","7"],dict(tajne=7)),output("spravne\n",["2"],dict(tajne=2)),output("vyssi\n"*5+"konec\n",["1"]*5,dict(tajne=9))],14,["while","if","input"])
    logs=[["INFO boot","ERROR disk","WARNING space","ERROR vm"],["WARNING cpu","INFO ok","WARNING ram"],["ERROR backup","ERROR network","ERROR disk","WARNING temp","INFO ok"]]
    add("Analýza serverových logů", "Server PVE-01 poskytuje seznam logs. Spočítej záznamy s úrovní ERROR a WARNING. Vypiš ERROR N a WARNING M na samostatných řádcích. Nepřepisuj vstupní logs.",
        'errors = 0\nwarnings = 0\nfor log in logs:\n    if log.startswith("ERROR "):\n        errors += 1\n    elif log.startswith("WARNING "):\n        warnings += 1\nprint("ERROR", errors)\nprint("WARNING", warnings)',
        [output(f"ERROR {sum(x.startswith('ERROR ') for x in data)}\nWARNING {sum(x.startswith('WARNING ') for x in data)}\n",initial=dict(logs=data)) for data in logs],15,["assign","for","if","print"])
    return tasks


WEB_LESSONS = [
    ("Základní HTML dokument", "HTML je značkovací jazyk pro strukturu. DOCTYPE html volí moderní režim; html je kořen, head obsahuje metadata a body viditelný obsah. title je název dokumentu.",1),
    ("Nadpisy, odstavce a text", "h1–h6 vyjadřují úroveň nadpisu. p je odstavec; strong důležitost, em důraz, mark označení. br zalomí řádek, hr oddělí témata. Nadpisy vybírej podle významu.",3),
    ("Odkazy a obrázky", "a s href vytvoří odkaz. #id odkazuje na sekci. Externí target='_blank' doplň rel='noopener noreferrer'. img má src a alt; smysluplný alternativní text popisuje obsah obrázku.",5),
    ("Seznamy", "ul je nečíslovaný a ol číslovaný seznam. Jejich položky jsou li. Vnořený seznam patří dovnitř položky nadřazeného seznamu.",8),
    ("Tabulky", "table popisuje tabulková data, tr řádek, th záhlaví a td buňku. caption pojmenuje tabulku. thead/tbody organizují oddíly, scope='col' nebo 'row' pomáhá určit záhlaví.",9),
    ("Kontejnery a sémantické elementy", "div je obecný blok, span řádkový kontejner. header/nav/main/section/article/aside/footer dávají obsahu význam. main obsahuje hlavní obsah dokumentu.",11),
    ("Atributy id a class", "id je jedinečný identifikátor, class může označit více prvků. CSS používá #id a .class. title je doplňující popis, hidden skrývá prvek, disabled zakazuje vstup a required jej činí povinným.",12),
    ("Formuláře", "form obsahuje vstupy. label se propojí atributem for s id pole nebo pole obalí. input type email/number poskytuje základní validaci. textarea je víceřádkový vstup, select volba. HTML samo nezpracuje zprávu na serveru.",15),
    ("CSS: barvy, mezery a layout", "CSS selektor vybírá prvky. color a background-color mění barvy. padding jsou vnitřní mezery, margin vnější. border a border-radius ohraničují box. display:flex řadí prvky, grid tvoří mřížku. Externí CSS připoj link rel='stylesheet'.",21),
    ("Základy JavaScriptu", "JavaScript reaguje na události. document.getElementById vyhledá prvek, addEventListener('click', function(){...}) registruje obsluhu a textContent změní jeho text. Náhled interpretuje jen uvedenou omezenou gramatiku.",28),
    ("Entity a komentáře", "&lt; a &gt; zapisují znaky < a > jako text, &amp; ampersand, &quot; uvozovku a &nbsp; nezlomitelnou mezeru. HTML komentář začíná <!-- a končí -->; do obsahu se nevykreslí.",27),
    ("Projekt vlastní stránky", "Spoj sémantickou strukturu, smysluplné nadpisy, obsah, odkazy a externí styly. Ověř čitelnost, přístupné popisky a jedinečnost id v náhledu.",29),
    ("Závěrečné procvičování webu", "Web helpdesku má srozumitelnou navigaci, seznam služeb, tabulku provozu a označená pole formuláře. Otestuj místní odkazy i formulář; lokální náhled nikam neposílá data.",30),
]


def document(body, extra_head=""):
    return '<!DOCTYPE html>\n<html lang="cs">\n<head>\n<meta charset="UTF-8">\n<title>IT Academy</title>\n'+extra_head+'\n</head>\n<body>\n'+body+'\n</body>\n</html>'


def exists(selector, count=1): return dict(kind="exists",selector=selector,count=count)
def attr(selector, key, value=None, **extra):
    result=dict(kind="attr",selector=selector,attr=key,**extra)
    if value is not None: result["value"]=value
    return result
def css(selector, prop, value=None):
    result=dict(kind="css",selector=selector,property=prop)
    if value is not None: result["value"]=value
    return result


def web_tasks():
    tasks=[]
    def add(title, description, body, tests, lesson, styles="", script="", head="", category="web"):
        number=len(tasks)+1
        topic, explanation, _=WEB_LESSONS[lesson-1]
        if styles: head += '\n<link rel="stylesheet" href="style.css">'
        if script: head += '\n<script src="script.js" defer></script>'
        tasks.append(dict(id=f"WEB{number:02}",title=title,description=description,category=category,
            difficulty=1 if number<21 else 2,starter={"index.html":"<!-- "+description+" -->\n","style.css":"/* Vlastní styly */\n","script.js":"// Vlastní interakce\n"},
            tests=tests,lesson=f"WEBL{lesson:02}",topic=topic,objectives=[description,"Ověřit živý náhled a strukturální testy"],
            hints=[explanation,"Zkontroluj elementy, jejich rodiče, atributy a přiřazené selektory."],explanation=explanation,
            errors="Časté chyby: špatné vnoření, neuzavřená značka, chybějící alt/label, duplicitní id nebo nesprávná cesta k CSS.",
            example={"index.html":document(body,head),"style.css":styles,"script.js":script},reward=100 if number<29 else 250))
    add("První HTML stránka","Vytvoř HTML5 dokument s html, head, title a body; v body musí být neprázdný h1.","<h1>Ahoj, světe!</h1>",[dict(kind="document"),dict(kind="nonempty",selector="body h1")],1)
    add("Čeština na webu","Nastav html lang='cs', meta charset='UTF-8' a neprázdný title.","<h1>Český web</h1>",[dict(kind="document"),attr("html","lang","cs"),attr("meta","charset","utf-8"),dict(kind="nonempty",selector="title")],1)
    add("Nadpisy a odstavce","Přidej do body jeden h1, alespoň jeden h2 a dva odstavce p.","<h1>Academy</h1><h2>Studium</h2><p>První odstavec.</p><p>Druhý odstavec.</p>",[exists("body h1"),exists("body h2"),exists("body p",2)],2)
    add("Zvýrazni text","Použij strong, em, mark, br a hr uvnitř stránky.","<p><strong>Důležité</strong> a <em>zdůrazněné</em><br><mark>Označeno</mark></p><hr>",[exists(t) for t in ["strong","em","mark","br","hr"]],2)
    add("Můj první odkaz","Vytvoř neprázdný odkaz a s href='https://developer.mozilla.org/'.",'<a href="https://developer.mozilla.org/">Dokumentace</a>',[attr("a","href","https://developer.mozilla.org/"),dict(kind="nonempty",selector="a")],3)
    add("Externí odkaz","Odkaz na https://developer.mozilla.org/ otevři do _blank s rel obsahujícím noopener noreferrer.",'<a href="https://developer.mozilla.org/" target="_blank" rel="noopener noreferrer">MDN</a>',[attr("a","href","https://developer.mozilla.org/"),attr("a","target","_blank"),attr("a","rel","noopener",contains=True),attr("a","rel","noreferrer",contains=True)],3)
    add("Přidej obrázek","Použij img se src='server.svg' a smysluplným alt. Tento obrázek je v náhledu dostupný lokálně.",'<img src="server.svg" alt="Symbol serverové akademie">',[dict(kind="image",selector="img"),attr("img","src","server.svg")],3)
    add("Seznam koníčků","Vytvoř ul se třemi li a ol se dvěma li.",'<ul><li>Programování</li><li>Hry</li><li>Hudba</li></ul><ol><li>Napiš</li><li>Otestuj</li></ol>',[exists("ul li",3),exists("ol li",2)],4)
    table='<table><caption>Provoz IT</caption><thead><tr><th scope="col">Služba</th><th scope="col">Dostupnost</th></tr></thead><tbody><tr><td>Helpdesk</td><td>8–16</td></tr><tr><td>Monitoring</td><td>24/7</td></tr></tbody></table>'
    add("Školní rozvrh","Vytvoř table alespoň se třemi řádky tr, dvěma záhlavími th a čtyřmi datovými buňkami td.",table,[exists("table tr",3),exists("table th",2),exists("table td",4)],5)
    add("Přístupná tabulka","Přidej caption, thead/tbody a záhlaví th scope='col'.",table,[exists("table caption"),exists("table thead th",2),exists("table tbody td",2),attr("th","scope","col")],5)
    add("Struktura webu","Použij header, nav s odkazem, main se section a footer. Do section přidej div se span.",'<header><h1>Firma</h1><nav><a href="#sluzby">Služby</a></nav></header><main><section id="sluzby"><div><span>Správa IT</span></div></section></main><footer>IT firma</footer>',[exists(t) for t in ["header","nav a","main section","footer","section div span"]],6)
    add("ID a Class","Přidej prvek id='uvod' a třídu karta. Napiš CSS .karta s padding a #uvod s color.",'<div id="uvod" class="karta">Vítej</div>',[exists("#uvod.karta"),css("#uvod","color"),css(".karta","padding")],7,'.karta { padding: 16px; }\n#uvod { color: teal; }',category="css")
    add("HTML atributy","Přidej odstavec s title, jiný s hidden a input s required.",'<p title="Úvod">Vítej</p><p hidden>Skryto</p><input required>',[attr("p","title"),attr("p","hidden"),attr("input","required")],7)
    add("Navigace na stránce","Vytvoř nav a s místním odkazem #id na existující section.",'<nav><a href="#kontakt">Kontakt</a></nav><section id="kontakt"><h2>Kontakt</h2></section>',[exists("section"),dict(kind="anchor",selector="nav a")],7)
    form='<form><label for="jmeno">Jméno</label><input id="jmeno" name="jmeno" required><label for="email">E-mail</label><input id="email" name="email" type="email" required><label for="zprava">Zpráva</label><textarea id="zprava" name="zprava"></textarea><button type="submit">Odeslat</button></form>'
    add("Kontaktní formulář","Vytvoř form se dvěma pojmenovanými input poli a submit tlačítkem.",form,[exists("form input",2),attr("input","name"),attr("form button","type","submit")],8)
    add("Popisky polí","Vytvoř form se dvěma input poli. Ke každému přiřaď neprázdný label přes for/id nebo obalením.",form,[exists("form input",2),dict(kind="labels",selector="form input")],8)
    add("Validace vstupu","Ve form přidej povinný email a number vstup s popisky.",'<form><label for="e">E-mail</label><input id="e" type="email" required><label for="n">Počet</label><input id="n" type="number" required><button type="submit">Odeslat</button></form>',[attr("input","type","email"),attr("input","type","number"),attr("input","required"),dict(kind="labels",selector="form input")],8)
    add("Výběrová pole","Přidej checkbox, dvě radio se stejným name a select se dvěma option.",'<form><input type="checkbox" name="souhlas"><input type="radio" name="priorita" value="low"><input type="radio" name="priorita" value="high"><select><option>Dotaz</option><option>Incident</option></select></form>',[attr("input","type","checkbox"),attr("input","type","radio"),exists("select option",2)],8)
    add("Textová zpráva","Vlož do form textarea s labelem a tlačítko type='submit'.",form,[exists("form textarea"),dict(kind="labels",selector="textarea"),attr("form button","type","submit")],8)
    add("Oprav přístupnost","Vytvoř stránku s img a form se dvěma input poli; všechny obrázky mají alt, vstupy label a id jsou jedinečná.",'<img src="server.svg" alt="Server">'+form,[exists("img"),exists("form input",2),dict(kind="accessibility")],8)
    add("Barevná stránka","Pomocí CSS změň color na h1 a background-color na body.",'<h1>Barevný helpdesk</h1><p>Vítej</p>',[css("h1","color"),css("body","background-color")],9,'body { background-color: #e8f7ff; }\nh1 { color: teal; }',category="css")
    add("Odsazení a okraje","Vytvoř div.karta a pomocí CSS mu nastav margin a padding.",'<div class="karta"><p>Obsah karty</p></div>',[exists("div.karta"),css(".karta","margin"),css(".karta","padding")],9,'.karta { margin: 12px; padding: 20px; }',category="css")
    add("Karta obsahu","Vytvoř .karta s border, border-radius a padding. Sleduj box model v náhledu.",'<article class="karta"><h2>Správa serverů</h2><p>Datacenter Academy</p></article>',[exists(".karta"),css(".karta","border"),css(".karta","border-radius"),css(".karta","padding")],9,'.karta { border: 2px solid teal; border-radius: 12px; padding: 20px; }',category="css")
    add("Flex layout","Vytvoř kontejner .radek se třemi div a nastav display:flex a gap.",'<div class="radek"><div>Python</div><div>HTML</div><div>CSS</div></div>',[exists(".radek div",3),css(".radek","display","flex"),css(".radek","gap")],9,'.radek { display: flex; gap: 12px; }',category="css")
    add("Grid layout","Vytvoř .mrizka se čtyřmi div. Použij display:grid a grid-template-columns pro dva sloupce.",'<div class="mrizka"><div>A</div><div>B</div><div>C</div><div>D</div></div>',[exists(".mrizka div",4),css(".mrizka","display","grid"),css(".mrizka","grid-template-columns")],9,'.mrizka { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }',category="css")
    add("Externí CSS","Připoj style.css přes link rel='stylesheet'. V externím souboru nastav color pro h1.",'<h1>Externí styly</h1>',[dict(kind="stylesheet"),css("h1","color")],9,'h1 { color: royalblue; }',category="css")
    add("Speciální znaky","V odstavci zobraz značku <p> pomocí &lt; a &gt;. Přidej HTML komentář.",'<!-- Vysvětlení --><p>Značka se píše &lt;p&gt; &amp; text.</p>',[dict(kind="entity"),exists("p")],11)
    add("JavaScript tlačítko","Tlačítko id='tlacitko' po kliknutí změní text prvku id='vysledek' na Ahoj!. Použij připojený script.js nebo inline script.",'<button id="tlacitko" type="button">Klikni</button><p id="vysledek">Zatím nic.</p>',[dict(kind="click",selector="#tlacitko",target="#vysledek",value="Ahoj!")],10,script='document.getElementById("tlacitko").addEventListener("click", function () {\n    document.getElementById("vysledek").textContent = "Ahoj!";\n});',category="javascript")
    add("Osobní vizitka","Vytvoř stránku s main, h1, dvěma odstavci, seznamem tří koníčků, obrázkem s alt, odkazem a externím CSS.",'<main><h1>Alex</h1><p>Učím se programovat.</p><p>Vítej na mém webu.</p><ul><li>Kód</li><li>Hry</li><li>Hudba</li></ul><img src="server.svg" alt="Akademie"><a href="https://developer.mozilla.org/">Dokumentace</a></main>',[dict(kind="document"),exists("main h1"),exists("main p",2),exists("ul li",3),dict(kind="image",selector="img"),attr("a","href"),dict(kind="stylesheet"),css("h1","color")],12,'h1 { color: teal; }\nmain { padding: 20px; }')
    add("Firemní IT Helpdesk","Vytvoř český HTML5 web helpdesku: h1, nav s místním odkazem, main se sekcí služeb, seznam tří služeb, tabulka provozu (caption, th, td), kontaktní form (jméno, email, zpráva, submit, správné label), externí CSS a upravený vzhled.",'<header><h1>IT Helpdesk</h1><nav><a href="#sluzby">Služby</a><a href="#kontakt">Kontakt</a></nav></header><main><section id="sluzby"><h2>Naše služby</h2><ul><li>Správa serverů</li><li>Zálohy</li><li>Síť</li></ul></section>'+table+'<section id="kontakt"><h2>Napiš nám</h2>'+form+'</section></main><footer>IT společnost</footer>',
        [dict(kind="document"),attr("html","lang","cs"),exists("h1"),dict(kind="anchor",selector="nav a"),exists("main section"),exists("section ul li",3),exists("table caption"),exists("table th",2),exists("table td",2),exists("form input",2),attr("form input","type","email"),exists("form textarea"),attr("form button","type","submit"),dict(kind="labels",selector="form input"),dict(kind="labels",selector="form textarea"),dict(kind="accessibility"),dict(kind="stylesheet"),css("body","background-color"),css("h1","color")],13,'body { background-color: #e8f3fa; padding: 18px; }\nh1 { color: teal; }\nsection { padding: 12px; border: 1px solid teal; border-radius: 8px; }')
    return tasks


def build():
    missions=python_tasks()+web_tasks()
    lessons=[]
    for prefix, category, definitions in [("PYL","python",PY_LESSONS),("WEBL","web",WEB_LESSONS)]:
        for index,(title,explanation,number) in enumerate(definitions,1):
            task=missions[number-1 if category=="python" else number+29]
            lessons.append(dict(id=f"{prefix}{index:02}",title=title,category=category,mission=task["id"],
                explanation=explanation,example=task["example"],practice=task["description"],
                steps=["Napiš nebo uprav kód.","Spusť a prohlédni výsledek.","Změň kód a spusť znovu.","Samostatně splň zadání a otestuj všechny případy."],errors=task["errors"]))
    debugging=[]
    broken=[("PY17",'vek = int(input())\nif vek >= 18\n    print("dospely")',"Chybějící dvojtečka"),
        ("PY20",'n = int(input())\nwhile n > 0:\nprint(n)\n    n -= 1',"Chybné odsazení"),
        ("PY07",'n = int(input())\nif n % 2 = 0:\n    print("sude")\nelse:\n    print("liche")',"Přiřazení místo porovnání"),
        ("PY11",'print(text[99])\nprint(text[-1])\nprint(text[1:4])',"Index mimo rozsah"),
        ("PY27",'vek = int(input())\nprint(vek + 1)',"Neošetřený vstup"),
        ("PY20",'n = int(input())\nwhile n > 0:\n    print(n)',"Nekonečný cyklus"),
        ("PY22",'def obsah_obdelniku(sirka, vyska):\n    print(sirka * vyska)',"Chybějící return"),
        ("WEB03",document('<h1>Web</h1><h2>Sekce</h2><div><p>Jeden</p><p>Dva</p>'),"Neuzavřený kontejner"),
        ("WEB20",document('<img src="server.svg"><form><input id="x"><input id="x"></form>'),"Alt, label a duplicitní id"),
        ("WEB26",document('<h1>Web</h1>','<link rel="stylesheet" href="styles.css">'),"Chybná cesta CSS"),
        ("WEB21",document('<h1>Barvy</h1>','<link rel="stylesheet" href="style.css">'),"Chybný selektor"),
        ("WEB03",document('<h1>Web</h1><h2>Sekce</h2><strong><em>Text</strong></em><p>Jeden</p><p>Dva</p>'),"Špatné vnoření")]
    by_id={task["id"]:task for task in missions}
    by_id["WEB06"]["tests"].append(dict(kind="element",selector="a",attrs=dict(href="https://developer.mozilla.org/",target="_blank",rel=["noopener","noreferrer"])))
    by_id["WEB17"]["tests"] += [dict(kind="element",selector="form input",attrs=dict(type=kind,required=True)) for kind in ["email","number"]]
    by_id["WEB18"]["tests"].append(dict(kind="radio",selector="form input"))
    for index,(base,source,title) in enumerate(broken,1):
        task=json.loads(json.dumps(by_id[base]))
        task.update(id=f"DBG{index:02}",base_id=base,title=title,description="Najdi a oprav chybu: "+task["description"])
        task["starter"]["main.py" if base.startswith("PY") else "index.html"]=source
        if index==11: task["starter"]["style.css"]='nadpis { color: teal; }\nbody { background-color: white; }'
        debugging.append(task)
    assert len(missions)==60 and len(lessons)==28 and len(debugging)>=10
    target=ROOT/"data/programming/catalog.json"
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_text(json.dumps(dict(missions=missions,lessons=lessons,debugging=debugging),ensure_ascii=False,indent=2)+"\n",encoding="utf-8")


if __name__=="__main__": build()
