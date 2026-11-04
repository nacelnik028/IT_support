# Ověření rozšířené hratelné verze

## Ukládání, směny a poslech — původní zadání dokončeno 4. 11. 2026

- Celý aktuální Test-All **46 sad PASS**, 46 startů enginu, exit 0, bez runtime chyb/varování. Nové sady: work_persistence 69, shift_scoring 31, advanced_shifts 268, attempt_review 49, london_listening 515, unified_profile 38 a continuation_review 200 headless. Kampaň/legacy24, staré save a jediné odměny zachované; save_safety 474, lekce 1075, UI všech 65 misí a 336 výukových akcí ve všech třech režimech PASS.
- PC/VR grafická matice: **298 PASS Compatibility / 298 PASS Forward+**, 196 aktuálních PNG. Šest PC kombinací, skutečný VR 1600×1200, text 100/130 %, panel 80/140 % a 0,9/2 m, obě ruce, trigger/scroll/drag/klávesnice, focus/tracking. MCP 31 PASS; osm původních statických varování odděleně, bez nových.
- Windows **27 externích sad + dva nativní smoke běhy PASS**. Přejmenovaný samotný EXE z cizí složky, bez projektu/PCK/editoru. APK: podpis/původní certifikát/CRC/ARM64 OpenXR/1.5.0 code 6 PASS, **20 externích sad + dva desktopové smoke běhy PASS** nad skutečnými APK prostředky. Dalších deset cílených sad pro každý přesný balíček PASS. Obsah: Windows 5616 kontrol / 282 souborů, APK 5563 / 286; 277 materiálů, skutečné audio a JSON hodnoty shodné.
- EXE **104,453,712 B**, rezerva **403,888 B** pod 100 MiB; SHA256 `3186142a681c55386ba0669751c6466fbdffd73f5d422aac725e460e6ccccf26`. APK **90,829,077 B**; SHA256 `b97c5a8d15fcf1d074d2eeac235afbe5980e71dd7e8e6ef3060ee77cd0c6bdf4`.
- Zdrojový commit `a43cd6d`, shodný manifest 269 zdrojů `db723a77ce1a7a7c7da99e5857850850a101a773f34ee083bdd6d0fccb2e573c`. [Přesná metadata](build/VERIFICATION.json), [aktuální snímky a trvalé logy](docs/ui-review/2026-11-04-release-base/README.md), [ovládání](docs/CONTINUATION_RELEASE.md).
- **PICO hardware NEPROVEDENO – headset není dostupný.** Android native start, stereo, tracking/ovladače, optika, komfort, FPS a paměť nejsou těmito testy potvrzené. Subjektivní lidský poslech neprovedený; hash/dekódování/PCM/skutečný přehrávač ano. Bez ADB a bez push.

Tato fáze uzavírá původní prompt. Uživatelské doplnění verze v nastavení následuje až potom; jeho nové exporty budou mít vlastní ověření. Starší sekce níže jsou historické.

## Gameplay PC/PICO bez headsetu — 3. 11. 2026

Implementováno a ověřeno na PC a synteticky v XR; přímý test na PICO 4 čeká
na dostupný headset. Tato sekce nahrazuje aktuální distribuční údaje níže;
starší sekce zachovávají historické výsledky.

- Herní implementace: `f6b05d8`, `cda0a5f`, `8e931aa`. Oba exporty používají
  stejných 240 zdrojových souborů; přesné hashe jsou v obou BUILD_INFO.json.
  Společný deterministický manifest SHA256:
  `77a19d821a39954afe9f657aaf7c5776af5cdaaf5e954b30552b70a4a5c6a8fe`.
- Celý tools/Test-All.ps1: **39 sad PASS**, bez runtime chyb/varování.
  `test-output/gameplay-test-all-final.log`; úplný závěrečný opakovaný běh
  s doplněnými negativními kontrolami: `test-output/gameplay-release-test-all.log`.
- Nové sady: shifts **136**, gameplay **212**, gameplay_review **77 headless /
  129 GPU**. XR **116 headless i GPU Compatibility** včetně dragu a posuvu
  po změně rozměrů/vzdálenosti panelu. PC praktický průchod gameplay **212 GPU PASS**.
  Všechny cíle vznikají skutečnými operacemi, pohybem/fyzikou a úplnými kliky.
- Zachováno 65 misí v modelu i formulářích, legacy24, 21 lekcí ve všech třech
  režimech a 336 výukových UI akcí. Save safety 474, session safety 124,
  ui_workflow 579, ui_design 162 a world_ui 31 PASS. Přegenerování build_content
  i build_shifts nemění bajty žádného katalogu; legacy_campaign zůstal shodný.
- Směny: všech devět ticketů od začátku do konce, alternativní pořadí oprav,
  aktuální ověření, odmítnutí starého triggeru/dvojí odměny, nové vytvoření
  GameManageru včetně neseného disku a odstraněného serialu, restart, import/export,
  vadná ID/verze/index/výsledky/inventář a selhání zápisu s opakováním bez dvojí XP.
  Opakované přechody směna/hub/IT ve všech režimech/programování/Londýn/kampaň PASS.
- Úvod: skutečné PC vstupy a kolize, syntetický head pose/teleport/obě ruce,
  správný ovladač dveří, průchod, správný monitor a UI kontrola, grip SPARE-2T,
  vrácení a pauza. Nesprávný cíl, zavření/znovuotevření monitoru, zrušení,
  přeskočení, opakování a obnovení upravené kampaně/směny PASS. Bez XP.
- Síť: kabel/port, VLAN a IP/brána čtou stejný NetworkSimulator; neověřené úseky,
  skutečný hostitel, před/po, oprava/undo a skrytí příčiny ve zkoušce PASS.
- Řeč: **12 různých přesných replik + 12 samostatných pomalých variant**,
  188 544 B MP3. Import, délka, nenulové PCM vzorky, SHA256 skutečných MP3 dat,
  přesný text/mluvčí/situace, opakování, nezměněný pitch 1.0, delší pomalá syntéza,
  Master mute/hlasitost a stop při pauze/focus/změně relace PASS. Přehrávání
  AudioStreamPlayer bylo skutečně spuštěno. **Subjektivní poslech člověka se
  tím neprohlašuje za provedený**; nepokryté věty zůstávají textové.
- Grafická matice: Windows / RTX 5060, Compatibility i Forward+, 720p/1080p/4K
  × 100/130 %. 104 trvalých PNG v [datované složce](docs/ui-review/2026-11-03-gameplay/README.md),
  včetně skutečného VR SubViewportu 1600×1200 s klávesnicí i bez ní. Vizuálně
  prohlédnuté rozložení a reprezentativní původní snímky; podpis zachován.
  Godot MCP / tests/DesignMCP.tscn: 31 PASS; osm dříve popsaných statických
  varování o typech/stínění, žádná runtime chyba. Varování nebyla potlačena.

**Skutečné balíčky:**

- Windows EXE: **104 826 336 B**, rezerva **31 264 B** do 100 MiB.
  SHA256 `e194ae3ef1f8b95e5665bc746efd3fb5c6ceb9e348971925634c70f85df1ac1c`.
  Samotný přejmenovaný EXE mimo projekt, bez PCK/editoru: nativní headless/GPU
  smoke PASS. Dalších 20 externích sad nad přesně zabalenými daty PASS;
  obsah 5425 kontrol / 253 souborů / 278 materiálů. Následně rozšířené
  shifts 136, gameplay 212 a XR 116 znovu PASS proti tomuto přesnému EXE.
- PICO APK: **90 743 347 B**, **1.4.0 / versionCode 5**.
  SHA256 `8d9a39fd8f13ff9d8b3888778f6f707eb0c827cd12e3a8883263b467195aacaf`.
  Podpis, CRC, ARM64 a skutečný PICO/OpenXR manifest PASS. Původní certifikát
  SHA256 `3449ce02012b69d3d0b9d19eea1706521e290fac48ab7ff1d5d20bea8c003997` zachován.
  Dva desktopové smoke běhy a 13 externích sad nad skutečnými prostředky APK PASS;
  obsah 5372 kontrol / 257 souborů. Dodatečně shifts 136 / gameplay 212 / XR 116 PASS.
  **To není Android native start ani test nativních Android knihoven na zařízení.**
- Všechny JSON hodnoty odpovídají zdrojům. Testovací save, pracovní složky,
  model TTS ani WAV nejsou v distribuci. Testy nastavují SaveManager.path_override
  a oddělené DisplaySettings/VRSettings před GameManagerem. Hráčův save se nepoužil.
  Výsledky balíčků: `test-output/windows-package/results.json`,
  `test-output/pico-package/results.json`, `test-output/gameplay-packages-final/results.json`.
  Aktuální přehled: [VERIFICATION.json](build/VERIFICATION.json).

Vývojové běhy zachytily a opravily posuv posledního tlačítka pauzy kvůli zaokrouhlení,
přetékání Překladu/Nápovědy po přidání automatiky audia a znovuotevření cvičného
monitoru. První APK ověřovač ještě očekával verzi 1.3.0; nyní čte preset a hlídá
původní certifikát. Závěrečné běhy jsou čisté. Po doplnění manifestu zdrojů byl
EXE znovu sestaven a všechny jeho sady zopakovány proti novému SHA256.

**NEPROVEDENO – headset není dostupný:** instalace/Android start, stereo,
fyzický tracking, optická čitelnost, komfort, FPS a paměť na PICO.
Žádné ADB zařízení nebylo pro tuto etapu dotazováno ani změněno.
Konkrétní pozdější kroky jsou v [hardwarovém checklistu](docs/PICO4_HARDWARE_CHECKLIST.md).
Herní funkce a oba exporty jsou dokončené; hardwarové ověření zůstává otevřené.
Git push nebyl proveden.

## Rozcestník, dekorace všech místností a B1–B2 — 3. 11. 2026

Aktuální etapa plní PROMPT_ACADEMY_HUB_PC_VR.md a doplňující požadavky na
dekorace. Herní zdroje exportů jsou `0cb87a31baace36a34b7f686e1e36f95d0df5d51`.
Následující starší sekce zachycují předchozí vydání, nikoli omezení této etapy.

- **Celá aktuální tools/Test-All.ps1: 36 sad PASS**, čistý závěrečný log
  `test-output/hub-release-test-all.log`. Všech 65 misí, původních 24 definic,
  21 lekcí ve třech režimech, náhodné série i programování zůstávají funkční.
- **academy_hub 52 PASS**: skutečné WASD do všech čtyř místností a zpět,
  neutrální vstup z menu, odložená upravená infrastruktura/ticket/postup,
  všechny IT režimy, programovací koncept a náhled, rušení nákupu, restart,
  staré pozice, nové podlahy a skutečný teleportovací oblouk proti dveřím.
- **english_model 1809 PASS**: všech 54 kombinací situace/režimu/varianty,
  devět skutečných zákaznických dotazů, ověření porozumění, rozpočty a časy,
  Standard/Flex, přepočet změněného košíku, chybný součet, jediná platba,
  platný lístek, omezení místem a pravdivé selhání zápisu s opakováním.
- **london_quiz 527 PASS**: 20 stabilních ID, ručně určené očekávané odpovědi,
  všechny režimy, promíchání sémantických ID, opravy bez navýšení prvního skóre,
  dokončení/rušení, historie, restart, neplatný save a archiv původních výsledků.
- **english_world 1043 headless / 1063 GPU PASS**: všech šest situací a všech
  20 otázek přes skutečné PC vstupy a oba syntetické XR paprsky do SubViewportu,
  stisk/uvolnění, současné paprsky a ochrana před duplicitním vstupem. Matice
  720p/1080p/4K × 100/130 % textu zahrnuje dialog, zákaznický dotaz a kvíz.
  `hub-english-graphical.log`; hardwarový tracking tím není ověřený.
- **Materiály GPU Compatibility i Forward+ PASS**: 49 snímků v každém rendereru,
  všech pět prostorů, detaily, obě strany a stavy dveří, stejná matice rozlišení.
  Každý profil: 280 materiálových instancí, 0 chybějících přiřazení,
  27 strukturálních stěn, 0 koplanárních překryvů. Prohlídka snímků a příčiny
  oprav v `docs/MATERIAL_AUDIT.md`; výběr před/po pod `docs/ui-review/2026-11-02-hub/`.

Testy používají vlastní SaveManager.path_override i samostatné konfigurace před
GameManagerem. Nové sady mají PID v názvu, staré sady běží sekvenčně.
Hráčův academy_save.json se nepoužívá. Původní IT katalogy a jejich generátory
se nemění; schéma save 2 přijímá staré soubory i nové samostatné větve.

Původní selhání této etapy se nezamlčují. První průchod hubu odhalil starou
migraci severní pozice aplikovanou také na nový práh; hranice byla opravena a
hub znovu prošel. První plná regrese se zastavila na očekávání přesunu dříve
uzavřeného prahu programovací učebny; nyní otevřená bezpečná pozice se zachovává,
test stále kontroluje skutečně neplatnou starou polohu i shodu XP/výsledků.
První porovnání archivu v testu bylo citlivé na JSON int/float; srovnávají se
normalizované hodnoty na obou stranách. Grafická prohlídka odhalila chybný
nadpis režimu po znovuotevření dialogu; pořadí inicializace opraveno a přidáno
šest kontrol. Ztrátu nativního fokusu snímkovací helper řeší obnovením pouze
izolované testovací relace; bezpečné pauzování hry zůstává funkční.

Finální distribuční ověření této etapy:

- **Samostatné EXE 104 579 568 B**, rezerva **278 032 B** do 100 MiB,
  SHA256 `96510e62937792be20d8977936a8ab907f6b0444ad7f875921bfb2c38e208562`.
  Nativní headless i GPU start v izolované složce bez editoru a sousedního PCK
  PASS. Smoke dokončí 6 situací, kvíz 20/20, trénink, Python/Web i návrat.
  **17 externích sad nad přesným packem nakonec PASS**; Londýn GPU 1063,
  umístění učebny GPU 117, terminál 64 a fyzický průchod 39. Závěrečné výsledky
  a cílené opakování jsou v `windows-package/results.json`.
- **Podepsané APK 90 508 612 B**, verze **1.3.0 / versionCode 4**,
  SHA256 `aefaddcb03b5c4f246344136bac18cb838c5f6ff9866468c1166eadb93bc5940`.
  Podpis v2, CRC, ARM64/OpenXR/PICO manifest PASS; identifikátor i certifikát
  souhlasí s předchozím APK. Skutečné prostředky z APK: **oba desktopové smoke
  běhy a všech 10 externích sad PASS**, Londýn 1043, model 1809, kvíz 527,
  hub 52, UI 363, učebna 114, programování 765, XR 69 a terminál 64.
  Otisky aktuálních zdrojů i katalogů odpovídají. `pico-package/results.json`.
- **Obsah a materiály skutečných balíčků**: 188 souborů Windows / 192 APK,
  žádné build/builds/tests/tools/test-output/docs uvnitř. Každý zabalený JSON
  souhlasí hodnotami s referencí; Windows kompaktuje jen mezery v izolované
  exportní kopii. Dodatečný GPU audit přesného packu: **5033 / 5057 kontrol
  PASS**, v obou 278 materiálů po prvním vytvoření světa, platné shadery se
  shodným kódem a dostupné vygenerované normálové textury. Prohlídka zdrojového
  světa má po interakcích 280 instancí včetně dočasných materiálů zvýraznění.
  `windows-package/package_content-final-graphical.log` a protějšek v pico-package.
- **Fyzické PICO NEPROVEDENO**: nové `adb devices -l` bez autorizovaného
  headsetu. Android knihovny nebyly spuštěny na zařízení, tracking, komfort,
  optická čitelnost a FPS se neprohlašují za ověřené. Žádný telefon se neměnil.

První balíčkový audit Windows ukončil vytvořený svět během asynchronního GL
nahrávání textur: 1147 věcných kontrol prošlo, ale dva texture-leak ERROR při
ukončení správně označily běh za nečistý. Test nyní čeká na nahrání a odložené
uvolnění prostředků; stejný EXE prošel cíleným opakováním i rozšířeným auditem.
Herní zdroje ani obsah exportu se kvůli tomu neměnily. První report je zachovaný
v `windows-package/results-initial.json` a selhání v manifestu. Diagnostický
opakovaný běh z adresáře projektu narazil na editorovou vendor konfiguraci;
konečné opakování běželo opět izolovaně mimo projekt a bez varování.

Aktuální `build/VERIFICATION.json`, oba BUILD_INFO a SHA256SUMS odkazují jen na
tyto dva současné artefakty. `build/` zůstává zachováno; `builds/` nevzniklo.
Předchozí výsledky níže jsou historické. Následující tehdejší plán hubu,
vizuálního auditu a B1–B2 je touto etapou splněný.

## English in London — dokončeno 2. 11. 2026, nativní Windows

Čtvrtý fyzický pavilon navazuje jižním průchodem 04 na serverovnu. Obsahuje
procedurální London Eye a Elizabeth Tower, Temži a most, Sama, Alexe, skutečný
košík, cvičný terminál, vstupenku s ID a kontrolní závoru. LON01–LON06 mají tři
režimy a tři varianty; rodina mění také počty dospělých/dětí a součty. Výsledky
jsou oddělené od kampaně. IT mise, lekce a legacy24 se nemění.

| Co bylo skutečně spuštěno | Výsledek a omezení |
|---|---|
| Aktuální Test-All.ps1 nad herními zdroji | **34 sad PASS**, exit 0, bez ERROR/SCRIPT ERROR/WARNING; `test-output/london-test-all.log`. Zahrnuje všech 65 misí, 21×3 lekcí i nový Londýn. |
| Anglický model | **988 kontrol PASS**, všech 54 kombinací šesti situací, tří režimů a tří variant; negativní platby, rozpočet, změna košíku, součty, nejbližší dostupný čas, duplicitní vstup, lístek, směry, save a selhání zápisu. |
| PC + syntetické XR ve zdrojích | **409 headless / 417 GPU kontrol PASS**. Skutečné WASD/E, myš, Enter, šipky, čísla a Esc; všechny situace přes UI a oba XR ovladače přes skutečný ray klik do SubViewport. Nejde o fyzický tracking. |
| Grafická matice Londýna | 720p / 1080p / 4K × 100/130 % textu, bez ořezu akcí. Prohlédnuté snímky v `docs/ui-review/2026-11-02-london/`; GPU Compatibility, NVIDIA RTX 5060. |
| Samostatné Windows EXE | Native headless i GPU start z izolované složky, bez editoru a sousedního PCK. Smoke dokončí všech šest situací včetně platby a světového cíle a odchodu. PE / vložený PCK a limit 100 MiB PASS. |
| Přesný zabalený Windows projekt | Všech 14 sad a oba nativní starty nakonec PASS. Londýn 988/417, UI 363, programování 31/1071/63/765/27, umístění učebny 120 včetně pauz a skutečných kliknutí Pokračovat, XR 69, terminál 64, UI design 162, world_ui 31 a průchod 39. První selhané běhy zůstávají zaznamenané odděleně; viz níže. |
| Skutečný obsah obou balíčků | Anglický katalog a nové rodinné počty ověřeny uvnitř; žádné adresáře build/builds/tests/tools/test-output v zabalených prostředcích. Windows `london-windows-pack-content.log`, APK kontrola skutečného ZIPu. |
| PICO APK sestavení | Podepsané Debug ARM64, 1.2.0 / versionCode 3, původní cz.academy.itsupport a podpis. Podpis, CRC, min/target SDK 29/34 a OpenXR/PICO manifest PASS. |
| Prostředky přímo z APK v desktopovém Godotu | Headless i GPU smoke PASS; model 988, svět/PC a syntetické XR 409, UI 363, učebna 114, programování 765, XR 69 a terminál 64 PASS. Otisky zdrojů a katalogů odpovídají. `test-output/pico-package/results.json`. |
| Fyzické PICO | **NEPROVEDENO** — žádný autorizovaný headset v ADB. Instalace/spuštění Android knihoven, skutečný tracking, komfort a FPS nejsou ověřené. Požadovaných 72 Hz není naměřený výkon. |

Všechny testy izolují save přes SaveManager.path_override a vlastní nastavení
před konstrukcí GameManageru. Obnova kampaně, přímé přechody mezi oblastmi,
fyzický odchod, teleport, menu, zrušení UI/nákupu a kompatibilita starého save
jsou součástí nových regresí. Atomické ukládání a pravdivá chyba zápisu zůstávají.

První grafické automatizace nebyly úspěšné a nejsou vydávány za PASS. UI design
někdy ztratil syntetický klik rozdělený přes snímky; helper nyní posílá úplný
press/release s korektní maskou bez mezilehlých nativních událostí. Při pěším
průchodu byla v diagnostice potvrzena skutečná pauza po ztrátě desktopového
fokusu (`mode=pause, enabled=false`), nikoli neprostupná geometrie. Automatizace
nyní ověří bezpečnou pauzu a použije skutečné tlačítko Pokračovat; bezpečnostní
chování hry se nevypíná. Všechny původní požadavky na chůzi, editor a zachování
kampaně zůstávají. Stejná příčina při prvním E na NAS byla ošetřena i ve starém
world_playthrough: test nabízí skutečné Pokračovat a posílá úplný stisk/uvolnění E.
Opravené externí testy znovu prošly nad přesným finálním EXE.
První výsledky i následné běhy jsou v `windows-package/reruns.json`,
`current-corrective-reruns.json` a manifestu.
Při vývoji byl dále odstraněn nízký kolizní schod mostu; pěší automatizace vede
volnou uličkou kolem NPC. Finální source i balíčkové průchody jsou čisté.

Finální **EXE 104 786 904 B**, rezerva **70 696 B**, SHA256
`57e2d5d3566d0e11bb24b31123f0aebbca67524b41432b98cd112fb6002273ff`.
**APK 90 466 889 B**, SHA256
`89b4d55741deaad6251e4588af13b6baf52d86bcbe724b1a6c8870bf17745f90`.
Podrobné strojové výsledky jsou v `build/VERIFICATION.json`; oba exporty jsou
z herních zdrojů commitu `42600a3`. Pozdější změny doplňují testovací automatizaci,
reporty a navazující prompt a nemění obsah hry v exportech.

Tato kontrola není kompletní schválení všech textur. Uživatel hlásí vadný vzhled
vstupu / dveří Londýna a výslovně zadal další AI audit a opravu všech vadných
textur/materiálů. `PROMPT_ACADEMY_HUB_PC_VR.md` dále požaduje skutečný nástupní
rozcestník, přepracování situací na B1–B2, nejméně 20 otázek o Londýně a skutečné
zákaznické dotazy při nákupu lístků. Tyto navazující funkce se zde neprohlašují
za implementované. Volitelné vlastní psaní, zvuk a rozpoznávání řeči nejsou přidány.

## Oprava blikání zdi u programovací učebny — 2. 11. 2026

Před opravou měly tři segmenty stěny AcademyRoom stejné povrchy jako západní
stěna serverovny; měření nalezlo šest překrývajících se ploch. Po odstranění
duplicit je překrytých ploch nula. Navazující zeď mimo serverovnu zůstává.
Otevřené/zavřené dveře z obou stran vizuálně ověřeny v Compatibility i Forward+;
snímky `test-output/door-wall-before-*.png` a `door-wall-after-*.png`.

Cílené zdrojové testy: programming_location 114, programming_polish 27,
world3d 35, door3d 15 a training_rooms 68 PASS, bez runtime chyb/varování.
Nové skutečné Windows EXE i herní prostředky z nového PICO APK prošly stejnou
kontrolou nulového překrytí (`door-wall-packaged-windows.log` / `pico.log`).
Samostatné EXE má nativní headless i GPU smoke PASS; APK má platný podpis v2,
CRC, ARM64 a OpenXR/PICO manifest. Podrobnosti a SHA256 v build/VERIFICATION.json.
Aktualizované APK dále prošlo test_pico.py: headless i GPU smoke, UI 357,
průchod 114, programování 765, syntetické XR 69 a terminál 64 PASS.
Testy používají vlastní save a konfigurace; fyzické PICO není připojené.
Úplná sada z předchozí sekce nebyla pro tuto jedinou změnu geometrie opakována.

## Sjednocení build/ a nové PICO APK — 2. 11. 2026, nativní Windows

Navázáno na aktuální origin/main `fed2f4e`. Původní `build/ITSupportSimulator.exe`
se neměnil (SHA256 `daf7d88bd7b340df3055f3309ed9f1d1e55f9c654073bee6eb0e184cf5c5b74b`).
`builds/` odstraněna lokálně i ze změny pro Git; starší odkazy na ni níže jsou
historické. PICO je v `build/pico4/ITSupportSimulator-PICO4.apk`.

| Kontrola | Výsledek a rozsah |
|---|---|
| Úplný `tools/Test-All.ps1` | 32 sad PASS, exit 0, žádný SCRIPT ERROR/ERROR/WARNING; `test-output/build-migration-test-all.log`. Včetně 65 misí, všech 21×3 lekcí, 336 výukových UI akcí a izolace save/relací. |
| Původní Windows soubory | EXE, SHA256SUMS, BUILD_INFO.json/.md a .gitattributes zachované podle vstupních hashů; doplněna PICO data a upraven README. |
| Windows nativní start | Samotné EXE mimo projekt, headless i Compatibility GPU PASS, 65/21 a 60/28 obsahu, Python/web, vstup/odchod obou učeben. |
| Windows vložený pack | Všech 12 sad headless PASS; `test-output/windows-package/results.json`. |
| Doplňkové grafické Windows sady | 10/12 PASS; programming_location 7 selhání, ui_design selhal na navigaci Storage ve 4K. Opakování při 60 FPS také selhalo (26 / 5 selhání). Příčina není potvrzená; tyto testy nejsou prohlášené za PASS. Původní EXE a herní zdroje se neměnily. Samostatné záznamy `graphical-results.json`, `graphical-programming_location.log`, `graphical-ui_design.log` a `windows-*-60fps.log`. |
| Aktuální APK | Nový export aktuálních zdrojů, Training academy 1.1.0 / versionCode 2, ARM64, min 29 / target 34; podpis v2, ZIP CRC, nativní knihovny a manifest z výsledného APK PASS. Stejný certifikát jako původní APK: `3449ce02012b69d3d0b9d19eea1706521e290fac48ab7ff1d5d20bea8c003997`. |
| Skutečné herní prostředky z APK | `tools/test_pico.py`: headless i GPU smoke PASS; UI workflow 357, programming_location 114, integration 765, XR 69 a terminál 64 PASS. Výsledky `test-output/pico-package/results.json`. Desktopový Godot načítá prostředky přímo z APK, pouze Android extension discovery je pro tento běh vypnuté. |
| Aktuálnost a exportní filtry | Otisky všech zdrojů souhlasí s `build/pico4/BUILD_INFO.json`; zabalené katalogy souhlasí. APK neobsahuje build/, builds/, tests/ ani tools/. Původní herní skripty, scény, assets, katalogy a project.godot jsou shodné s fed2f4e. |
| Fyzický PICO | NEOVĚŘENO: `adb devices -l` bez autorizovaného zařízení. Není potvrzené skutečné Android spuštění, tracking ani FPS; desktopové testy prostředků nenahrazují headset. |

APK: 90 430 147 B, SHA256 `cbf9dc83fae810157fe806563b4fc59d8feed4371777628ceaa7c1ab788aed0c`.
Kontrola podpisu je v `test-output/platform-build/`, souhrn v `build/VERIFICATION.json`.
Testy používají SaveManager.path_override a oddělené nastavení; hráčův save
se pro testy nepoužívá. Opravena platformní cesta v testu ui_workflow; herní kód se neměnil.

## Training academy — UI/UX, 2. 11. 2026

Tato aktuální sekce nahrazuje starší tvrzení o rozhraní a distribuci. Základ
je uživatelem určený commit `99c201215f83408f333829ed05aa0489253acc14`.
Načtena skutečná verze Godotu 4.7.2.stable.official.ed1daf0bf; editor i šablony
mají ověřené oficiální SHA512. Godot 4.6.3 nebyl použit pro validaci projektu.

| Ověření aktuální verze | Výsledek |
|---|---|
| Úplný `tools/test_all.py` podle aktuálního `Test-All.ps1` | 32 sad PASS, 0 selhání |
| Nový `ui_workflow.gd`, headless | 357 kontrol, 0 selhání |
| Stejný workflow graficky, skutečná hlavní scéna | 357 kontrol, 0 selhání |
| 4K skutečné písmo a SVG (`render_quality`) | 8 kontrol, 0 selhání |
| Přesný vložený pack výsledného EXE, Linux editor | všech 12 sad PASS |
| Přesné přejmenované samotné EXE, Wine headless | PASS, exit 0 |
| Přesné přejmenované samotné EXE, Wine graficky | menu a funkční smoke PASS; běžné zavření exit 0 |
| Nativní Windows / fyzický headset | neprovedeno |

Nový workflow používá skutečné události myši a klávesnice; před GameManager
nastavuje vlastní SaveManager.path_override i DisplaySettings.path_override.
Kontroluje dostupnost všech desktopových tlačítek menu bez posuvu, 3D/VR,
přímý vstup do programování bez zahájení úlohy a obnovení kampaně. Pokrývá
mizení běžného oznámení a trvalost kritického neuložení i v prázdné učebně.
Editor: rozdíl run/verify, samostatný výstup a chyby, kliknutí na skutečný
soubor/řádek, zvýraznění, nativní undo/redo, kurzor/výběr, vstupy, zastaralé
ověření a zachování uloženého nejlepšího výsledku. Formuláře: koncept,
odmítnutí bez trestu či změny infrastruktury, úspěch modelu při selhání zápisu,
existující opakování zápisu, izolace hostitele a surový číselný koncept.

Výchozí relevantní programovací a UI sady prošly před implementací. Uchovaná
kopie původního commitu při srovnávacím běhu nového workflow reprodukovala
6 ztrát číselného konceptu v šesti kombinacích; finální verze nemá tuto chybu.
Během implementace byly opraveny zastaralé přesné textové kontroly xr_modes
(3D tlačítko) a training_rooms (názvy oznámení); žádné assertions se nevypínaly.
Starší neúspěšné logy nejsou zaměňované za závěrečný úplný běh.

Grafika: 1280×720, 1920×1080, 3840×2160, každé 100 % i 130 %. Linux,
Compatibility/Mesa llvmpipe, Xvfb, shodná testovací preference Úsporná,
RenderingServer.force_draw s --disable-render-loop/--manual-capture.
Běží skutečný framebuffer a všechny vstupy/layout kontroly. Prohlédnuty
menu včetně VR, HUD, formuláře a chyby, editor/výstup/chyby/ověření,
nastavení i lekce. 4K SVG textura 38×38; ostrost hran native/magnified:
menu 0.389/0.197, rack 0.425/0.178, terminál 0.277/0.136.

**EXE:** build/ITSupportSimulator.exe, Windows x86_64 Debug, **104 720 824 B**,
vložený pack **1 544 108 B**, rezerva **136 776 B** do 100 MiB.
SHA256 `daf7d88bd7b340df3055f3309ed9f1d1e55f9c654073bee6eb0e184cf5c5b74b`.
Oficiální exportér, platné PE/GDPC, bez vedlejšího PCK, bez UPX/úprav PE.
Wine 10.0 spouštěl kopii pod jiným názvem z odlišného pracovního adresáře.
GUI ukázalo titulek „IT Support Simulator: Training academy (DEBUG)“.
Wine hlásí nepodporovaný dotaz na SDR white level; GUI přesto skutečně
vykreslilo menu a prošlo smoke. Linux/Xvfb hlásí nepodporované přepnutí VSync.
Tato omezení se neoznačují za herní chyby ani za čisté nativní Windows logy.

Pack regression: ui_workflow 357, programming_runtime 31, programming_catalog
1071, programming_academy 63, programming_integration 765 (252 generovaných
variant), programming_polish 27, programming_location 114, xr_modes 69,
terminal_sessions 64, ui_design 162, world_ui 31, world_playthrough 34;
vše bez selhání. Tyto testy běžel Linux editor s --main-pack, nikoli Windows runtime.

Snímky: [verzovaný výběr před/po](docs/ui-review/2026-11-02-ux/README.md),
plná místní matice test-output/ux-before (60 PNG) a ux-after (72 PNG).
Logy finálních běhů: test-output/final/regression.log a regression/,
ui-workflow-graphical.log, render-quality.log, build.log, pack-final.log,
wine-graphical.json. Přesné pack logy jsou také v test-output/windows-package/.
Souběžné headless běhy měly různé datové složky; grafické běhy byly postupné.

Přejmenování zachovává původní user data cestu přes Godot custom user dir;
Linux cesta je skutečně ověřená, ve Wine vzniká kompatibilní Windows cesta.
Žádné katalogy, první 24 mise, legacy_campaign.json, referenční postupy ani
simulační pravidla nebyly změněné. Desktop focus pause/F11/obrazová potvrzení
ověřují původní world_ui a display_settings regrese. XR ověření je syntetické.

Opakovatelné cloud `install_script` a `start_skill` byly uložené do návrhu,
instalační refresh byl vykonaný. Uložení návrhu není publikace ani ověření
obnovy v novém tasku. Publikaci provádí uživatel v nastavení prostředí.
EXE je nepodepsané; archivní ZIP/APK zůstávají staré. Nativní Windows, fyzické
VR a stažení nové verze z GitHubu nebyly provedeny. Git push následuje jako
samostatná operace; publikaci cloud prostředí provádí uživatel.



## Předchozí etapa — přesun učebny, 2. 11. 2026

Tato sekce se vztahuje k nynější etapě. Následující záznamy z října jsou
historické a nedokládají ověření nového EXE na Windows.

- Výchozí stav `4000cb0`: všech 30 aktuálních sad z Test-All prošlo na
  skutečném Godotu 4.7.2.stable.official.ed1daf0bf. Godot 4.6.3 přítomný
  v obrazu neobsahuje používané CanvasItem API; není podporovanou náhradou.
- Potvrzená chyba ztráty desktopového fokusu: nová regrese před opravou
  3 selhání; po opravě `world_ui` 31 kontrol, 0 selhání. Pokrývá také
  uvolnění kláves, explicitní pokračování a zachování rozepsaného formuláře.
- `programming_location`: 114 kontrol headless, 0 selhání. Dvě návštěvy
  nové západní místnosti skutečnou chůzí, raycast/E, Python a HTML/JS,
  kliknutí na Otestovat, návrat do MAIN a zachování kampaně. Ověřuje také
  uložení/načtení podporované staré pozice u dveří, opravu pouze polohy,
  zachování XP/výsledků a oddělení statických dávek místností.
- Finální `programming_location` graficky: 114 kontrol, 0 selhání,
  skutečné události E/myši a čerstvé screenshoty nového umístění.
  Žádný hráčův save/config se nepoužil.
- Finální úplná regrese: všech **31 sad PASS**, exit 0, žádné chyby ani
  varování v headless logu. Seznam čten přímo z Test-All.ps1, včetně
  training_ui --all-modes. Zdrojové a balíčkové testy měly oddělené datové složky.
- Přesný finální EXE (hash v build/SHA256SUMS): **11 balíčkových sad PASS**,
  exit 0 a čisté logy, včetně location 114, world_ui 31, integration 765,
  katalogu 1071 a UI matice 162. Samostatný Wine headless smoke také PASS.
- Grafická `ui_design`: 162 kontrol, 0 selhání; 1280×720, 1920×1080,
  3840×2160 při 100/130 % textu; skutečné události myši a klávesnice,
  viditelnost akcí, posuv dlouhých formulářů, fokus a oprava hodnot.
- Grafická `DesignMCP.tscn`: 31 kontrol, 0 selhání; skutečná hlavní 3D
  scéna, menu, HUD, konzole, nastavení, lekce a vedení v téže matici
  720p/1080p/4K × 100/130 %. Kvůli softwarovému renderu použito
  --disable-render-loop + --manual-capture: všech osm čekacích snímků
  layoutu/vstupu běží, pak skutečný RenderingServer.force_draw.
  Běžný režim testu nadále čeká na frame_post_draw.
- `render_quality`: 8 kontrol, 0 selhání. Skutečný 4K framebuffer,
  38×38 SVG ikona a porovnání rasterizovaných hran textu, nikoli jen PNG.
- Grafika: Linux x86_64, Xvfb 3840×2160, Compatibility / Mesa 25.0.7
  llvmpipe LLVM 19.1.7. Zvuk Dummy. Jediné grafické varování ovladače:
  změna V-Sync není podporovaná. Není to benchmark herního GPU; výkon
  původní a upravené scény nebyl měřen za srovnatelných podmínek.
- Všech 65 misí, 21 IT lekcí, 28 programovacích lekcí a 60 úloh zůstává
  zachováno. Generované katalogy, legacy24 i referenční řešení beze změn.
- Není dostupný Godot MCP; byly použity skutečný engine, existující testy,
  příkazová řádka a prohlédnuté čerstvé screenshoty.

Aktuální EXE a jeho přesné parametry uvádí `build/BUILD_INFO.json` a
`build/SHA256SUMS`. Jde o oficiální x86_64 Debug export s vloženými daty,
nikoli přejmenovaný Release. Tracked build ověřuje PE/PCK a limit 100 MiB,
pak spouští samotné přejmenované EXE z oddělené složky bez externího PCK.
Wine smoke ověřuje 65/21, obě učebny, západní polohu, 60/28, Python,
HTML/JS náhled a návrat do hlavní relace. Editorové testy nad přesným
vloženým packem jsou oddělené od spuštění skutečného Windows EXE.

Skutečné grafické okno finálního EXE ve Wine bylo prohlédnuto; standardní
zavření exit 0. Wine hlásí nepodporovaný dotaz na SDR white level a liší se
některé symbolové fallbacky fontů; screenshot je v nových UI podkladech.

Nativní grafické hraní ve Windows, fyzický PICO/OpenXR a antivirová kontrola
ve Windows nejsou v této etapě ověřené. Starší ZIP/APK v `builds/` nebyly
přestavěny. Dřívější nativní PASS nelze přenášet na nový EXE.

Doplnění po výslovném pokynu k publikaci: commit `99c2012` byl odeslán do
GitHub main bez force. Přímé stažení EXE z raw.githubusercontent.com a
zdrojového archivu z codeload.github.com pro přesný commit **PASS**.
EXE v obou případech začíná MZ, má 104 713 528 bajtů a shodný SHA256:
`ea2b6a5fedf2d0ba390269c4d4c513e28f62aafc8a29b2cc2f3afaad83604c41`.
Jde o celou binárku včetně herních dat, nikoli Git LFS pointer.


## Spuštění jediného EXE ze ZIPu — 26. 10. 2026

Hlavní `ITSupportSimulator-Windows.zip` nyní používá přenosné EXE s vloženými
herními daty. Nevyžaduje sousední PCK. Samostatná vývojářská varianta v
builds/windows nadále používá externí PCK a není obsahem hlavního ZIPu.

Výsledný ZIP byl otevřen testem a vytaženo **pouze jeho EXE** do dočasné složky
s názvem ZIPu. Bez projektu, PCK i ostatních souborů prošel skutečný native
headless a GPU start, odlišný pracovní adresář i přejmenované EXE. Native smoke
ověřil původní hru, obě učebny, Python a HTML/JS náhled. Logy
test-output/platform-build/portable-native-*.log a builds/VERIFICATION.json.

Přesný přenosný EXE navíc: všech 10 zabalených sad PASS, exit 0, bez chyb/varování
(runtime 31, katalog 1071, academy 63, integration 765, polish 27, XR 69,
terminál 64, ui_design 162, world_ui 27, world_playthrough 34). CRC a shoda EXE
v ZIPu PASS, vlastní scan Defenderu dokončen bez detekce.

EXE SHA256: `7d24a4b372a30496d590aa2301b0f26b71e87b6bfb412ee377712f394167b6b9`.
ZIP SHA256: `adc38a2af983ec74cda3210b3e727687f55d4088317100c69b0fc1594d347236`.
Herní zdroje a PICO APK zůstaly shodné s předchozí verzí. Reputační upozornění
SmartScreen může zůstat; oprava řeší konkrétní chybějící herní data při spuštění
z archivu a nemění nastavení zabezpečení Windows.

## Přístup, vzhled učebny a Windows distribuce — 26. 10. 2026

Všech **30 sad Test-All PASS**, exit 0, bez runtime chyb/varování.
Nový `programming_polish.gd` v závěrečném běhu: **27 kontrol PASS**.
Test začíná běžným spawnem a skutečně obejde admin stoly, projde levou
uličkou, zaměří/otevře dveře, vstoupí i vyjde. Před opravou jej zastavil SW-CORE.
Dále kontroluje bezpečnost dveří, postup po skutečné změně kódu, native undo/redo
mezi soubory, filtry stanovišť, zkoušky generovaných variant, reset náhledu a 130% UI.

Finální externí PCK: všechny programovací sady, XR 69, terminál 64,
UI design 162, world UI 27 a world playthrough 34 PASS. Nad přesným PCK
také GPU Compatibility **integration 765 + polish 27 PASS** a kontrola snímků.
Současné integration/polish běhy používají vlastní save/CFG s PID;
ověřování nezasahuje do hráčova uloženého postupu.

Windows EXE je beze změn shodné s oficiální Release šablonou Godotu;
data jsou v sousedním `ITSupportSimulator.pck`. ZIP je nutné celý rozbalit.
Native start mimo projekt headless i GPU PASS. Hash/CRC ZIPu, shoda obou
binárních souborů v ZIPu a zabalený katalog 60/28 v APK PASS.
Podrobné hashe/výsledky: builds/VERIFICATION.json.

Defender: dokončený vlastní scan finální Windows složky, událost 1001,
bez odpovídající detekce. **SmartScreen může stále zobrazit Unknown publisher:**
není dostupný podpisový certifikát/reputace a toto upozornění se neobchází
změnou bezpečnostních nastavení. Viz SPUSTENI-WINDOWS.txt.

Aktualizované PICO APK má ověřený podpis/ARM64/OpenXR manifest;
fyzický headset a jeho výkon zatím nejsou ověřené.

## Programming Academy — 26. 10. 2026

`tools/Test-All.ps1`: **29 sad PASS, exit 0, bez runtime chyb a varování**.
Původní kampaň 65/65 v modelu i UI, 21×3 serverových lekcí a všechny
regrese save/relací/místností zůstávají funkční. Původní katalogy jsou obsahově
shodné s checkpointem 5661021; kompletní přegenerování v dočasné kopii také shodné.

Nové sady ve finálním ověření zdrojů a přesného zabaleného PCK:

- programming_runtime: 31 kontrol výpočtů, parseru, funkcí, chyb, nekonečných cyklů a VFS.
- programming_catalog: 1071 kontrol všech 60 úloh, 28 lekcí a 12 oprav; správná/chybná i ekvivalentní řešení.
- programming_academy: 63 kontrol skutečného počítače/editoru, save/XP, odchodu a zachování kampaně.
- programming_integration: 765 kontrol; 28×3 režimů, DOM kliknutí, CSS barvy v Control UI, 252 generovaných variant, syntetické XR psaní, fyzická klávesová událost, zoom/soubory a obnova výsledků.

Godot MCP ProgrammingMCP i původní WorldMCP při samostatném finálním běhu
PASS, errors=[]. Prohlédnuty snímky skutečné 3D místnosti, Python editoru se
serverovými logy a interaktivního webu. GPU Compatibility integration 765/765
prošel také nad přesným exportovaným PCK, mimo zdrojový projekt.

Finální Windows EXE SHA256:
`6bbeebbe125feb8626b46a5941da13e8d8b5177f289b32323428b2696ba3eac4`.
Spuštění skutečného EXE headless i GPU v izolaci PASS; přesný PCK navíc všechny
nové sady, XR 69, terminál 64, UI 162/27 a world playthrough 34 PASS.
ZIP obsahuje totožný EXE a dokumentaci. APK podpis/ARM64/OpenXR manifest,
zabalený katalog 60/28 a CRC obou archivů PASS. Velikosti/hashes jsou
v builds/VERIFICATION.json.

**Fyzický PICO nebyl připojen.** Tracking, skutečný Bluetooth hardware,
komfort a stabilní FPS nejsou ověřené. Python i web jsou zdokumentované
omezené výukové implementace; nejde o plný CPython či browser.
Všechny herní testy používají SaveManager.path_override a vlastní konfiguraci.

## Opravy terminálu a Windows EXE — 26. 10. 2026

Celý `tools/Test-All.ps1`: **24 sad PASS, exit 0, bez runtime chyb a varování**.
65 misí v modelu i UI, 21 lekcí × 3 režimy, 1075 výukových kontrol,
336 výukových UI akcí, 474 kontrol ukládání a 700 kontrol navigace.
Nová sada `terminal_sessions.gd`: **63 headless i GPU kontrol PASS**.
Chrání správný kontext hostitele, undo pro oba hypervisory, výukové události,
hodnocení chyb, odloženou kampaň a opakování skutečně selhaného zápisu.

Výsledný samostatný EXE má 104 340 256 bajtů a vložený PCK. `tools/test_windows.py`
ověřil přímý start tohoto EXE bez zdrojového projektu headless i graficky na
Windows (oba exit 0, čisté logy). Nad daty vloženými přímo v témže EXE prošlo
**64 kontrol terminálu, 162 kontrol UI, 27 kontrol 3D UI a 39 kontrol servisu**,
včetně 4K; vše bez runtime chyb a varování. Použit Forward+/Vulkan / Intel UHD.
Šablona nepovoluje externí `--script`/`--path`; podrobné testy proto používají
plný editor přes `--main-pack`, přímý start EXE se kontroluje zvlášť.

Přesný SHA256 ověřeného souboru a stavy kontrol jsou v `build/VERIFICATION.json`.
Logy: `test-output/terminal-fix-test-all.log`, `terminal-sessions-gpu.log` a
`test-output/windows-package/`; screenshoty v jeho podadresáři `screenshots`.
Použité jsou izolované SaveManager/DisplaySettings cesty, přímý EXE start
má `--test-world`. Hráčův save nebyl změněn. Obsah misí/lekcí včetně legacy24
zůstává shodný; generátory obsahu nebylo třeba měnit.

## Profesionální UI při zachování 3D — 25. 10. 2026

Celý `tools/Test-All.ps1`: **23 sad PASS, exit 0, bez runtime chyb/varování**.
65/65 misí přes model i skutečné formuláře, legacy24, 21 lekcí × 3 režimy,
1075 výukových kontrol, 336 UI akcí, 474 kontrol save a 124 kontrol relací.
Log: `test-output/design-test-all-verified.log`.

| Ověření | Výsledek |
|---|---|
| Nová matice UI: 720p/1080p/4K × 100/130 % text | 162 headless i GPU PASS, skutečná myš a klávesa, místní validace, kontext VM a fokus hledání |
| Skutečná hlavní 3D scéna ve stejné matici | 31 Godot MCP kontrol PASS, errors=[] |
| Konzole a šest kroků průvodce | 60 GPU PASS, včetně konceptů/fokusu/posuvu |
| Vedená výuka | 700 GPU PASS pro všech 21 lekcí |
| 3D HUD, modalita a preference | 27 GPU PASS |
| Rozlišení/F11/fullscreen a potvrzení | 76 GPU PASS |
| Písmo a SVG ve 4K | 8 GPU PASS, reálná textura ikony 38×38 px |
| MCP fyzické interakce a výuka | 79 objektů; raycast/E, konzole, save/návrat, opakované dveře a návrat od instruktora PASS, errors=[] |
| Aktualizovaný samostatný Windows EXE+PCK | 162 UI + 27 skutečných3D kontrol PASS, oba exit 0, čistý stderr |

Výchozí i výsledné snímky pocházejí ze skutečné hry, srovnání v
[docs/ui-review/README.md](docs/ui-review/README.md). Prohlédnuty také matice
všech tří rozlišení a zvětšeného textu včetně Hyper-V, disků, chyby pole,
nastavení a 3D instruktora. Menu i potvrzení konzolí mají jasnou hlavní akci;
dlouhé formuláře zůstávají posuvné pod pevným potvrzením.

Zachované je 3D prostředí a jeho ovládání, výuka, save i odložená kampaň.
Obsah misí/lekcí a generátory se nemění. Všechny běhy používají oddělené
SaveManager a DisplaySettings cesty. Nová matice má navíc oddělené cesty
pro grafický a headless běh.

Logy: `test-output/design-gpu-ui_design-final.log`, `design-gpu-*.log`;
sestavení `design-build.log`, balíček `design-package-*-out/err.log`;
snímky `design-final-*`, `design-world-*`. PNG před/po jsou také uložené
v Gitu pod `docs/ui-review/` a Godot je díky `.gdignore` nebalí do hry.

## Oprava vedené výuky v nových konzolích — 25. 10. 2026

Před opravou skutečný průchod selhal ve 3 ze 6 kontrol: opětovný klik na
předvybraný hostitel nepotvrdil krok, kontext instruktora měl nulovou výšku
a návrat k potřebnému panelu ponechal formulář schovaný za kontextem.
Opravené jsou také obnovení posledního kroku VM a směrování zvýraznění do sekcí.

- Nový `tutorial_navigation.gd`: **700/700 kontrol headless, GPU i samostatný Windows balíček**, exit 0, bez runtime chyb/varování. Všech 21 vedených lekcí se ovládá přes viditelný strom, sekce a formuláře bez testovacího `open_action` či nastavování page/tab. Zahrnuje klik/Enter na předvybraný uzel, návrat z instruktora, obnovení VM shrnutí, chybnou RAM, koncepty, posuv i ochranu dalších režimů a kampaně.
- Celý `Test-All.ps1`: **22 sad PASS**, 65 misí v modelu i UI, 21 lekcí ve všech 3 režimech, 336 původních výukových UI akcí, 474 kontrol save a ostatní regrese.
- Rozšířený Godot MCP: raycast/E na cvičný server → management → opětovný klik na uzel → průvodce → instruktor → skutečný formulář PASS, errors=[].
- Prohlédnuté snímky nové výuky v720p/1080p/4K, shrnutí se Start/Ověřit a 3D návratu do konfigurace. EXE+PCK i přibalené dokumenty jsou aktualizované. Definice obsahu, legacy24 a generátory se neměnily.

Důkazy: `test-output/tutorial-test-all.log`, `tutorial-navigation-final.log`,
`tutorial-navigation-gpu-final.log`, `tutorial-package.log` a `tutorial-*.png`.
Testy používají vlastní SaveManager/DisplaySettings cesty; hráčův save a config
se nepoužily. Nativní potvrzení aktivují tlačítko dialogu; hlavní konfigurace
používá skutečné vstupní události a ověřuje dosažitelnost ovládacích prvků.

## Nové konzole, nastavení a validace platformy — 25. 10. 2026

Finální `tools/Test-All.ps1`: **21 sad PASS, exit 0, bez runtime chyb a varování**.
Všechny běhy používají izolované cesty SaveManager i DisplaySettings.

| Kontrola | Skutečný výsledek |
|---|---|
| Chyby platformy | 396 kontrol; odmítnutí Dynamic Memory i nativní migrace PVE VM, nezměněná infrastruktura |
| Konzole a průvodce | 60 kontrol headless i samostatný Windows EXE; skutečné kliknutí všemi 6 kroky, aktuální CPU/RAM, koncepty, posuv/fokus po chybě i úspěchu, VM101 v síti |
| 3D rozhraní | 27 kontrol headless, Forward+, Compatibility i zabalený EXE; modalita, psaní bez chůze, návrat nastavení do pauzy, HUD všech režimů, předvolby grafiky |
| Celá kampaň | 65/65 misí v simulaci i přes nové viditelné formuláře; shoda legacy24 |
| Výuka a uložený postup | 21 × 3 režimy, 1075 kontrol lekcí, 336 výukových UI akcí, 474 kontrol save, 124 relací, 68 kontrol oddělení místností |
| Obraz a přístupnost | 68 headless / 76 GPU kontrol nastavení; skutečný fullscreen a všech 6 rozlišení, timeout a chyby zápisu, vlastní klávesy a text |
| Ostrost | 8 GPU kontrol; skutečný 4K framebuffer, ostré fonty v menu/racku/terminálu, SVG textura 38 × 38 |
| Godot MCP | 79 objektů, raycast/E/konzole/save/návrat/dveře PASS, errors=[] |

Snímky nové konfigurace a nastavení v 720p, 1080p a 4K, všechny kroky průvodce,
130% text a zmenšený HUD byly skutečně prohlédnuté. Balíček EXE+PCK byl nově
sestaven a oba externí grafické testy skončily exit 0. Testy nejsou součástí PCK.

Logy v `test-output/`: `ux-test-all-final.log`, `ux-package-console.log`,
`ux-package-world-ui.log`, `ux-display-gpu-final.log`, `ux-render-quality.log`,
`ux-world-ui-gpu-final.log`, `ux-compatibility.log`; snímky mají prefix `ux-`.
Opakované generování katalogu zachovalo stejné hashe. Prvních 24 misí,
legacy definice a jejich referenční řešení zůstaly zachované.

## Oddělení místností — 25.10.2026

Nová sada `tests/training_rooms.gd` a scéna `tests/TrainingRoomsMCP.tscn`
ověřují stejné skutečné 3D prostředí.68 kontrol A–H prošlo headless,
graficky přes Godot MCP (Forward+/RTX5060, `errors=[]`) i ve Windows EXE+PCK.
Všechny testy používají vlastní `SaveManager.path_override` a config.

| Test | Ověření |
|---|---|
| A | Skutečná chůze dveřmi → TRAINING, pozastavená kampaň, funkční všechny3 režimy |
| B | Chůze zpět → MAIN, zrušená lekce, UI, šipky, kroky, dialogy a sandbox |
| C | Návrat do centra nabízí nový výběr bez automatického obnovení |
| D | Dokončená zkouška, nejlepší výsledek, statistiky a dříve získané kariérní XP přetrvají po načtení |
| E | Fyzické vytažení cvičného disku nemění produkční stav ani jeho LED |
| F | Start lekce/série a obnova tréninkové relace v MAIN jsou odmítnuté |
| G | Teleport před dalším fyzikálním snímkem, načtení vnější pozice, menu a zánik scény ukončí trénink |
| H | Opakované přechody i kolísání u dveří; právě jeden přechod na průchod |

Obnovená pracovní mise přijme produkční zásahy, dokončí se a udělí další XP.
Vizuálně prohlédnuty `test-output/training-room-{entry,lesson,exit}.png`.
Windows balíček: `test-output/training-package.log`,68 kontrol, exit0.
Původní obsah katalogů a legacy24 se neměnil. Všech18 sad Test-All PASS, exit0,
bez runtime chyb/varování:65 misí v modelu i UI,21×3 lekcí/1075 kontrol,
336 výukových UI akcí,474 kontrol save a68 nastavení. Poslední kontrola přímé
obnovy po teleportu doplňuje souhrnný běh samostatným headless/MCP ověřením.
Podrobnosti jsou v PROGRESS.md a `test-output/training-test-all.log`.

Datum: 24.10.2026. Engine: Godot4.7.2.stable.official.ed1daf0bf, Windows x86_64.

## Dveře a výrazné vylepšení vizuálu

Dva pevné nástěnné panely ovládají dveře i po zasunutí křídla do stěny.
Bezpečnostní čidlo odmítne zavření do hráče a při vstupu během zavírání znovu
otevře. `door3d.gd`:15/15 headless i samostatné Windows EXE PASS; ověřeno
zaměřením skutečného panelu a opakovaným E z obou stran, nikoli pouze přímým
voláním přepínače. Stejný otevřít/zavřít průchod proběhl přes Godot MCP, errors=[].

Prezentace nyní používá Forward+/Vulkan,4× MSAA, měkké lokální stíny,
SSAO/SSIL, SSR a statickou interiérovou radianci. Původní simulátory a obsah
zůstaly beze změny. Vlastní geometrie zahrnuje zaoblené kovové modely,
perforace, detaily disků, křivky kabeláže, jemné podlahové spáry, strop a stěny,
prosklený pohled do skutečné chodby a detailní pracovní místa. Všech6 monitorů
ve3D čte přímo aktuální GameManager a obnovuje přehled2× za sekundu.

Grafické ověření: servisní průchod39 kontrol PASS, nastavení76 PASS,
ostrost8 PASS včetně4K glyphů a38px SVG. Úsporný OpenGL renderer prošel
stejným34kontrolovým servisním průchodem. Nové Windows EXE+PCK zvládlo
samostatný grafický servis34 kontrol a dveře15 kontrol; oba procesy exit0.
MCP ověřil79 interaktivních objektů, původní konzoli, uložení a návrat.

Benchmark s vypnutým VSync na RTX5060, pohled na hlavní serverovnu:

| Rozlišení | Průměr snímku | FPS | Draw calls | Hlásená VRAM |
|---|---:|---:|---:|---:|
|1920×1080 |3,04ms |329 |282 |471MiB |
|3840×2160 |10,37ms |96 |282 |1390MiB |

Jde o konkrétní měření jedné scény, ne záruku výkonu na jiných počítačích.
Statické díly slučuje MultiMesh (1501 odstraněných samostatných instancí).
ReflectionProbe atlas není používán kvůli [ověřené chybě enginu](https://github.com/godotengine/godot/issues/122498);
odlesky zajišťují SSR a interiérová radiance. Finální grafické logy jsou bez
chyby atlasu a bez úniků GPU textur. Testovací průchod nechá doběhnout poslední
kliknutí ve zvukovém vlákně před ukončením, obdobně jako samotná hra.

Vizuálně prohlédnuty snímky `test-output/visual-server-room.png`,
`visual-rack-close.png`, `visual-nas-fault.png`, `visual-glass-office.png`,
`visual-door-controls.png`, `visual-door-open-control.png` a `visual-academy.png`.
LED vadného disku zůstává viditelná před novým rámečkem, panel dveří nabízí
Zavřít při otevřeném křídle a nová HUD výzva je celá v obraze.

Závěrečný Test-All: všech17 sad PASS, exit0, bez runtime chyb a varování.
Zahrnuje65/65 misí v modelu i UI,21 lekcí ve všech3 režimech (1075 kontrol),
336 výukových UI akcí,474 kontrol save a nové opakované ovládání dveří.
Úplný log je v `test-output/visual-test-all.log`.
Ostatní aktuální důkazy: `visual-capture-final.log`, `visual-benchmark.json`,
`visual-display.log`, `visual-fonts.log`, `visual-package.log`,
`visual-door-package.log`, `visual-compatibility.log` a `visual-build.log`.
Všechny běhy používají izolované SaveManager.path_override a config cesty.

## Přestavba do3D

Nová hlavní scéna `scenes/world/Game.tscn` integruje původní GameManager a UI
se skutečným CharacterBody3D světem. V projektu zůstaly všechny původní scény,
50 misí a21 lekcí; přidáno15 praktických misí51–65. Následující testy používají
výhradně SaveManager.path_override, grafické testy také vlastní konfiguraci.

| Ověření | Výsledek |
|---|---|
| První úplný Test-All po přidání misí |15 sad PASS;65/65 misí v modelu i původním UI;21×3 lekcí,1075 kontrol;336 výukových UI akcí |
| Závěrečný Test-All |Všech16 sad PASS, exit0, bez runtime chyb a varování;65 misí v modelu/UI,21×3 lekcí,474 kontrol uložení a původní regresní sady |
| Physical3D po závěrečném auditu |41 kontrol PASS: identita, backup, hot-swap, kapacita/rozhraní, vytažený slot/save/rebuild, selhání RAID10, síť, napájení, oddělení všech3 režimů |
| World3D |35 kontrol PASS: pohyb a kolize, raycast a skutečné E, dveře a chůze do akademie, režimy vedení, konzole, konkrétní disk a LED; identifikační značka nepřejde do nové relace |
| World playthrough |34 headless /39 GPU kontrol PASS: servisní mise přes skutečné3D cíle, formuláře a potvrzení, výběr náhrady, rebuild a dokončení; fyzický switch port; stěna blokuje interakci; UHD škálování; návrat do kampaně a přímý vstup do15 misí |
| Godot MCP |77 interaktivních objektů; raycast/E/detail/Proxmox formuláře/změna/save/návrat PASS; errors=[] |
| Nastavení obrazu |76 kontrol GPU PASS; všech6 rozlišení včetně4K a upozornění na save |
| Ostrost původního UI |8 kontrol GPU PASS; nativní glyphy a38×38px SVG ve4K |
| Generátory |build_content.py včetně build_extension/world_catalog vytvoří bajtově shodné JSON; původních24 definic a21 lekcí nezměněno |
| Windows balíček |Samostatné EXE+PCK graficky provedlo stejný34kontrolový3D průchod; exit0, log bez chyb |

Závěrečný Test-All se všemi16 sadami (včetně World playthrough) skončil úspěšně.
Poslední dvě opravy menu a izolace zvýraznění navíc ověřily cílené testy
World3D35 a World playthrough34/39 kontrol. Log: `test-output/3d-test-all-final.log`.
Další logy: `3d-test-all.log`, `3d-playthrough-gpu-final.log`, `3d-package.log`,
`3d-display-gpu.log`, `3d-quality-gpu.log` a `3d-build-final.log`.

Vizuálně prohlédnuty GPU snímky serverovny, akademie, administračního rozhraní
a servisního formuláře ve4K. Modely jsou vlastní procedurální geometrie;
žádné externí licence/assety nebyly přidány. Statické díly používají sdílené
materiály a MultiMesh (1005 sloučených instancí); interakce/kolize/LED zůstávají
samostatné. Výměna disku je změna simulace, nikoli jen animace. Obnova RAID je
záměrně zrychlený laboratorní čas po50%; síť zůstává připravenou topologií.

## Následná oprava prázdného Nastavení

Po otevření stránky se zobrazovala pouze hlavička: kořenový VBox stránky
neměl vertikální roztažení a jeho ScrollContainer dostával nulovou výšku.
Opraveno nastavením `SIZE_EXPAND_FILL` na kořeni stránky.

Regrese nyní kontroluje plochu ovládacích prvků, hranice viewportu a ořezání
všemi nadřazenými scroll kontejnery. Před opravou selhalo27 kontrol, po opravě
`display_settings.gd` prošel68/68 headless a76/76 na GPU. Zahrnuto všech6
rozlišení, otevření skutečným tlačítkem a kombinace se save upozorněním v720p/4K.
Graficky prohlédnuty snímky `settings-720p.png` a `settings-warning-3840.png`.
Znovu prošly `ui_safety.gd`31/31 a `render_quality.gd`8/8; glyph oversampling
i38×38px DPITexture ve4K zachovány. MCP otevřel Nastavení a vrátil `errors=[]`.
Save i config testů zůstaly oddělené od hráčových souborů. Níže uvedený úplný
Test-All je z předchozí etapy; tato úprava ověřuje rozložení cílenými testy.
Windows EXE+PCK v `build/` byly aktualizovány a samostatně graficky ověřeny:
skutečné tlačítko otevřelo viditelné ovládací prvky v720p, kód0, čistý log
`test-output/settings-package.log`; prohlédnut snímek `settings-packaged.png`.

## Opravy po auditu: relace, ukládání a formuláře

Samostatné auditovací reprodukce byly převedeny do standardních regresí
v `tests/`; všechny tři nové skripty spouští také `tools/Test-All.ps1`.
Ověřuje se skutečný úspěch zápisu, nejen úspěch operace v simulátoru.

| Kontrola aktuálních oprav | Výsledek |
|---|---|
| `session_safety.gd`: restart série, indexy, undo a kolize `vmbr0` | 112/112 PASS |
| `save_safety.gd`: chyby souborů, struktura, migrace, zápisy všech misí | 387/387 PASS |
| `ui_safety.gd`: skutečná tlačítka, koncepty a stav uložení | 31/31 PASS headless i GPU |
| `display_settings.gd` na GPU: všech6 rozlišení, fullscreen, F11 | 49/49 PASS |
| `render_quality.gd`: skutečné pixely textu a DPITexture ve4K | 8/8 PASS |
| Godot MCP: izolovaná testovací scéna | Spuštěna, debug `errors=[]` |
| Úplný závěrečný `Test-All.ps1` | 13/13 sad PASS, kód0, bez runtime chyb a varování |
| Všechny mise v modelu i přes formuláře | 50/50 PASS, shoda původních24 definic PASS |
| Všechny lekce ve všech3 režimech včetně zápisů | 1075/1075 kontrol PASS |
| Lekce přes UI ve všech3 režimech | 336 akcí,0 chyb |
| Generátor a dřívější regrese | 199 +88 +35 kontrol PASS |
| Nastavení obrazu headless | 41/41 PASS |
| Přegenerovaný Windows EXE+PCK, grafické spuštění bez editoru | PASS, kód0, čistý log |

Regrese přechodů zahrnují kampaň → sérii → lekci → změněnou kampaň → obnovenou
sérii → obnovenou lekci → kampaň, všechny3 režimy lekcí a opakované vytvoření
GameManageru jako po restartu aplikace. Testují i přímé obnovení relace mimo UI.
Restart druhé úlohy zachovává předchozí výsledek, frontu, pozici a odloženou
kampaň. Neplatné indexy ponechají paměť i uložený soubor beze změny.

Chyba zápisu je vyvolána adresářem v izolované cestě dočasného souboru.
Zásah i dokončení ticketu přesto uspějí v paměti, vracejí `saved=false`,
poslední platný soubor zůstane beze změny a opakování uloží aktuální stav.
UI nabídne opakování a zablokuje neúspěšný návrat s uložením i ukončení.
Vadné JSON a strukturální varianty (včetně `scores:null`, chybného ID,
indexu série, kroku lekce a chybějící větve) nevyvolají chybu startu a nejsou
automaticky přepsány. Výslovná obnova uchová přesné původní bajty v záloze.
Schema1 fixture včetně dodatečné VM bez nových polí ověřuje XP, normalizaci
skóre, infrastrukturu a přesnou migrační zálohu. Testují se i desetinné klíče
lekcí ze staršího schema2 a záloha posledního platného souboru.

Graficky prohlédnuty `test-output/safety-draft-720p.png`, `safety-draft-4k.png`,
`safety-save-failed.png` a `safety-invalid-save.png`: skutečná rozepsaná RAM6144,
správné zvýraznění pole, čitelné upozornění, opakování zápisu a posuvné menu.
Test ověřuje i odeslání zachovaného nepotvrzeného čísla, koncepty různých VM,
disky, nabídky, checkboxy a terminál. Ostrost hran zvětšeného/nativního atlasu:
menu0,197/0,402, rack0,180/0,412, terminál0,123/0,257; SVG má38×38px.

Hráčův save ani nastavení nebyly zapisovány. Testy používají vlastní
`SaveManager.path_override`; grafické testy a MCP i `DisplaySettings.path_override`.
Obsahové katalogy, generátory a původních24 misí zůstaly nezměněné.
Koncepty a undo jsou úmyslně pouze v paměti relace; po restartu aplikace
se obnovuje potvrzená konfigurace. Automatická oprava vadného souboru ani
simulace fyzického výpadku disku či napájení nejsou součástí těchto testů.

Úplný závěrečný log je v `test-output/fixes-test-all-final.log`, grafický běh
nových UI regresí v `fixes-ui-graphics.log`. Windows build je v `build/`;
samostatný balíček byl testován externím skriptem s vlastními save/settings
cestami, včetně restartu série a obnovení VLAN39 v kampani. Logy sestavení
a balíčku: `fixes-build.log`, `fixes-package-engine.log`; prohlédnut snímek
`package-safety.png`. Test-output i sestavené binární soubory jsou ignorované
Gitem; samotné regrese a jejich zapojení do Test-All jsou verzované.

Následují záznamy předchozích etap.

Oprava ostrosti4K: `tests/render_quality.gd` prošel8 grafickými kontrolami.
Test porovnává skutečně vykreslené pixely při3840×2160, nejen velikost okna
či framebufferu. Ukazatel kontrastu hran původního zvětšeného atlasu / nativního
vykreslení byl0,197/0,402 pro nadpis menu,0,180/0,412 pro popisky racku a přibližně
0,125/0,261 pro systémový font terminálu.16px SVG ikona dostala skutečnou GPU
texturu38×38 při měřítku2,4. Zachováno přepínání rozlišení a stav simulace.
Grafický test nastavení znovu49/49 PASS a první interaktivní VM lekce PASS.
Všech50 misí znovu prošlo UI smoke testem včetně potvrzovacích dialogů bez
chyb. Aktualizovaný Windows balíček spuštěn bez editoru, kód0, čistý log;
MCP hlásí prázdný seznam chyb. Výřezy porovnání jsou v místním test-output/.

Dodatečné ověření nastavení obrazu a ukončení: `tests/display_settings.gd`
prošel graficky49 kontrolami a headless41 kontrolami. Grafický test skutečně
vykreslil všech6 nabízených rozlišení až3840×2160, přepnul nativní fullscreen
i okno, ověřil F11, načtení uložených voleb a viditelnost výukového cíle ve4K.
Samostatný běh vyvolal skutečné tlačítko Ukončit hru a skončil s kódem0 bez
chyb i varování. Ověřeno zachování rozehrané konfigurace. Znovu prošla první
interaktivní VM lekce a všech88 regresních kontrol. Předchozí kompletní průchod
obsahu je uveden níže; toto je cílená kontrola změn obrazu a menu.

| Kontrola | Výsledek |
|---|---|
| Godot MCP: verze, metadata, tvorba scény centra a spuštění | Provedeno; monitor později vrací „No active Godot process“ |
| Přímý grafický start Godotu se skutečným menu | PASS, exit code0, bez chyb v samostatném logu |
| První kompletní mise před rozšiřováním | PASS |
| Stavové dokončení všech50 misí | 50/50 PASS |
| Shoda původních24 definic s výchozím checkpointem | PASS |
| UI: formuláře, rizikové dialogy, cíle a předání ticketu | 50/50 PASS |
| UI: dobrovolné otázky a navazující vysvětlení | 50/50 PASS |
| Lekce: Učím se / Procvičování / Zkouška | 21×3 PASS,949 kontrol |
| Lekce přes skutečné UI a navigaci | 21×3 PASS,336 akcí |
| První9kroková lekce, nesprávná RAM a obnova rozpracovaného kroku | PASS |
| Generátor, kombinace filtrů, migrace save a doporučení | 199 kontrol PASS |
| Obměny generátoru ve20 seeded sériích | 77 odlišných konfigurací |
| Regrese: cíle, RAID, sítě, parser, rizika, save/load a XP | 88 kontrol PASS |
| Rozšíření: LXC, VSS, VHDX, Replica, spare a kvóty | 35 kontrol PASS |
| Vizuální kontrola1440×900 a1280×720 | PASS |
| Samostatný Windows engine + PCK | PASS, exit code0 |
| Git whitespace check | PASS |

Automatické UI testy vyplňují skutečné Control formuláře a vyvolávají jejich
signály; rizikové operace procházejí potvrzovacími dialogy. Nejde o ruční
odehrání všech misí. Snímky skutečně renderovaných obrazovek jsou v místním
ignorovaném `test-output/`.

Vedená výuka byla zkontrolována při1280×720: rámeček a šipka míří na RAM
skutečného VM formuláře. Praktický i zkouškový režim nepoužívají overlay;
zkouška nemá přímé nápovědy. Ukládání schema1→2 zachovává XP, skóre, chyby,
achievementy, rozpracovaný ticket i jeho infrastrukturu a vytváří v1 zálohu.
Náhodná série se obnoví ve stejné pozici včetně rozehraného stavu.

Testy ověřují i chyby: RAID10 ve stejném páru, libovolné dvě chyby RAID6,
chybné VLAN/DNS, odlišné možnosti External/Internal/Private, plný pool,
nesprávný slot/serial, původní RAW disk, nechráněnou cache, multiwriter LUN,
konfliktní obnovu, chybějící fencing, zámek VM, selhání VSS a shell injection.
Save/load se zkouší v oddělených testovacích souborech.

Windows balíček není standardní export přes exportní šablonu. Používá
plný lokální Godot engine a vyexportovaný PCK. Rozsah laboratorní simulace
a neimplementované úplné průvodce Ceph/CSV popisuje README.md.

Opakování všech testů:

```powershell
./tools/Test-All.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
```
