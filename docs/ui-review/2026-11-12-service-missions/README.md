# Servisní mise, varianty, tester a zvuk — ověření

Zdrojové etapy A–E rozšiřují existující dílnu a původní editor/interpretr.
Vstup: Rozcestník → 05 / Počítačové sítě → vzadu vpravo Tréninková dílna →
Servisní stůl. Vyber režim a společnou misi nebo běžný ticket/variantu.

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

Podrobnosti: [dílna](../../NETWORK_WORKSHOP.md),
[mise](../../SERVICE_MISSIONS.md), [zvuk](../../SERVICE_AUDIO.md).
