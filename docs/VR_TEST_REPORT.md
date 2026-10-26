# PC / PICO 4 – ověření 2026-10-26

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

Distribuce: `builds/windows/ITSupportSimulator.exe`, kompletní
`builds/ITSupportSimulator-Windows.zip`, `builds/pico4/ITSupportSimulator-PICO4.apk`.
Přesné velikosti a SHA256 jsou v `builds/VERIFICATION.json`. ZIP/APK se ukládají
na GitHub; samotný EXE je větší než GitHub limit pro jeden soubor a je uvnitř ZIPu.
