# Celé zadání rozhraní a konstrukcí — 4. 11. 2026

Práce pokračuje na všech bodech přiloženého zadání. Toto je průběžný záznam,
nikoli prohlášení o dokončení všech bodů. EXE/APK zatím nejsou znovu sestavené.

- [x] 1: přečtené zadání/stav/README, reprodukce existujícího UI a geometrie.
- [x] 2: kompaktní pauza, podnabídky a přesunuté funkce.
- [ ] 3: nové londýnské dialogy.
- [x] 4: přesný podpis „Vytvořil Vít Kellner“ ve všech velikostech a VR.
- [ ] 5: cíle, průběh a zpětná vazba podle režimu.
- [x] 6: stojany a ukotvení fyzických tabulí.
- [ ] 7: trvající navigace k pracovištím Londýna.
- [x] 8: skutečné kapsy a souvislé rámy obou posuvných dveří, sjednocené portály.
- [x] 9: tmavé křídlo IT dveří se již neodsouvá do Londýna.
- [x] 9a: béžové lamely, commit `a3f36e5`, samostatná reprodukce před/po.
- [ ] 10: nastavitelný spodní panel programování a výsledky ověření.
- [x] 11: hotové technické panely místo lišt na zazděné jižní stěně serverovny.
- [ ] 12: zkrácení prezentace textů se zachováním všech potřebných údajů.
- [ ] 13: společný vzhled a všechny ovládací cesty — závěrečné ověření.
- [ ] 14: data a ochrany — původní 47sadový baseline PASS, finální regrese následuje.
- [ ] 15: úplný aktuální runner, grafika/XR, snímky a konečné předání.

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
