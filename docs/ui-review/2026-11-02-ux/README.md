# Training academy — implementované UI/UX, 2. 11. 2026

Všechny snímky zachycují skutečnou hlavní scénu a její rozhraní.
Výchozí kód je commit 99c201215f83408f333829ed05aa0489253acc14;
kopie před změnami sloužila pouze ke srovnání, nebyl vytvořen Git worktree.

## Konkrétní změny

- Menu: kompaktní identita, hlavní tyrkysové 3D tlačítko, sekundární VR a tři
  popsané části hry. Nastavení a Ukončit zůstávají bez celostránkového posuvu.
- Vstup do programování používá stávající cestu z pauzy. Nezačne úlohu a obnoví
  odloženou kampaň při návratu. Učebna zůstává vlevo; měnily se pouze popisky.
- Oznámení místnosti: malý panel vlevo dole, jeden aktuální text, 4 s životnost.
  Neuložené změny mají trvalou informaci a existující opakování zápisu.
- Editor: Spustit kód / Ověřit řešení, oddělené záložky, přesná diagnostika,
  nativní buffery a označení výsledku předchozí verze. Trvalé ukládání kódu
  není přidané ani slibované.
- Formuláře: rozepsání, použití, skutečné uložení a odmítnutí mají textový stav
  pro konkrétní kontext. Surový číselný koncept přežije překreslení i fokus.
- Název Training academy zachovává stávající kompatibilní složky save/config.

## Srovnatelné snímky

Linux Godot 4.7.2, OpenGL Compatibility, Mesa llvmpipe, Xvfb; stejný renderer,
rozlišení, 130 % textu, mise 4 a deterministické přechody/kamera testu.
Pro levnější software rendering se v obou bězích použila preference Úsporná.
Není to změna produkční konfigurace. Pořadí obrazovek a data zadání určuje
ui_workflow.gd. Předchozí editor měl v chybové scéně výklad režimu learn;
nový snímek je správně v practice podle viditelného přepínače.

| Obrazovka 1280×720, 130 % | Před | Po |
|---|---|---|
| Hlavní menu skutečné 3D scény, včetně VR | [před](before-menu-720-130.png) | [po](after-menu-720-130.png) |
| Oznámení místnosti | [před](before-room-notice-720-130.png) | [po](after-room-notice-720-130.png) |
| HUD kampaně | [před](before-hud-720-130.png) | [po](after-hud-720-130.png) |
| Validační chyba formuláře | [před](before-form-validation-720-130.png) | [po](after-form-validation-720-130.png) |
| Dlouhý formulář | [před](before-form-long-720-130.png) | [po](after-form-long-720-130.png) |
| Editor s chybou | [před](before-editor-errors-720-130.png) | [po](after-editor-errors-720-130.png) |
| Výstup programu | [před](before-editor-output-720-130.png) | [po](after-editor-output-720-130.png) |
| Ověření | [před](before-editor-results-720-130.png) | [po](after-editor-results-720-130.png) |
| Nastavení | [před](before-settings-720-130.png) | [po](after-settings-720-130.png) |
| Lekce | [před](before-lessons-720-130.png) | [po](after-lessons-720-130.png) |

Selhání ukládání: [formulář](after-form-save-failure-720-130.png),
[programovací editor](after-editor-save-failure-720-130.png).
4K/130 %: [menu](after-menu-4k-130.png), [editor](after-editor-4k-130.png).
Všechny uvedené obrazy byly prohlédnuté, nejen vytvořené.

Plná místní matice obsahuje 60 snímků před a 72 po v ignorovaných adresářích
`test-output/ux-before` a `test-output/ux-after`: 1280×720, 1920×1080 a 3840×2160,
každé při 100 % a 130 %. Ve verzované složce je reprezentativní výběr, aby
screenshoty zbytečně nezvětšovaly repozitář. Obrázky se nebalí do hry.

## Reprodukce

```sh
godot-4.7.2 --path . --rendering-method gl_compatibility --audio-driver Dummy --disable-render-loop --script tests/ui_workflow.gd -- --screenshots --manual-capture
godot-4.7.2 --path . --rendering-method gl_compatibility --audio-driver Dummy --disable-render-loop --script tests/render_quality.gd -- --screenshots --manual-capture
```

`--manual-capture` vykresluje skutečný framebuffer pomocí force_draw;
layout, vstupní události a assertions zůstávají aktivní. UI workflow má
357 kontrol, grafika i headless PASS. Kvalita 4K má 8 kontrol PASS včetně
skutečné SVG textury 38×38 a ostřejších hran textu než zvětšený malý atlas.
Baseline novým srovnávacím testem reprodukovala ztrátu nepotvrzeného čísla
ve všech šesti kombinacích; finální kód ji zachovává.

[Skutečné menu Windows EXE ve Wine](windows-exe-wine.png), 1600×900/100 %, je samostatné ověření. Jeho odlišnosti od Linux editoru shrnuje TEST_REPORT.md.
Nativní Windows ani fyzický headset nejsou tímto prostředím ověřené.
