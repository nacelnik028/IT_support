# Samostatné Windows EXE

Spusť `ITSupportSimulator.exe` (Training academy). Obsahuje celou hru včetně Python/Web učebny
vlevo od serverů. PCK, Godot editor ani instalátor nejsou potřeba.
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
Nepoužívá UPX, ruční připojování PCK ani úpravy PE šablony.
Ověří x86_64 PE a vložený PCK, velikost pod 100 MiB, potom spustí přejmenované
samotné EXE z jiné pracovní složky bez projektu či PCK. Smoke kontroluje
obsah 65/21, trénink, západní učebnu 60/28, Python i webový náhled a návrat.
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
Aktuální PICO APK 1.1.0 je v `pico4/ITSupportSimulator-PICO4.apk`.
Pochází ze stejných aktuálních herních zdrojů; `pico4/BUILD_INFO.json` obsahuje
jejich otisky. Ověření přesunu/exportů je v `VERIFICATION.json`.
Sestavíš ho příkazem `python tools/build_platforms.py --godot C:/Godot/Godot_console.exe --pico-only`
z kořene projektu. Windows EXE tento příkaz zachovává.

## Aktuální UI/UX verze

Nové kompaktní menu, programovací editor a pravdivé stavy uložení jsou uvnitř
samotného EXE. Velikost je 104 720 824 B, export Windows x86_64 Debug.
Přejmenování nemění původní složku uložených pozic. Přesné výsledky, hash EXE, velikost
obsaženého packu a omezení ověření uvádí BUILD_INFO.md a TEST_REPORT.md.
Snímky jsou v docs/ui-review/2026-11-02-ux.
