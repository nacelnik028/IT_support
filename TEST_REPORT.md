# Ověření rozšířené hratelné verze

Datum: 24.10.2026. Engine: Godot4.7.2.stable.official.ed1daf0bf, Windows x86_64.

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
