# PC / PICO 4 – ověření

## Finální vydání 1.5.0 — dokončeno 4. 11. 2026

Tato sekce uvádí výsledky pro skutečné aktuální soubory. Starší oddíly níže jsou historické. Původní zadání bylo nejprve dokončené v ec51021; následně doplněná verze v Nastavení (88a0bdb), zrušení drženého XR stisku (a6d58e3) a platný tracker v testu (74edf37).

- **Celý aktuální Test-All: 46 sad PASS**, 46 skutečných startů Godotu, exit 0, bez runtime chyb/varování. Nová matice 239 headless, koncepty 69, skóre 31, pokročilé směny 268, rozbor 49, poslech 515 a profil 38 PASS. Zachované legacy24, 65 misí přes formuláře, 1075 kontrol lekcí, save_safety 474, všechny tři režimy / 336 výukových UI akcí. Programování 765 kontrol / 252 variant, včetně platného syntetického trackeru a původní hranice editoru; fyzický programovací průchod 29 PASS i s výslovnou pauzou/pokračováním.
- **Grafika: 351 Compatibility / 351 Forward+ PASS**, 224 aktuálních PNG. Osm obrazovek včetně verze 1.5.0 v Nastavení: 1280×720, 1920×1080, 3840×2160 × text 100/130 %. Skutečný VR SubViewport 1600×1200, obě velikosti textu/klávesnice/panel 80/140 % a vzdálenost 0,9/2 m. Oba paprsky a úplný trigger, současné triggery, release mimo, drag/scroll, A/X a B/Y. Držený trigger se při focus-out, neplatném/odebraném trackeru, resize a A/X zruší bez potvrzení tlačítka. Původní XR 120 PASS.
- **Windows: 27 externích sad + native headless, Compatibility a Forward+ PASS.** Samotný přejmenovaný EXE z cizí pracovní složky bez projektu/PCK/editoru. **APK: 20 externích sad + dva desktopové smoke běhy PASS** nad skutečnými prostředky, původní certifikát/podpis/CRC/ARM64 OpenXR/1.5.0 code 6 ověřené. Dalších deset cílených sad na každý přesný balíček PASS. Navíc aktuální trackerová fixture programování 765 PASS nad oběma přesnými balíčky. Obsah Windows 5616 kontrol / 282 souborů, APK 5563 / 286, 277 materiálů; skutečné MP3 bajty a všechny hodnoty JSON shodné.
- **EXE 104454336 B**, rezerva **403264 B** pod 100 MiB. SHA256 `7e8caea9d12a0771c65c15b553c8e96630c521f5935307f295bd124ebb39c366`. **APK 90829657 B**; SHA256 `bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`.
- Herní zdroj `a6d58e3`, fixture testů 74edf37, shodný manifest 269 zdrojů `3723c98d56314e39be0b5f56b891ba510c63a76a03fa11914620f3f7b029f022`. [BUILD_INFO](../build/BUILD_INFO.md), [strojové ověření](../build/VERIFICATION.json), [snímky a trvalé logy](ui-review/2026-11-04-release/README.md), [ovládání všech funkcí](CONTINUATION_RELEASE.md). MCP aktuálního zdroje 31 PASS; osm původních statických varování je oddělených v mcp.json, bez nových či plošného potlačení.
- Staré save/schema1/2, kampaň/směna/učebny, koncepty a jediné XP po selhání zápisu/retry/restartu ověřené. Generátory obsahově reprodukovatelné a prvních 24 definic/legacy_campaign zachované. Neúspěšné vývojové běhy a předchozí hashe jsou archivované odděleně; žádné staré PASS nejsou připsané novému souboru.
- **PICO hardware NEPROVEDENO – headset není dostupný.** Android native start/aktualizace, stereo, tracking a ovladače, optická čitelnost, komfort, FPS/paměť čekají na zařízení. Subjektivní lidský poslech neprovedený; automatické hashe/dekódování/nenulové PCM/skutečný přehrávač ověřené. Žádné ADB dotazy či nasazení a žádný Git push.

## Ukládání, směny a poslech — původní zadání dokončeno 4. 11. 2026

- Celý aktuální Test-All **46 sad PASS**, 46 startů enginu, exit 0, bez runtime chyb/varování. Nové sady: work_persistence 69, shift_scoring 31, advanced_shifts 268, attempt_review 49, london_listening 515, unified_profile 38 a continuation_review 200 headless. Kampaň/legacy24, staré save a jediné odměny zachované; save_safety 474, lekce 1075, UI všech 65 misí a 336 výukových akcí ve všech třech režimech PASS.
- PC/VR grafická matice: **298 PASS Compatibility / 298 PASS Forward+**, 196 aktuálních PNG. Šest PC kombinací, skutečný VR 1600×1200, text 100/130 %, panel 80/140 % a 0,9/2 m, obě ruce, trigger/scroll/drag/klávesnice, focus/tracking. MCP 31 PASS; osm původních statických varování odděleně, bez nových.
- Windows **27 externích sad + dva nativní smoke běhy PASS**. Přejmenovaný samotný EXE z cizí složky, bez projektu/PCK/editoru. APK: podpis/původní certifikát/CRC/ARM64 OpenXR/1.5.0 code 6 PASS, **20 externích sad + dva desktopové smoke běhy PASS** nad skutečnými APK prostředky. Dalších deset cílených sad pro každý přesný balíček PASS. Obsah: Windows 5616 kontrol / 282 souborů, APK 5563 / 286; 277 materiálů, skutečné audio a JSON hodnoty shodné.
- EXE **104,453,712 B**, rezerva **403,888 B** pod 100 MiB; SHA256 `3186142a681c55386ba0669751c6466fbdffd73f5d422aac725e460e6ccccf26`. APK **90,829,077 B**; SHA256 `b97c5a8d15fcf1d074d2eeac235afbe5980e71dd7e8e6ef3060ee77cd0c6bdf4`.
- Zdrojový commit `a43cd6d`, shodný manifest 269 zdrojů `db723a77ce1a7a7c7da99e5857850850a101a773f34ee083bdd6d0fccb2e573c`. [Přesná metadata](../build/VERIFICATION.json), [aktuální snímky a trvalé logy](ui-review/2026-11-04-release-base/README.md), [ovládání](CONTINUATION_RELEASE.md).
- **PICO hardware NEPROVEDENO – headset není dostupný.** Android native start, stereo, tracking/ovladače, optika, komfort, FPS a paměť nejsou těmito testy potvrzené. Subjektivní lidský poslech neprovedený; hash/dekódování/PCM/skutečný přehrávač ano. Bez ADB a bez push.

Tato fáze uzavírá původní prompt. Uživatelské doplnění verze v nastavení následuje až potom; jeho nové exporty budou mít vlastní ověření. Starší sekce níže jsou historické.

## Gameplay bez headsetu — 2026-11-03

Praktický úvod, tři souvislé směny, síťové vysvětlení, 12 mluvených replik
s pomalými variantami, nastavitelný panel a volitelná diagnostika jsou implementované.
Výchozí panel 1,76×1,32 m / 1,25 m i viewport 1600×1200 zůstaly zachované;
komfort dovoluje 80–140 % a 0,9–2 m, s resetem a persistentním CFG.

- XR 116 headless/GPU Compatibility PASS: skutečné syntetické trackery a obě ruce,
  ray/pixel i po změně velikosti/vzdálenosti, skutečný drag, scroll, release mimo
  monitor, virtuální klávesnice, focus/tracking a původní výukové hranice.
- Gameplay review 77 headless / 129 GPU v Compatibility i Forward+ PASS.
  Celý úvod synteticky přes head pose, teleport, ovladač dveří/průchod, levý ray
  na monitor a UI, pravý grip konkrétní náhrady, vrácení a pauzu. Oba paprsky
  přehrávají přesný poslech bez volby odpovědi nebo dvojí operace.
- 104 [trvalých PC/VR snímků](ui-review/2026-11-03-gameplay/README.md), text 100/130 %,
  skutečný SubViewport s klávesnicí i bez ní. Na PC se opravdu vykreslilo 720p/1080p/4K.
  Screenshot neověřuje optiku headsetu.
- APK 1.4.0 / code 5: podpis/CRC/ARM64/PICO/OpenXR PASS, původní certifikát zachován.
  13 externích sad a oba smoke běhy nad skutečnými APK prostředky v desktopovém
  Godotu PASS; dodatečně směny 136, gameplay 212 a XR 116 PASS. Windows má oba
  nativní EXE-only smoke běhy a 20 balíčkových sad PASS. SHA256 viz build/VERIFICATION.json.

Diagnostika uvádí skutečné FPS, interval 1/FPS, renderer, viewport a engine
statistiky. **CPU/GPU časy se neměří** a 72 Hz není naměřených 72 FPS.
Audio bylo dekódováno a přehrávač spuštěn na PC; subjektivní lidský poslech
se tím neprohlašuje za provedený.

**NEPROVEDENO – headset není dostupný:** Android native start, stereo, tracking,
optická čitelnost, komfort a výkon/paměť na PICO. Bez ADB dotazů či instalace.
[Konkrétní pozdější hardwarový checklist](PICO4_HARDWARE_CHECKLIST.md).
Podrobné výsledky a vývojová selhání/opravné běhy jsou v TEST_REPORT.md.

## Rozcestník a B1–B2 — 2026-11-03

Nový společný start PC/VR je neutrální hala se čtyřmi fyzickými průchody.
Teleport zahrnuje halu i východní chodbu; oblouk a cílová kapsle respektují
zavřené dveře, stěny, vybavení a zákaz řeky mimo most. Původní posuvné dveře,
snap turn, kalibrace, sezení/stání, oba ovladače a ochrana při focus/tracking
zůstávají součástí existujícího XR systému. Dekorace místností nepřidávají
bitmapy, monitory ani světla; statická geometrie používá sdílené materiály.

Celý zdrojový Test-All: **36 sad PASS**. academy_hub 52, english_model 1809,
london_quiz 527, english_world **1043 headless / 1063 graficky**, xr_modes 69.
Syntetické XR testy používají skutečné ray kliky do SubViewportu oběma rukama,
úplný press/release, opakované/souběžné triggery, jednu platbu/odměnu, všech
šest situací B1–B2 a všech 20 otázek, room-scale odchod i teleport z UI.
Nejde o fyzický tracking. Kampaň se obnovuje i po přímých přechodech mezi kurzy.

Audit na RTX 5060 v Compatibility i Forward+: 49 snímků/profil, všechna prostředí,
720p/1080p/4K a 100/130 % textu; 280 materiálových instancí bez chybějících
přiřazení a 27 strukturálních stěn bez koplanárního překryvu. Opravený londýnský
průchod, směrové cedule, krky postav a dekorace jsou vizuálně zkontrolované.
Výsledky exportů uvádějí aktuální TEST_REPORT.md a build/VERIFICATION.json.
Samostatné Windows: oba nativní starty a 17 externích sad nakonec PASS.
Skutečné prostředky nového APK: headless/GPU smoke a 10 externích sad PASS.
Dodatečný GPU audit obsahu obou packů: 5033/5057 kontrol, všechny JSON hodnoty,
278 počátečních materiálových instancí, platné shadery a vygenerované textury.
Dočasně se vypíná jen seznam Android GDExtension při desktopovém čtení APK;
Android nativní knihovny tím nejsou testované.

APK **1.3.0 / versionCode 4**, původní `cz.academy.itsupport`, ARM64 a OpenXR/PICO
manifest: podpis a CRC PASS. SHA256 certifikátu nového i předchozího APK je
`3449ce02012b69d3d0b9d19eea1706521e290fac48ab7ff1d5d20bea8c003997`;
možnost aktualizace zachována. `adb devices -l` stále nevrací autorizovaný
headset. **Android start, reálný tracking, optická čitelnost, komfort a FPS
na PICO nejsou ověřené.** Cílových 72 Hz není naměřených 72 FPS.

Níže jsou historické výsledky před touto etapou.

## English in London — 2026-11-02

Nové EXE i APK obsahují šest situací, tři režimy a varianty včetně skutečných
počtů/cen. Nové společné UI prošlo reálnými ray kliky obou syntetických XR
ovladačů v SubViewport, včetně press/release, současných triggerů, jediné platby
a konkrétní vstupenky. Teleport z místnosti a fyzický odchod ruší dialog a vracejí
kampaň. Snap, tracking/focus a virtuální vstupy nadále ověřuje xr_modes 69.

Celý zdrojový Test-All: 34 sad PASS. Anglický model 988, PC/syntetické XR
409 headless a 417 graficky PASS. Přesné EXE: nativní headless/GPU smoke a 14
zabalených sad PASS po zdokumentované opravě automatizace nativní pauzy.
PICO APK 1.2.0 / versionCode 3: podpis/CRC/ARM64/OpenXR PASS; skutečné prostředky
APK v desktopovém Godotu: oba smoke běhy a sedm sad PASS včetně Londýna.

Finální model navíc kontroluje nejbližší dostupný čas, celkem má 988 kontrol.
Žádný autorizovaný PICO nebyl připojený. Android spuštění, fyzický tracking,
komfort a 72 FPS se neprohlašují za ověřené. Kompletní aktuální rozlišení důkazů,
hashů a původních selhání je v TEST_REPORT.md a build/VERIFICATION.json.
Hlášené textury vstupu do Londýna a audit všech materiálů jsou výslovně zahrnuté
do dalšího zadání PROMPT_ACADEMY_HUB_PC_VR.md; funkční test je nenahrazuje.

## Původní XR etapa — 2026-10-26

Existující projekt Godot 4.7.2, 65 misí, 21 lekcí ve třech režimech. Žádný
katalog, generátor ani legacy24 se při přidání XR nemění.

| Oblast | Výsledek | Důkaz / rozsah |
|---|---|---|
| Celá původní hra + XR | PASS | `test-output/final-xr-test-all.log`, 25 sad, exit 0. 65 misí v modelu i UI, 21×3 lekcí (1075 kontrol), 336 výukových UI akcí, save 474, relace 124, hranice místností 68. |
| XR integrace | PASS – syntetické | `tests/xr_modes.gd`, finálně 69 kontrol headless i GPU Compatibility. XRTracker poses, skutečné signály trigger/grip/B a joysticky, přerušení a obnova head pose bez restartu session; nejde o test fyzického tracking. |
| VR UI | PASS – syntetické | Skutečný ray klik v SubViewport včetně levého ovladače při jiném směru pravého, editace původního formuláře virtuální klávesnicí, Backspace, vložené dialogy. Prohlédnut snímek `test-output/xr-monitor-console.png` (1600×1200). |
| Trénink ve VR | PASS – syntetické | Vstup/odchod teleportem ve všech learn/practice/exam, fyzický odchod při otevřené konzoli, reset cvičné infrastruktury/UI, obnova kampaně. |
| Desktop 3D přes MCP | PASS | `WorldMCP.tscn`: 79 objektů, raycast/E, původní Proxmox formuláře, zásah/save/návrat, opakované dveře, akademie a instruktor; MCP `errors=[]`. |
| Windows Release | PASS | Skutečný oficiální Release EXE s vloženým PCK, samostatný headless i grafický start mimo projekt; menu, 65/21 obsah, svět, akademie/návrat. `test-output/platform-build/native-*-game.log`. |
| Windows zabalená hra | PASS | Externí testy proti přesnému exportovanému PCK: XR 69, terminál 64, ui_design 162, world_ui 27 a world_playthrough 39 kontrol. `test-output/windows-package/results.json`. Testovací kamera při automatickém míření nezachytává myš, aby nativní recenter neměnil raycast. |
| PICO APK | PASS – sestavení | Podepsané Debug APK, pouze arm64-v8a, min 29 / target 34, PICO VR metadata, OpenXR loader a vendor .so. `apksigner verify`, `aapt dump badging` a sloučený manifest v `test-output/platform-build/`. |
| PICO fyzický headset | NEPROVEDENO | `adb devices -l` nevrací autorizované zařízení. APK nebylo nainstalováno ani spuštěno na PICO. |
| PC VR nedostupný | PASS – očekávané odmítnutí | Skutečný EXE mimo projekt s `--xr-mode on`: runtime zde není dostupný, engine hlásí inicializační chybu a přejde do normálního režimu; hra vrátí menu, exit 0, žádný SCRIPT ERROR. `test-output/native-pc-vr-unavailable.log`. |
| PC VR runtime + headset | NEOVĚŘENO NA HARDWARU | Reálné stereo, tracking hlavy/ovladačů a PC streaming vyžadují headset/runtime. |
| 72 FPS na PICO | NEMĚŘENO | Předvolba žádá 72 Hz, pokud runtime nabízí. Úspěšný export ani GPU test na RTX 5060 nepotvrzuje 72 FPS na PICO. |

Všechny herní testy nastavují `SaveManager.path_override`, DisplaySettings a
VRSettings používají vlastní testovací konfigurace. Samostatný EXE smoke používá
`--test-world` před konstrukcí GameManageru. Hráčův `academy_save.json` se pro testy
nepoužívá. Přenos save je validovaný, odmítá poškozený JSON a zálohuje původní soubor.

Windows používá vestavěné Godot OpenXR. Vendors 5.1.0 je součástí editoru a
Android APK; Windows se exportuje ze stejného zdrojového stromu bez Android
vendor GDExtension. Odstraňuje to zbytečnou PC nativní závislost a její předčasné
varování na `hand_tracking`. PC 3D má původní kvalitu; VR vypíná stíny a obrazové
efekty, standalone také ventilátory a používá Compatibility s 2× MSAA.

Před vydáním pro běžné hráče zbývá nasadit APK na běžný PICO 4 a ručně projít
tracking/recenter, obě ruce, teleport/dveře, snap a sezení, uchopení/vložení disku,
kabel a power, vytvoření VM, RAM/CPU, VLAN/IP, disk, backup, terminál, všechny
tři výukové režimy a odchod při otevřeném monitoru. Změřit GPU/CPU frame time,
FPS a paměť delší relace; cílový rozpočet při 72 Hz je přibližně 13,9 ms/snímek.
Nastavení čitelnosti a pohodlí obrazovky je nutné potvrdit v optice headsetu.

Aktuální distribuce po sjednocení 2. 11. 2026: `build/ITSupportSimulator.exe`
a `build/pico4/ITSupportSimulator-PICO4.apk`. Starší Windows ZIP byl odstraněn.
Přesné velikosti a SHA256 jsou v `build/VERIFICATION.json`, zdroje nového APK
v `build/pico4/BUILD_INFO.json`. EXE i APK se ukládají přímo na GitHub.
Výsledky v tabulce výše jsou historické z 26. 10.; aktuální kontroly uvádí TEST_REPORT.md.
