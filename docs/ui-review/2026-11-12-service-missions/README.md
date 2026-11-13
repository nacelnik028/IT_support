# Servisní mise, varianty, tester a zvuk — ověření

Zdrojové etapy A–E rozšiřují existující dílnu a původní editor/interpretr.
Vstup: Rozcestník → 05 / Počítačové sítě → vzadu vpravo Tréninková dílna →
Servisní stůl. Vyber režim a společnou misi nebo běžný ticket/variantu.

## Finální regrese a export

Zdroj `cc18d3adec9bedd1494ff9ea1a09ce7f91fb831d`. **63/63 sad Test-All PASS**, všech 21 lekcí v každém ze tří
režimů a 336 UI akcí; bez runtime chyb a varování. [Úplný log](verification/test-all-release.log),
[souhrn](verification/test-all-summary.json), [kontrola generátorů](verification/final-content.log).

Nové EXE **104702320 B**, SHA256 `44d2e068f51e7e21d20beccb0d1814d6e264fef7c4e63bdbf41d5e1a4eec324c`. Nativní start samotného
EXE s grafikou i bez ní, obě dokončené mise a 7 nenulových PCM. Dalších 16
headless a tři grafické sady běží proti přesně témuž vloženému packu, game
resources nejsou nahrazené: [výsledky](verification/package/results.json),
[nativní snímek](verification/package/native-service-review.png).
Inventář kontroluje všechny JSON hodnoty a přesné nativní QOA bloky sedmi
zvuků proti zdrojovému Godot importu, vedle hashů původních WAV. Dekódování
nenulového PCM a přehrávání je samostatně ověřené.
Manifest všech 331 herních souborů souhlasí se zdrojem.

[Soupis 164 PNG, rozměry a SHA256](verification/screenshots.json).

Reprodukce z kořene projektu (Godot 4.7.2):

```powershell
./tools/Test-All.ps1 -GodotPath '..\..\Godot_v4.7.2-stable_win64_console.exe'
python tools/verify_service_content.py
python tools/build_windows.py --godot '..\..\Godot_v4.7.2-stable_win64_console.exe'
python tools/test_service_package.py --godot '..\..\Godot_v4.7.2-stable_win64_console.exe'
```

Zvukové bloky se pro porovnání nově rekonstruují přímo z autorských WAV a
importních voleb, takže kontrola nepotřebuje předchozí zdrojovou `.godot` cache.

## Co protokoly prokazují

- `workshop_variants`: 1 067 kontrol, seed 0 a tři skutečné obměny každého A–H,
  všechny režimy, alternativní opravy, odmítnuté zkratky, reset/undo/ukázka.
- `support_dialogue`: 2 124 kontrol, pozorování zákazníka odpovídá variantě,
  skutečná příčina/změna/ověření, nezávislé komunikační skóre, žádný falešný
  technický důkaz z dotazů nebo zákazníkova potvrzení.
- `service_missions`: 199 kontrol, obě mise ve třech režimech, aktuální vstup
  a revize Pythonu, chybný i alternativní program, chybějící důkaz, oddělená
  technická/jazyková pomoc, starý profil, skutečné selhání zápisu a jediné XP.
- `service_missions_ui`: 639 bez grafiky; 696 v každém rendereru graficky.
  Šest úplných PC průchodů, skutečné vložení kódu přes CodeEdit, chybné řešení
  a oprava, obě syntetické XR ruce, funkční virtuální klávesnice.
- `service_continuation`: 92 bez grafiky; skutečné akce potvrzení, replay,
  resetu, odložení, zkoušky po obnovení, restartu a opakování zápisu.
- `cable_tester`: 45 bez grafiky / 49 graficky, skutečné konektory a porty,
  obě grip poses a paprsky, nesouhlasící/otevřená/nedostupná trasa a zastaralost.
- `service_audio`: 52 kontrol bez grafiky i graficky, nenulové dekódované PCM,
  skutečné přehrávače, úspěšné a odmítnuté události, pohyb/dveře, London Speech,
  hlasitosti/pauza/focus a zánik čtyř živých smyček bez testovacího časovače.

Zdrojové grafické matice používají Compatibility i Forward+, 1280×720,
1920×1080 a 3840×2160 při textu 100/130 %. VR snímky pocházejí přímo ze
SubViewportu 1600×1200 při obou velikostech textu, nikoli ze zmenšeného
desktopového zrcadla. Snímky byly vizuálně prohlédnuté včetně 720p/130 %,
editoru a klávesnice ve VR, přenosného displeje a závěrečného rozboru.

## Vybrané snímky

- [Rozpracovaná mise a zákazník](mission-customer-SERVICE-PORTAL-exam-gl_compatibility.png)
- [Předání při 720p / 130 %](mission-dialog-mission-1280-130-gl_compatibility.png)
- [Editor a VR klávesnice / 130 %](mission-editor-keyboard-mission-vr-130-gl_compatibility.png)
- [Výsledek Pythonu po přesunu pracoviště](mission-python-SERVICE-MOVE-exam-gl_compatibility.png)
- [Přenosný tester ve scéně](tester-carried--gl_compatibility.png)
- [Stejné měření pravým XR paprskem](tester-vr-1--gl_compatibility.png)
- [Souhrn výsledku](mission-result-mission-3840-130-forward_plus.png)
- [Skutečný průchod Godot MCP](mcp-service-review.png)
- [Editor a XR klávesnice přesného exportu](export/mission-editor-keyboard-mission-vr-130-gl_compatibility.png)
- [Tester ve 3D přesného exportu](export/tester-carried--gl_compatibility.png)

Exportní PNG jsou v krátké složce `export/`, aby šly uložit do Gitu i při
hluboko vnořené Windows cestě projektu. Relokace zachovala bajty; tři grafické
sady byly zopakované s touto cestou. [Protokol](verification/short-evidence-paths.log).

## Zvuk a výkon

`C-before-*` a `C-after-*` zachycují tutéž kameru v obou rendererech.
Zdroj před zvukem 51ca3e5, RTX 5060, 1920×1080, VSync off, 90 zahřívacích
a 240 měřených snímků. Průměr intervalu snímků Compatibility 3,790→3,862 ms,
Forward+ 3,722→3,887 ms. Počet draw calls se nezměnil (2473 / 727).
Surové logy mají předponu `C-`. Nejde o oddělené CPU/GPU měření nebo PICO FPS.
Sedm WAVů má vlastní deterministický generátor, CC0 a SHA256 v manifestu.
Automatické dekódování a přehrávání nenahrazuje lidský poslech.

## Interpretace protokolů a omezení

`verification/mcp-mixer-fixed.json` zachycuje obě dokončené mise, sedm
nenulových PCM a pouze osm původních statických varování mimo nové části.
`lab-mixer-fixed-1..5.log` dokládají pět čistých původních síťových průchodů
po opravě asynchronního úklidu audio serveru. Předchozí přerušené a chybové
logy zůstávají označené `interrupted`, `failed`, `cleanup` či `investigation`;
nejsou dokladem finálního úspěchu. Úplná regrese používá původní přísná
pravidla pro chyby i varování a izoluje save i nastavení.

Generátor verze 1 má tři odlišné třídy obměn na ticket; další kladné seedy je
opakují. Běžné A–H jsou dočasné během návštěvy, společné mise se odkládají
do samostatné větve profilu. Tester měří fyzickou trasu a dostupnost portu,
ne VLAN/DNS. Python je bezpečná podporovaná podmnožina nad virtuálními daty.
Komunikace není certifikace CEFR. Fyzický headset a subjektivní poslech nebyly
ověřené. APK zůstává dřívější, bez tohoto servisního rozšíření. Bez push/publikování.

První běh exportního QA (`verification/package-harness-failed/`) odhalil chyby
izolace a složek pro snímky v novém externím runneru. Zvuková kontrola také
chybně předpokládala nekomprimované bajty: zdrojové importní nastavení používá
nativní QOA. Finální kontrola zachovává kořen user://, izoluje názvy fixture
i filtry záloh, vytváří cílové složky a porovnává přesná importovaná data se
zdrojovým importem, hash autorského WAV zvlášť. Původní aserce zůstávají;
herní zdroj ani EXE se těmito opravami ověření nezměnily.

Podrobnosti: [dílna](../../NETWORK_WORKSHOP.md),
[mise](../../SERVICE_MISSIONS.md), [zvuk](../../SERVICE_AUDIO.md).
