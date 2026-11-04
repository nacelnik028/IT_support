# Londýn — béžové lamely, bod 9a (4. 11. 2026)

Opravená je tvorba dekoru v `WorldVisuals.corridor()`. Béžové díly patřily
zadní stěně prosklené chodby serverovny, nikoli vstupu do Londýna. Původní
smyčka `range(-8,0)` s kladnými offsety vytvářela poslední trojici na
X = −0,95 / −0,83 / −0,71, Y = 1,6, Z = 10,34. Poslední dvě lamely
byly viditelné před vnitřní plochou západní stěny Londýna (X = −0,875).
Podobně překračoval první shluk levý konec vlastní chodby.

Sedm celých trojic je nyní rovnoměrně rozmístěných mezi vnitřními plochami
bočních stěn chodby X = −7,73 / −1,27. Zohledněná je tloušťka těchto stěn
i šířka celé trojice. Lamely nadále dosedají na původní zadní stěnu Z = 10,375.
Nevznikla žádná překrývající deska, nová dekorace ani nová kolize.

## Srovnání ze stejné kamery

Nový uživatelský screenshot nebyl mezi doručenými soubory; příloha obsahovala
pouze text zadání. Následující vlastní snímky před/po mají přesně stejnou
kameru: hráč (1,4; 0,02; 12), výška očí 1,68, cíl (−0,8; 1,5; 10,34),
FOV 76°, 1920 × 1080. V páru se zavřenými dveřmi je jediný pixelový rozdíl
v obdélníku (944, 121)–(993, 509), v místě dvou přesahujících lamel.
Nelze potvrdit shodu s nedoručeným původním úhlem.

- [Před opravou / dveře zavřené](before-west-closed-gl_compatibility.png)
- [Po opravě / dveře zavřené](after-west-closed-gl_compatibility.png)
- [Před opravou / dveře otevřené](before-west-open-gl_compatibility.png)
- [Po opravě / dveře otevřené](after-west-open-gl_compatibility.png)
- [Původní dekor v serverovně](before-server-corridor-closed-gl_compatibility.png)
- [Opravený, zachovaný dekor v serverovně](after-server-corridor-closed-gl_compatibility.png)

Další PNG zahrnují obě strany všech čtyř obvodových stěn a východní vstup
(`after-north-*`, `after-west-*`, `after-south-*`, `after-east-*`, `after-entry-*`)
v Compatibility i Forward+. Matice `after-west-1280/1920/3840-100/130-*`
obsahuje všech šest skutečných rozlišení a velikostí textu pro oba renderery.
Vnější plochy bez podlahy byly prohlédnuté kamerou; chůze byla ověřená pouze
po skutečných přístupných podlahách, včetně obou stran sdílené severní stěny.

## Ověření

- `london_geometry`: **226 PASS headless / 226 PASS Compatibility / 226 PASS Forward+**.
  Kontroluje všechny vytvořené lamely před batchingem, návaznost na zadní stěnu,
  skutečné fyzikální paprsky v původním místě (žádná kolize ani interakce),
  souvislou severní stěnu v pěti výškách z obou stran a skutečnou chůzi.
  Trasa vede podél západní stěny v obou stavech dveří, po mostě, podél jižní
  a východní části, chodbou rozcestníku a do IT učebny. Návrat do zazděného
  přímého průchodu fyzika správně blokuje z obou stran.
- Celý aktuální `Test-All.ps1` (47 sad, včetně všech tří výukových režimů):
  **47 PASS**, 47 startů enginu, exit 0, bez runtime chyb/varování;
  [celý nový log](verification/test-all.log), všech 336 výukových UI akcí.
- Godot MCP / `DesignMCP.tscn`: **31 PASS**, samostatně uložených osm již
  evidovaných statických varování v nezměněných skriptech; žádné nové ve
  `WorldVisuals.gd`. Přesný výstup: [mcp-design.json](verification/mcp-design.json).
- Grafický `xr_modes`: **120 PASS**, skutečný SubViewport 1600 × 1200,
  oba syntetické ovladače, kliky, posuv a virtuální klávesnice.
  [Aktuální VR konzole](xr-monitor-console.png). Fyzický PICO nebyl testovaný.
- Všechny nové běhy používají `SaveManager.path_override` a vlastní CFG.
  Katalogy ani první 24 definic / legacy kampaň se neměnily.

Reprodukční běh měl šest očekávaných selhání mezí původních lamel a dvě
chyby nově psané testovací trasy, která vedla skrz květináč. Trasa byla opravena
vedením kolem vybavení, bez přesouvání hráče do cíle nebo změny kolizí hry.
Původní log je oddělený v `verification/baseline.log`; jeho výsledky nejsou PASS.

Opakování cílené grafické kontroly:

```powershell
Godot_console.exe --path . --rendering-method gl_compatibility --script tests/london_geometry.gd -- --screenshots --matrix
Godot_console.exe --path . --rendering-method forward_plus --script tests/london_geometry.gd -- --screenshots --matrix
```

## Oddělený nález dveří a rozsah distribuce

Tmavý díl se světlým pruhem je **ACADEMY-DOOR**, na severní stěně u X = 9.
Při odsunutí na Z = 6,5 přesahuje k Z = 7,95. Je zachycený například na
[severní stěně](after-north-london-gl_compatibility.png) a nemá souvislost
s béžovými lamelami na západní stěně u Z = 10,34. Samostatný bod 9 byl následně opraven skutečnou severní kapsou;
[podklady další etapy](../2026-11-04-interface/README.md). Změna 9a samotná
mechanismus dveří neupravovala.
Při prohlídce nebyl nalezen další obdobný přesah béžových dekorací.

Zazděný přímý průchod serverovna–Londýn je zachovaný. Vstup do Londýna
zůstává východní chodbou rozcestníku. Úprava je ve zdrojích; EXE/APK nebyly
znovu sestavené. Nebyl proveden Git push.
