# Rozcestník a opravy povrchů — 2. 11. 2026

Nativní Windows / Godot 4.7.2 / RTX 5060. Soubory `before-*` a `after-*`
zachycují stejné kamery v Compatibility a Forward+. Před opravou bylo přes
londýnský průchod falešné křídlo, sloupky a lišty; zadní texty byly zrcadlené.
Detail přepážky také zachycuje doplnění spojovací geometrie krku postavy.

- `*-10-london-entry-north.png`: vstup ze serverovny před/po.
- `*-11-london-entry-south.png`: zpětný pohled před/po.
- `*-13-counter.png`: postava a přepážka před/po.
- `*-16-hub.png`: čitelná orientace, rostliny a lavičky.
- `*-19-hub-overview.png`: volná ulička haly, lamely a portály.
- `*-materials.json`: inventář skutečných přiřazených materiálů.

[Úplný audit a příčiny oprav](../../MATERIAL_AUDIT.md).
Plná místní matice je v `test-output/material-before-*`, `material-after-*`
a `london-review`. Tyto verzované snímky jsou pod `.gdignore` a nevstupují do
herních exportů. Syntetické XR vstupy a desktopové GPU snímky nejsou fyzický
tracking nebo výkon PICO. Finální výsledky balíčků uvádí TEST_REPORT.md.
