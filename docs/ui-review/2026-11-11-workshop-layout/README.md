# Pracovní panel dílny a dveře / 11.–12. 11. 2026

Zadání navazuje na zdroj `91c0ab4`. Ovládání a pravidla pokusů jsou v
[NETWORK_WORKSHOP.md](../../NETWORK_WORKSHOP.md).

## Změna

Pět záložek odděluje ticket, diagnostiku, opravy, analyzátor a rozbor. Výběr
ticketů a historie mají vlastní tlačítka, spodní akce jsou mimo posouvaný obsah.
Měření uvádějí skutečný zdroj a cíl, aktuálnost i stručný výsledek. Detaily jsou
rozbalovací. Opravy mají sedm samostatných skupin a potvrzení resetu. Fokus,
posun a rozpracované volby přežijí překreslení i návrat do 3D.

Tabule topologie má společné lokální souřadnice a končí před obložkou dveří.
GSM sestava se posunula jako celek včetně fyzických cílů a kolizí. Pohyb dveří
odhalil původní kolizi křídla s pravým rámem; odsazení závěsu za obložku ji
odstranilo bez změny typu dveří, vypínání kolizí nebo čidel. Celé snímky HUD
žádné skutečné oříznutí levého horního rohu neukázaly.

## Reprodukce

```powershell
& $Godot --headless --path . --script tests/network_workshop.gd
& $Godot --headless --path . --script tests/workshop_layout.gd
& $Godot --path . --rendering-method gl_compatibility --script tests/workshop_layout.gd -- --screenshots
& $Godot --path . --rendering-method forward_plus --script tests/workshop_layout.gd -- --screenshots
& tools/Test-All.ps1 -GodotPath $Godot
python tools/build_windows.py --godot $Godot
python tools/test_workshop_package.py --godot $Godot
```

Testy nastavují `SaveManager.path_override` i samostatné cesty obou nastavení
před vznikem hry. Měření, zápis i jeho skutečné selhání používají izolovaná data.

## Obrazové důkazy

[before](before/) zachycuje původní stav, [after](after/) nový. Stejný testovací
skript a kamery pokrývají diagnostiku, opravy, běžný příchod, otevřené dveře a
ovladač, návrat z dílny i celou tabuli s GSM. Výchozí Opravy jsou spodní část
původní Diagnostiky. Nová matice obsahuje 720p/1080p/4K při 100 a 130 % textu
v obou rendererech. Skutečný VR SubViewport má 1600 × 1200, obě velikosti textu,
syntetické kliky obou paprsků a posouvání. Fyzický headset není ověřený.

Nová sada navíc ověřuje 11 zdrojů měření, navigaci bez vedlejších účinků,
zastaralé důkazy, uzavřenou zkoušku, A–H ve volném tréninku bez historie,
bezpečné opakování zápisu, stabilní fokus a posun, rozbalení, potvrzení resetu,
Tab/šipky/Enter/Esc/B/Y, 90 fyzikálních kroků pohybu křídla, oba ovladače,
obousměrnou chůzi a fyzickou SIM s předáním hovoru mezi BTS.

## Průběžný stav

Aktuálně 284 nových headless kontrol a 454 kontrol celé matice Forward+ PASS.
Původní sada dílny po rozdělení navigace prošla 492 kontrolami. Kompletní
55sadový runner, finální Compatibility a nový přesný EXE jsou ještě ověřované.
Tato část bude po dokončení nahrazena skutečnými závěrečnými výsledky.
