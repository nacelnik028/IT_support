# Celé zadání rozhraní a konstrukcí — dokončeno 5. 11. 2026

**Dodatečně přestavěné Windows EXE (5. 11.) už tuto etapu obsahuje.**
[Kontrola přímo v EXE a nový hash](../2026-11-05-exe-menu/README.md).
Původní výroky o pouze zdrojových změnách níže jsou záznamem stavu před tímto přestavením;
PICO APK zůstává starší.


Všechny zdrojové úpravy bodů 1–15 a samostatného 9a jsou dokončené.
Finální zdroj d8efc89: celý Test-All 51/51 PASS, všech 336 výukových UI akcí
ve třech režimech; grafika v Compatibility i Forward+ PASS. EXE/APK zůstávají
původní. Přesná omezení a rozdíl proti fyzickému headsetu jsou uvedené níže.

- [x] 1: přečtené zadání/stav/README, reprodukce existujícího UI a geometrie.
- [x] 2: kompaktní pauza, podnabídky a přesunuté funkce.
- [x] 3: nové londýnské dialogy.
- [x] 4: přesný podpis „Vytvořil Vít Kellner“ ve všech velikostech a VR.
- [x] 5: cíle, průběh a zpětná vazba podle režimu.
- [x] 6: stojany a ukotvení fyzických tabulí.
- [x] 7: trvající navigace k pracovištím Londýna.
- [x] 8: skutečné kapsy a souvislé rámy obou posuvných dveří, sjednocené portály.
- [x] 9: tmavé křídlo IT dveří se již neodsouvá do Londýna.
- [x] 9a: béžové lamely, commit `a3f36e5`, samostatná reprodukce před/po.
- [x] 10: nastavitelný spodní panel programování a výsledky ověření.
- [x] 11: hotové technické panely místo lišt na zazděné jižní stěně serverovny.
- [x] 12: zkrácení prezentace textů se zachováním všech potřebných údajů.
- [x] 13: společný vzhled a všechny ovládací cesty — závěrečné ověření.
- [x] 14: izolované testy, původní data/legacy24, odložené relace a ochrany — finální regrese PASS.
- [x] 15: celý aktuální Test-All 51 PASS, oba renderery, skutečný XR viewport a finální důkazy.

## Konstrukční etapa (6, 8, 9, 11)

IT křídlo se posouvá na Z = 0,5 do severní kapsy. Původní koncové Z = 6,5
bylo příčinou přesahu do Londýna. Nová kapsa má dvě skutečné stěny s dutinou
0,30 m pro křídlo široké včetně dekorací 0,216 m; v kapse ani v jejím vstupu
není původní plný stěnový collider. Zárubeň je na straně kapsy rozdělená také
podle této dutiny. Křídlo může projíždět celým prostorem bez průniku do stěny.
Stejné řešení používají programovací dveře. Nástěnné ovladače zůstávají z obou
stran dostupné. Programovací čidlo nově znovu otevře i při vstupu během zavírání.

`WorldArchitecture.gd` sjednocuje otevřené portály, dveřní kapsy, stěnové kotvy
a podlahové stojany. London Quiz a Poslech mají menší panely s větším textem,
dvě podpěry a podstavce. Jejich viditelné části odpovídají skutečným kolizím.
Instruktoři mají stejnou podporu; dashboard, provozní monitor, nástěnné panely
a rozcestník mají kotvy. Opravený je také původně zvednutý podstavec terminálu.
Zazděný přímý průchod serverovna–Londýn zůstává zachovaný.

- `architecture_repair`: **4497 PASS headless / 4497 PASS Compatibility / 4497 PASS Forward+**.
  Celý skutečný tween obou dveří se kontroluje fyzikálním objemovým dotazem
  v každém snímku, třikrát otevření/zavření, včetně dekorací a obou čidel.
- `door3d` 15, `programming_location` 116, `academy_hub` 55, `world3d` 35,
  `london_geometry` 226 PASS v cíleném headless runneru.
- Grafický materiálový audit: **30 strukturálních stěn, 0 koplanárních překryvů,
  278 materiálů, 0 chybějících přiřazení**.
- Oba renderery: dveře otevřené/zavřené a z obou stran, Londýn bez přesahu,
  tabule, monitory, instruktoři a rozcestník. `physical-*` obsahují matici
  1280×720 / 1920×1080 / 3840×2160 × text 100/130 %.
- Vlastní `SaveManager.path_override` a vlastní nastavení; katalogy/legacy24 beze změny.

Příklady: [IT kapsa](it-door-ops-open-gl_compatibility.png),
[Londýn při otevřených IT dveřích](london-north-open-gl_compatibility.png),
[London Quiz](physical-1280-130-quiz-gl_compatibility.png),
[Poslech](physical-1280-130-listening-gl_compatibility.png),
[souvislá jižní stěna serverovny](server-finished-wall-gl_compatibility.png).
Všechny snímky `before-menu/pause/dialog/editor` zachycují původní UI před úpravou.

Automatické XR budou uvedené odděleně od fyzického PICO; headset není dostupný.

## Pauza a podpis (2, 4)

Základní pauza má pět hlavních akcí a nanejvýš aktuální úkol; ve VR také
přímý Komfort VR. Bez posouvání v 720p/130 %. Kam jít obsahuje skutečné vstupy
a podnabídku ticketů/směn. Diagnostika je v Nastavení → Obraz, přenos na kartě
Postup, nápověda a praktický úvod v Ovládání. Esc respektuje rodiče podnabídky.
Chyba uložení zachová pauzu a nabídne opakování, bez odchodu do menu.

`pause_repair`: **217 headless / 239 Compatibility / 239 Forward+ PASS**,
celá PC matice a skutečný VR viewport 1600×1200, oba syntetické triggery,
kliky všemi přesunutými cestami, návraty Esc, pět vstupů, zachování kampaně
a skutečné selhání zápisu. Regrese: ui_workflow 615, xr_modes 120,
world_ui 31 a gameplay_review 77 PASS. Původní runtime chyba odloženého fokusu
na již odstraněné tlačítko byla opravena; finální logy jsou čisté.
[Nová pauza 720p/130 %](pause-1280-130-gl_compatibility.png),
[Kam jít](destinations-1280-130-gl_compatibility.png),
[VR pauza](pause-vr-130-gl_compatibility.png),
[podpis](menu-1280-130-gl_compatibility.png).

## Editor (10)

Skutečný VSplitContainer s viditelným úchytem mění poměr editoru a výsledků.
Výstup má vlastní posuv; vstupy lze sbalit bez ztráty obsahu. Méně časté nástroje
jsou ve dvou nabídkách. Celé zadání zůstává dostupné v dialogu ve všech režimech.
Ověření rozlišuje počet testů, skóre, hlavní důvod a volitelné podrobnosti
s očekávaným/skutečným výstupem mimo zkoušku. Po editaci je výsledek zastaralý.

`editor_repair`: **380 headless / 410 Compatibility / 410 Forward+ PASS**.
Celá PC matice, skutečné myší tažení a oba syntetické XR triggery, dlouhý výpis,
input(), přechod na chybový řádek, úspěch/neúspěch, zastarání, úplné zadání,
nabídky, koncepty a pravidla zkoušky. XR drag čeká na skutečné fyzikální snímky,
které přenášejí pohyb paprsku; dřívější test čekající jen render snímky je
oddělený neúspěšný vývojový běh. Regrese work_persistence 69,
programming_catalog 1071, integration 765 / 252 variant a polish 29 PASS.
[Výstup 720p/130 %](editor-output-1280-130-gl_compatibility.png),
[ověření](editor-verification-1280-130-gl_compatibility.png),
[celé zadání](editor-task-1280-130-gl_compatibility.png),
[VR](editor-output-vr-130-gl_compatibility.png).

## Londýn (3, 5, 7)

Záhlaví a aktuální krok zůstávají na místě. Zadání s počty, produktem, časem,
rozmezím a rozpočtem, skutečný košík a scénářové komunikační cíle jsou vlevo;
replika NPC a souvislé odpovědi vpravo. Dlouhé části mají vlastní posuv. Překlad
a nápověda jsou u zadání. Dostupné zákaznické nahrávky mají vlastní výběr
číslované repliky, normální/pomalé přehrání a zastavení mimo odpovědi.

Model rozlišuje zdvořilost věty a věcnou shodu počtů/produktu. Chybnou
objednávku nepřepisuje. Výuka vysvětlí problém a další krok, procvičování má
stručnou odezvu, zkouška pouze potvrzuje zaznamenání. Hodnocení zkoušky se
odkryje až při dokončení nebo výslovném ukončení; ukončená zkouška už nepřijímá
volby. Neúspěšný pokus neudělí dokončení. Výsledky uvádějí textový stav,
skutečné cíle, skóre a podstatné chyby. Průběžný rozbor mimo zkoušku dovoluje
pokračovat; úspěšný výsledek zachovává původní pravidlo skóre a odměn.

Původní tlačítka jen zavírala panel. Nyní spouštějí trvající navigaci vázanou
na konkrétní pokus. AStarGrid má půlmetrové buňky kontrolované fyzikální kapslí,
respektuje stěny, přepážku, frontu a most. Po odchýlení obnoví trasu. HUD uvádí
cíl, vzdálenost po cestě a směr; malá modrá značka ukazuje další část trasy.
U cíle následuje E/trigger. Platba, lístek a příchod zůstávají fyzické akce.
Příchod, interakce, zrušení, změna pokusu a ukončení zkoušky značku uklidí.

Závěrečná london_repair: 2002 headless / 2078 Compatibility / 2082 Forward+ PASS;
počty fyzikálních kontrol závisí na skutečných snímcích chůze. Nový test
kliká navigační tlačítka a skutečně dojde ke všem pěti místům, dokončí pěší
nákup i cestu k věži, ověřuje pokračování téže relace a úklid značek.
Navíc celé UI nákupu ve všech třech režimech na PC i oběma XR paprsky,
chyby, rozbor a restart ve všech PC rozlišeních/textu. english_world 1094,
english_model 1809, quiz, listening a profil PASS. Konečný celý souhrn je na konci tohoto protokolu.

## Texty a styl (12, 13)

Menu a souhrny jsou kratší. Původní technická zadání a dlouhá vysvětlení
jsou v nativních rozbalovacích podrobnostech; všechny údaje zůstávají
přístupné také ve zkoušce. Výukový obsah a přirozené B1–B2 repliky zachované.
Katalogy, generátory a prvních 24 definic se nemění. Společná paleta používá
modrý obrys pro fokus, zelený stav úspěchu a textové hodnocení. Žádné nové
závislosti ani rastrová rozhraní. ui_workflow 615 a ui_design 162 PASS;
nově skutečná grafická Compatibility matice včetně klávesnice, drag/scroll,
fokusu, rušení drženého triggeru a obou rukou PASS. Compatibility i Forward+ jsou hotové: 28 cílených grafických běhů PASS.

## Poslední kontrola zkoušky

Odmítnutá volba ve zkoušce nyní zachová původní otázku NPC. Tím se skryje
hodnocení i v samotné anglické replice, nejen v české zpětné vazbě. Výsledek
přitom stále obsahuje skutečnou chybu. Nová kontrola zkouší i odmítnutou
žádost o neexistující produkt; původní modelová regrese 1809 PASS.
Závěrečný celý runner i londýnská grafika byly po této úpravě zopakované a prošly.

## Reprodukce a meze

Celý runner (včetně všech tří výukových režimů):

```powershell
& tools/Test-All.ps1 -GodotPath '..\..\Godot_v4.7.2-stable_win64_console.exe'
```

Samostatné nové kontroly: `tests/pause_repair.gd`, `tests/london_repair.gd`,
`tests/editor_repair.gd`, `tests/architecture_repair.gd` a
`tests/london_geometry.gd`. Graficky přidej `--rendering-method gl_compatibility`
nebo `forward_plus` a za `--` volbu `--screenshots`. U geometrie/konstrukcí
volba `--matrix` doplní všech šest PC kombinací. Každá sada si izoluje save/CFG.

`verification/graphics-results.json` rozlišuje skutečné běhy a jejich zdroj.
`source-manifest.json` zaznamenává zdrojové soubory i shodu legacy24;
`screenshots.json` obsahuje rozměry a SHA256 všech uložených PNG včetně snímků
výchozího stavu. Zachytávací obálky v `capture-harness/*.txt` pouze přesouvají
výstup snímků do této složky nebo doplní fotografii skutečného VR editoru;
asserty a akce původních sad zachovávají. Neúspěšné vývojové běhy jsou
oddělené v `verification/development`.

Referenční uživatelské obrázky nebyly k příloze připojené — dorazil jen text.
Proto srovnání 9a používá vlastní přesně shodnou kameru před/po, nikoli tvrzení
shody s nedodaným obrázkem. [Samostatné 9a a jeho reprodukční kamera](../2026-11-04-london-geometry/README.md).
Fyzické PICO, stereo, optická čitelnost, výkon a komfort headsetu nebyly
ověřené. Syntetické XR používá skutečný renderovaný SubViewport a vstupní
cestu obou ovladačů. Subjektivní lidský poslech se tím nedokládá.

Změny jsou ve zdrojích. EXE/APK 1.5.0 nebyly znovu sestavené; build soubory,
katalogy a generátory jsou proti výchozímu `8f6dd87` beze změn. Bez Git push.

Funkční commity: `a3f36e5` (9a), `45b85f4` (konstrukce/dveře/tabule),
`1433add` (pauza/podpis), `d3724db` (editor), `3ac6550` (grafické ověření editoru),
`34b9189` (Londýn/texty/navigace), `84478db` (neutrální zkouška).

## Konečné ověření posledního zdroje

**Celý Test-All.ps1: 51/51 PASS**, 51 startů Godotu, exit 0, bez runtime
chyb/varování. Všech 21 lekcí ve všech třech režimech a 336 skutečných UI akcí.
65 původních misí přes formuláře, legacy24, save/schema1/2, koncepty, jediné
odměny, odložená kampaň i směna, platební revize a zrušení drženého XR kliknutí
zachované. [Úplný log](verification/test-all.log), [strojový souhrn](verification/test-all.json).

**28 cílených grafických běhů PASS** napříč etapami; poslední dotčené části
jsou zopakované po poslední úpravě. Compatibility i Forward+, 1280×720,
1920×1080 a 3840×2160 × text 100/130 %. Skutečný VR viewport 1600×1200,
oba paprsky/triggery, virtuální klávesnice v reálném editoru, drag/scroll,
panel 80/140 %, vzdálenost 0,9/2 m a ztráta kontextu.
[Přesné běhy a zdroje](verification/graphics-results.json).
MCP posledního zdroje: 31 PASS; stejných osm původních statických varování,
bez nových nebo plošného potlačení. [MCP](verification/mcp-frozen.json).

Závěrečné rozšíření navíc kontroluje nový pokus stejného scénáře a návrat
z rozboru, neutrální zkoušku i při odmítnuté volbě, otočení PC kamery/XR hlavy
a jméno cíle se vzdáleností v reálném VR náramkovém panelu. Testovací dokončení
respektuje i náhodnou variantu nového procvičování. Předešlé neúspěšné nebo
přerušené vývojové běhy jsou označené odděleně; nejsou konečným PASS.

Prohlédnuté příklady:

- [Pauza 720p / 130 %](pause-1280-130-forward_plus.png)
- [Dialog / neutrální zkouška](london-dialog-exam-1280-130-forward_plus.png)
- [Výsledek](london-result-exam-1280-130-forward_plus.png)
- [Skutečná navigace](london-route-tower-walk-gl_compatibility.png)
- [Editor a ověření](editor-verification-1280-130-forward_plus.png)
- [Skutečný VR editor s klávesnicí](integration-forward_plus-vr-keyboard.png)
- [Navigace na VR náramku](london-vr-wrist-tracked-world-forward_plus.png)
- [Samostatné před/po 9a](../2026-11-04-london-geometry/README.md)

Všechny uložené PNG mají zaznamenané skutečné rozměry a SHA256; reprezentativní
snímky každé změněné části byly vizuálně prohlédnuté. PICO hardware a původní
uživatelský úhel z nedodaného obrázku nejsou těmito důkazy potvrzené.
Zdroj je v commitu `d8efc89`. Další dokončovací commity jsou `84478db`,
`0e007fe` a `d8efc89`; dřívější funkční commity jsou uvedené výše.

Poslední dvě úpravy dále potvrzují commity `0e007fe` (oddělení pokusů)
a `d8efc89` (pohled a VR náramek). U fotografického přípravku bylo potřeba
zaregistrovat syntetické trackery až po uzlech, aby obdržely první aktualizaci
statické pózy; původní neúspěšný souhrn je označený ve development složce.
Oba závěrečné snímky náramku jsou ze skutečně viditelného sledovaného uzlu.
