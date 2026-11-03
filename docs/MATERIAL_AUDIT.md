# Audit povrchů celé akademie — dokončeno 3. 11. 2026

Audit navazuje na uživatelem hlášený vadný vzhled londýnského vstupu. Materiály
jsou převážně procedurální; nebylo třeba přidávat bitmapové textury ani fonty.
Kontrola importu byla doplněna skutečnými GPU snímky a jejich vizuální prohlídkou.

## Inventář a rozsah

Autorské obrazové/shaderové zdroje jsou `assets/icons/academy.svg` a tři shadery:
`raised_floor.gdshader` (podlahy tří technických místností),
`perforated_metal.gdshader` (perforace racků/disků),
`interior_reflection.gdshader` (statické interiérové odrazy). Kovový normál
vzniká jako sdílený NoiseTexture2D za běhu, monitory používají skutečné
ViewportTexture a texty vestavěný font Godotu. Ostatní povrchy používají
sdílené StandardMaterial3D z Geometry; aktivní highlight a pohyblivé části
zůstávají dynamické. V projektu nejsou další autorské PNG/JPEG/TTF/OTF textury.

`tests/material_audit.gd` prochází skutečný strom meshů včetně MultiMesh,
zapisuje typy materiálů, použití, příklad umístění a shader do `materials.json`.
Výchozí audit měl 243 materiálových instancí, po dekoraci všech místností 280; chybějící
přiřazení **0**. Geometrické porovnání **27 strukturálních stěn: 0 koplanárních
překryvů**. Tato kontrola se týká hlavních kolizních stěn, nikoli každé dekorace.

Prohlédnuté oblasti: celá serverovna, IT akademie, programovací učebna, obě
strany původních posuvných dveří otevřených i zavřených, všechny nové průchody,
hub a chodba; racky, disky, servisní skříně, kabely, stoly a monitory; londýnské
kolo a kabinky, věž a ciferníky, řeka, most, zábradlí, postavy, přepážka,
terminál a kontrola. Stejné záběry vznikají v Compatibility i Forward+.
Výběr je v [ui-review/2026-11-02-hub](ui-review/2026-11-02-hub/README.md).
Plné místní podklady jsou v `test-output/material-before-*` a `material-after-*`.
Finální čisté logy: `hub-material-compatibility.log` a `hub-material-forward.log`.
V každém rendereru je 19 základních pohledů a 30 snímků matice rozlišení/textu,
celkem 49. Výchozí snímky pocházejí z 2. 11.; konečné zahrnují dekorace všech místností.

## Nalezené závady a provedené opravy

| Místo / projev | Příčina a oprava | Ověření / snímky |
|---|---|---|
| Londýn, pohled ze serverovny: tmavé dveřní křídlo a sloupky napříč otevřeným vstupem | Datacenter3D.build_details stále kreslil staré dekorativní dveře a souvislé lišty pro někdejší stěnu. Křídlo a klika odstraněny; sloupky a lišty končí před otvorem. Vstup má souvislý rám, překlad a volný práh. | `10-london-entry-north` před/po, oba renderery; skutečná PC chůze a syntetický XR průchod. |
| Londýn, pohled zpět: zrcadlené cedule a zdánlivá mříž | Chybná zadní strana Label3D a staré sloupky. Geometry.text nyní nevykresluje zrcadlené zadní strany; EnglishRoom umisťuje vstupní a zpětný nápis na odpovídající strany. | `11-london-entry-south` před/po; obecná změna textu vizuálně kontrolována i v ostatních místnostech. |
| Sam a Alex: mezera mezi hlavou a trupem | Procedurálním postavám chyběla spojovací geometrie krku. Doplněna ve sdíleném EnglishRoom.npc. | `13-counter` před/po, oba renderery; informační postava v přehledu pavilonu. |
| První orientační tabule hubu byla z nástupního místa příliš drobná | Zvětšeny fyzické rozměry textu a portálových cedulí, spawn vystředěn na tabuli. | `16-hub`, oba renderery a rozlišení; dekorace nepřekrývá nápisy. |

Záměrné jednobarevné stylizované povrchy, perforace racků a rozdíly v dostupných
odrazech rendererů nebyly vydávány za chybějící textury. Nenalezeny rozbité
autorské cesty, chybějící bitmapy, neplatné shadery ani převrácené normály.
Západní sdílená stěna programování zůstává jediná; nová hala přidává pouze
potřebné části mimo původní místnosti. Nové barevné pruhy a koberce jsou nad
podlahou s oddělenou hloubkou, nezdvojují její kolizi. Sokly končí před portály.

## Dekorace rozcestníku

Na doplňující požadavek přibyly rostliny v pevných květináčích, dřevěné lamely,
zaoblené lavičky s opěradly, kobercový ostrůvek, stropní žebra a barevné vodicí
pruhy. Dekorace zůstává u okrajů; nepřibyly monitory, velké textury ani další
světla. Vše používá sdílené materiály a dávkování statické geometrie.
Nástupní bod i cesty zůstávají volné pro chůzi a VR kapsli.

Další doplnění uživatele pokrývá všechny místnosti. Serverovna a IT trénink mají
technické značení, servisní skříňku a podlahové akcenty, IT také rostlinu ve volném
rohu. Programovací učebna má přehledné Python/Web motivy na bočních stěnách.
Londýn má cihlový obklad pokladny, stříšku, nábřežní dlažbu, rostliny a mělký
reliéf města na vzdálené stěně. AcademyDecor sdílí geometrii a materiály s hubem.

## Reprodukce

```powershell
Godot_console.exe --path . --rendering-method gl_compatibility --script tests/material_audit.gd -- --matrix
Godot_console.exe --path . --rendering-method forward_plus --script tests/material_audit.gd -- --matrix
Godot_console.exe --path . --rendering-method gl_compatibility --script tests/english_world.gd -- --screenshots
```

Testy nastavují vlastní SaveManager.path_override, DisplaySettings a VRSettings
s PID před konstrukcí hry. Matice zahrnuje 720p/1080p/4K a 100/130 % textu.
Automatická kontrola UI sama nenahrazuje prohlídku materiálů. Desktopový
Compatibility běh ověřuje dostupný renderer; není měřením optiky ani výkonu PICO.

## Skutečně zabalené prostředky

Dodatečný externí `package_content.gd` nad přesným EXE a skutečnými prostředky
APK prošel graficky v Compatibility: 5033/5057 kontrol, 278 materiálových instancí
po prvním vytvoření světa, žádný mesh bez materiálu, platné používané shadery
se stejným kódem jako zdroje a dostupné vygenerované normálové textury.
Rozdíl proti 280 instancím prohlídky tvoří dočasné materiály po interakcích.
Stejný test porovná všechny JSON hodnoty a vyloučí pracovní adresáře.
Logy: `test-output/windows-package/package_content-final-graphical.log`
a `test-output/pico-package/package_content-final-graphical.log`.
U desktopového čtení APK je vypnut pouze seznam Android GDExtension; nejde
o spuštění Android knihoven nebo test fyzického PICO.
