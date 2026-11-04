# Finální verze 1.5.0 — 4. 11. 2026

224 skutečných PNG: 112 Compatibility a 112 Forward+. Osm obrazovek včetně Nastavení s aktuální verzí, šest PC kombinací a skutečný 1600×1200 VR SubViewport s textem 100/130 %, klávesnicí otevřenou/zavřenou, panelem 80/140 % a vzdáleností 0,9/2 m. 351 kontrol na renderer / 239 headless PASS. Snímky byly znovu vytvořené po XR opravě; původní stav před doplněním verze je v ../2026-11-04-release-base.

- [Nastavení 1280×720 / 130 %](gl_compatibility-settings-1280-130.png)
- [Nastavení VR / 130 %, klávesnice, maximální panel](forward_plus-settings-keyboard-vr-130-panel1.39999997615814.png)
- [Obnova kódu 4K / 130 %](gl_compatibility-code-3840-130.png)
- [Poslech a zaznamenaná pomoc](gl_compatibility-listening-result-1280-130.png)
- [Společný profil 4K](forward_plus-profile-3840-130.png)

Prohlédnuté originály a kontaktní listy, bez useknutého údaje verze nebo hlavních ovladačů; delší rozbor/profil/fronta má scroll a fokus. Kontaktní listy jsou pouze přehled, originály zachovávají skutečné rozlišení.

[verification](verification) obsahuje celý 46-sadový zdrojový běh, přesné Windows/APK/focused výsledky, inventáře a native Forward+ EXE-only smoke. mcp.json: 31 PASS a osm předchozích statických varování. Neúspěšný audit drženého triggeru a předchozí výsledky jsou oddělené; nový cancel vyjede mimo tlačítko a teprve poté pustí stisk. Focus, invalidní/odebraný tracker, resize i A/X potvrzené skutečným Button counterem, oba paprsky/drag/scroll zachované.

**PICO hardware NEPROVEDENO – headset není dostupný.** Tyto snímky nejsou optická čitelnost v headsetu ani měření trackingu/FPS. APK běžel pouze jako desktopové prostředky. Audio testy nedokládají subjektivní lidský poslech. Bez ADB a bez push.
