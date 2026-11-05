# Datacenter Academy — stav vývoje

## Programovací editor: skutečný prostor obsahu — 5. 11. 2026

- Zkrácené zadání a okraje, instrukce v bočním panelu. Vstupy input() vedle výsledků, kompaktní stav a přepínač testů ve společném řádku. Viditelný 18px oddělovač s minimy obou oblastí a tlačítko Zvětšit výsledky / Běžné rozložení zachovávající soubory i pokus.
- Desktop nad 900px přidává využitelnou plochu; VR zůstává v horních 900 pixelech skutečného SubViewportu 1600×1200 s rezervou pro klávesnici. Výstup/podrobnosti používají čitelné monospace písmo a vlastní skutečnou výšku řádků včetně znaků výsledku.
- editor_repair nově 1122 headless PASS: nejméně pět celých viditelných řádků po všech ořezech a transformacích, včetně necelého scrollu, přepnutí záložek, vstupů, resize, rozbalení podrobností, neúspěchu/úspěchu, zvětšení/návratu, PC kolečka a obou syntetických VR paprsků se skutečným joystickovým scrollem a drag.
- programming_integration 765 PASS / 252 variant. ui_workflow 615 PASS po aktualizaci kontrol tooltipu kompaktního ověření; zachována neplatnost po editaci, nejlepší výsledky, koncepty, web a fyzická/VR klávesnice. Aktivní úloha při návratu k editoru neotevírá nevyžádaný dialog.
- Při vizuální kontrole odstraněny také čtyři staré stěnové popisky, které kolidovaly s novými cedulemi vstupů. Finální GPU matice a celý 51sadový runner probíhají; Windows build následuje po jejich úspěchu. APK se nepřestavuje.


## Společné dokončené vstupy — 5. 11. 2026

- Společné WorldArchitecture rozšířené na všech 7 sestav: čtyři číslované portály hubu, obě posuvné sestavy a vstup Londýna. Oboustranné stupňované obložky se zkosením, zapuštěná ostění, patky, spojovací detaily, oddělené velké názvy a menší popisy.
- Křídla, servisní kryty dutých kapes a pevné ovladače mají shodné materiály a konstrukci; průchozí profil i původní čidla zůstaly. Původní IT LED posunuta z dráhy rámu. Zazděný serverovna–Londýn zachován.
- architecture_repair nově 19170 headless PASS: ovladače programování z obou stran přes ray/E i s otevřeným křídlem, opakovaný pohyb a fyzikální kontrola všech skutečných dekorací křídla v každém snímku. Grafické varianty před rozšířením ovladačového helperu 15466 PASS v obou rendererech; úplné aktuální opakování běží.
- door3d 17 PASS včetně nové skutečné chůze oběma směry. academy_hub 55 a programming_location 116 PASS: fyzické průchody i ochrana kampaně. Nové snímky předních/vratných stran a kapes jsou ve stejné datované složce; finální vizuální kontrola pokračuje.
- EXE/APK zatím beze změn, bez změn katalogů či legacy24.


## Alex jako informační bod — 5. 11. 2026

- Alex zachován pro LON06. Kontext station=info nabízí přímo cestu k Elizabeth Tower, tři režimy a výslovné pokračování; oslovení ani volba režimu nemění rozpracovaný nákup či revizi.
- Malá ukotvená cedule vedle postavy, shodné označení v navigaci, interakci a rozhovoru. Obecné situace, kvíz a poslech zůstávají dostupné.
- Rozšířený london_repair: 2755 headless kontrol PASS, LON06 ve všech režimech přes PC i oba syntetické XR paprsky; ochrana odložené kampaně. Aktuální grafické snímky nabídky i postavy prohlédnuté v docs/ui-review/2026-11-05-alex-portals-editor/.
- GPU regrese a navazující konstrukce/editor pokračují. Save/CFG izolované. EXE/APK v této etapě ještě nepřestavěné.


## Windows EXE skutečně přestavěné — 5. 11. 2026

- Původní EXE po zdrojové etapě zůstalo staré; uživatel proto viděl původní pauzu.
  Nyní `build/ITSupportSimulator.exe` obsahuje aktuální zdroje a403a40.
- 104480112 B, SHA256 `831f5540f0e18a8427cf19eb412cd1cedaf355a1582067b1e0b676b30dd8e170`. Nativní EXE-only smoke,
  skutečné Windows UI Esc / Kam jít / návrat PASS; snímky přímo ze spuštěného EXE.
- Přesný vložený pack: pauza 217 headless / 239 Compatibility / 239 Forward+ PASS,
  audit 5674 PASS / 292 souborů / 275 materiálů. Herní zdroje nezměněné,
  původní celá source regrese 51 PASS stále odpovídá. Testovací save a CFG izolované.
- [Protokol a snímky](docs/ui-review/2026-11-05-exe-menu/README.md).
  Metadata a checksumy aktualizované; předchozí výsledky archivované odděleně.
  PICO APK zůstává starší a nebylo přestavěné; manifesty nejsou označené jako shodné.



## Celé zadání rozhraní a konstrukcí — dokončeno 5. 11. 2026

- Dokončené všechny zdrojové body 1–15 a samostatné 9a. Zdroj d8efc89.
  Celý aktuální Test-All.ps1: 51/51 PASS, exit 0, 51 startů, žádná runtime
  chyba/varování. Výuka všech 21 lekcí × 3 režimy, 336 skutečných UI akcí.
- 28 cílených grafických běhů PASS v obou rendererech: PC 720p/1080p/4K ×
  100/130 %, skutečný VR viewport, obě ruce, drag/scroll a klávesnice v editoru.
  Nové případy zkoušky, generace stejné situace, směru podle pohledu a VR
  náramku jsou zopakované po svých úpravách. MCP posledního zdroje 31 PASS,
  osm stejných historických statických varování, žádné nové potlačení.
- Prvních 24 definic/legacy i katalogy a generátory beze změn, kampaň/směna,
  koncepty, revize a jediné platby/odměny zachované. Izolované save a CFG.
- [Úplný protokol a snímky](docs/ui-review/2026-11-04-interface/README.md).
  Prohlédnuté obrázky a manifesty zdroje/PNG, poslední celý log trvale ve
  verification/test-all.log. Vývojová selhání jsou oddělená a vysvětlená.
- EXE/APK jsou původní 1.5.0 a tuto zdrojovou etapu neobsahují. Bez push.
  Fyzické PICO neprovedené. Příloha obsahovala jen text; 9a má vlastní
  shodnou kameru před/po, shodu s nedodaným uživatelským snímkem nelze doložit.

Následující sekce jsou etapové a historické záznamy.


## Celé přiložené zadání — rozhraní a konstrukce, probíhá 4. 11. 2026

- Uživatel výslovně potvrdil všechny body přílohy, včetně 9a. Práce pokračuje celým rozsahem. [Průběžný seznam všech bodů, snímky a výsledky](docs/ui-review/2026-11-04-interface/README.md); hotové konstrukce nejsou vydávané za celé dokončené zadání.
- Konstrukční etapa 6/8/9/11: společné rámy/portály, skutečné duté kapsy obou posuvných dveří, křídlo IT směřuje na sever Z 0,5 a ne do Londýna. Původní kolize v objemu kapes odstraněné přímo při tvorbě stěny; rám na straně kapsy má také dutinu. Programovací dveře nově reagují čidlem i během zavírání. Ovladače dostupné z obou stran, zazděná zkratka zachovaná.
- London Quiz/Poslech mají menší čitelné panely, dvě nohy a podstavce s odpovídajícími kolizemi. Ukotvené monitory, dashboard, rozcestník, dekorativní panely a oba instruktoři; terminál už nezačíná nad podlahou. Nedokončenou mříž na jižní stěně serverovny nahrazují technické panely, bez další velké informační tabule.
- Celý skutečný pohyb: architecture_repair **4497 GPU PASS Compatibility / 4497 GPU PASS Forward+**, třikrát oba směry, fyzikální objemový dotaz v každém snímku, dekorace i bezpečnostní obrat obou dveří. Cílené headless sady: dveře 15, umístění programování 116, hub 55, svět 35 a lamely 226 PASS. Materiály **278/0 chybějících**, stěny **30/0 koplanárních překryvů**. Nové fyzické snímky v obou rendererech včetně 720p/1080p/4K × 100/130 %.
- Pauza a podpis (2/4): kompaktní základ bez scrollu i v 720p/130 %, Kam jít a pracovní podnabídka, přesunutá diagnostika/přenos/nápověda v Nastavení, VR komfort přímo. Esc a skutečné selhání uložení zachované. Přesný podpis `Vytvořil Vít Kellner`. Nové pause_repair **217 headless / 239 Compatibility / 239 Forward+ PASS**, všech šest PC kombinací a oba syntetické XR paprsky. Regrese workflow 615 / XR 120 / world_ui 31 / gameplay_review 77 PASS.
- Dialogy/cíle/navigace, editor a texty jsou implementované. Probíhá úplná finální regrese. EXE/APK se dosud nepřestavují; bez push. Původní 47sadový celý baseline po opravě 9a skutečně PASS, log uložený v její verification složce.

## Směr podle pohledu a VR náramek — 5. 11. 2026

- Londýnská navigace vyhodnocuje směr vůči skutečné PC kameře nebo XR hlavě,
  takže samotné otočení hlavy nezanechá šipku vůči starému natočení těla.
  VR náramek nyní obsahuje i konkrétní cíl a vzdálenost z direction HUD.
- London_repair 2002 headless PASS: navíc otáčení kamery na pěti pěších
  trasách, otočení XR hlavy bez pohybu těla a skutečný obsah náramku.
  xr_modes 120 PASS při samostatném opakování. Dřívější souběh dvou xr_modes
  kolidoval na jejich pevné academy_test_xr_modes cestě; neúspěšný běh je
  archivovaný odděleně a tyto dvě sady se již spouštějí sériově.
- Po této etapě se opakuje celý runner i grafický londýnský průchod.
  Katalogy a EXE/APK beze změn; žádný push, žádný fyzický headset test.

## Nový pokus stejné situace — 5. 11. 2026

- DialogueController rozlišuje i generaci pokusu, nikoli jen ID scénáře.
  Nové spuštění stejné situace z nabídky už nepřevezme otevřený starý rozbor.
  Pokračování existující situace z nabídky vrátí rozhovor; ukončená zkouška
  nadále zůstane pouze ve výsledku podle modelového příznaku exam_ended.
- Rozšířená london_repair skutečně kliká rozbor → nabídka → pokračování
  i rozbor → nabídka → nový stejný scénář na PC/obou XR rukou.
  1995 headless PASS. Dokončovací helper respektuje také náhodně vybraný
  produkt a čas nové praxe, namísto původně pevné varianty 15:00.
- Celý Test-All a oba grafické renderery běží po této úpravě znovu.
  Předchozí dokončené běhy i chybná pevná testovací varianta jsou uložené
  odděleně jako vývojové důkazy. Bez změn datových katalogů nebo distribucí.

## Zkouška — neutrální replika po odmítnuté volbě, 5. 11. 2026

- Kontrola odhalila, že česká odezva byla ve zkoušce neutrální, ale anglické
  „Could you try that again“ prozrazovalo odmítnutí. Po odmítnuté volbě se
  ve zkoušce zachová původní NPC otázka a hodnocení zůstane až ve výsledku.
  Cíle, chyba, revize a podmínky dokončení se tím nemění.
- Nová negativní UI kontrola volí neexistující produkt ve zkoušce na PC i
  oběma XR paprsky; 1913 headless PASS. Původní english_model 1809 PASS.
- Oba grafické renderery a celý aktuální 51sadový runner se po této poslední
  změně opakují. Předchozí úplný běh se archivuje samostatně. Bez změny
  katalogů, hráčova save, distribucí nebo push.

## Londýn a texty — etapa 3/5/7/12/13, 5. 11. 2026

- Nový LondonPresentation odděluje úkol/parametry/objednávku/cíle, NPC,
  odpovědi a pomoc. Pevné záhlaví a výsledkový stav, samostatné posuvy;
  žádné audio mezi odpověďmi. Zákaznické nahrávky mají výběr konkrétní repliky.
- EnglishManager odvozuje průběh a cíle ze skutečné relace, rozlišuje jazyk
  a věcně chybný počet/produkt a nic automaticky neopravuje. Výuka vysvětlí,
  praxe stručně upozorní, zkouška hodnotí až při ukončení. Neúspěšná zkouška
  nepřidá dokončení a po odkrytí výsledku už nepřijímá další volby. Úspěšné
  skóre i původní ochrany platby/revizí zůstávají zachované.
- LondonNavigation: fyzikálně kontrolovaný AStarGrid, trvající cíl/vzdálenost,
  malá značka, skutečné průchody/most, obnovení trasy po odchýlení, E/trigger
  u cíle a úklid při příchodu/interakci/zrušení/změně/ukončení zkoušky.
- Pěší test navigačními tlačítky dokončí nákup i věž a zachová stejnou relaci.
  Nová sada 1875 headless / 1950 Compatibility PASS; fyzikální počet závisí
  na snímcích. Celé UI nákupu všechny 3 režimy PC a obě XR ruce. Starší UI
  regrese english_world 1094, english_model 1809, ui_workflow 615,
  ui_design, poslech, quiz, profil a koncepty PASS. Rozšířený audio helper
  čeká na layout před posuvem a navíc kontroluje každý ořezávající předek.
- Kratší menu/souhrny, úplná technická zadání přes BriefPresentation;
  původní definice/katalogy/generátory ani legacy24 neměněné. Modrý fokus
  odlišný od zeleného hodnocení. Žádné nové závislosti.
- Compatibility celé grafické matice/klávesnice/drag/scroll/focus/trigger cancel
  PASS, Forward+ dobíhá. Nový celý Test-All je právě spuštěný po posledních
  úpravách. Předchozí přerušené/neúspěšné vývojové běhy jsou ve verification/
  development odděleně; nejsou vydávané za závěrečný výsledek. MCP 31 PASS,
  stejných osm historických statických varování, bez nových.
- EXE/APK zůstávají původní 1.5.0, bez push; fyzický PICO test neprovedený.

## Editor — etapa 10, 5. 11. 2026

- Commit d3724db obsahuje nastavitelný VSplitContainer, sbalitelné vstupy,
  nabídky nástrojů, celé zadání a jasný výsledek se skóre/počty/důvodem/detailním
  porovnáním mimo zkoušku. Skutečné editace zachovávají označení zastaralého výsledku.
- Nová editor_repair: 380 headless / 410 Compatibility / 410 Forward+ PASS,
  PC 720p/1080p/4K × 100/130 %, VR viewport a oba triggery. Test fyzikálního
  pohybu paprsku nyní čeká na physics_frame; žádná produkční ochrana vypnutá.
- Koncepty 69, katalog 1071, integrace 765 / 252 variant a polish 29 PASS.
  Snímky/logy ve společné interface složce. EXE/APK zatím původní; bez push.

## Bod 9a — béžové lamely v Londýně, 4. 11. 2026

- Původ potvrzen graficky i geometrií: `WorldVisuals.corridor()`, poslední trojice dekoru zadní stěny prosklené chodby serverovny (X −0,95/−0,83/−0,71, Z 10,34). Dvě lamely vystupovaly před západní stěnu Londýna. Původní smyčka přesahovala také levý konec vlastní chodby; nešlo o zbytek londýnského průchodu.
- Celé trojice se nově rozmísťují podle skutečných vnitřních hran bočních stěn chodby, se započtenou tloušťkou a odstupem. Dekor zůstává napojený na zadní stěnu. Žádná maskovací deska ani změna kolizí; v původním místě nejsou skryté kolize/interakce. Souvislá stěna a zazděný přímý průchod zachované, cesta rozcestníkem průchozí.
- Nový `london_geometry`: **226 PASS headless / 226 PASS Compatibility / 226 PASS Forward+**, skutečný CharacterBody/input, oba stavy sousedních dveří, most/obvod/východní chodba/IT strana a blokace přímého průchodu z obou stran. Celý aktuální Test-All **47 sad PASS**, 47 skutečných startů, exit 0, žádná runtime chyba/varování, výukové UI 336 akcí ve všech třech režimech. Etapový commit `a3f36e5`; log trvale ve verification/test-all.log. MCP DesignMCP **31 PASS**, osm již evidovaných statických varování v nezměněných skriptech odděleně. Grafické XR **120 PASS** včetně skutečného viewportu/obou syntetických rukou/scrollu/klávesnice; bez fyzického PICO.
- [Snímky a přesná reprodukce](docs/ui-review/2026-11-04-london-geometry/README.md): shodná vlastní kamera před/po, otevřené/zavřené dveře, oba renderery, 720p/1080p/4K × 100/130 %, obvod z obou stran. Nový uživatelský screenshot nebyl doručen (příloha obsahovala jen text), proto nelze potvrdit shodu s jeho původním úhlem. Reprodukční log se šesti skutečnými přesahy a dvěma chybami původní testovací trasy archivovaný odděleně; trasa opravena kolem květináče bez obcházení fyziky.
- Odděleně potvrzen tmavý **ACADEMY-DOOR** u X 9 / otevřené Z 6,5, s přesahem do Z 7,95. Je to samostatný bod 9, který tato úzce zaměřená oprava 9a nemění; byl následně opraven v konstrukční etapě výše. Další obdobné béžové přesahy při prohlídce nenalezeny.
- Pouze zdroje/testy/dokumentace; EXE/APK z vydání níže tuto dodatečnou opravu neobsahují. Vlastní testovací save/CFG, katalogy a legacy24 beze změn. Bez push.

## Finální vydání 1.5.0 — dokončeno 4. 11. 2026

Tato sekce uvádí výsledky pro skutečné aktuální soubory. Starší oddíly níže jsou historické. Původní zadání bylo nejprve dokončené v ec51021; následně doplněná verze v Nastavení (88a0bdb), zrušení drženého XR stisku (a6d58e3) a platný tracker v testu (74edf37).

- **Celý aktuální Test-All: 46 sad PASS**, 46 skutečných startů Godotu, exit 0, bez runtime chyb/varování. Nová matice 239 headless, koncepty 69, skóre 31, pokročilé směny 268, rozbor 49, poslech 515 a profil 38 PASS. Zachované legacy24, 65 misí přes formuláře, 1075 kontrol lekcí, save_safety 474, všechny tři režimy / 336 výukových UI akcí. Programování 765 kontrol / 252 variant, včetně platného syntetického trackeru a původní hranice editoru; fyzický programovací průchod 29 PASS i s výslovnou pauzou/pokračováním.
- **Grafika: 351 Compatibility / 351 Forward+ PASS**, 224 aktuálních PNG. Osm obrazovek včetně verze 1.5.0 v Nastavení: 1280×720, 1920×1080, 3840×2160 × text 100/130 %. Skutečný VR SubViewport 1600×1200, obě velikosti textu/klávesnice/panel 80/140 % a vzdálenost 0,9/2 m. Oba paprsky a úplný trigger, současné triggery, release mimo, drag/scroll, A/X a B/Y. Držený trigger se při focus-out, neplatném/odebraném trackeru, resize a A/X zruší bez potvrzení tlačítka. Původní XR 120 PASS.
- **Windows: 27 externích sad + native headless, Compatibility a Forward+ PASS.** Samotný přejmenovaný EXE z cizí pracovní složky bez projektu/PCK/editoru. **APK: 20 externích sad + dva desktopové smoke běhy PASS** nad skutečnými prostředky, původní certifikát/podpis/CRC/ARM64 OpenXR/1.5.0 code 6 ověřené. Dalších deset cílených sad na každý přesný balíček PASS. Navíc aktuální trackerová fixture programování 765 PASS nad oběma přesnými balíčky. Obsah Windows 5616 kontrol / 282 souborů, APK 5563 / 286, 277 materiálů; skutečné MP3 bajty a všechny hodnoty JSON shodné.
- **EXE 104454336 B**, rezerva **403264 B** pod 100 MiB. SHA256 `7e8caea9d12a0771c65c15b553c8e96630c521f5935307f295bd124ebb39c366`. **APK 90829657 B**; SHA256 `bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`.
- Herní zdroj `a6d58e3`, fixture testů 74edf37, shodný manifest 269 zdrojů `3723c98d56314e39be0b5f56b891ba510c63a76a03fa11914620f3f7b029f022`. [BUILD_INFO](build/BUILD_INFO.md), [strojové ověření](build/VERIFICATION.json), [snímky a trvalé logy](docs/ui-review/2026-11-04-release/README.md), [ovládání všech funkcí](docs/CONTINUATION_RELEASE.md). MCP aktuálního zdroje 31 PASS; osm původních statických varování je oddělených v mcp.json, bez nových či plošného potlačení.
- Staré save/schema1/2, kampaň/směna/učebny, koncepty a jediné XP po selhání zápisu/retry/restartu ověřené. Generátory obsahově reprodukovatelné a prvních 24 definic/legacy_campaign zachované. Neúspěšné vývojové běhy a předchozí hashe jsou archivované odděleně; žádné staré PASS nejsou připsané novému souboru.
- **PICO hardware NEPROVEDENO – headset není dostupný.** Android native start/aktualizace, stereo, tracking a ovladače, optická čitelnost, komfort, FPS/paměť čekají na zařízení. Subjektivní lidský poslech neprovedený; automatické hashe/dekódování/nenulové PCM/skutečný přehrávač ověřené. Žádné ADB dotazy či nasazení a žádný Git push.

## Platný tracker v původním programovacím testu — 4. 11. 2026

- Zpřísněná ochrana chybějícího trackeru správně přepla nezaregistrovaný syntetický rig do pauzy; původní programming_integration neměl žádný head tracker a očekával skrytý panel po překročení hranice. Test nyní registruje platnou high-confidence head pose a po deaktivaci ji uklidí. Původní kontrola zavření editoru i všechny ostatní kontroly zachované.
- programming_integration **765 PASS / 252 generovaných variant** se skutečnou VR klávesnicí, přepínáním souborů a hranicí. Herní kód ani hash exportů se tímto doplněním fixture nemění. Předešlý neúplný celý běh je archivovaný samostatně; nový celý runner následuje. Bez push.

## Zrušení drženého XR triggeru při ztrátě kontextu — 4. 11. 2026

- Dodatečný skutečný audit tlačítka reprodukoval **235 kontrol / 1 selhání**: staré lose_focus uvolnilo ukazatel nad původním tlačítkem a potvrdilo jej. Baseline uložený jako release-focus-cancel-audit.log, bez destruktivní operace (skutečný Button počítal aktivace).
- VRMonitor.cancel_press nejdříve přemístí kurzor mimo viewport a teprve pak uvolní stisk. XRPlayer vyčistí také vlastníka paprsku. Použito při focus-out, neplatném/odebraném head trackeru, skrývání/deaktivaci, změně rozměrů i A/X přemístění panelu. Běžné úmyslné uvolnění triggeru zůstává normální kliknutí.
- Rozšířená skutečná matice **239 headless PASS / 351 Compatibility PASS / 351 Forward+ PASS**, všech 224 PNG aktuálně obnovených. Nové negativní kontroly: držený trigger při focus-out, neplatném i odebraném trackeru, resize a A/X. Žádné nechtěné potvrzení; všechny původní kliky, obě ruce, drag/scroll a audio zachované. Původní XR **120 PASS**.
- Programovací fyzický průchod měl při desktopovém focus-out legitimně pozastavený pohyb; test nyní nejprve prokáže skutečnou pauzu a výslovně aktivuje existující Pokračovat pomocí Enter. Žádné přesunutí hráče do cíle ani vypnutí ochrany. **29 GPU PASS**, původní chůze oběma směry, kolize a modelové záruky zachované. Diagnostika blokace vypisuje režim/dveře/focus.
- Verze v nastavení zůstává 1.5.0, přidaná až po ec51021. Předchozí verze 88a0bdb měla 46 zdrojových sad / APK 20 / cílené balíčky PASS, Windows 26/27 kvůli zmíněné pauze; tyto výsledky archivované odděleně a nepřenášené na nový hash. Oba exporty a celý aktuální runner se nyní ověří po poslední opravě. Bez push, PICO hardware neprovedený.

## Uživatelské doplnění verze po dokončení původního zadání — 4. 11. 2026

- Základní prompt nejdříve uzavřen commitem **ec51021**, včetně celého aktuálního runneru 46 PASS a obou skutečných ověřených exportů. Teprve poté přidaná verze podle následného výslovného požadavku uživatele.
- Nastavení nyní pod titulkem zobrazuje **Verze hry: 1.5.0**, načtenou z application/config/version. Společná komponenta pro PC i VR, bez nového ovládacího prvku nebo ukládané preference. Android version/name musí při sestavení odpovídat tomuto údaji; versionCode zůstává nově zvýšené 6 oproti původnímu vydání 5.
- Rozšířená stávající skutečná matice o Nastavení: **234 headless PASS**, **346 Compatibility PASS / 346 Forward+ PASS**, 224 nových PNG ve složce 2026-11-04-release. Skutečná viditelnost údaje ve všech PC velikostech/textu i VR panelu/klávesnici; malý PC a VR snímek vizuálně prohlédnuté. Původní UI design 162 PASS.
- Přímý native export smoke navíc vypisuje game_version; builder a APK ověřovač hlídají shodu verze. Finální oba exporty a jejich zcela nové hashové výsledky následují. Bez push a bez PICO/ADB.

## Původní prompt hotový — ukládání, směny a poslech — původní zadání dokončeno 4. 11. 2026

- Celý aktuální Test-All **46 sad PASS**, 46 startů enginu, exit 0, bez runtime chyb/varování. Nové sady: work_persistence 69, shift_scoring 31, advanced_shifts 268, attempt_review 49, london_listening 515, unified_profile 38 a continuation_review 200 headless. Kampaň/legacy24, staré save a jediné odměny zachované; save_safety 474, lekce 1075, UI všech 65 misí a 336 výukových akcí ve všech třech režimech PASS.
- PC/VR grafická matice: **298 PASS Compatibility / 298 PASS Forward+**, 196 aktuálních PNG. Šest PC kombinací, skutečný VR 1600×1200, text 100/130 %, panel 80/140 % a 0,9/2 m, obě ruce, trigger/scroll/drag/klávesnice, focus/tracking. MCP 31 PASS; osm původních statických varování odděleně, bez nových.
- Windows **27 externích sad + dva nativní smoke běhy PASS**. Přejmenovaný samotný EXE z cizí složky, bez projektu/PCK/editoru. APK: podpis/původní certifikát/CRC/ARM64 OpenXR/1.5.0 code 6 PASS, **20 externích sad + dva desktopové smoke běhy PASS** nad skutečnými APK prostředky. Dalších deset cílených sad pro každý přesný balíček PASS. Obsah: Windows 5616 kontrol / 282 souborů, APK 5563 / 286; 277 materiálů, skutečné audio a JSON hodnoty shodné.
- EXE **104,453,712 B**, rezerva **403,888 B** pod 100 MiB; SHA256 `3186142a681c55386ba0669751c6466fbdffd73f5d422aac725e460e6ccccf26`. APK **90,829,077 B**; SHA256 `b97c5a8d15fcf1d074d2eeac235afbe5980e71dd7e8e6ef3060ee77cd0c6bdf4`.
- Zdrojový commit `a43cd6d`, shodný manifest 269 zdrojů `db723a77ce1a7a7c7da99e5857850850a101a773f34ee083bdd6d0fccb2e573c`. [Přesná metadata](build/VERIFICATION.json), [aktuální snímky a trvalé logy](docs/ui-review/2026-11-04-release-base/README.md), [ovládání](docs/CONTINUATION_RELEASE.md).
- **PICO hardware NEPROVEDENO – headset není dostupný.** Android native start, stereo, tracking/ovladače, optika, komfort, FPS a paměť nejsou těmito testy potvrzené. Subjektivní lidský poslech neprovedený; hash/dekódování/PCM/skutečný přehrávač ano. Bez ADB a bez push.

Tato fáze uzavírá původní prompt. Uživatelské doplnění verze v nastavení následuje až potom; jeho nové exporty budou mít vlastní ověření. Starší sekce níže jsou historické.

## Úplný runner a dokončení přehrávání — 4. 11. 2026

- Celý aktuální Test-All **46 sad PASS**, 46 startů skutečného Godotu, exit 0 a žádný SCRIPT ERROR/ERROR/WARNING. Včetně 1075 lekcí, save_safety 474, terminal_sessions 64, 65 UI misí a všech tří režimů training_ui / 336 akcí. Trvalý celý log continuation-test-all-complete.log. Tato regrese předchází níže uvedenému zpřesnění audio větve a pozdějšímu uživatelskému doplnění verze; konečné další běhy budou uvedeny samostatně.
- Windows původní grafický poslechový test odhalil nedoručené kliky a přerušený poslech při skutečném desktop focus-out. Zpřesněné testy mají celý odkrytý cíl, globální souřadnice/masku a úplný press/release; přerušení neobcházejí, ale výslovně po refocus znovu kliknou Přehrát. Produkční ochrana fokus/tracking zůstává aktivní. Žádný časovač nepřiděluje heard.
- LondonSpeech váže jednorázový finished callback na token/generaci konkrétního přehrání; stop_speech zneplatní i čekající callback a odpojí vazbu. Zastavení, jiný klip a starý callback nemohou doložit nový poslech. Všechny produkční stop cesty používají tuto funkci.
- Poslech po opravě: **515 headless PASS / 519 GPU Compatibility PASS** (čtyři další kontroly po zaznamenaném reálném focus-out a výslovném přehrání). Ruční očekávané významy všech 12 úloh i všechny tři režimy, všech 24 hashů/dekódování a plné skutečné normální přehrání. Starší selhání archivovaná odděleně ve verification/failures, nikoli vykázaná jako finální PASS.
- Přesné APK prostředky před poslední změnou: 20 sad PASS; cílené balíčkové sady deset pro každou platformu PASS. Windows 26/27, selhal právě výše vyřešený grafický poslech. Exporty se nyní obnoví a znovu ověří; žádné staré PASS se nepřenesou na nový hash. Zobrazení verze v nastavení dosud čeká na dokončení původního zadání. Bez push a bez PICO/ADB.

## Dokončování regrese — 4. 11. 2026

- Při návratu zjištěno skutečné selhání terminal_sessions: odeslaný příkaz zapisoval model a následné odstranění konceptu podruhé. Mazání formulářového konceptu nyní proběhne před command dispatch a součástí stejného zápisu. Původní striktní kontrola jediného persistence signálu zůstala zachovaná; přidaná obnova novým GameManagerem prokazuje i nepřítomnost odeslaného konceptu. **64 PASS**.
- Dřívější první celý běh odhalil také tři inline testové inicializátory při přidání izolace VR configu; opravené oddělení řádků. Testy programování už prošly ve druhém celku, který správně zastavil skutečný problém terminálu. Ani jeden neúplný běh není vykázaný jako finální PASS.
- Nové dialogy jsou snímané s klávesnicí skutečně současně otevřenou (vložený dialog se po focus políčka opět zobrazí). Compatibility i Forward+ po 298 PASS. Poslechové příznaky v UI jsou česky ano/ne. Celý běh a oba přesné balíčky po poslední opravě následují.
- Další požadavek uživatele: zobrazit aktuální verzi v nastavení **až po dokončení původního promptu**. Pořadí bude zachované; dosud nepřidáno. Bez push.

## Grafická matice a příprava distribucí — 3. 11. 2026

- Nová continuation_review: 200 PASS headless, 298 PASS Compatibility a Forward+. Sedm nových obrazovek × 1280×720/1920×1080/3840×2160 × text 100/130 %, skutečný 1600×1200 SubViewport, oba texty/klávesnice otevřená-zavřená/panel 80–140 % a vzdálenost 0,9–2 m. Oba paprsky a úplné triggery, současný trigger, release mimo tlačítko, drag/scroll, A/X, B/Y, focus/tracking stop audia a stojící simulační čas.
- Vizuální kontrola odhalila malé absolutní dialogy ve 4K; obnova a rozbor nyní škálují s viewportem. Nové snímky z obou rendererů. GPU: work_persistence 69, attempt_review 49, xr_modes 116, ui_design 162 a academy_hub 55 PASS. Původní nové testovací fixture chyby a čekání na fyzikální frame opravené, nejsou vydávané za produktové chyby.
- Godot MCP DesignMCP 31 PASS, po opravě osmi nově zavedených statických varování zůstává osm dříve evidovaných (AcademyDecor/EnglishRoom/EnglishManager/LondonQuizUI/GameShell). Nic není plošně potlačené; přesný výstup archivován.
- Generátory content/extension/shifts/listening reprodukovatelné bez rozdílu; legacy_campaign a prvních 24 definic obsahově shodné s e523eb4. Rozšířené skutečné balíčkové sady a přímý smoke pro obnovu/scoring/pokročilé směny/rozbor/poslech/profil. Zdrojový smoke všechny nové značky true.
- Runner nyní 46 sad; konečný celý běh a skutečné exporty se právě dokončují. Android preset zvýšen 1.5.0 / code 6, stejné ID a podpis. PICO/ADB neprovedené; bez push.

## Poslech a společný přehled znalostí — funkční etapy, 3. 11. 2026

- 12 samostatných poslechových úloh LONL01–12 používá přesné původní nahrávky a skutečné pomalé varianty. Skrytý přepis, sémantické promíchané odpovědi, tři režimy, výslovná obnova zkoušky, oddělená pomoc/výsledky a žádné XP. Nová fyzická tabule Poslechové procvičování v Londýně. Přerušení/ztlumení není doložený poslech. Opraveno odložené zpracování finished signálu s generačním tokenem proti závodu při opakování.
- london_listening 464 PASS headless/GPU Compatibility; všech 24 hashů, dekódování a nenulové PCM, úplné přehrání 12 klipů, ruční očekávané významy, přepis/pomoc/mute/restart/rychlé přepnutí, izolace dialogu/kvízu. Nejde o lidský subjektivní poslech. Původní english_model 1809, quiz 527, gameplay 212 a english_world 1070 PASS. Fyzický průchod english_world nově používá zachovanou cestu přes rozcestník.
- Moje znalosti v menu, pauze, IT, programování a Londýně odvozuje 13 dovedností ze stávajících důkazů. Nezkoušeno/Procvičeno/S pomocí/Bez pomoci, nejlepší a poslední výsledek, režim/pomoc/zdroj/datum, konzervativní staré výsledky a oddělený archiv. Konkrétní deterministická doporučení skutečně vedou do existujících místností a úloh, s nabídkou relevantního konceptu a původního režimu.
- unified_profile 38 PASS headless/GPU, skutečné menu/formuláře/CodeEdit/quiz/listening/scenario doporučení a zachovaná kampaň/směna; ui_workflow 615 PASS, rozšířená work_persistence 69 PASS headless/GPU (druhá VM/hostitel, zmizelý cíl, staré rizikové potvrzení, všechny režimy skutečné částečné lekce). Stará potvrzení váží revizi relace. Opraveno opětovné použití editoru čekajícího na zánik a přenos jeho starého bufferu.
- Migrační training_features 199 PASS: trace bez identity starého snapshotu se začne jako neúplný, nepřipojí se cizí historie. Doplněny vlastní VR config cesty i do původních sad. Runner 45 sad; úplná závěrečná regrese a exporty následují. Bez push, PICO hardware NEPROVEDENO.

## Konkrétní rozbor výsledků — funkční etapa, 3. 11. 2026

- AttemptReview zaznamenává omezené strukturované události s identitou pokusu, zařízení/hostitele, revizí a skutečnými hodnotami před/po. Odlišuje použití, diagnostiku, ověření, odmítnutí, předání a plánovanou poruchu. Neparsuje text deníku. Undo vrací i větev historie; nový pokus nezobrazuje cizí živé zásahy.
- Po skutečném předání samostatný DebriefPresentation ukáže původní příčinu z modelu, provedené zásahy a aktuální důkazy. Starý proof po změně není aktuální kontrola; PBS Verify a živá aplikace jsou oddělené. Posledních 20 rozborů se uchová ve work.reviews a otevře z Pokračování. Starší neznámá historie je výslovně neúplná.
- Rozbor doporučuje konkrétní existující ID IT lekcí a obsahuje jednu dobrovolnou otázku. Odpověď je jednorázová, dosažené skóre/XP nemění. Programovací pokusy uchovají konkrétní chybný test/diagnostiku soubor/řádek a omezený výpis po restartu; nepředstírají analýzu algoritmu.
- attempt_review **49 PASS headless i GPU Compatibility**: reálné síťové změny/odmítnutí/stará revize/undo, ověřená oprava, správný hostitel a před-po, restart, plný klik dobrovolné otázky bez XP, fyzický serial disku, RAM/start a záloha, odmítnutí cizí relace a skutečný chybný Python na main.py:2 po restartu.
- Regrese s novou historií: advanced_shifts 268, work_persistence 51, regression 88, programming_integration 765 a ui_smoke všech **65 misí přes formuláře PASS**, bez runtime chyb/varování. Runner nyní obsahuje 43 sad. Trvalé finální logy v nové ui-review/verification; dřívější string/float porovnání při vzniku nového backup pole opravené bezpečným typovým porovnáním.
- README a docs/RESULT_REVIEW.md aktualizované. Další práce: samostatné poslechové úlohy, společný profil, kompletní grafická/XR regrese a oba aktuální exporty. Bez push; fyzické PICO neprovedené.

## Dvě pokročilé směny s prioritami — funkční etapa, 3. 11. 2026

- SHIFT-RECOVERY a SHIFT-RESILIENCE mají po pěti samostatných ticketech nad jedním skutečným světem. Fronta ukazuje prioritu, dopad, závislosti a stav; výběr pouze mění kontext. Opravy před přijetím i dvě rozdílná platná pořadí jsou podporované.
- Stabilní plánované incidenty REC-PBS-LINK (po prvním ověření obou služeb odpojí jen kabel PBS) a STO-CACHE-POWER (při 50 % rebuildu selže ochrana cache). Stav plánovače je součást světa, takže undo/model/restart fungují společně. Retry zápisu nespouští událost znovu. Žádné skryté resetování inventáře nebo jiných konfigurací.
- Volitelný explicitní simulovaný čas sleduje skutečný výpadek služeb, nikoli FPS/čas za pauzou. Testované pořadí oprav mění dostupnost a naměřené simulační minuty (1 oproti 0). Čas není stresující limit ani další skrytá penalizace skóre.
- Každý pokročilý ticket má vlastní trvalá počítadla; poslední předání znovu ověří celý model i aktuální monitoring. Fyzická chybná výměna zdravého člena RAID10 při vadném sousedovi skutečně vytvoří Failed/data_loss a vyřadí aplikaci; jasný servisní postup je výslovný restart, nikoli fingovaný rebuild.
- advanced_shifts **268 PASS headless i GPU Compatibility**: všechny nové tickety dvakrát přes skutečné operace, různé priority/předání, fyzický inventář po novém GameManageru, jediná aktivace/obnova/undo/restart/failure-retry, skutečný chybný postup a klik priority plným press/release. Původní shifts **136 PASS**. Runner nyní obsahuje 42 sad.
- tools/advanced_shifts.py verze1 a build_shifts.py generují katalog reprodukovatelně po bajtech. První tři definice směn porovnány s předchozím commitem beze změn; kampaň/legacy24 nejsou upravené. Validátor podporuje starý sekvenční formát i nové nesekvenční výsledky/plánovač/metriky bez ztráty historie.
- README a docs/CONTINUOUS_SHIFTS.md aktualizované, trvalé testovací logy v nové ui-review/verification. Celková regrese, grafická matice a exporty budou následovat po zbytku zadání. Bez push a bez PICO/ADB.

## Konzistentní hodnocení směn — funkční etapa, 3. 11. 2026

- Původní chyba reprodukována skutečným tlačítkem a novým GameManagerem: nápověda po obnově 0, ticket 100. Trvalý baseline log 18 kontrol popisuje chybný původní kontrakt; není součást finálního runneru.
- Nové pokusy mají metodiku 2: základ 100, nápověda −4, chyba −8 a riziko dodatečně −15. Ukládají se nápovědy a hranice chyb/rizik jednotlivých ticketů; předchozí chyba se znovu neodečte. Jediný ScoreRules počítá i formátuje rozpis. Uložené výsledky jsou dostupné z historie po restartu.
- Tlačítko nápovědy váže revizi a úroveň; opakovaný/starý callback nepřičte stejný stupeň. Přechod ticketu zachová předchozí rozpis. Staré historie a rozpracovaná metodika 1 bez spolehlivé historie nápověd zachovávají známé výsledky/XP; migrace nic neodměňuje.
- shift_scoring **31 PASS headless/GPU Compatibility**: jedna nápověda → po restartu 1 a skutečné skóre 96, další ticket 100, skutečná chyba 92 jen jednou, staré tokeny, selhání zápisu/původní bajty/retry/restart bez druhých XP a reálné načtení původního rozpracovaného formátu. Původní shifts **136 PASS**. Runner nyní obsahuje 41 sad. Logy trvale v nové ui-review/verification.
- Dokumentace směn aktualizovaná; další etapou jsou pokročilé souběžné incidenty, rozbor, samostatný poslech a společný profil. Finální exporty následují až po dokončení zdrojů. Bez push.

## Trvalé koncepty a výslovná obnova výuky — funkční etapa, 3. 11. 2026

- Programovací soubory Python/HTML/CSS/JS, kurzor/výběr/posuv a aktivní soubor mají samostatné uložené koncepty podle obsahu, režimu, lekce a přesné varianty. Generovaná série uchová recept/seed/pořadí; opravovací úlohy fungují stejně. Krátký odklad zápisu, flush při změně/odchodu/ukončení, explicitní obnovit/začít znovu/smazat. Obnova neběží ani nehodnotí kód; nativní undo/redo jen živě.
- IT koncepty uchovají i nepoužitý číselný text; klíč odděluje pokus/hostitele/VM/operaci. Model se obnovou nemění a destruktivní souhlas se neukládá. Samostatná work.lessons zachová sandbox/krok/chyby/nápovědy/režim; živý stav se při odchodu vyčistí a obnova je dobrovolná až ve správné učebně.
- Menu a IT učebna mají kompaktní Pokračování, editor Rozepsaná práce. Viditelný stav zápisu a poslední úspěšný čas; retry neopakuje modelovou akci. Limity 128 kódových konceptů / 128 KiB na soubor / 2 MiB celkem, 64 IT formulářů a save 8 MiB. Nadlimitní kód zůstane v paměti jako NEULOŽENO i po odchodu a lze jej vrátit k úpravě; nepovolí falešně úspěšné ukončení.
- Staré platné schema1/2 zachováno. Nové větve validované včetně cest/verzí/parametrů. Vadná volitelná rozepsaná práce neblokuje platnou kampaň/výsledky: původní bajty se archivují před vynecháním konceptů; import takových dat je odmítnutý bez změny cílového souboru.
- Opraven nově odhalený úklid celé scény z programování: prostorové sondy během leave_training již znovu nevstoupí do učebny a neztratí odloženou kampaň. Klíče konceptů normalizují JSON int/float. Živé CodeEdit buffery se při přepnutí souboru nepřepisují uloženou polohou.
- work_persistence **51 PASS headless i GPU Compatibility**: skutečné CodeEdit editace, úplný press/release obnovy, nový GameManager/scéna, syntax error, tři webové soubory, režimy, generátor/opravy, raw IT formulář, všechny IT režimy, chybný zápis/čas/retry, vadná volitelná větev, limity a import/export. Runner nyní obsahuje 40 sad.
- Dosavadní regrese: save_safety 474, session_safety 124, programming_academy 63, programming_integration 765 (252 variant), training_rooms 68, lessons 1075 a ui_workflow **597 PASS**. Starý UI test úmyslně startuje čistou úlohu v každé grafické kombinaci a ověřuje nový trvalý stav Uloženo; nové resume dialogy testuje work_persistence. Zachované původní záruky. Konečné logy jsou trvale v docs/ui-review/2026-11-03-continuation/verification.
- Dokumentace docs/WORK_PERSISTENCE.md, README, programování a hub aktualizovaná. Celá závěrečná regrese/grafická matice/exporty ještě následují po dalších funkčních částech zadání. Bez push; PICO hardware neprovedený.

## Doplnění uživatele — zazděný průchod serverovna/Londýn, 3. 11. 2026

- Přímý jižní průchod nahrazen jedinou souvislou stěnou se skutečnou kolizí. Odstraněn původní rám, překlad a směrové cedule; výchozí fyzická chodba hub → Londýn zůstala otevřená.
- academy_hub 55 PASS headless i GPU Compatibility: skutečná chůze z obou stran nemůže projít, XR oblouk zastaví stěna; průchod rozcestníkem a všechny ostatní oblasti zachovány. Trvalý prohlédnutý snímek docs/ui-review/2026-11-03-continuation/server-london-sealed-gl_compatibility.png.
- Dokončena také výchozí regrese všech 39 sad bez chyb/varování a všech 20 externích Windows balíčkových sad + oba nativní smoke běhy komprimovaného rozpočtového exportu. Trvalé logy v nové ui-review složce. Další části původního zadání pokračují. Bez push.

## Navazující etapa — exportní rozpočet, 3. 11. 2026

- Přečteno celé nové zadání, výchozí čistý Git e523eb4, Godot MCP 4.7.2 a metadata existujícího projektu. Runner skutečně obsahuje 39 sad; výchozí regrese běží do odděleného next-stage-baseline.log.
- Změřeny oficiální šablony Debug 103 176 704 B / Release 109 268 480 B. Nativní bezeztrátové ZSTD katalogů v izolované Windows exportní kopii získalo prostor bez změn PE nebo obsahu. Před kompresí i po ní porovnány přesné bajty.
- Skutečné EXE nyní 104 371 136 B, rezerva 486 464 B. Nativní headless/GPU smoke a audit zabaleného obsahu 5437 PASS, 255 souborů, 278 materiálů, všechny JSON hodnoty shodné. Další balíčkové sady a výchozí regrese pokračují; toto není konečný release celé etapy.
- Podrobnosti v docs/EXPORT_SIZE_BUDGET.md. Kampaň/legacy24, audio i fonty zachovány. Bez PICO/ADB a bez push. Další práce: trvalé koncepty a výslovná obnova výuky.

## Zadání další etapy — ukládání, hlubší směny a poslech, 3. 11. 2026

- Na žádost uživatele připraven `PROMPT_DALSI_ETAPA_UKLADANI_SMENY_POSLECH.md` pro navazující AI. Jde o zadání budoucí implementace, nikoli tvrzení o hotových nových funkcích.
- Pokrývá trvalé programovací/IT koncepty a výslovnou obnovu výuky, skutečnou nesrovnalost penalizace nápovědy směn, dvě pokročilé směny s prioritami/následky, konkrétní rozbor, 12 poslechových úloh a společný přehled znalostí.
- Zadává ochranu kampaně/směn, migraci a validaci save, jediné odměny, všechny výukové režimy, offline PC/PICO, skutečné integrační/GPU/XR a balíčkové testy. Výslovně řeší rezervu EXE 31 264 B a oba exporty; hardware PICO zůstává neověřený, push až na další pokyn.
- Ověřeno 15 navazujících kapitol, UTF-8, uzavření bloku kódu, povinné ochrany a 51 existujících projektových cest. Tato dokumentační etapa nemění herní kód, katalogy, save ani EXE/APK; herní testy se pro nový prompt neopakovaly.

## Gameplay PC/PICO — dokončené ověření a oba exporty, 3. 11. 2026

- Funkční commity f6b05d8 (panel/diagnostika), cda0a5f (směny/save) a 8e931aa (úvod/síť/řeč). Dokončena požadovaná implementace v původním projektu, bez push.
- Celý aktuální Test-All: **39 sad PASS**, exit 0, bez runtime chyb a varování. Závěrečný log test-output/gameplay-release-test-all.log, trvalá kopie v docs/ui-review/2026-11-03-gameplay/verification. Směny 136, gameplay 212, review 77 headless/129 GPU, XR 116 headless/GPU; 65 misí/21×3 lekcí/336 UI akcí, save 474 a session 124 zachovány. Katalogy reprodukovatelné po bajtech, legacy24 shodné.
- Skutečný PC průchod úvodem 212 GPU PASS, grafická matice Compatibility/Forward+ po 129 PASS; MCP DesignMCP 31 PASS a osm již dřívějších statických varování. 104 trvalých PNG v datované složce, celá matice a VR obsah vizuálně prohlédnuté. Nejde o optiku headsetu.
- Windows EXE-only **104 826 336 B**, rezerva **31 264 B**. SHA256 e194ae3ef1f8b95e5665bc746efd3fb5c6ceb9e348971925634c70f85df1ac1c. Nativní headless/GPU smoke mimo projekt a všech 20 externích balíčkových sad PASS. Samotný EXE bez PCK/editoru. Skutečný obsah 253 souborů, 5425 kontrol, 278 materiálů.
- PICO APK **90 743 347 B**, **1.4.0 / code 5**. SHA256 8d9a39fd8f13ff9d8b3888778f6f707eb0c827cd12e3a8883263b467195aacaf. Podpis/původní certifikát/CRC/manifest PASS. Dva desktopové smoke běhy a všech 13 externích sad nad skutečnými APK prostředky PASS; 257 souborů/5372 kontrol. Bez ADB dotazů či změn zařízení.
- Dodatečné aktuální kontroly obou přesných balíčků: shifts 136 / gameplay 212 / XR 116 PASS, včetně skutečných MP3 bajtů podle hashů, inventáře po restartu a jediné odměny při selhání zápisu/opakování. Log test-output/gameplay-packages-final.log a trvalé JSON výsledky.
- Oba exporty používají stejný manifest 240 zdrojů: 77a19d821a39954afe9f657aaf7c5776af5cdaaf5e954b30552b70a4a5c6a8fe. BUILD_INFO, SHA256SUMS a VERIFICATION nyní obsahují jen skutečné aktuální výsledky. Žádný pracovní TTS model/WAV/test save v distribuci. Všechny testy mají vlastní save/config před GameManagerem.
- README, TEST_REPORT, VR report, návody směn/poslechu a hardwarový checklist aktualizovány. **Android start, stereo, tracking, optická čitelnost, komfort a FPS/paměť na PICO: NEPROVEDENO – headset není dostupný.** Automatické audio testy nejsou subjektivním lidským poslechem. Obě meze jsou výslovně zapsané.

## Gameplay — praktický úvod, síť a poslech, 3. 11. 2026

- Devět ověřovaných kroků úvodu: skutečný pohled/chůze nebo XR teleport, konkrétní ovladač a průchod, TRAIN-PC-PVE, UI kontrola, SPARE-2T a vrácení, pauza/pokračování. Samostatný dočasný model, žádné XP či scénář v save; obnovení kampaně/směny i konceptů. Zrušení/opakování a znovuotevření monitoru bez deadlocku.
- Síťové vysvětlení používá NetworkSimulator/PhysicalOperations, skutečná VM/hostitel/port, neověřené úseky, příčinu/dopad a před-po včetně kabelu. Důkaz kontroly má revizi; zkouška skrývá příčinu.
- 12 přesných mluvených replik LON01–LON06 a 12 samostatných pomalých variant Jenny (Dioco); MP3 celkem 188 544 B, licenční zdroj a mapování/hash offline. Přehrání nemění dialog; stop při pauze/focus/tracking/odchodu, vlastní Speech bus do Master, volitelná automatika.
- gameplay 185 PASS headless i skutečně graficky Compatibility; gameplay_review 77 headless a 129 GPU v Compatibility i Forward+, reálný SubViewport/obě ruce/grip/teleport/UI. ui_workflow 579 PASS. MCP DesignMCP 31 PASS, osm již dříve popsaných statických varování, bez runtime chyby.
- Opraven posuv posledního tlačítka pauzy (pixelové zaokrouhlení) a přesunuta automatika řeči do kompaktního footeru; původní english_world po opravě 1061 PASS. První úplný běh selhal právě na šesti kontrolách tohoto rozložení, nový celek běží.
- Nové datované PC/VR snímky, návody a výslovný NEPROVEDENO hardwarový checklist. První Windows export v limitu; konečné balíčky a jejich testy jsou další etapa.

## Gameplay — souvislé směny, 3. 11. 2026

- Vlastní deterministický katalog tří směn × tři navazující tickety: fyzická síť/VLAN/IP/záloha, VM/paměť/start/záloha, konkrétní disk/hot-swap/rebuild/monitoring. Nový ticket zachová stav, zneplatní jen ověření.
- Souvislé směny jsou v přehledu serverovny a pauze. Vlastní validovaná větev save, restart aplikace včetně neseného disku, původní kampaň, historie 50 směn, XP pouze za zlepšení. UI předává revizi ticketu proti opakovanému triggeru.
- shifts: 135 kontrol PASS headless; skutečné operace všech devíti ticketů, alternativní pořadí, neplatná data, přenos save, selhání zápisu/opakování a více přechodů všemi IT režimy/hubem/programováním/Londýnem. Log test-output/gameplay-shifts.log. Grafický průchod následuje.

## Gameplay PC/PICO bez headsetu — etapa 1, 3. 11. 2026

- VR komfort: panel 80–140 %, vzdálenost 0,9–2 m, reset a persistentní CFG. Mesh a ray/pixel používají stejné rozměry, viewport zůstává 1600×1200.
- Pauza nabízí výchozím stavem vypnutou diagnostiku (FPS, interval 1/FPS, renderer, viewport, draw calls, objekty, engine video paměť). CPU/GPU časy neměří a netvrdí.
- xr_modes: 114 kontrol PASS headless, včetně krajních rozměrů/vzdáleností, projekce a persistence. Log test-output/gameplay-xr.log. Grafická a celková regrese následuje; žádné tvrzení o headsetu.

## Připravený prompt pro další herní rozšíření bez PICO — 3. 11. 2026

- Na žádost uživatele vznikl `PROMPT_GAMEPLAY_PC_PICO_BEZ_HEADSETU.md`:
  435 řádků / 13 hlavních kapitol. Zadává VR připravenost a diagnostiku,
  praktický úvod, tři souvislé směny, vysvětlení síťových závad a anglický poslech.
- Uživatel nyní nemůže testovat na PICO. Zadání proto požaduje implementaci,
  skutečné PC/GPU a syntetické XR testy, oba exporty a oddělený pozdější
  hardwarový checklist; zakazuje vydávat tyto kontroly za tracking či FPS PICO.
- Popsána ochrana kampaně i směn, starých save, legacy24 a autorského podpisu,
  offline audio, skutečné integrační kontroly a limit EXE 100 MiB. Případné
  chybějící nahrávky či neprovedené exporty se musí pravdivě přiznat.
- Jde o budoucí implementační zadání. V této dokumentační etapě se hra,
  katalogy, uložená data ani distribuční soubory neměnily. Ověřena struktura,
  UTF-8, uzavření bloků kódu a 17 existujících projektových cest; diff čistý.
  Herní testy se pro samotný nový prompt neopakovaly. Následuje commit, bez push.

## Autorský podpis úvodního menu — dokončeno 3. 11. 2026

- MenuPresentation zobrazuje přesně `Vytvořil: Vít Kellner a Codex` vpravo dole,
  ve vlastním řádku pod tlačítky. Stávající ukotvený MarginContainer a VBox
  drží pravý/spodní odstup 24 jednotek UI (cca 19 px v 720p a 29 px v 1080p).
  AcademyTheme, jeho MUTED barva a původní font; velikost 14 se škáluje s textem.
- Podpis se vytváří pouze v menu, obnoví se po návratu z pauzy. Bez zalamování,
  kliknutí a fokusu; nezasahuje do tlačítek ani do VR ovládání. Herní obsah,
  katalogy, save schéma a distribuční EXE/APK se v této etapě neměnily.
- Graficky prohlédnuta celá matice 1280×720 / 1920×1080 / 3840×2160 × 100/130 %.
  ui_workflow **579 PASS headless i GPU Compatibility**: podpis, okraje,
  překryvy, Enter/Tab, kliknutí, hraní, pauza a skutečný návrat do menu;
  také absence v programovacích a výukových panelech a ochrana kampaně.
- Stávající ui_design **162 PASS**, world_ui **31 PASS** (headless).
  xr_modes **99 PASS headless i GPU Compatibility**: stejný panel 1600×1200,
  obě velikosti textu, ray/trigger, fokus a návrat z nastavení. Jde o syntetické
  XR; skutečný headset PICO, tracking a optika se v této etapě netestovaly.
- Godot MCP / DesignMCP: **31 PASS**, Forward+/RTX 5060. První běh měl 6 chyb
  zastaralého testu: pro HUD obnovoval kameru v novém hubu. Test nyní nejprve
  vstoupí do serverovny; nový běh nemá runtime chyby. MCP stále hlásí 8 dřívějších
  statických varování v nezměněných herních skriptech (typy/stínění proměnných).
- Testy nastavují SaveManager.path_override i vlastní CFG před GameManagerem;
  XR nyní také výslovně obnoví výchozí testovací DisplaySettings. Testovací
  posuv pauzy počítá skutečné měřítko okna stejně jako ui_design.
- Trvalé snímky spuštění, 1080p, 720p/130 % a VR/130 % jsou v
  `docs/ui-review/2026-11-03-credit/`. Logy `test-output/credit-*.log`;
  kompletní Test-All ani exporty se pro tuto prezentační změnu neopakovaly.

## Rozcestník, B1–B2 a oba ověřené exporty — dokončeno 3. 11. 2026

- Původní PROMPT_ACADEMY_HUB_PC_VR.md dokončen v existujícím projektu.
  Nástup PC/VR je v neutrální severní hale; 01 serverovna, 02 IT trénink,
  03 západní programování, 04 východní chodbou Londýn. Na doplnění uživatele
  odekorován rozcestník i všechny čtyři místnosti, bez nových bitmap a fontů.
- Opraveny skutečně nalezené vady londýnského průchodu, zrcadlené zadní texty,
  chybějící krky postav a čitelnost orientace hubu. Kompletní GPU prohlídka
  Compatibility i Forward+: po 49 snímcích, 280 materiálových instancí,
  0 chybějících přiřazení, 27 strukturálních stěn a 0 koplanárních překryvů.
- Všech šest LON situací: tři varianty a režimy B1–B2, skutečné Standard/Flex,
  počty, ceny, časové podmínky, povinné zákaznické dotazy a ověření porozumění.
  London Quiz u Alexe: 20 stabilních otázek s ověřenými oficiálními zdroji,
  vysvětleními, opravami a vlastními uloženými výsledky. Staré A1–A2 v archivu.
- Finální zdroje hry `0cb87a31baace36a34b7f686e1e36f95d0df5d51`.
  **Celý aktuální Test-All.ps1: 36 sad PASS**, čistý hub-release-test-all.log.
  Hub 52, model 1809, kvíz 527, PC/syntetické XR 1043 headless / 1063 graficky.
  Obnova upravené kampaně, save/restart, všechny IT režimy a legacy24 PASS.
- **Windows EXE 104 579 568 B**, rezerva **278 032 B** do 100 MiB.
  Oba nativní EXE-only starty mimo projekt a 17 externích balíčkových sad nakonec
  PASS. Bezeztrátové odstranění mezer JSON se děje pouze v exportní kopii.
  Počáteční GL leak při okamžitém ukončení nového auditu opraven čekáním testu;
  stejný EXE znovu ověřen, původní nečistý běh zůstává popsaný v manifestu.
- **PICO APK 90 508 612 B**, 1.3.0 / versionCode 4. Podpis v2, původní certifikát,
  CRC a ARM64/OpenXR/PICO manifest PASS. Oba desktopové smoke běhy nad skutečnými
  prostředky APK a 10 externích sad PASS. Otisky zdrojů a katalogů odpovídají.
- Skutečný obsah: 188/192 souborů, žádné pracovní adresáře; všechny JSON hodnoty
  shodné. Dodatečný GPU audit obou packů 5033/5057 PASS, 278 počátečních materiálů,
  platné shadery a dostupné vygenerované textury. SHA256 obou souborů je v
  build/SHA256SUMS, BUILD_INFO a aktuálním build/VERIFICATION.json.
- ADB stále bez autorizovaného PICO: **Android start, reálný tracking, optika,
  komfort a FPS NEOVĚŘENY**. Syntetické XR a desktopové prostředky APK jsou
  výslovně odlišené od hardwarové zkoušky. Žádný telefon se neměnil.
- README, oba návody, test/VR report, audit, snímky před/po a build dokumentace
  aktualizovány. `build/` zachováno, `builds/` nevzniklo. Bez push.

## Rozcestník, B1–B2 a londýnský kvíz — funkční etapa, 2. 11. 2026

- Implementována samostatná severní nástupní hala, čtyři skutečné fyzické cesty
  bez přesunu pracovišť a neutrální HUB=4. PC/VR start z menu míří do haly;
  pauza zachovává živou polohu. Kampaň se bezpečně odkládá i přes více oblastí.
- Na doplnění uživatele odekorován hub i všechny čtyři místnosti: společné
  procedurální rostliny, lavičky, lamely, technické/studijní značení a londýnské
  nábřeží, pokladna a městský reliéf. Žádné nové bitmapy, fonty ani monitory.
- Opraven londýnský otevřený průchod: odstraněno staré falešné křídlo, sloupky
  a lišty napříč vstupem, opraveno značení z obou stran. Jednostranné cedule
  již neukazují zrcadlené zadní texty. Postavám doplněny chybějící krky.
- Všech šest stabilních LON ID má B1–B2 dialogy, skutečné cenové možnosti
  Standard/Flex, časová omezení, změny počtů/produktu a povinné zákaznické dotazy
  s ověřením porozumění. Archiv starých A1–A2 výsledků zachovává původní postup.
- Samostatný offline kvíz LONQ01–LONQ20, oficiální zdroje ověřeny při vývoji,
  tři režimy, opravy, promíchání, historie a vlastní validované výsledky.
- Cíleně PASS: hub 52 včetně skutečné chůze a teleportovacího oblouku proti
  zavřeným/otevřeným dveřím; model B1–B2 1809; kvíz 527; PC + syntetické XR UI
  1037 headless / 1063 graficky v rozšířené matici. Úplná regrese a
  nové distribuční exporty se dokončují v navazující ověřovací etapě.
- Vizuální audit Compatibility po dekoraci: 280 materiálových instancí,
  0 chybějících přiřazení, 27 strukturálních stěn a 0 koplanárních překryvů.
  Podklady a omezení jsou v docs/MATERIAL_AUDIT.md a docs/ui-review/2026-11-02-hub.
- Původní první kompletní běh odhalil očekávání již znovu otevřeného starého
  severního prahu. Bezpečná pozice se nyní zachová; test dál porovnává XP,
  programovací výsledky i migraci skutečně neplatné severní polohy.
- build_windows.py zmenšuje pouze mezery JSON v izolované exportní kopii,
  každou hodnotu ověří zpětným parse. Nemění autorské IT katalogy ani PE šablonu.
  Nové balíčky se ověřují i kontrolou všech skutečně zabalených JSON a materiálů.

## English in London — finální předání a navazující prompt, 2. 11. 2026

- Finální herní zdroje `42600a3`. Nový kompletní Test-All.ps1: **34 sad PASS**,
  exit 0 a čistý log london-test-all.log. Anglický model **988**, PC/syntetické
  XR **409 headless / 417 graficky** PASS. Všech 54 kombinací variant/režimů
  má dosažitelné a vzájemně konzistentní řešení; další dostupný čas je ověřený.
- Nové samostatné Windows EXE: **104 786 904 B**, rezerva **70 696 B**.
  Native headless i GPU start mimo projekt bez PCK PASS. Všech 14 zabalených
  sad nakonec PASS; původní selhané automatizace jsou zachované v manifestu.
  Umístění učebny 120 kontrol včetně skutečných kliknutí na Pokračovat;
  world_playthrough 39 po opravě úplného stisknutí/uvolnění E a obsluhy pauzy.
- Nové PICO APK: **90 466 889 B**, 1.2.0 / versionCode 3. Podpis, CRC,
  ARM64/OpenXR manifest PASS. Skutečné prostředky z APK: oba desktopové smoke
  běhy a sedm sad PASS, model 988, svět 409, UI 363, učebna 114, programování
  765, XR 69, terminál 64. Otisky skutečných zdrojů a katalogů souhlasí.
- Oba exporty obsahují stejný nový obsah, bez build/tests/tools/test-output
  adresářů. build/ zachováno, builds/ nevzniká. Aktuální hashe, původní selhání
  a následné úspěchy jsou v build/VERIFICATION.json a TEST_REPORT.md.
- Žádný autorizovaný PICO headset v ADB: Android start, reálný tracking, komfort
  a FPS NEOVĚŘENY. Syntetické XR ani desktopové APK testy se za hardware nevydávají.
- Připravený PROMPT_ACADEMY_HUB_PC_VR.md má **481 řádků / 12 hlavních kapitol**:
  skutečný nástupní hub a fyzické cesty do čtyř místností; kontrola všech textur,
  materiálů a oprava vadných v celé hře včetně uživatelem hlášeného vstupu Londýna;
  přepracování šesti situací na B1–B2; nejméně 20 otázek o Londýně; skutečné
  zákaznické dotazy při nákupu lístků na London Eye. Rozcestník, grafický audit,
  B1–B2 a nový kvíz jsou na výslovný pokyn budoucí prací další AI.
- README, návod PICO, dokumentace Londýna, VR/test report a vizuální podklady
  aktualizovány. Hotové zdroje, exporty a dokumentace uložené v Gitu; bez push.

## Závěrečná kontrola dialogových údajů — 2. 11. 2026

- Třetí varianta LON04 sjednocena s významem „next available“: po vyprodaném
  14:00 nabízí 15:00, nikoli 16:00 při současně dostupném 15:00. Přidána přímá
  kontrola nejbližšího dostupného času ve všech režimech a variantách.
- Diagnostika grafického průchodu potvrdila skutečnou bezpečnou pauzu při
  ztrátě desktopového fokusu. Test ji nyní ověří a pokračuje skutečným kliknutím
  na Pokračovat; původní požadavky na cestu, editor a kampaň zůstávají zachované.
- Navazující prompt rozšířen o samostatné otázky na Londýn i skutečné dotazy
  hráče při nákupu vstupenek. Finální exporty a report následují po této kontrole.

## Obsahové varianty a zadání navazující etapy — 2. 11. 2026

- Rodinné procvičování nyní mění také skutečné počty: 1 adult + 1 child,
  2 adults + 1 child a 1 adult + 2 children, se souhlasnými cenami a rozpočty.
  Model všech 54 kombinací znovu 979 kontrol PASS. Základní výuková situace
  zůstává jeden dospělý a jedno dítě podle původního zadání.
- Opraven pouze způsob syntetického kliknutí ve starém testu ui_design:
  úplný press/release s korektním button_mask, bez vstupu nativních událostí mezi
  obě části kliku. Původní GPU automatizace někdy nedoručila klik a následně
  čekala po přístupu do neotevřeného formuláře; selhaný běh je uchován samostatně.
  Kontroly skutečné navigace a všech 162 požadavků se nemění.
- Na pokyn uživatele se rozcestník nyní neimplementuje. Soubor
  PROMPT_ACADEMY_HUB_PC_VR.md připravuje pro další AI skutečný nástupní hub,
  kompletní prohlídku všech textur/materiálů a opravu vadných v celé hře
  (výslovně rozbitého vstupu do Londýna) a přepracování všech šesti anglických
  situací na B1–B2. Tyto tři změny jsou budoucím zadáním, ne hotovou funkcí.
  Vizuální snímky aktuálního Londýna jsou v docs/ui-review/2026-11-02-london.

## English in London — implementace PC a VR, 2. 11. 2026

- Přidán čtvrtý fyzický pavilon jižně od serverovny, průchod 04. Procedurální
  London Eye s 24 kabinkami, čtyřciferníková Elizabeth Tower, Temže, most,
  lavičky, dva NPC, ceník, terminál a kontrolní závora. Původní učebna se nehýbe.
- Samostatný katalog LON01–LON06 a skutečný společný model PC/XR: celočíselné
  pence, košík, dostupnost, potvrzení, jediná platba a konkrétní použitelný lístek.
  Tři režimy, varianty časů/rozpočtů, více správných formulací, překlad na požádání,
  vysvětlení chyb a historie frází. Cesta k věži vyžaduje skutečnou návštěvu cíle.
- Režim ENGLISH_LONDON=3 zachovává původní enum. Odložení/obnova kampaně,
  přímé přechody mezi oblastmi, fyzický odchod i teleport ruší pouze dočasný
  nákup/UI. Validovaná volitelná větev english používá původní atomický save,
  bez XP a změny schématu. Chybu zápisu lze opakovat v panelu.
- Model: 979 kontrol PASS; skutečné PC UI a oba syntetické XR ovladače, všech
  šest situací, geometrie a matice 720p/1080p/4K × 100/130 %; grafický běh
  417 kontrol PASS. Testy mají vlastní SaveManager.path_override a nastavení.
  Při GPU kontrole opravená kolizní hrana mostu; automatická pěší trasa vede
  volnou uličkou kolem informačního NPC. Snímky test-output/london-review.
- Existujících 32 regresních sad PASS. Nové english_model a english_world
  přidány do Test-All; závěrečný kompletní běh a balíčkové testy následují.
  IT katalogy, legacy24 a výuková data se nemění. Godot MCP ověřil projekt a verzi.
- První nové EXE má 104 786 776 B (rezerva 70 824 B), samostatný native smoke
  z jiné složky PASS včetně všech šesti situací. PICO 1.2.0 / versionCode 3
  sestaveno, podpis/CRC/ARM64/OpenXR manifest PASS. Autorizovaný headset chybí;
  tracking, spuštění na Androidu a FPS nejsou vydávány za ověřené.
- Na následný pokyn se rozcestník nyní neimplementuje. Po dokončení testů a
  exportů vznikne samostatné podrobné zadání pro další AI. Dokumentace Londýna
  je v docs/ENGLISH_LONDON.md; distribuce zůstává v build/, builds/ nevzniká.

## Připravené zadání English in London pro další AI — 2. 11. 2026

- Na žádost uživatele vytvořen `PROMPT_LONDON_ENGLISH_VR.md`: podrobné zadání
  čtvrté londýnské místnosti s London Eye, Elizabeth Tower a praktickou angličtinou.
- Výslovně požaduje plnohodnotné PC ovládání myší/klávesnicí i VR/PICO ovladači,
  šest situací včetně nákupu vstupenky, výběr anglických replik jako základ,
  volitelné psaní, skutečné vyhodnocení a oddělené uložené výsledky.
- Popsaná integrace, ochrana kampaně, testy a exporty do zachované build/.
  Jde pouze o připravený implementační prompt; místnost zatím vytvořená není.
  Ověřena čitelnost UTF-8, odkazy na místní soubory a úplnost PC/VR požadavků;
  herní kód ani balíčky se v této etapě neměnily.

## Blikající zeď u programovací učebny — opraveno 2. 11. 2026

- Reprodukováno překrytí tří stěnových segmentů učebny se západní stěnou
  serverovny: celkem šest totožných viditelných ploch kolem dveří a nad nimi.
- AcademyRoom již znovu nevytváří sdílenou zeď a překlad. Ponechána pouze
  navazující část mimo serverovnu, bez mezer a bez změny dveří či jejich ovladačů.
- Geometrická kontrola před opravou 6 překrytých ploch, po opravě 0. Prohlédnuty
  snímky z obou stran s otevřenými/zavřenými dveřmi v Compatibility i Forward+.
- Cílené regrese PASS: programming_location 114, programming_polish 27,
  world3d 35, door3d 15 a training_rooms 68. SaveManager.path_override zachováno;
  katalogy, původních24 misí a herní relace se nemění.
- Nové Windows EXE a PICO APK v zachované složce build/; oba skutečně zabalené
  projekty ověřeny stejnou geometrií: 0 překrytých ploch. Nativní Windows smoke
  headless i GPU PASS, PICO podpis/CRC/ARM64/OpenXR manifest PASS. Fyzický headset
  není připojený. Nové velikosti a hashe jsou v build/VERIFICATION.json.
- Nové APK navíc prošlo test_pico.py: oba desktopové smoke běhy, UI 357,
  průchod 114, programování 765, syntetické XR 69 a terminál 64 PASS.
- Doplněn chybějící tests/programming_location.gd.uid; editor ho jinak při
  Android importu obnovoval s varováním. Následuje commit a push opravených balíčků.

## Sjednocení výstupů do build a aktuální PICO — 2. 11. 2026

- Z čistého místního 4000cb0 stažen origin/main, fast-forward na fed2f4e.
  Zachován celý existující build/, původní Windows EXE má stále SHA256
  daf7d88bd7b340df3055f3309ed9f1d1e55f9c654073bee6eb0e184cf5c5b74b.
- PICO přesunuto do build/pico4/, kořenová builds/ včetně starých Windows
  balíčků odstraněna. Starší zmínky o builds/ níže jsou historické cesty.
  Upraveny exporty, ignore pravidla, build/test nástroje a odkazy v návodech.
  build/.gdignore a exportní filtry brání přibalení exportů do dalších exportů.
- Na doplňující pokyn uživatele vytvořeno nové APK z aktuálních zdrojů fed2f4e:
  Training academy 1.1.0 / versionCode 2, západní učebna a nové UI. Identifikátor
  cz.academy.itsupport i certifikát zachovány. Podepsaný Debug, ARM64, SDK 29/34,
  skutečný APK manifest/OpenXR/PICO a CRC PASS. Velikost 90 430 147 B,
  SHA256 cbf9dc83fae810157fe806563b4fc59d8feed4371777628ceaa7c1ab788aed0c.
- build_platforms.py / Build-Platforms.ps1 podporují samostatný PICO export
  (--pico-only / -PicoOnly) se zachováním Windows souborů. BUILD_INFO.json u APK
  obsahuje přesné otisky zdrojů; --verify-only je nepřepisuje novými zdroji.
- Úplný Test-All.ps1: 32 sad PASS, exit 0, čistý log build-migration-test-all.log.
  Opraven pouze přenositelnost testu ui_workflow: předtím vyžadoval linuxovou
  cestu save i na Windows. Nyní 357/357 PASS podle skutečné platformy.
- tools/test_pico.py: skutečné prostředky z APK v desktopovém Godotu, headless
  i GPU smoke PASS; UI 357, fyzická cesta/učebna 114, programování 765,
  XR 69 a terminál 64 PASS. Otisky zdrojů/katalogů souhlasí. Android nativní
  knihovny se v tomto desktopovém testu nespouštějí. PICO/ADB není připojené:
  spuštění přímo na headsetu, tracking a FPS zůstávají NEOVĚŘENÉ.
- Zachované Windows EXE: nativní headless i grafický smoke PASS, všech 12
  zabalených sad headless PASS. Doplňkový grafický běh selhal ve dvou sadách
  programming_location a ui_design; opakování při 60 FPS také selhalo.
  Tyto grafické automatizace nejsou označené PASS, příčina není potvrzená.
  Podrobnosti a samostatné záznamy úspěchů/selhání jsou v TEST_REPORT.md
  a build/VERIFICATION.json. Herní skripty, scény, katalogy a save schéma beze změn.
- Následuje autorizovaný commit a běžný push origin/main; builds/ se odstraňuje
  z aktuální větve, historie repozitáře se nepřepisuje.

## UI/UX a název Training academy — 2. 11. 2026

- Navázáno na uživatelem určený čistý commit 99c201215f83408f333829ed05aa0489253acc14.
  Západní místnost, původní severní uzávěr a pozastavení při ztrátě fokusu zůstávají.
- Menu má kompaktní identitu, oddělené 3D/VR a popsané vstupy do tří existujících
  částí hry. Programování používá stejný enter_world přechod jako pauza, bez
  automatického spuštění úlohy; kampaň se obnovuje přes stávající správu relací.
- Oznámení místnosti je u levého dolního okraje a mizí po 4 s. Kritické neuložení
  zůstává v HUD i v prázdné učebně; v editoru má trvalý řádek s opakováním zápisu.
- Editor: Spustit kód / Ověřit řešení, tooltipy, Výstup / Chyby / Ověření, kliknutí
  na známý soubor/řádek, zvýraznění a označení předchozího výsledku po změně kódu.
  Nativní buffery, undo/redo, výběr, kurzor a vstupy zůstávají zachované.
- Formuláře mají stav vázaný na platformu, hostitele, VM a operaci. Použití v modelu
  není potvrzení zápisu. Obnovu surového číselného textu je nutné provést jeden
  snímek po obnovení fokusu SpinBoxu, který jinak koncept přeformátuje.
- Přejmenováno na Training academy v menu, okně, terminálu a 3D značení.
  Custom user directory zachovává původní cesty save/config pro Linux/Windows/macOS.
- Bez změn katalogů, referenčních řešení, simulace, XP nebo pravidel vyhodnocování.
  Interpreter pouze předává přesná metadata řádku chyby. Nové UI navazuje na
  AcademyTheme a stávající komponenty; nevznikají nové fonty ani herní assety.
- UI workflow: 357/357 headless i graficky; kvalita 4K 8/8; přesný Windows pack
  12 sad PASS. Úplný závěrečný běh 32 sad: 32 sad PASS, 0 selhání.
- EXE: Windows x86_64 Debug, 104 720 824 B, vložený PCK, rezerva 136 776 B.
  SHA256 daf7d88bd7b340df3055f3309ed9f1d1e55f9c654073bee6eb0e184cf5c5b74b.
  Detaily a rozlišení Wine/Linux/nativní Windows jsou v TEST_REPORT.md a build/.
- Screenshoty v docs/ui-review/2026-11-02-ux; plná matice v test-output/ux-before
  a ux-after. Opakovatelné install_script a start_skill jsou uložené v návrhu
  cloud prostředí. Publikaci prostředí provádí uživatel; Git push je samostatná následná operace.


## Publikace a ověření stažení — 2. 11. 2026

- Na výslovný pokyn uživatele odeslán commit 99c2012 do origin/main běžným
  fast-forward pushem, bez force. Vzdálený main následně ověřen přes Git.
- Staženo skutečné build/ITSupportSimulator.exe z raw.githubusercontent.com
  pro přesný publikovaný commit a jeho zdrojový archiv z codeload.github.com.
  Oba obsahují celé Windows PE o 104 713 528 bajtech, nikoli LFS pointer.
- SHA256 přímého EXE i EXE uvnitř archivu souhlasí s build/SHA256SUMS:
  ea2b6a5fedf2d0ba390269c4d4c513e28f62aafc8a29b2cc2f3afaad83604c41.
- Tato kontrola potvrzuje publikaci a stažení; nepřidává nativní Windows
  ani fyzické PICO ověření. Herní zdroje a ověřené EXE se neměnily.


## Přesun programovací učebny a spolehlivý Windows build — 2. 11. 2026

- Navázáno na čistý checkout 4000cb0, bez obnovování projektu. Ověřena
  skutečná 4.7.2 a oficiální SHA512 editoru/exportních šablon. Výchozích
  30 testovacích sad prošlo; stará auditní tvrzení se nepovažovala za důkaz.
- Celá programovací místnost je vlevo od racků za západními dveřmi.
  Jediná transformace zahrnuje vybavení, fyzické kolize, pracovní stanice,
  ovladače i osvětlení. Severní otvor uzavřený, levý vstup průchozí,
  nové značení a viditelný návrat do serverovny. Čidlo používá místní
  souřadnice; MultiMesh rozlišuje nový západní prostor.
- Starou podporovanou pozici v uzavřeném prahu opravuje pouze obnova
  polohy hráče. Mise, XP, výsledky, infrastruktura a schéma save se nemění.
- Reprodukována chůze po ztrátě desktopového fokusu; oprava uvolní klávesy
  a otevře pauzu bez automatického pokračování. Konzole zachová koncept.
  Před opravou 3 selhání nové regrese, po opravě world_ui 31/31.
- Opraven rozpor Build-Windows: skutečný samostatný Debug export místo
  EXE+PCK. Oficiální matching template, izolovaný import/export, kontrola
  PE/vložených dat, limit 100 MiB a EXE-only smoke před nahrazením cíle.
  Případný starý externí PCK se archivuje, aby nezastínil vložená data.
  Windows preset embed_pck=true; doplňkový Release/PICO pipeline zachovává
  výslovně svou složkovou variantu. Není použitá komprese UPX ani úprava PE.
- Přidán multiplatformní tools/test_all.py čtoucí aktuální seznam z PS1,
  rozšířen test přesného zabaleného projektu a dokumentován build/ postup.
  Nová sada programming_location je součástí Test-All; aktuálně 31 sad.
- Finální úplná regrese 31 sad PASS, balíčková regrese 11 sad PASS;
  grafický průchod novou učebnou 114/114, 3D grafická matice 31/31,
  UI 162/162 a skutečná 4K kvalita 8/8. Výsledné EXE má 104 713 528 B,
  pod 100 MiB; skutečný Wine headless smoke a grafické menu exit 0.
- Čerstvé vizuální podklady v docs/ui-review/2026-11-02. Podrobné výsledky,
  limity Wine/Xvfb a aktuální hash EXE jsou v TEST_REPORT.md a build/.
- Žádné změny legacy24, katalogů či referenčních postupů. Archivní ZIP a
  PICO APK nejsou novou distribucí. Nativní Windows/PICO ověření a
  následné stažení z GitHubu se neprohlašují za provedené.


## Oprava spuštění přímo ze staženého ZIPu — dokončeno (2026-10-26)
- Uživatel doložil chybu „Couldn’t load project data / Is the .pck file missing?“ s cestou do Temp/..._ITSupportSimulator-Windows.zip.*. Windows vytáhl při spuštění uvnitř ZIPu pouze EXE; předchozí hlavní ZIP vyžadoval sousední PCK. Samotný návod Extrahovat vše není dostatečně odolný distribuční výsledek.
- Hlavní ZIP nově dostane přenosné EXE s vloženým PCK, exportované přímo Godotem. Vývojářská varianta v builds/windows si ponechá externí PCK a nemodifikovaný runtime, přenosná je v builds/windows-portable. Herní zdroje, katalogy, save ani PICO APK se nemění.
- Build pipeline připravuje oba Windows exporty. ZIP ověřuje CRC/shodu EXE a spustí přesně vytažené jediné EXE v dočasné složce pojmenované jako ZIP, bez projektu či PCK, z jiného pracovního adresáře a také pod přejmenovaným názvem; headless i GPU. Nový --windows-only nevyžaduje Android build. README a SPUSTENI-WINDOWS.txt vysvětlují rozdíl variant. SmartScreen/certifikát se tímto neslibuje vyřešit.
- Finální hlavní ZIP nyní obsahuje přenosné ITSupportSimulator.exe s vloženými daty, bez sousedního .pck. EXE: 110831992 B / SHA256 7d24a4b372a30496d590aa2301b0f26b71e87b6bfb412ee377712f394167b6b9. ZIP: 40488773 B / adc38a2af983ec74cda3210b3e727687f55d4088317100c69b0fc1594d347236. Starší návod o povinném PCK se vztahuje pouze na vývojářskou variantu a na dřívější ZIP.
- Ověřeno přesné EXE vytažené z výsledného ZIPu do Temp: native headless i grafický start PASS, žádný PCK/projekt/vedlejší soubor, odlišný pracovní adresář i přejmenované EXE. Native smoke potvrdil 65/21 původního obsahu, obě učebny, 60/28 programování, Python, HTML/JS/náhled a čistý odchod. ZIP se nahrazuje atomicky až po této kontrole.
- Přesná přenosná distribuce také prošla všemi 10 zabalenými sadami: runtime 31, katalog 1071, academy 63, integration 765, polish 27, XR 69, terminál 64, ui_design 162, world_ui 27 a world_playthrough 34; vše exit 0 a čisté logy. tools/test_windows.py nyní standardně ověřuje tuto hlavní přenosnou variantu. Log zip-portable-package-tests.log a builds/VERIFICATION.json.
- Kontrola hashů, identity EXE v ZIPu a CRC PASS. Vlastní scan Defenderu přenosné složky dokončen, bez detekce. Herní soubory a katalogy ani PICO APK se neupravovaly; APK stále aede0ee05f47d496e5675a26ae617db2ba6d5353f7ecd9c618158bc1cd0fb41a. Změna je distribuční, proto se předchozí úplná herní sada neopakovala nad nezměněnými zdroji; otestována jsou přímo výsledná zabalená data a skutečné EXE. Následuje commit a autorizovaný push aktualizovaného hlavního ZIPu.

## Programming Academy — opravy a nový Windows balíček ověřeny (2026-10-26)
- Přístup do učebny je opravený a skutečně projitý od výchozí pozice: zadní ulička za admin stoly → levá ulička se značením → dveře → učebna → zpět. SW-CORE už dveře neblokuje. Původní infrastruktura a interakce se switchem zůstaly zachované.
- Učebna má propracovanější architekturu/stanoviště/klávesnice/myši/stojany/židle, značení, vybavení a rostliny. Editor sdílí AcademyTheme s původní hrou; má jasně rozlišenou navigaci/primární akci/nápovědu, čitelnou konzoli a ověřené 130% písmo. Při změně lekce/resetu se ruší také starý webový náhled; prázdný náhled vysvětluje spuštění. Dlouhý výstup a vstupy se vizuálně zalamují.
- Ověřeno native undo/redo a kurzor při přepínání souborů, oprava postupu learn bez skutečné úpravy, režimy generovaných úloh, změna Python/Web/Exam stanoviště, dveřní čidlo a ochrana souběžných animací. Testovací soubory integration/polish mají suffix PID, aby dva ověřovací procesy nesdílely stejný SaveManager.path_override. Hráčův save se nepoužívá.
- Kompletní Test-All: 30 sad PASS, exit 0, bez chyb/varování (polish-test-all.log). Finální cílený programming_polish má 27 kontrol PASS; integration 765 PASS. Přesný nový PCK navíc všechny programovací sady, XR 69, terminál 64, ui_design 162, world_ui 27 a world_playthrough 34 PASS. GPU Compatibility nad finálním PCK: integration 765 a polish 27 PASS; prohlédnuté screenshoty. Staré campaign/lessons/legacy_campaign jsou obsahově shodné s 21d6fbd.
- Nová Windows distribuce používá neupravenou oficiální Release šablonu a samostatný ITSupportSimulator.pck. EXE 109268480 B / SHA256 d34d36f3be1a6c49c56525ae86469b92e4f417ddf0b43cf00dd80c385c4b0562; PCK 1563500 B / 5ffa1bf2db694e0451d4f2581b3db0f7e1704bd22a7ea6d5732b30870d6d69d5. Celý ZIP má 40488518 B / 64451d122fda83649bfa7f7cfa5183632492f03b710abe302f4fbb034ec64e21. Obsahuje shodné EXE/PCK, návod a SHA256SUMS; kontrola hashů/CRC PASS. Nespouštět přímo uvnitř ZIPu, nejdřív Extrahovat vše. Oba Windows build nástroje používají externí PCK a originální šablonu místo úprav starého EXE.
- PICO APK aktualizováno: 90422379 B / aede0ee05f47d496e5675a26ae617db2ba6d5353f7ecd9c618158bc1cd0fb41a. Podpis, ARM64/OpenXR/PICO manifest, CRC a zabalený obsah 60 úloh/28 lekcí PASS. Fyzický headset není připojen; tracking/komfort/FPS nejsou hardwarově ověřené.
- Microsoft Defender dokončil vlastní kontrolu finální Windows složky, události 1000/1001, 20:00:13 místního času; žádná odpovídající detekce. Manifest zaznamenává ověření. SmartScreen „Unknown publisher“ je jiná reputační kontrola: EXE zůstává nepodepsané, v dostupných certifikačních úložištích není code-signing certifikát. **Odstranění okna SmartScreen není zaručené ani deklarované jako hotové.** Nastavení zabezpečení se neměnilo, nevytváří se vlastní důvěryhodný certifikát ani výjimka. Přesný postup a omezení jsou v SPUSTENI-WINDOWS.txt a README s oficiálním zdrojem Microsoftu.
- Finální zdroje a ZIP/APK/manifest se commitují a pushují na origin/main podle trvajícího pokynu uživatele. Další práce na odstranění neznámého vydavatele vyžaduje platné podepisování/reputaci nebo distribuci prostřednictvím důvěryhodného kanálu; nejde o opravu GDScriptu.

## Oprava přístupu a sjednocení Programming Academy (2026-10-26)
- Checkpoint 21d6fbd / d4c6f4f. Uživatel doložil přesné upozornění Microsoft Defender SmartScreen „unrecognised app / Unknown publisher“: nejde o uvedení konkrétního viru. EXE je NotSigned, není k dispozici podpisový certifikát, v místní historii Defenderu nebyla nalezena detekce této hry. Zmizet reputační upozornění nelze poctivě slíbit; nevypíná se ochrana, neodstraňuje MOTW a nevytváří falešný důvěryhodný podpis.
- Nový test programming_polish reprodukoval skutečnou závadu: hráč projde hlavní uličkou, ale síťová skříň SW-CORE blokuje přístup/zaměření dveří. SW posunut z x=-6.1 na -3.6, kabelové/portové interakce zachovány. Test nyní celou cestu skutečně projde od běžného spawnu přes vstup i zpět, bez teleportu před dveře.
- AcademyVisuals doplňuje sdílenou architekturu, panely, podlahové značení, členění stanovišť, podrobné klávesnice/myši/stojany, židle, drobné vybavení, rostliny a označení obou stran dveří. Tabule má čitelný souhrn místo příliš dlouhého dashboardu; MultiMesh odděluje i třetí místnost.
- Dveře odmítají souběžné animace a zavření do hráče. Vnitřní nástěnný ovladač má správně otočenou textovou plochu. Sdílené AcademyTheme, navigační stavy, zlaté nápovědy a tyrkysové testování sjednocují editor s původním UI; výstup má opravený kontrast.
- Opraveny další konkrétní závady: opakovaný Run bez úpravy už nesplní vedený krok; soubory udržují vlastní CodeEdit/undo/redo/kurzor; změna režimu funguje i u generované úlohy; přechod na jiné stanoviště obnoví správný filtr a ukončí nesouvisející cvičení. Odpojené editory se při zániku UI uvolní (ověřený čistý log bez úniků).
- Dosavadní ověření: programming_polish 23/23, academy 63/63 a grafický integration 765/765 PASS. Kompletní Test-All nyní obsahuje 30 sad a běží. Následuje export EXE + externí PCK, kontrola shody runtime s oficiální šablonou, scan Defenderu, test přesného balíčku a distribuce/push. SPUSTENI-WINDOWS.txt vysvětluje rozbalení a přesný limit neznámého vydavatele.

## Programming Academy — etapa 10 dokončena, finální distribuce (2026-10-26)
- Rozšíření je implementované v existujícím projektu: třetí průchozí 3D oblast, samostatný režim/hranice, Python/Web/Exam počítače, CodeEdit, bezpečná výuková podmnožina Pythonu a funkční omezený HTML/CSS/JS náhled. Přítomno 60 praktických úloh, 28 lekcí a 12 opravovacích variant; learn/practice/exam, série, dashboard, save/XP a XR ovládání jsou propojené.
- Úplný tools/Test-All.ps1: všech 29 sad PASS, exit 0, bez runtime chyb/varování (programming-final-test-all.log). Původních 65 misí v modelu/UI, 21×3 serverových lekcí / 1075 kontrol, 336 výukových UI akcí, save 474 a session safety 124 PASS. Čtyři programátorské sady mají ve finálním jednotlivém/PCK ověření 31 + 1071 + 63 + 765 kontrol; generátor má 252 odlišných variant.
- Původní WorldMCP při samostatném běhu znovu celý PASS, errors=[]; předchozí neúspěšné kliknutí se reprodukovalo při souběžných grafických exportních startupech, proto se finální GPU ověření provádělo postupně. Nový ProgrammingMCP rovněž PASS/errors=[]. Prohlédnuty snímky místnosti, editoru, skutečných výsledků serverových logů a webového DOM.
- build_content.py spuštěn v dočasné kopii: všechny původní i nové katalogy se přegenerují shodně. campaign.json, lessons.json a legacy_campaign.json jsou obsahově identické s checkpointem 5661021. Původních24 definic zůstalo zachováno.
- Finální Windows Release EXE: builds/windows/ITSupportSimulator.exe, 110820008 B, SHA256 6bbeebbe125feb8626b46a5941da13e8d8b5177f289b32323428b2696ba3eac4. Kompletní ZIP builds/ITSupportSimulator-Windows.zip: 40475777 B, cb8967f6c21579d939371b1b44a6731ea47d4098b7da47e337918b7bcebea589. ZIP obsahuje přesně tento EXE, licence, README, návody/dokumentaci a popis podporovaného rozsahu; CRC i vložený EXE ověřeny.
- PICO APK builds/pico4/ITSupportSimulator-PICO4.apk: 90410316 B, SHA256 cc502e35c27019c27ac71d6687d3dcf13963a6819f4a1cf15c5b5c5a33c6f997. apksigner/aapt potvrzují podpis, ARM64 a OpenXR/PICO manifest; ZIP CRC a skutečný zabalený katalog 60/28 plus LIMITS.txt ověřeny. Jde o sideload Debug APK.
- Samostatný finální Windows EXE otestován mimo projekt headless i GPU; native smoke ověřil starý obsah, vstup/odchod obou center, vlastní Python, HTML/JS/preview a přibalené limity. Přesný PCK navíc: všechny čtyři programovací sady, XR 69, terminál 64, ui_design 162, world_ui 27 a world_playthrough 34 PASS. Grafický test přesného PCK Compatibility: integration 765/765 PASS, bez varování. Manifest a výsledky jsou v builds/VERIFICATION.json.
- ADB nemá autorizované zařízení. Tracking, fyzická/Bluetooth klávesnice na konkrétním PICO, komfort dlouhého psaní a FPS na headsetu NEJSOU hardwarově ověřené. XR testy jsou syntetické. Interpreter a webový renderer jsou výslovně omezené, nikoli plný Python/prohlížeč; viz docs/PROGRAMMING_ACADEMY.md a data/programming/LIMITS.txt. Trvalé koncepty kódu nejsou implementované (volitelná část zadání).
- Testy používaly SaveManager.path_override a vlastní CFG. Nové runtime komponenty nevyžadují externí Python/prohlížeč na Windows ani Androidu. Zdrojové změny jsou v etapových commitech; finální commit přidává ověřené ZIP/APK/manifest a tuto zprávu, následuje autorizovaný push origin/main. Samotný EXE je ignorovaný kvůli limitu GitHubu; je celý uvnitř ZIPu.

## Programming Academy — závěrečné ověřování a distribuce (2026-10-26)
- Godot MCP ProgrammingMCP: skutečný Python počítač/editor, ekvivalentní funkce s různými argumenty, strukturální HTML/JS náhled, DOM kliknutí, odchod a čistý opětovný vstup PASS; errors=[]. Prohlédnut snímek neprůhledného editoru a interaktivního webu.
- Integration rozšířen na 765 kontrol PASS GPU Compatibility: skutečné předání fyzické klávesy do XR CodeEdit, celá programátorská klávesnice uvnitř viewportu, obnovení všech výsledků a odmítnutí vadné větve programming v save. PICO hardware nebyl připojen.
- První Windows/PICO exporty rozšíření sestaveny; samostatný EXE spustil menu, všechny oblasti, Python i HTML/JS/preview a obsah LIMITS.txt v izolaci. APK ověřeno apksigner/aapt, ARM64/OpenXR/PICO, bez autorizovaného ADB zařízení. Po drobném zpřístupnění dat mise v editoru a náhodného seedu pro ruční Run následuje konečný rebuild a test přesného PCK. Distribuční soubory se označí finální až po jeho ověření.

## Programming Academy — etapy 5–9 (2026-10-26)
- Dokončen katalog všech 30 Python + 30 webových úloh, 15 + 13 lekcí a 12 opravovacích variant. Každá položka obsahuje skutečné soubory, vysvětlení, cíle, nápovědy, referenční řešení a spustitelné testy. tools/build_programming.py je deterministický a volá se i z build_content.py; původní IT katalogy se nemění.
- WebDocument sestavuje strom HTML, kontroluje vnoření/atributy/popisky, CSS selektory/kaskádu a podporované deklarace. WebPreviewController vykresluje upravený obsah, barvy, boxy, jednoduchý flex/grid, tabulky, odkazy a formuláře. LearningJavaScript parsuje podporované DOM dotazy/registrace kliknutí/textContent; kliknutí skutečně změní strom i Control UI. Rozsah není plný prohlížeč a je výslovně uveden v editoru.
- Všechny lekce fungují v learn/practice/exam. Generátor 1–20 úloh mění vstupy i testy, každou variantu přehrává referenčním řešením. Dashboard ukazuje dokončení, průměr, chyby, nejlepší zkoušky a XP; opakování i varianty sdílejí omezené odměny základní úlohy.
- VR používá původní ray/trigger/drag/scroll monitor, rozšířenou klávesnici se všemi požadovanými znaky a odsazením, přepínání souborů a zoom 16–36. Přidáno předávání fyzické/Bluetooth klávesnice do zaměřeného pole. Žádné nativní desktopové závislosti nové učebny.
- Testy: runtime 31/31, katalog 1071/1071 (všechna správná/chybná řešení, alternativní Python/HTML/JS), academy 63/63, integration 761/761 v headless i GPU Compatibility (28×3 lekcí, skutečná změna CSS/DOM, 252 generovaných variant, syntetické XR vstupy). Grafické snímky prohlédnuty; opravena nevhodná automatická výška záhlaví, přidáno neprůhledné pozadí editoru.
- Úplný první Test-All byl přerušen po úspěchu původních lekcí kvůli varování Vendors: editor import odstranil explicitní výchozí XR nastavení. Nastavení obnoveno, běží závěrečné ověření. Starý WorldMCP při jednom GPU běhu selhal na načasování obnovy wizardu; samostatný nový ProgrammingMCP a úplné původní UI regrese následují. Netvrdit finální export/dokončení před etapou 10.
- Dokumentace docs/PROGRAMMING_ACADEMY.md a data/programming/LIMITS.txt popisuje přesné limity. Fyzický PICO/ADB test není dosud proveden. Další krok: finální Test-All, MCP, grafická kontrola, Windows/APK export, ověření přesného PCK a push autorizovaný uživatelem.

## Programming Academy — etapy 1–4, první funkční lekce (2026-10-26)
- Checkpoint před implementací: 5661021. Notion hlavní stránka a obě příručky načteny MCP; offline kopie data/knowledge/programming_notion_*.md. Původní katalogy a legacy24 se nemění.
- Nová skutečně průchozí učebna severně od serverovny, posuvné dveře s ovladači po obou stranách, pět počítačů, Python/Web/Exam stanoviště, Ada instruktor a studijní tabule. Scéna vytvořena Godot MCP.
- GameModeManager rozlišuje MAIN, SERVER_TRAINING (zpětný alias TRAINING) a PROGRAMMING_ACADEMY. Přechod fyzickou hranicí, teleport i zánik scény ruší dočasné cvičení/editor; přímé přechody mezi oběma centry jsou chráněné proti rekurzivnímu obnovení kampaně.
- CodeEdit nabízí vlastní víceřádkový kód, syntax highlighting, odsazení, desktopový clipboard/undo, virtuální input, konzoli, run/test/reset, nápovědu a zoom. Stejný panel používá původní XR ray/monitor. VR klávesnice rozšířena o programátorské znaky a čtyři mezery.
- Vlastní PythonParser/PythonRuntime: lexer, AST, výrazy, proměnné, řetězce/f-stringy, kolekce/comprehension, bloky, funkce, try/except, math/random, VFS. Žádné spuštění Pythonu/GDScriptu/systémových procesů z hráčova kódu. Bounded runtime; podmnožina a limity jsou v data/programming/LIMITS.txt a editoru.
- PY01 lze dokončit vlastními řešeními, vedené kroky vyžadují úpravy a skutečné spuštění. Výsledky/XP se ukládají do kompatibilní volitelné větve programming v původním SaveManageru; opakování odměňuje jen zlepšení nejlepšího skóre. Aktivní cvičení se neukládá.
- Testy: programming_runtime 25/25, programming_academy 63/63, training_rooms 68/68 a campaign 65/65 PASS. Vše se SaveManager.path_override. Zatím pouze první lekce; další obsah, strukturální webový renderer, generátor, kompletní regrese a nové exporty následují. Skutečný PICO zatím neotestován.

## Návod k instalaci na PICO 4 (2026-10-26)
- Přidán samostatný NAVOD_PICO4.md v kořeni projektu a odkaz z README. Postup pro běžný PICO 4 popisuje APK, vývojářský režim/USB debugging, autorizaci počítače, PowerShell a již instalované ADB i stažení Platform-Tools na jiný počítač, instalaci/aktualizaci a spuštění hry.
- Doplněno první ovládání, komfort a řešení unauthorized/offline/chybějícího zařízení či APK a odlišného podpisu s ochranou uloženého postupu. Postup vývojářského režimu ověřen proti oficiální dokumentaci PICO, příkazy proti ADB. Zachováno upozornění, že skutečný headset/tracking/FPS nebyly otestované.
- Pouze dokumentace: kontrola odkazů a konzistence s existujícím APK, exportním presetem a XR ovládáním; herní zdroje, uložená data a distribuční soubory beze změny.

## PC + PICO 4: exporty a závěrečné ověření (2026-10-26)
- Konečná distribuce: EXE 110508888 B / SHA256 1926f92b853202e87172334ee22bd40940bd675d385c23bfb61053cf9f1a8a07; ZIP 38346233 B / b750aae84a071a001350395b87f6376eef9d60610cc5b294dcd95d800b79e053; APK 90272345 B / 8b73ae5c8185965e2734acb868a9df32797b505d2a747e321c91cf5e33eab2cd. ZIP obsahuje přesně ověřený EXE, aktuální README a licence; ZIP i APK prošly kontrolou CRC. Finální manifest zachovává i výsledky testů přesného PCK.
- Přesně tento EXE: tools/test_windows.py graficky z izolovaného adresáře PASS, všechny logy bez chyb/varování: XR 69, terminál 64, ui_design 162, world_ui 27, world_playthrough 39; nativní start headless i GPU PASS. Log final-windows-package-69.log a windows-package/results.json. Následné samostatné grafické spuštění --xr-mode on bez runtime správně vrátí menu, exit 0, žádný SCRIPT ERROR; log native-pc-vr-graphical-unavailable.log. finální build/ověření: final-platforms-69.log a final-distribution-verified.log.
- Dokončeny skutečné exporty do builds/windows/ITSupportSimulator.exe, builds/ITSupportSimulator-Windows.zip a builds/pico4/ITSupportSimulator-PICO4.apk. Použity shodné oficiální Godot 4.7.2 export templates, JDK 17, SDK compile 36 / Build Tools 36.1.0 / NDK 29.0.14206865 / Gradle 8.11.1. APK min/target 29/34, pouze ARM64, podpis v2, PICO VR metadata a OpenXR loader/vendor knihovny ověřeny. Sideload Debug APK, Windows Release s vloženým PCK.
- Nové tools/build_platforms.py + Build-Platforms.ps1 exportují obě platformy a provádějí ověření, balení a SHA256 manifest builds/VERIFICATION.json. Windows používá přímo core OpenXR; Android Vendors GDExtension se přibaluje pouze do APK. Stejné herní zdroje se pro Windows importují v dočasném adresáři. Přímé spuštění GUI binárky enginu při Android exportu řeší zadržení stdout pipe Windows console launcheru Gradle daemonem. Aapt dostává relativní cestu kvůli Unicode ve jménu pracovní složky.
- Godot MCP umí vytvoření/úpravy scén a spuštění/testování, ale v nabídce nemá export_project; exporty provádí oficiální CLI stejného enginu. MCP WorldMCP: raycast/E, 79 objektů, Proxmox formulář, zásah/save/návrat, opakované dveře a instruktor/výuka PASS, finálně errors=[].
- Úplný tools/Test-All.ps1: 25 sad PASS, exit 0 (test-output/final-xr-test-all.log), včetně všech 65 misí v modelu/UI, 21×3 lekcí / 1075 kontrol, 336 UI výukových akcí, save 474, session safety 124 a room boundary 68. Kampaň, legacy_campaign a lessons JSON porovnány také s checkpointem 785506e, datový obsah shodný; generátory se nemění.
- Finální XR sada rozšířena na 69 kontrol PASS headless i GPU Compatibility: původních 64 plus vlastnictví paprsku levého/pravého ovladače, zrušení kliknutí při uvolnění mimo monitor, skutečné zavření klávesnice a bezpečné přerušení/obnova head pose bez potřeby nové session_focussed události. Snímky menu a VR konzole prohlédnuty. Logy final-xr-interaction*.log.
- Skutečný Windows EXE ověřen headless i graficky z cizí dočasné složky bez editoru/projektu. Zabalené PCK ověřuje plný engine s externími testy: XR, terminál, ui_design, world_ui a servisní world_playthrough. Poslední test byl zbaven nedeterministického pohybu testovací kamery při nativním zachycení/recentrování myši; stále ověřuje skutečný raycast/E i servisní formuláře, žádná změna herního FPS ovládání.
- Samostatný EXE s --xr-mode on bez dostupného runtime: očekávaná OpenXR inicializační chyba, návrat do menu, žádný SCRIPT ERROR, exit 0; native-pc-vr-unavailable.log. Reálný PC VR headset/tracking ani standalone tracking/FPS nebyly ověřeny. ADB nevidí autorizované zařízení. Cíl 72 Hz je požadavek runtime, nikoli výsledek měření.
- README obsahuje spuštění obou režimů, sideload přes ADB, komfort, virtuální klávesnici, validovaný přenos save, sestavení a přesná omezení. Podrobnosti v docs/VR_TEST_REPORT.md. ZIP a APK jsou určeny do Gitu/GitHubu; samotný EXE překračuje 100 MiB limit a je uvnitř kompletního ZIPu. Ukládání hráče bylo při všech testech izolované přes path_override.

## PC + PICO 4: výchozí checkpoint (2026-10-26)
- Nové zadání autorizuje Windows EXE, ARM64 PICO APK a push na origin/main. Výchozí čistý strom 785506e je shodný s GitHubem; obsah 65 misí a 21 lekcí se zachová.
- Dostupný Godot MCP potvrzuje Godot 4.7.2.stable.official.ed1daf0bf. Existující FPS, GameShell, UIController a oddělené tréninkové relace tvoří základ obou režimů.
- Před implementací ověřeny oficiální dokumentace Godot XR/Android a OpenXR Vendors. Následuje společný přepínač režimu, XR rig, monitor s virtuální klávesnicí, regresní testy a skutečné exporty. Hardware testy se vykazují odděleně.

## PC + PICO 4: sdílený VR režim (2026-10-26)
- Zachován původní GameShell/FirstPersonController, všech 65 misí, 21 lekcí a katalogy. Menu nabízí klasické 3D a PC VR, standalone Android zahajuje VR přímo. PC OpenXR se při volbě VR spouští novým procesem stejné hry s --xr-mode on; chybějící runtime vrátí menu s vysvětlením. Přepnutí zpět na desktop zachovává GameManager.
- Přidán XRPlayer vytvořený přes Godot MCP (XROrigin3D, XRCamera3D, dva XRController3D). Verze OpenXR Vendors 5.1.0-stable podporuje Godot 4.6+. Akční mapa obsahuje PICO 4 i PC profily, trigger, grip, joysticky, menu/B/Y a A/X. Enterprise, eyes, face a optické sledování rukou nejsou požadovány.
- Stejný kolizní hráč a TrainingZone se používají pro joystick, fyzický pohyb i teleport. Výchozí teleportace, snap 15/30/45°, plynulý pohyb a režim vsedě mají vlastní uložený komfort. Ztráta focus/tracking pozastaví zásahy. Fyzické náhradní disky a tlačítka napájení pracují přes původní GameManager.apply; servisní potvrzení, serial a backup se zachovávají.
- Původní UI včetně konzolí, terminálu a modalit se přemístí do SubViewport 1600×1200 na prostorový monitor. Virtuální klávesnice včetně českých znaků, Backspace/Enter/Tab, controller ray klik/drag a scroll používají skutečné UI vstupy. Monitor je ukotven ve světě a lze jej přemístit A/X.
- Přenos postupu exportuje/importuje validovaný academy-transfer.json, import zálohuje předchozí save. Android používá Compatibility/OpenGL, 2× MSAA, bez stínů/SSAO/SSIL/SSR a otáčení ventilátorů; požadavek 72 Hz pouze při nabídce runtime. Výkon na PICO dosud neměřen.
- tests/xr_modes.gd: 64 kontrol PASS, včetně syntetických XRTracker poses a skutečných controller inputs, pohybu, grip disku, monitoru, klávesnice, focus, room-scale odchodu při otevřené konzoli a teleportového resetu learn/practice/exam. Grafický předchozí 55kontrolový běh PASS; prohlédnut snímek prostorové konzole. Vše používá SaveManager.path_override a vlastní konfigurace.
- První reálný Windows Release EXE s PCK a vendor DLL úspěšně spuštěn samostatně mimo projekt (exit 0; menu, 65/21 obsah, svět a vstup/odchod akademie). První podepsané ARM64 PICO APK vytvořeno; apksigner a aapt potvrzují podpis v2, min SDK 29, target 34, OpenXR/PICO manifest a pouze arm64-v8a. Finální opakované exporty a ověření následují po regresích. ADB nemá připojené zařízení; tracking a FPS nejsou označeny za ověřené.

## Porovnání s místní kopií a odstranění distribuce z Gitu (2026-10-26)
- Porovnána čistá místní větev main na f5acc3f s GitHub main na 4c86cd2. GitHub byl o 6 commitů napřed, bez samostatných místních commitů; lišilo se 19 souborů, z toho 7 distribučních v build/. Herní rozdíly: správný hostitel v diagnostice terminálu a napájení VM přes GameManager.apply včetně undo, výukových událostí, hodnocení a ukládání. Dále nový audit, test terminal_sessions a změny starého Windows balení.
- Celé data/ a obsahové generátory jsou mezi oběma verzemi shodné, včetně 65 misí, 21 lekcí a legacy24. Ověřování proběhlo v izolované kopii nejnovějšího GitHubu.
- Na následný pokyn uživatele místní main bezpečně posunuta fast-forwardem na požadovaný 4c86cd2 a připravena pro další úpravy. Původní místní balíček před synchronizací přesunut do ignorovaného test-output/local-build-before-sync-20261026/. Navazující úklidový commit odstraňuje distribuční složku také z místního sledovaného projektu. Místní import a přímý test terminálu 63/63 PASS; doplněno Godotem vygenerované UID nového testu. Logy repository-sync-import.log a repository-sync-terminal.log v test-output/.
- Na výslovný požadavek uživatele odstraněna z aktuálního stromu repozitáře celá složka build/ se 7 soubory včetně 104340256bajtového EXE. Existující .gitignore již build/ vylučuje. Git historie se nepřepisuje, starší commity svůj distribuční obsah zachovávají.
- Nejnovější zdroje rozbaleny přímo z Git historie bez build/ a původní .godot/ cache do test-output/repository-without-build/. Nový Godot 4.7.2 import PASS. Herní skripty, scény ani assety neodkazují na distribuční složku.
- Úplný tools/Test-All.ps1 nad touto kopií: všech 24 sad PASS, exit 0, bez runtime chyb a varování. Terminál 63, kampaň 65/65 v modelu i UI, lekce 21×3 / 1075 kontrol, výukové UI 336 akcí, save 474, relace 124, navigace 700 a nastavení 68 kontrol PASS. Log test-output/without-build-test-all.log; build/ nebyl přítomen ani po testech.
- Godot MCP / WorldMCP nad stejnou kopií: 79 interaktivních objektů, raycast/E, původní konzole, zásah/uložení/návrat, opakované dveře a výukový průchod včetně instruktora PASS, errors=[]. Forward+/Vulkan na RTX 5060; prohlédnut snímek výukového formuláře v 720p.
- README popisuje spuštění zdrojového projektu v Godotu bez distribuce a označuje dosavadní exportní nástroje jako původní postup; audit odkazuje na zachovaný TEST_REPORT. Uživatel výslovně vyřadil práci na exportu EXE, nový export se zde neimplementoval ani netestoval. Všechny herní testy používají SaveManager.path_override a oddělený DisplaySettings.path_override.

## Opravy terminálu a ověřené samostatné EXE (2026-10-26)
- Opraveny obě chyby z auditu: pveversion a Get-VMHost čtou skutečně vybraného hostitele; terminálové start/vypnutí nyní prochází GameManager.apply se stejným undo, výukovými událostmi, hodnocením a ukládáním jako formuláře. Dotazy historii nepřekrývají. Neplatný hostitel a opožděný zásah po odchodu z místnosti se bezpečně odmítnou.
- Nová tests/terminal_sessions.gd: 63 kontrol PASS headless i GPU. Skutečné odesílání přes UI, Proxmox/Hyper-V, všechny tři výukové režimy, postup výuky a chyby, izolace odložené kampaně a skutečné selhání zápisu/opakování.
- Úplný tools/Test-All.ps1 nyní obsahuje 24 sad: vše PASS, exit 0, bez runtime chyb a varování. Zachováno 65 misí v modelu i UI, 21×3 lekcí / 1075 kontrol, 336 výukových UI akcí, 474 kontrol save, 124 kontrol relací a 700 kontrol navigace. Log test-output/terminal-fix-test-all.log.
- Na následný výslovný požadavek uživatele aktualizována i distribuce. tools/build_windows.py a Build-Windows.ps1 sestavují skutečný samostatný EXE s vloženým PCK přes oficiální exporter, s opětovným použitím přibaleného enginu v dočasné kopii. Ověřuje se verze, PE/PCK a velikost; opakované sestavení nezvětšuje engine o další staré PCK. Katalogy ani exportní preset se nemění.
- Nový tools/test_windows.py ověřil přesně výsledný 104340256bajtový EXE (SHA256 372936020238d3b93b44af169e99d309dcc654a4649f2494b6f16b64c5b8f74f): přímý nativní headless i grafický start bez zdrojového projektu, oba exit 0 a čistý log. Exportní šablona nepovoluje externí --script/--path, takže testy zabalených dat běží odděleně plným editorem přes --main-pack.
- Závěrečné zabalené herní zdroje: terminál 64, ui_design 162, world_ui 27 a world_playthrough 39 kontrol PASS, bez runtime chyb/varování; Forward+/Vulkan na Intel UHD Graphics, také 4K. Logy/snímky test-output/windows-package/. Strojový záznam přesného ověřeného EXE je build/VERIFICATION.json. README, BUILD_INFO, TEST_REPORT i audit jsou aktualizované.
- Všechny závěrečné testy používají SaveManager.path_override a oddělenou konfiguraci; přímý EXE start --test-world nastavuje obě cesty před Game.new(). Ověřeno, že hráčův save nebyl přepsán. campaign.json, legacy_campaign.json a lessons.json mají stejné SHA256 jako před opravou. Godot MCP není v sezení dostupný; použit místní engine. Obnovena skutečná Git historie repozitáře nacelnik028/IT_support pro požadovaný commit a push.

## Kontrola úplnosti projektu (2026-10-26)
- Na žádost uživatele zkontrolován existující zdrojový projekt; podrobný výsledek a reprodukce jsou v [docs/PROJECT_AUDIT.md](docs/PROJECT_AUDIT.md). Složka build je podle následného pokynu uživatele mimo hodnocení. Herní kód ani katalogy se neměnily.
- Přítomno 65 misí, 21 lekcí ve třech režimech, 50 článků a hlavní 3D, výukové, simulační, postupové i ukládací systémy. Reference souborů a akcí bez chyb. Prvních 24 misí odpovídá legacy_campaign.json. build_content spuštěný výhradně v dočasné kopii obnovil stejný obsah JSON; originální data nebyla přepsána.
- Nový úplný tools/Test-All.ps1: všech 23 sad PASS, exit 0, bez runtime chyb a varování. Ověřeno 65 misí v modelu i UI, 21×3 lekcí / 1075 kontrol, 336 výukových UI akcí, 474 kontrol ukládání, 124 kontrol relací a 700 kontrol navigace. Log test-output/audit-test-all-console.log.
- Nové grafické běhy na Intel UHD Graphics / Forward+: ui_design 162, world_ui 27 a render_quality 8 kontrol PASS, čisté logy audit-gpu-*.log. Prohlédnuty aktuální snímky konzole a lekcí v 720p se 130% textem a skutečný 3D HUD akademie. Import Godot 4.7.2 bez chyb.
- Dvě nově reprodukované, dosud neopravené chyby: pveversion nad PVE-02 a VMMS v Get-VMHost nad HV-02 čtou příslušná data prvního hostitele; změny napájení přes terminál obcházejí GameManager.apply a nevytvářejí historii undo ve volném tréninku. Druhý případ ověřen přes skutečný vstup terminálu v UI. Reprodukce a log: test-output/audit_terminal.gd / audit-terminal.log. Stávající testy tyto případy nezachycují.
- Hlavní systémy současného laboratorního rozsahu jsou přítomné; pokročilá rozšíření Ceph, úplný Cluster/CSV a bootovací ZFS rpool zůstávají podle README mimo úplné praktické průvodce.
- Všechny testy a reprodukce používají SaveManager.path_override a oddělené nastavení; hráčův save se nepoužil. Godot MCP nebyl v tomto sezení dostupný, použit místní engine. Tato stažená kopie nemá .git; commit zde nelze vytvořit a nový repozitář nebyl zakládán.

## Profesionální vzhled a použitelnost UI (2026-10-25)
- Zachována hlavní 3D scéna, serverovna, chůze, raycast/E, fyzický servis, dveře i oddělená akademie. Úprava se týká prezentace menu, konzolí, katalogů, nastavení a HUD; katalogy, mise, lekce a legacy_campaign.json se nemění.
- Před úpravami hra spuštěna přes Godot MCP, skutečný klik na Zahájit směnu a pět výchozích snímků v 720p. Nalezené problémy: podobný vzhled navigace a potvrzení, výchozí šedý strom, malé popisky, neseskupená široká pole, příliš vysoký úvod lekcí a HUD bez konkrétního dalšího cíle.
- Nový sdílený AcademyTheme (grafitové plochy, kontrastní text, tyrkysová hlavní akce, zlatý instruktor, explicitní hover/fokus/výběr/disabled), UIComponents a MenuPresentation. Písmo Segoe UI s českými fallbacky; zachované oversampling_with_scale a DPITexture ovládacích ikon. Menu má výraznou identitu a jednu hlavní akci.
- Konzole mají trvalý kontext platformy, hostitele a skutečného cíle formuláře, také při výchozí VM bez kliknutí do stromu. Pole jsou ve skupinách a sloupcích, RAM popisky v GiB, potvrzení je pevně pod posuvným obsahem. Formátová chyba má zprávu a rámeček u pole, fokus a zrušení při opravě bez překreslení; nemění hodnocení. Koncepty, posuv a fokus nadále spravují původní komponenty.
- Katalogy mají pevné filtry, kompaktní položky, dokončení textem/symbolem a prázdné výsledky. Nastavení odděluje režim obrazu od kvality, klávesy jsou ve sloupcích. HUD kampaně ukazuje dokončené cíle a skutečný další cíl. Zlaté vedení zůstává pouze v Učím se.
- Nová sada ui_design.gd: 162 kontrol PASS headless i GPU pro 720p/1080p/4K × 100/130 % textu, skutečné klikání a editace, místní validace, kontext a fokus hledání. Zařazena do Test-All. Grafická a headless varianta mají vlastní oddělené save/config cesty. UI regrese: console_ux 60, tutorial_navigation 700, world_ui 27, display_settings 76 GPU a render_quality 8 PASS; glyphy ve 4K přibližně 2× ostřejší v daném testu, ikona skutečně 38×38 px.
- DesignMCP.tscn: 31 kontrol PASS ve skutečné 3D scéně ve stejných 6 kombinacích, errors=[]. Prohlédnuty snímky všech rozlišení a 130 % textu. WorldMCP: 79 objektů, raycast/E/detail/konzole/změna/save/návrat, opakované dveře a vedený návrat od instruktora PASS, errors=[]. MCP klikání čeká na dokončené vykreslení před hit testem.
- Trvalé srovnatelné snímky před/po a vysvětlení v docs/ui-review/README.md; zdrojové matice a logy v test-output/design-*. Testovací data používají výhradně SaveManager.path_override a DisplaySettings.path_override.
- Závěrečný tools/Test-All.ps1: všech 23 sad PASS, exit 0, bez runtime chyb a varování. Zachováno 65/65 misí v modelu i UI a legacy24, 21 lekcí × 3 režimy (1075 kontrol, 336 výukových UI akcí), 474 kontrol save, 124 kontrol relací a izolace kampaně. Log test-output/design-test-all-verified.log.
- Windows EXE+PCK v build/ aktualizované. Samostatný zabalený EXE graficky prošel ui_design 162 a world_ui 27 kontrolami, oba exit 0 a čistý stderr (design-package-*-out/err.log). Dokumentace přibalená; snímky a testovací skripty se do PCK neexportují.

## Oprava tutoriálu v novém UI (2026-10-25)
- Reprodukovány tři chyby skutečným klikáním (před opravou 3 selhání ze 6 kontrol): klik na již vybraného hostitele neemitoval item_selected; kontext instruktora měl nulovou výšku; Zobrazit potřebný panel kontext nezavřelo, takže formulář zůstával skrytý. Předchozí testovací adaptér první problém obcházel ručním emitováním signálu stromu.
- Strom nyní potvrdí výběr také opětovným kliknutím nebo Enterem. Kontext instruktora i ticketu vyplní dostupnou výšku. TutorialPresentation směruje skutečné cíle do sekcí a operací nového UI; návrat od instruktora otevře konfiguraci a obnovení posledního kroku VM otevře shrnutí se Start/Ověřit.
- Nad formulářem zůstává kompaktní aktuální instrukce a chyba kroku. Zvýrazňuje se konkrétní operace nebo sekce; krátké dorovnání po dokončení layoutu neschová cíl obnoveným posuvem a dále nechává uživateli volný posuv. Koncepty mají přednost a samotná navigace neprovádí operace ani nepotvrzuje výukové kroky. Vedení platí pouze pro Učím se.
- Nový tutorial_navigation.gd: 700 kontrol PASS headless, všech 21 vedených lekcí bez open_action či nastavování page/tab v testu; skutečné vstupy do stromu, sekcí a formulářů, potvrzení přes skutečné tlačítko dialogu. Zahrnuje Enter, chybnou RAM, obnovu posledního kroku, koncept, posuv, 720p/1080p/4K, zákaz vedení v dalších režimech a zachovanou kampaň. Součást Test-All, aktuálně 22 sad PASS (exit 0, bez runtime chyb/varování), včetně 65 misí, 21×3 režimů, 336 výukových UI akcí a 474 kontrol save. Log tutorial-test-all.log.
- Doplněný Godot MCP test prošel raycast/E na skutečný cvičný server, otevření managementu, klik na předvybraný uzel, instruktora a návrat k viditelnému průvodci; errors=[]. Snímky tutorial-recovered-identity-720.png, tutorial-summary-720.png a tutorial-world-recovered-720.png skutečně prohlédnuty. Závěrečný tutorial_navigation prošel všech 700 kontrol také graficky a v nově sestaveném samostatném Windows EXE+PCK, oba exit 0 a bez runtime chyb/varování. Prohlédnuty i snímky identity v1080p/4K. Logy tutorial-navigation-final.log, tutorial-navigation-gpu-final.log a tutorial-package.log; build aktualizovaný. Grafický test čeká na dokončení vykreslení layoutu a směruje vstupy do správného viewportu nezávisle na fokusu nativních oken.
- README/TRAINING popisují nové ovládání. Definice misí/lekcí, generátory ani legacy soubory se nemění. Všechny běhy mají oddělené save i nastavení.

## Závěrečné ověření a Windows balíček (2026-10-25)
- Aktuální tools/Test-All.ps1: všech 21 sad PASS, exit 0, bez runtime chyb a varování. Nové sady platform_context 396, console_ux 60 a world_ui 27 kontrol. Zachováno 65/65 misí v modelu i UI, 21 lekcí ve všech 3 režimech (1075 kontrol a 336 UI akcí), 474 kontrol save, 124 relací, 68 oddělení místností a ostatní regrese. Log test-output/ux-test-all-final.log.
- Graficky: display_settings 76 PASS včetně skutečného fullscreen a všech 6 rozlišení, render_quality 8 PASS včetně skutečného 4K framebufferu, ostrosti fontů a SVG 38×38. Zdrojové console_ux 58 GPU a world_ui 27 GPU PASS; konečnou 60kontrolovou variantu konzolí navíc ověřil zabalený EXE. Snímky konzole/nastavení/ovládání v 1280×720, 1920×1080 a 3840×2160, všech kroků průvodce, 130% textu a HUD skutečně prohlédnuté. Logy ux-graphical-final.log, ux-display-gpu-final.log, ux-render-quality.log, ux-world-ui-gpu-final.log.
- Godot MCP: 79 interaktivních objektů, raycast/E/detail/konzole/změna/save/návrat a opakované otevření/zavření dveří PASS, errors=[]. Kompatibilní renderer: world_ui 27 PASS (ux-compatibility.log).
- Aktualizovány build/ITSupportSimulator.exe + PCK. Samostatné grafické spuštění balíčku z build/ pomocí externích izolovaných testovacích skriptů: console_ux 60/60 a world_ui 27/27, oba exit 0 a čisté logy ux-package-console.log / ux-package-world-ui.log. EXE používá jen prostředky PCK; testovací skripty nejsou součástí distribuce. Zachováno zdokumentované balení plným enginem.
- Finálně znovu ověřena reprodukovatelnost build_content, shoda prvních 24 definic proti původnímu 47ea9fa a nezměněný legacy_campaign.json. Všechny běhy mají SaveManager.path_override i oddělený DisplaySettings.path_override; hráčův save/config se nepoužily. README/TRAINING odpovídají novému ovládání, TEST_REPORT obsahuje výsledky. Požadované funkční opravy a nové ovládání jsou dokončené.

## Výuka, HUD, přístupnost a katalogy – etapa P2 (2026-10-25)
- HUD odvozuje název a režim z aktivní relace, velikost stavového/instruktorského panelu z textu. Oznámení vstupu se nezobrazuje přes aplikaci ani aktivní lekci. Společné nastavení se vrací do pauzy; Escape zavírá nejprve dialog, potom kontext a konzoli. Psaní nepohybuje hráčem, HUD respektuje vlastní klávesy a velikost textu.
- První směna má přeskočitelné čtyřkrokové seznámení; znovu je dostupné z pauzy. Menu má jednu hlavní akci. Mise/lekce mají hledání a stavový filtr, články/slovník hledání. Chyba nabízí vysvětlení a související lekci. Zkouška zůstává bez zvýraznění řešení.
- Úspěch, provozní upozornění a odmítnutí mají odlišný textový stav. Sloty rozlišují člena pole, hot spare, volný a vadný disk. Operace nad prázdným uzlem nepředvolí VM jiného hostitele; pevné hostitelské cíle nabízejí přepnutí.
- Generátory nyní upravují mezery pouze v lidských textech nového obsahu. RAM je GiB/MiB se skutečným převodem 1024; diskové kapacity zůstávají laboratorní GB. Zdrojové texty a JSON jsou konzistentní, opakované build_content má stejné hashe; prvních24 misí i legacy soubor zůstaly shodné.
- console_ux rozšířen na60 kontrol (headless PASS), world_ui27 headless/Forward+/Compatibility PASS, ostrost a závěrečný celek se ověřují před balením. Snímky konzole, nastavení a ovládání v720p/1080p/4K i krátkého HUD byly skutečně prohlédnuté. MCP79 objektů, raycast/E/konzole/save/návrat/dveře PASS, errors=[]. MCP test drží kameru nezávislou na přesunech desktopového kurzoru.
- První úplný Test-All21 sad prošel. Při opakování se jednou objevil pouze výstupní audio leak v ui_safety; čtyři verbose opakování byla čistá, cleanup nově čeká také120ms nástěnného času jako ostatní audio testy. Závěrečný běh používá aktuální zdroje a odmítá každé runtime varování.
- Měřeny skutečné předvolby v1920×1080 na RTX5060/Forward+, bez VSync/limitu: přibližně110/75/55 FPS pro Úsporná/Vyvážená/Vysoká v konkrétním pohledu. Nejde o srovnatelný obecný benchmark předchozí etapy ani záruku pro jiné počítače. Log/JSON ux-world-ui-gpu.log / ux-quality-benchmark.json.

## Konzole, průvodce a společné nastavení – etapa P1/P2 (2026-10-25)
- Konzole mají pevný strom, viditelné sekce a výběr jedné operace. Kontext ticketu/instruktora se přepíná tlačítkem nahoře. Navigace, hodnoty formulářů, pracovní kontext a nastavení jsou vyčleněné do komponent.
- Průvodce VM má šest skutečných kroků s uložením do existující simulace, Zpět/Další, shrnutím, instalací, startem a ověřením. Zachované události výuky, žádné skryté souběžné formuláře. Testovací adaptéry ovládají sekce a výběr operací.
- Zachovaný posuv/fokus/kurzor, koncepty po VM/hostiteli/relaci a nepotvrzená čísla. CPU/RAM, Dynamic Memory a síť čtou konfiguraci cíle. Nabídky VM ukazují existující kompatibilní ID/název/hostitele. Formátová validace nemění hodnocení. Potvrzení mají čitelný souhrn.
- Nastavení Obraz/Zvuk/Ovládání/Rozhraní: persistentní hlasitost/ztlumení, citlivost, klávesy s kolizemi a resetem, text 100/115/130 %, potvrzení obrazu do 15 s s návratem. Přidané skutečné grafické předvolby, VSync a FPS limit; navazuje ověření ve 3D.
- Síťový přehled iteruje všechny existující VM, včetně VM101; editace vybírá konkrétní platformu/hostitele/VM.
- Ověřeno: všech 65 misí přes nové formuláře, 336 UI operací všech 21 lekcí ve všech 3 režimech, tutorial_first, ui_safety 32 a display_settings 68 PASS. Nový console_ux: 56 kontrol PASS headless i Forward+/RTX5060, včetně skutečných kliknutí všemi šesti kroky, RAM, fokusu, posuvu po odmítnutí, timeoutu obrazu, konceptů, kláves a VM101 v síti. Izolované save/config.
- Snímky konzole, nastavení a ovládání pořízené v 720p/1080p/4K; 720p a kroky průvodce prohlédnuté, následuje zbývající vizuální a celková regrese. Windows balíček se aktualizuje po závěrečném ověření.

## Kontext operací – etapa P0 (2026-10-25)
- Sdílený OperationContext ověřuje skutečnou platformu zdrojového hostitele u operací Hyper-V i PVE a kompatibilní odlišný cíl migrace/Replica. Obecné napájení, síť a zálohy zůstávají společné; offline převod má samostatnou validaci exportu. Dynamic Memory používá rozpočet skutečného hostitele.
- Nový platform_context.gd: 396 kontrol PASS včetně obou přesných reprodukcí a neměnnosti infrastruktury při odmítnutí. campaign.gd: všech 65 misí PASS, legacy24 beze změny. Izolované save/config cesty. Následuje přepracování prezentace konzolí.
## Audit a zadání dalších úprav (2026-10-25)
- Na žádost uživatele provedena kontrola dokumentace, UI, simulace, výuky, nastavení, 3D ovládání, testů a distribuce. Připraveno samostatné zadání `PROMPT_PRO_AI.md` s prioritami P0–P3. Tato etapa mění pouze dokumentaci; opravy hry jsou zadáním pro navazující implementaci.
- Na izolovaném modelu reprodukovány chybějící kontroly platformy: Hyper-V `memory` přijme vypnutou PVE VM100 a `live_migrate` ji přesune přímo z PVE-01 na HV-02. Seznamy VM a zachovaný `selected_vm` dovolují nesprávný kontext také v UI. Zadání obsahuje přesné reprodukce a požadavky na negativní regrese.
- Graficky ověřen dlouhý průvodce (6 formulářů, výška obsahu2498 / dostupná615 jednotek UI), reset posuvu1400→0 po `draw_ui()`, nabídky konzolí, Storage, menu, pauza, nastavení a výuka. Zaznamenán také zavádějící HUD „vyber si lekci“ při aktivní lekci, oznámení překrývající nabídku lekcí a pevný seznam VM100/200 v síťovém přehledu. Návrhy vzhledu/přístupnosti jsou v zadání odlišené od reprodukovaných chyb.
- Celý `tools/Test-All.ps1`: všech18 sad PASS, exit0, bez runtime chyb/varování;65/65 misí v modelu i UI,21×3 lekcí (1075 kontrol),336 výukových UI akcí,474 kontrol save a ostatní regrese. Log `test-output/review-test-all.log`. Současné testy uvedené nové chyby platformy nezachycují.
- Godot MCP / `WorldMCP.tscn`:79 interaktivních objektů, raycast/E/konzole/změna/uložení/návrat a opakované ovládání dveří PASS, `errors=[]`. Vlastní grafický audit běžel přes Forward+/RTX5060 v720p; další dřívější snímky byly prohlédnuty jako doplňkový podklad. Nové4K testování ani benchmark se v tomto auditu neprováděly.
- Pomocný skript, snímky a reprodukční log jsou v ignorovaném `test-output/review_capture.gd`, `review-*.png`, `review-capture.log`. Všechny běhy používaly `SaveManager.path_override`; grafické běhy/MCP i oddělený config. Herní kód, katalogy ani Windows balíček nebyly změněny.

## Oddělení serverovny a tréninkové místnosti (2026-10-25)
- `GameModeManager` udržuje jediný režim MAIN/TRAINING. Existující posuvné dveře a oba ovladače zůstaly; nová `TrainingZone` má Area3D/BoxShape3D, prostorovou toleranci hranice 16 cm a průběžnou kontrolu skutečné polohy i před zásahy. Teleport, načtení vnější pozice, menu a zánik scény ukončí trénink.
- `GameManager` má samostatné `main_sim` a `training_sim`. Vstup odloží pracovní ticket, výběr lekce používá sandbox. Produkční i cvičné racky, LED, ventilátory a živé monitory čtou svou instanci. Produkční interakce a dokončení pracovních misí jsou v centru blokované; všechny tři režimy lekcí i náhodné série vyžadují TRAINING.
- Odchod ruší tutorial, kroky, zvýraznění/šipky, otevřené dialogy, koncepty, nesený konektor, undo, závady a dočasné relace. Obnovuje původní ticket včetně konfigurace a fyzického stavu. Výsledky `education.lessons/attempts`, výsledky série, XP, achievementy a kariérní skóre zůstávají. Nová návštěva ani restart hry automaticky neobnoví nedokončenou lekci.
- Přidány požadované české zprávy při vstupu/odchodu a stav „Tréninkové centrum – vyber si lekci“. README/TRAINING popisují nové chování. Katalogy, všech65 misí,21 lekcí i legacy24 zůstaly beze změny; generátory nebylo třeba měnit.
- Nová společná sada `training_rooms.gd` / `TrainingRoomsMCP.tscn`:68 kontrol A–H PASS headless i graficky přes Godot MCP (Forward+/RTX5060, errors=[]). Obsahuje skutečnou chůzi dveřmi oběma směry, všechny3 režimy, poškození cvičného disku a nezávislé LED, uložené výsledky/XP, odmítnutí mimo centrum, načtení vnější pozice i odmítnutí obnovy bezprostředně po teleportu, zánik scény, menu a opakované přechody se stabilitou hranice. Obnovená pracovní mise se opravdu dokončí a udělí další XP. Snímky `test-output/training-room-{entry,lesson,exit}.png` vizuálně prohlédnuty.
- Finální Test-All: všech18 sad PASS, exit0, bez runtime chyb/varování.65/65 misí v modelu i původních formulářích,21×3 lekcí (1075 kontrol),336 výukových UI akcí,474 kontrol save,124 relací,41 fyzických kontrol,35 World3D,15 dveří,34 servisního průchodu,199 generátoru,32 UI safety a68 nastavení PASS. Log `test-output/training-test-all.log`; doplněná poslední kontrola obnovy po teleportu má samostatný headless/MCP průchod68/68. Testy výslovně vstupují do TRAINING; v rámci jedné návštěvy nadále ověřují přepínání relací, po odchodu jejich zrušení.
- Zánik UI nyní výslovně uvolní WAV a přehrávač; headless servisní test nechá zvukovému vláknu80ms skutečného času (simulační čas zde běží rychleji). Podrobný log potvrdil odstranění úniku AudioStreamWAV/Playback. Test-All vypíše kompletní výstup selhávající sady a odmítá také runtime varování.
- Windows EXE+PCK v `build/` aktualizované; stejná sada A–H ověřuje balíček externím izolovaným skriptem, log `test-output/training-package.log`. Dokumentace je přibalená. Všechny běhy používají `SaveManager.path_override` a vlastní config, hráčův save nebyl použit.

## Výrazná vizuální úprava serverovny a akademie — dokončeno (2026-10-24)
- Přechod na Godot4 Forward+/Vulkan,4× MSAA, lokální měkké stíny, SSAO/SSIL a SSR. Nová statická interiérová radiance doplňuje odlesky kovu; [chyba enginu ReflectionProbe #122498](https://github.com/godotengine/godot/issues/122498) se obchází bez alokace problematického atlasu. Žádné potlačování chyb v logu.
- Vlastní zaoblené ArrayMesh modely, kovové mikrodetaily z jedné256px normal mapy, perforované panely, servisní úchyty, šrouby, větráky, reálné křivky napájecích/síťových kabelů, podlahové spáry a materiály, stropní konstrukce a nástěnné panely. Prosklená stěna má skutečnou hloubku chodby s teplým světlem.
- Pracoviště mají detailní klávesnice, myši, židle a počítačové skříně.6 skutečných3D monitorů zobrazuje živá data stejného GameManager přes SubViewport (obnova2× za sekundu), původní administrační aplikace zůstávají celé funkční. LED disků jsou před novým rámečkem, aby zůstaly viditelné.
- Upraven HUD: čitelné panely, kontextová výzva uprostřed dole a zaměřovač s odezvou. Označení pracovišť je fyzicky připevněné ke stěnám. Přidané detaily nevytvářejí kolize v původních uličkách; dveře mají stále pevné panely z obou stran.
- Průběžně ověřeno: door3d15 PASS, world3d35 PASS, world_playthrough34 headless/39 GPU PASS. GPU snímky `test-output/visual-{server-room,rack-close,glass-office,door-controls,academy}.png` prohlédnuty. Opraveny také rozměry nové HUD značky a výzvy po vizuální kontrole.
- Benchmark na místní RTX5060, bez VSync: přibližně329fps v1080p a96fps ve4K při pohledu na hlavní serverovnu;282 draw calls,1501 sloučených statických instancí. Jde o měření konkrétní scény a sestavy, ne obecnou záruku FPS. Skript `tests/visual_benchmark.gd`, log/JSON v test-output.
- MCP79 objektů, konzole/save/návrat a opakované E na pevném ovladači otevřít/zavřít PASS, errors=[]. Nové EXE+PCK v build/ zvládlo34kontrolový servisní průchod i15kontrolový test dveří; exit0, čisté GPU logy. Nastavení76 GPU a ostrost8 GPU PASS. OpenGL varianta také34 PASS. Poslední kliknutí v testu se nechává doběhnout ve zvukovém vlákně před ukončením.
- Finální Test-All: všech17 sad PASS, exit0, bez runtime chyb/varování.65/65 misí v modelu i UI,21 lekcí ve všech3 režimech (1075 kontrol),336 výukových UI akcí a474 kontrol save. Log `test-output/visual-test-all.log`. Aktuální dokumentace je zkopírovaná do build/; EXE+PCK obsahují nový vizuál i opravu dveří.
- Katalogy ani původní mise/lekce nebyly měněny. Všechny běhy měly izolované save/config cesty. Spouštění zůstává F5 nebo build/ITSupportSimulator.exe. Pro další vizuální práci navazovat na WorldVisuals/Geometry/MonitorDisplay a grafické visual_capture/visual_benchmark; ovládání dveří hlídá door3d.gd.

## Oprava opakovaného ovládání dveří (2026-10-24)
- Dveře akademie mají dva pevné nástěnné ovladače: v serverovně i uvnitř akademie. Křídlo se může zasunout do stěny, ovládání zůstává přístupné přes raycast/E a nabízí otevření nebo zavření podle aktuálního stavu.
- Bezpečnostní čidlo kontroluje skutečný prostor průchodu; hráč vedle tlačítka už zavření neblokuje. Obsazený průchod ukáže vysvětlení a vstup do průchodu během zavírání dveře znovu otevře.
- Nový `tests/door3d.gd`:15 kontrol PASS (oba směry, opakované E, pevná poloha ovladačů, čidlo před zavřením i během pohybu). Test zahrnutý v Test-All. Následuje požadované výrazné vylepšení vizuálu, bez změn simulačního obsahu a katalogů.

## Přestavba do3D — dokončené etapy1–9 (2026-10-24)
- Etapy1–9 implementované, otestované a uložené v Gitu. Finální scéna `scenes/world/Game.tscn`; zachováno původních50 misí/21 lekcí a doplněno15 praktických misí. Procedurální serverovna i akademie jsou skutečné3D, administrace používá původní UI a společný model.
- Akademie má nyní také vlastní funkční fyzický switch, servisní skříň a ZFS sloty. V produkční3D hře fyzické zásahy vyžadují přístup k zařízení; pomocné nové formulářové popisy zůstávají jen v samostatném původním UI pro ověření všech akcí.
- Závěrečný audit: změna konfigurace zneplatní předchozí přejímku, odpojený PBS kabel blokuje backup/restore, odpojený uplink dovolí lokální start VM a výpadek se projeví při síťovém ověření. Start/restart HV respektuje automatické spuštění hypervisoru.
- Physical3D41 PASS; World3D35 PASS; World playthrough34 headless/39 GPU PASS. MCP77 objektů, raycast/E/Proxmox/save/návrat PASS, errors=[]. GPU nastavení76 PASS a ostrost8 PASS. EXE+PCK v build/ provedlo externí izolovaný34kontrolový průchod graficky, exit0, čistý log `test-output/3d-package.log`.
- Doplňkové regrese závěrečného auditu: identifikační značka disku se nepřenáší do nové lekce (včetně zkoušky); tlačítko Kampaň po volném tréninku obnoví běžné odemykání a XP. Porovnání proti862f8da potvrdilo shodu všech původních50 misí, jejich50 referenčních řešení i21 lekcí.
- Závěrečný Test-All: všech16 sad PASS, exit0, žádné runtime chyby ani varování.65/65 misí v modelu i UI,21 lekcí ve všech3 režimech (1075 kontrol),336 výukových UI akcí,474 kontrol save a původní regrese. Log `test-output/3d-test-all-final.log`; následné cílené testy posledních dvou oprav35/34 headless a39 GPU PASS. Hráčův save ani config nebyly použity.
- Windows EXE+PCK v `build/` jsou aktualizované, samostatně ověřené a doplněné aktuální dokumentací. Spuštění: F5 v původním projektu nebo `build/ITSupportSimulator.exe`. Menu nabízí pokračování ve3D i přímý přístup k15 novým úkolům ve volném tréninku.
- Pro další obsah navazovat na `tools/world_catalog.py` → extension_catalog/build_extension/build_content; katalogy byly ověřeny jako reprodukovatelné. Při změnách3D spouštět také world3d/physical3d/world_playthrough a grafický průchod. Známé meze: vlastní stylizované procedurální modely, připravená topologie, laboratorně zrychlený rebuild. Žádný známý blokátor hraní.

## Přestavba do 3D — etapa 1 (2026-10-24)
- Výchozí čistý commit `862f8da`; záložní Git tag `pre-3d-20261024` zachovává celou funkční 2D hru.
- Prozkoumány všechny scény a rozhraní GameManager, InfrastructureSimulator, RAIDSimulator, síť, ukládání, tutoriály a generátory obsahu. Konzole jsou Control prezentace nad společným RefCounted modelem; budou vloženy do nové 3D herní scény bez nahrazování simulátorů.
- Plán: CharacterBody3D + RayCast3D, opakovatelné interakce a procedurální prostředí, stejné konzole na monitorech, fyzické operace přes společný model, samostatná místnost akademie a 15 doplňkových misí. Původní scény i prvních24 definic zůstanou zachované.
- Godot MCP ověřil projekt 4.7.2 a vytvořil základ scény `scenes/world/Datacenter3D.tscn`. Veškeré běhy a testy budou používat SaveManager.path_override a oddělenou konfiguraci.

## Přestavba do 3D — etapy 2–3 (2026-10-24)
- Nová vstupní scéna `scenes/world/Game.tscn` integruje původní UI a stejný GameManager. Původní `scenes/main_menu/Main.tscn` a všechny konzole zůstávají funkční a samostatně testovatelné.
- CharacterBody3D: WASD, Shift, myš s omezením náklonu, kolize, RayCast3D do3,2m, E, zvýraznění cíle, baterka F. Esc pauza/citlivost/volný kurzor; Tab stavové cíle. Při práci na monitoru je chůze vypnutá, návrat zachovává formulářové koncepty.
- Skutečná procedurální serverovna, první rack/PVE-01, pracovní stůl s Proxmox konzolí a monitor VM. Vše čte společnou infrastrukturu; nevzniká kopie simulace.
- Import Godot4.7.2 bez chyb. `tests/world3d.gd`:12 kontrol PASS včetně fyzikální chůze a kolizí, skutečného raycastu a vstupu E, otevření původních formulářů, zásahu a uložení. Testovací scéna `tests/WorldMCP.tscn` nastaví obě izolované cesty ještě před vytvořením GameManager.

## Přestavba do 3D — etapy 4–5 (2026-10-24)
- Čtyři racky,6 zařízení se skutečnými ID, NAS s8 sloty,2 ZFS sloty, SW-CORE s12 fyzickými porty, napájecí a síťové konektory, servisní skříň,2 počítače, monitoring VM/polí/kapacity. Vlastní sdílené procedurální modely, kovové materiály, perforace, kabelové žlaby, ventilátory a chlazení.
- Nové PhysicalOperations mění společný model: bezpečné napájení, kabely/obsazenost portů, kontrola identity/backup/hot-swap, vytažení, nošení a vložení kompatibilního disku. Vytažení zdravých členů opravdu snižuje redundanci či vyřadí pole. Náhrada používá StorageOperations.replace_disk a původní RAIDSimulator/rebuild, včetně uložených50/100% kroků.
- Síťové sondy a start VM respektují fyzické připojení a dostupnost NAS. LED zařízení i jednotlivých disků se synchronizují; prázdné sloty mají změněnou geometrii. Konektor lze odnést ke konkrétnímu portu switche.
- Stav fyzických zařízení, inventář, rozpracovaná výměna a poloha hráče jsou součástí každé uložené relace. SaveValidator kontroluje jejich strukturu/ID/rozsahy. Starší save získává výchozí hodnoty bez změny schématu2. Generátor `tools/world_catalog.py` je zapojený do build_extension/extension_catalog.
- `tests/physical3d.gd`:38 PASS, včetně malého/nesprávného disku, hot-swap, obnovy prázdného slotu i rebuild po restartu, skutečného selhání RAID10, síťového výpadku a oddělení všech3 režimů lekcí od kampaně. `tests/world3d.gd`:12 PASS. Grafický start/GPU a MCP ověřeny na první etapě; zaznamenané nepoužité destination už má návaznost a bude směrovat do akademie.

## Přestavba do 3D — etapa 6 (2026-10-24)
- Připojena skutečná samostatná místnost IT Training Academy, posuvné dveře s kolizí, tři laboratorní racky, RAID stanoviště se stejnými sloty, cvičné počítače, místo pro zkoušky a virtuální instruktor. Vstup pěšky i z hlavního menu/pauzy.
- Všech21 definic lekcí a dosavadní výsledky zůstaly původní. Fyzický příchod se validuje vzdáleností hráče, E na správném serveru předává původní server_selected. Výběr uzlu a konfigurace se nadále ověřují skutečnými událostmi a stavem konzolí.
- Učím se má zlatý 3D rám, směr/vzdálenost a instrukce. Procvičování a Zkouška neukazují správný cíl; zkouška zachovává původní zákaz nápovědy. Laboratorní stanice vyžadují samostatnou výukovou relaci, takže návštěva místnosti nezačne měnit kampaň.
- `tests/world3d.gd`:31 PASS: původní FPS kontroly, zaměření dveří, otevření přes E a skutečná chůze do sousední místnosti, všechny3 režimy, validace příchodu/serveru, návrat z konzole, cílení konkrétního disku a synchronizace LED. Původní baseline Test-All doběhl bez chyb (50 misí/21×3 lekcí); log `test-output/3d-baseline.log`.

## Přestavba do 3D — etapa 7 (2026-10-24)
- Přidáno15 praktických misí51–65 v `tools/world_catalog.py`: inventář racku, identifikace LED/serial, RAID hot-swap, odpojený kabel, konkrétní switch port, VLAN v UI, vypnutý hostitel, SATA náhrada ZFS, storage obchůzka, instalace PVE, bezpečný restart, nová VM a fyzický monitoring, kapacitní incident, výpadek napájení a přejímka.
- Cíle kontrolují stav zařízení a služeb; monitoring ukládá skutečně přečtené VM a jejich stav. Přidány referenční postupy včetně administrátorských formulářů. Generování navazuje na oba původní generátory. Definice21 lekcí, legacy24 i jejich řešení zůstaly beze změny.
- Menu umožňuje přímo vybrat15 nových situací přes volný trénink a filtr3D praxe; kampaň zachovává postupné odemykání a XP. Nové fyzické testy jsou součástí Test-All.
- Campaign65/65 PASS; Save safety474 kontrol PASS včetně každého kroku všech65 misí. Physical3D38 PASS, World3D31 PASS. Kompletní Test-All dále běží do původních výukových/UI sad; průběžný log `test-output/3d-test-all.log`.

## Přestavba do 3D — etapa 8 (2026-10-24)
- Dolaďeno rozmístění svítidel, materiály, kontrastní lišty, ventilace, kabelové trasy a detaily racků. Zapnuto4× MSAA pro3D. Vlastní modely nevyžadují externí assety ani stahování.
- Statická opakovaná geometrie se seskupuje do MultiMesh podle modelu/materiálu/místnosti; odstraněno1005 samostatných instancí. Interaktivní zařízení, kolize, LED, dveře, disky a ventilátory zůstávají nezávislé. Jediné stínující směrové světlo,5 místních světel bez dynamických stínů; žádné velké textury.
- Hráč vidí nesený disk; HUD ukazuje jeho serial, kabel a neuložené změny. Citlivost se ukládá do stejné oddělené konfigurace jako obraz. HUD a servisní formuláře zachovávají oversampling i4K měřítko.
- Nový `tests/world_playthrough.gd`:31 headless /36 GPU kontrol PASS: raycast+E, fyzická kontrola, serial a potvrzení, vytažení/3D prázdný slot, skříň/náhrada/rebuild/ověření a skutečné dokončení mise53; uchopení HV kabelu, E na port3 a obnovená služba. Ověřena stěna blokující interakci a skutečné4K škálování. Test přidán do Test-All.
- GPU snímky `test-output/world-academy.png`, `world-console.png`, `world-service-4k.png`, `world-disk-removed.png` a `world3d-stage2.png` vizuálně prohlédnuty. V plné sadě zatím prošlo všech65 misí také skutečnými původními formuláři.

Datum: 2026-10-24. Nový projekt Godot 4.7.2, pracovní adresář IT_support.

## Viditelnost obsahu Nastavení po otevření (2026-10-24)
- Opravena regrese z úpravy kontejnerů: kořen stránky `draw_settings()` se v nadřazeném VBox neroztahoval na dostupnou výšku. ScrollContainer měl nulovou výšku a zobrazovala se jen hlavička. Stránka nyní používá `SIZE_EXPAND_FILL`.
- `tests/display_settings.gd` nově ověřuje skutečnou plochu a ořezání přepínače fullscreen, rozlišení a potvrzovacího tlačítka, nikoli jen existenci Control. Kontroly běží při otevření, ve všech6 rozlišeních a s upozorněním na save v720p i4K. Před opravou27 selhání, po opravě68/68 headless a76/76 GPU PASS.
- Graficky prohlédnut obsah v `test-output/settings-720p.png` a `settings-warning-3840.png`. Test zachování konceptů `ui_safety.gd`31/31 PASS; pixelový `render_quality.gd`8/8 PASS. MCP otevřel Nastavení skutečným tlačítkem a ověřil viditelnost panelu, `errors=[]`. Použity výhradně testovací save/config cesty.
- Windows EXE+PCK v `build/` přegenerovány. Samostatný balíček otevřel Nastavení tlačítkem a ověřil všechny3 viditelné ovládací prvky v720p, kód0; prohlédnut `test-output/settings-packaged.png`, log `settings-package.log` bez chyb.

## Cílené opravy ochrany postupu (2026-10-24)
- Restart je řízen typem relace přes `restart_current()`. Náhodná úloha obnoví jen svůj scénář; fronta, pozice, dosavadní výsledky i odložená kampaň zůstávají zachované. Neplatný index mise se odmítá před změnou paměti i souboru.
- Přechody používají společné odložení kampaně, lekce či série. `resume_random()` i přímé `restore_session()` nejprve zachovají aktuální relaci. Opakovaný návrat do již aktivní kampaně ji nerestartuje.
- Undo se čistí při startu, obnovení a změně režimu. Prázdné undo je v UI neaktivní. Historie se mezi misemi a relacemi nepřenáší.
- `apply()` a `complete()` rozlišují úspěch zásahu (`ok`) a zápisu (`saved`, `save_error`). Ostatní operace zveřejňují společný stav ukládání. Trvalé upozornění s opakováním zápisu funguje i v menu; návrat s uložením a ukončení při chybě nepokračují.
- Nový `SaveValidator.gd` kontroluje větve, typy, ID, skóre, kroky lekcí, indexy série a shodu scénáře s frontou. Zachována schema1/schema2 včetně starších desetinných klíčů lekcí a skóre. Platné uložené relace mají cache s kontrolou hluboké shody; autosave zbytečně znovu neprochází celé archivované lekce.
- Vadný save se nenačte ani automaticky nepřepíše. Výslovné tlačítko obnovy nejprve zachová původní bajty v `.invalid-*.bak`. Zápis kontroluje chybu po flush i znovunačtený dočasný soubor, ponechává `.last-good.bak` a při selhání nahrazení zkouší obnovit původní soubor. Migrační `.v1.bak` zůstává zachovaná.
- Hyper-V odmítá jméno síťového objektu jiné platformy, konkrétně `vmbr0`; síť a VM zůstávají při odmítnutí beze změny.
- Koncepty formulářů jsou oddělené podle relace, konzole, hostitele, VM a akce. Zvuk, rozlišení a F11 zachovají text, nepotvrzená čísla, nabídky, checkboxy a disky; zachované číslo se při odeslání použije. Zahrnut i rozepsaný terminál a nastavení série. Potvrzený formulář a nová/obnovená relace koncept vyčistí.
- UI má výrazné a srozumitelné hlášení ukládání, bezpečnou obnovu a posuvné menu při chybě načtení. Zachovány oversampling písma, DPITexture ikony, měřítko i původní vzhled.
- Nové standardní regrese: `session_safety.gd` 112 kontrol PASS, `save_safety.gd` 387 PASS, `ui_safety.gd` 31 PASS headless i graficky. Test-All je obsahuje; původní testy misí/lekcí nyní ověřují také úspěšné ukládání.
- Graficky: `display_settings.gd` 49 PASS; `render_quality.gd` 8 PASS, SVG ve4K skutečně38×38px. Prohlédnuty snímky výukové RAM6144 v720p/4K, chyby zápisu i vadného save v menu. MCP spustil izolovanou testovací scénu a vrátil `errors=[]`.
- Úplný závěrečný `tools/Test-All.ps1` PASS, kód0, všech13 sad bez runtime chyb a varování:50/50 misí v modelu i UI,21×3 lekcí (1075 kontrol),336 výukových UI akcí,199 kontrol generátoru,88+35 původních regresí,112+387+31 nových kontrol a41 kontrol nastavení headless. Závěrečný log: `test-output/fixes-test-all-final.log`.
- Windows balíček v `build/` přegenerován. Samostatné EXE+PCK přes externí izolovaný ověřovací skript graficky spustilo konzoli, sérii, restart a návrat ke kampani; uložená VLAN39 zachována, kód0, čistý log. Prohlédnut i snímek balíčku. Build a jeho ověřovací logy jsou v `test-output/fixes-build.log` a `fixes-package-engine.log`.
- Všechny testy používají `SaveManager.path_override`; grafické testy a MCP i vlastní cestu nastavení. Hráčův save ani jeho nastavení nebyly zapisovány. Žádné změny katalogů ani generátorů; prvních24 definic a legacy soubory zůstávají původní.
- Meze: koncepty a undo se neukládají přes restart aplikace. Vadná data se automaticky neopravují; obnova s novým postupem vyžaduje výslovné tlačítko a zálohu. Selhání zápisu je reprodukované skutečnou překážkou v testovací cestě, nikoli zaplněním hráčova disku.

## Ostrá grafika a textury ve4K (dokončeno)
- Opravena příčina rozmazání: framebuffer již měl4K, ale transformace Control zvětšovala malý fontový atlas. Na kořeni UIController je nyní zapnutý oversampling_with_scale; glyphy se rasterizují podle skutečné velikosti na obrazovce včetně racků a samostatného systémového fontu terminálu.
- Nový scripts/ui/VectorIcons.gd dodává škálovatelné SVG/DPITexture ikony pro přepínače, checkboxy, seznamy, SpinBox, Tree a PopupMenu. Nahrazují drobné bitmapové ikony výchozího tématu. Detaily racků mají vyhlazené hrany.
- Poměr16:9, rozlišení1280×720 až3840×2160, fullscreen/F11, save i mise jsou zachovány. Běžná grafika panelů a racků se kreslí z vektorů přímo do cílového rozlišení.
- Nový tests/render_quality.gd testuje skutečné pixely přes GPU: menu/rack/terminál mají oproti zvětšenému atlasu více než dvojnásobný ukazatel kontrastu hran;16px SVG má ve4K vlastní38×38px texturu.8 kontrol PASS. Test vyžaduje grafický renderer, bez --headless; volitelně -- --screenshots.
- Grafický tests/display_settings.gd:49 kontrol PASS; první9kroková lekce tutorial_first PASS. Testy používají oddělené save a config soubory.
- tests/ui_smoke.gd znovu dokončil všech50 misí přes skutečné formuláře a potvrzovací dialogy bez chyb. Aktualizovaný Windows balíček v build/ spuštěn bez editoru: kód0, bez chyb v logu. Godot MCP spuštění a debug errors=[].
- Soubory: UIController.gd, RackView.gd, nový VectorIcons.gd a render_quality.gd, README.md a TEST_REPORT.md. Pro pokračování používat původní projekt, zachovat fontové oversampling a DPITexture; nepřevádět UI na malé rastrové obrázky.

## Nastavení obrazu a ukončení (dokončeno)
- Hlavní menu má tlačítka Nastavení a Ukončit hru. Ukončení i zavření okna nejdříve ukládá rozehraný stav; při chybě uložení zůstává hra otevřená.
- Nastavení: celá obrazovka / okno, F11 a šest rozlišení16:9 od1280×720 do3840×2160 (4K UHD). Volby v samostatném user://display_settings.cfg; hráčův save se nemigruje.
- Viewport skutečně renderuje zvolené rozlišení i ve fullscreen; rozhraní škáluje z1600×900. Okno se na menším monitoru přizpůsobí pracovní ploše.
- Opraveno škálování TutorialOverlay a automatické posouvání ke zvýrazněnému poli. Změna rozlišení zachovává stav mise i lekce.
- Soubory: scripts/core/DisplaySettings.gd, scripts/ui/UIController.gd, scripts/training/TutorialOverlay.gd, project.godot, tests/display_settings.gd, tools/Test-All.ps1, README.md a TEST_REPORT.md.
- Testy: grafický display_settings49 kontrol PASS (všech6 skutečných GPU rozlišení, fullscreen/okno/F11, uložené volby, 4K výukový cíl a skutečné ukončení tlačítkem); headless41 kontrol PASS. tutorial_first PASS a regression88/88 PASS.
- Vizuálně ověřeno menu, nastavení a výukový rámeček ve4K. Testy používají oddělené save/config soubory a nemění hráčovy volby.
- Windows balíček v build/ přegenerován; grafické spuštění EXE bez editoru skončilo s kódem0 bez chyb. Finální start přes Godot MCP má prázdný seznam errors.
- Pokračování: funkce jsou hotové; při dalších změnách obrazu spustit tests/display_settings.gd graficky i headless. Nový test je součástí Test-All.ps1.

## Rozšíření — Tréninkové centrum (dokončeno)
- Výchozí checkpoint:57aa41f; původní24 definice a referenční řešení zmrazeny v legacy_campaign.json / legacy_solutions.json.
- Přidána samostatná scéna centra, TutorialManager/Validator/Overlay a první9kroková lekce vytvoření WEB01.
- Průvodce ukládá skutečnou VM101 postupně: identita, ISO, CPU/RAM, disk, síť, instalace, start a ověření.
- Zvýraznění/šipka, registr UI prvků, přechody rack→uzel→formuláře, obnova cílového panelu.
- Režimy learn/practice/exam; zkouška blokuje nápovědu. Kampaň je odložená zvlášť, kroky i stav lekce jsou uložené.
- Save schema2 přijímá schema1 a před prvním přepisem vytváří zálohu.v1.bak. Číselná ID jsou normalizovaná, aby JSON1002.0 nevytvářelo jiné klíče pokroku.
- Klíčové soubory: scripts/training/*, scripts/simulation/EducationOperations.gd, tools/build_extension.py, data/training/lessons.json, tests/tutorial_first.gd, GameManager.gd, UIController.gd, SaveManager.gd.
- Katalog nyní obsahuje50 misí a21 lekcí (18 povinných + quorum/HA, iSCSI/MPIO a bezpečnost). Původních24 definic zůstává přesně shodných s legacy snapshotem.
- tests/campaign.gd:48/48 PASS. tests/lessons.gd: prvních18 lekcí ve všech3 režimech,838 kontrol PASS;2 bonusové lekce čekají na ověření.
- tests/training_ui.gd: prvních18 vedených lekcí přes101 skutečných formulářových akcí PASS.
- Generátor mění VMID/CPU/RAM/disk/storage, síťové chyby i RAID parametry; scénář vždy nejdřív přehraje v izolovaném modelu a ověří cíle.142 kontrol,71 různých konfigurací PASS.
- Přidány kategorie centra,3 režimy, Moje IT znalosti, doporučení, poslední zkoušky, slovník15 termínů a uložení náhodné série.
- Nové operace zahrnují offline převodHyper-V→PVE, správnou novou Gen2 konfiguraci, CT bind data, boot/ovladače, VSS/AVHDX, bezpečný RAW postup, cache a SAN.
- Ověřeno všech48 základních misí přes UI a20 lekcí ve všech3 režimech přes327 akcí v1280×720. Aktuálně přidány2 bonusové mise49/50 a bezpečnostní lekce1021;50/50 misí prochází stavovým testem.
- Přibylo ověření všech28 kombinací oblasti/obtížnosti, zachování samostatného stavu série a doporučení síťové lekce po chybách VLAN. tests/training_features.gd:199 kontrol PASS.
- README.md aktualizováno; TRAINING.md dokumentuje všechny21 lekce, datový formát kroků, migraci save a generátor.
- Poslední kompletní Test-All.ps1 prošel:50/50 misí v modelu i UI,21 lekcí ve všech3 režimech (949 kontrol),336 výukových UI akcí,199 kontrol generátoru/save,88+35 původních regresí. Vše bez runtime chyb.
- Generátor byl ověřen na77 různých konfiguracích a všech28 kombinacích oblasti/obtížnosti. Návrat ze série/lekce zachovává odloženou kampaň.
- Vizuálně zkontrolováno centrum, profil i skutečné zvýraznění RAM v1280×720; zkouška bez zvýraznění a nápovědy.
- README.md, TRAINING.md a TEST_REPORT.md obsahují aktuální ovládání, rozšiřování, testy a meze simulace.
- Windows PCK byl přebalen s50 misemi a21 lekcemi; samostatné EXE spuštěno bez editoru, exit code0 a prázdný chybový log. Balíček zahrnuje README, TRAINING a TEST_REPORT.
- Rozšíření je funkční; nezbývá známý herní blokátor. MCP umí scénu vytvořit a start vyvolat, ale jeho procesní monitor v tomto prostředí po startu neudržuje aktivní proces. Grafický start i úplné testy jsou navíc ověřené přímo Godotem.
- Při dalším vývoji navazovat na tools/build_extension.py + extension_catalog.py a EducationOperations.gd. Původních24 misí neměnit; jejich shodu hlídá campaign.gd. Testovat přes tools/Test-All.ps1, testovací save musí zůstat oddělené.

## Zdroje a nástroje
- Godot MCP ověřen: 4.7.2.stable.official.ed1daf0bf; create_scene, add_node, run_project, get_debug_output, stop_project.
- Všechny čtyři Notion stránky načteny; úplné lokální kopie v data/knowledge/notion_*.md.
- Skripty a data se upravují soubory, scény a běh se průběžně ověřují přes MCP.

## Hotovo a ověřeno — etapa 1
- Menu, stylizovaná klikací serverovna, ticket s cíli a stavové konzole.
- Oddělený model infrastruktury, bezpečná validace a ukládání do user://.
- Mise 1: firmware, HBA, UPS, konzole, management síť, diagnostika a ověření.
- Godot headless import bez chyb; tests/stage1.gd PASS včetně odmítnutí nesprávného postupu.
- Projekt spuštěn přes Godot MCP; čtení debug výstupu.

## Hotovo a ověřeno — etapa 3
- 88 regresních kontrol cílů/RAID/sítě/terminálu/bezpečnosti/save/load/XP a 35 dalších kontrol: celkem123 PASS.
- 24 misí znovu přes UI včetně24 dobrovolných kontextových otázek, všechny PASS.
- Vizuální průchod skutečně renderovaným menu, konzolemi, serverovnou a mapou při1440×900 i1280×720.
- Opravena chyba exkluzivních oken při přechodu z otázky do vysvětlení; opakovaný průchod bez runtime chyb.
- 50 článků Akademie z úplných zdrojů, dynamický výběr vlastních VMID/switchů a strom hostitelů/VM.
- Přidána Replica, všechny tři VHDX alokace, příprava datového disku uvnitř VM, skutečné chování kvót a automatický hot spare.
- README.md popisuje ovládání, architekturu, přidání mise, testy, sestavení a konkrétní limity simulace.
- Windows: exportní šablony nejsou nainstalované. Funkční přenosný balíček tvoří plný místní engine + PCK v build/; spuštění bez editoru ověřeno.

## Závěrečné ověření
- Poslední kompletní Test-All.ps1: první etapa PASS, všech24 misí PASS, 88 regresí PASS, 35 rozšířených kontrol PASS a všech24 misí + otázek přes UI PASS; bez runtime chyb.
- ObjectiveEvaluator používá bezpečné typové porovnání; počáteční Array proti cílovému String už nezpůsobí pád. Pět nových regresních kontrol ověřeno.
- Finální Windows PCK přegenerován; build/ITSupportSimulator.exe spuštěn samostatně bez editoru, exit code0, bez chyb v logu.
- Projekt znovu spuštěn přes Godot MCP. Git diff --check bez chyb.
- Vývojová pozice z první etapy byla rozpoznána a archivována jako academy_development_stage1.json; žádný test nepřepisuje hráčův postup.

## Hotovo a ověřeno — etapa 2
- 24 konkrétních datových misí (8 Proxmox, 8 Hyper-V, 8 storage).
- Sdílené konfigurace VM, síť L2/IP/DNS/aplikace, PBS backup/restore, QDevice/fencing/HA.
- Hyper-V role, VMMS, tři typy switchů, Gen2, Dynamic Memory, VHDX/guest FS, checkpoint/merge, migrace.
- Fyzické sloty/serial, výběr členů RAID, kapacity RAID0/1/5/6/10, ZFS/Spaces, rebuild, Disk Management, SMB/FSRM a iSCSI/MPIO.
- Bezpečný parser Linux/PowerShell příkazů, 50 článků z úplných Notion příruček, statistiky, XP, trénink a undo.
- tests/campaign.gd: všech 24 misí PASS; tests/ui_smoke.gd: všech 24 misí přes formuláře a dialogy PASS.
- Testy UI ukládají do odděleného academy_test_ui.json, ne do hráčovy pozice.

## Zbývá
- Žádná blokující práce pro hraní24 misí. Omezení a náměty dalšího rozšíření jsou uvedené níže a v README.

## Možné další rozšíření (není součást hotového laboratorního modelu)
- Kompletní konfigurační průvodci Ceph, Failover Cluster/CSV a převod VM mezi platformami.
- Plná kalendářová historie PBS chunků/retence a periodické síťové přenosy Replica.
- Libovolná topologie serverovny a obecný síťový zásobník; nyní jsou podsítě a hostitelé záměrně pevní.
- Standardní Windows template export a instalátor; přenosné EXE nyní používá plný181MB engine.

## Pokračování
Nejdřív přečíst tento soubor, README a existující skripty. Nevytvářet projekt znovu.
