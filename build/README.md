# Samostatné Windows EXE

Spusť `ITSupportSimulator.exe` (Training academy). Obsahuje celou hru a nový
odekorovaný nástupní rozcestník: 01 serverovna, 02 IT trénink, 03 vlevo Python/Web,
04 vpravo chodbou English in London. Londýn nabízí šest situací B1–B2,
zákaznické dotazy a samostatný kvíz s 20 otázkami u Alexe.
PCK, Godot editor ani instalátor nejsou potřeba.
EXE je Windows x86_64 **Debug**, nikoli Release, uložené přímo v Gitu bez LFS.
Musí mít méně než 104 857 600 bajtů. SHA256 ověř proti `SHA256SUMS`.

## Reprodukovatelné sestavení

Použij oficiální Godot `4.7.2.stable.official.ed1daf0bf` a jeho shodné exportní
šablony `4.7.2.stable`. Python 3.12+ potřebuje pouze standardní knihovnu.
Šablony stáhni z oficiálního vydání Godot Engine a ověř proti jeho `SHA512-SUMS.txt`.

Z kořene projektu na Windows:

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe'
# Nebo přímo, s explicitní oficiální Debug šablonou:
python tools/build_windows.py --godot C:/Godot/Godot_console.exe --template C:/Godot/windows_debug_x86_64.exe
```

Na Linuxu s připraveným Wine a jeho izolovaným prefixem:

```sh
python3 tools/build_windows.py --godot /path/to/godot-4.7.2 --template /path/to/windows_debug_x86_64.exe --runner /path/to/wine64
```

Skript ověří skutečnou verzi editoru i spuštěné šablony. V dočasné kopii
zdrojů provede import a oficiální `--export-debug` s `embed_pck=true`.
V této izolované kopii odstraní nepodstatné mezery z datových JSON a menší katalogy
uloží nativním bezeztrátovým Godot ZSTD kontejnerem GCPF. ContentReader čte obyčejný
JSON i tento kontejner. Před nahrazením ověří přesnou dekompresi, balíčkový audit
navíc shodu všech hodnot s autorskými zdroji. Zdrojové katalogy zůstávají stejné.
Nepoužívá UPX, ruční připojování PCK ani úpravy PE šablony.
Ověří x86_64 PE a vložený PCK, velikost pod 100 MiB, potom spustí přejmenované
samotné EXE z jiné pracovní složky bez projektu či PCK. Smoke kontroluje
obsah 65/21, trénink, západní učebnu 60/28, Python i webový náhled, všech šest
londýnských situací s platbou a světovým cílem, neutrální hub a dokončení všech
20 otázek a návrat bez dočasné relace.
Teprve úspěšný výsledek nahradí EXE a vygeneruje `BUILD_INFO.json` a `SHA256SUMS`.
Chyba ponechá předchozí EXE zachované. Logy jsou v `test-output/windows-*.log`.

Testy zdrojů (seznam se čte z `tools/Test-All.ps1`):

```sh
python3 tools/test_all.py --godot /path/to/godot-4.7.2
```

`--graphical --screenshots` spustí stejnou sadu s Compatibility rendererem,
pokud je dostupný displej. Testy používají vlastní save a konfiguraci.

## Omezení ověření

Původní ověření této UI/UX verze proběhlo na Linuxu. Wine headless ani grafický Xvfb/Mesa běh nejsou
nativní hraní na Windows. Podpis vydavatele není přidán; SmartScreen může
zobrazit neznámého vydavatele. Žádná ochrana Windows se nevypíná.
Aktuální ověření hubu a B1–B2 proběhlo nativně na Windows, včetně GPU
Compatibility a auditu materiálů ve Forward+. Podrobnosti oddělující zdroje, EXE, prostředky APK a chybějící
headset jsou v TEST_REPORT.md a VERIFICATION.json.
Aktuální PICO APK 1.4.0 (versionCode 5) je v `pico4/ITSupportSimulator-PICO4.apk`.
Pochází ze stejných aktuálních herních zdrojů; `pico4/BUILD_INFO.json` obsahuje
jejich otisky. Ověření přesunu/exportů je v `VERIFICATION.json`.
Sestavíš ho příkazem `python tools/build_platforms.py --godot C:/Godot/Godot_console.exe --pico-only`
z kořene projektu. Windows EXE tento příkaz zachovává.

## Aktuální gameplay, hub a B1–B2

Nový hub, dekorace všech místností, opravený vstup do Londýna, B1–B2 i kvíz jsou
uvnitř samotného EXE. Aktuální velikost je 104 826 336 B, rezerva 31 264 B
do limitu 100 MiB; export Windows x86_64 Debug.
Přejmenování nemění původní složku uložených pozic. Přesné výsledky, hash EXE, velikost
obsaženého packu a omezení ověření uvádí BUILD_INFO.md a TEST_REPORT.md.
Snímky před/po jsou v docs/ui-review/2026-11-02-hub.

Aktuální verze navíc obsahuje praktický úvod, tři souvislé směny, síťové vysvětlení
a 12 mluvených replik s pomalými variantami. Obě distribuce mají shodný deterministický
manifest zdrojů v BUILD_INFO.json; konkrétní výsledky jsou ve VERIFICATION.json.
Hardwarový PICO test čeká na headset.


Navazující obsah: trvalé koncepty a výslovná obnova, pět směn (dvě pokročilé),
uložený rozbor, 12 vlastních poslechových úloh a společný profil. Přímý průchod
serverovna–Londýn je zazděný, cesta vede přes hub. Přímý smoke ověřuje také
work_roundtrip, score_v2, advanced, debrief, listening a knowledge.

Aktuální externí testy: 27 Windows sad + dva native smoke běhy; 20 APK sad +
dva desktopové smoke běhy. test_gameplay_packages.py přidává deset cílených
sad pro každý přesný balíček. Všechny externí testovací cesty mají vlastní
platformní/process prefix; herní prostředky pocházejí ze skutečné distribuce.
Finální počty a skutečně dokončené výsledky vždy viz VERIFICATION.json.
