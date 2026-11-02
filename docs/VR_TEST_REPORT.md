# PC / PICO 4 – ověření

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
