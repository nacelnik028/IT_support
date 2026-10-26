# Samostatná Windows hra — 26. 10. 2026

- Engine: Godot 4.7.2.stable.official.ed1daf0bf, Windows x86_64 Debug šablona.
- Herní PCK je vložené přímo v `ITSupportSimulator.exe`. Ke spuštění stačí toto jediné EXE.
- Velikost: **104 340 256 bajtů (99,5 MiB)**, pod limitem 100 MiB pro jednotlivý soubor na GitHubu.
- Zdrojové opravy terminálu a aktualizované EXE se verzují společně v tomto repozitáři.
- `build/.gitattributes` vypíná LFS filtr pro EXE. Přímé stažení i zdrojový archiv obsahují skutečnou binárku.
- Kontrolní součty jsou v `SHA256SUMS`. `VERIFICATION.json` obsahuje SHA256 přesně toho EXE, které prošlo závěrečnou kontrolou.

## Ověření na Windows

- Celá zdrojová sada `tools/Test-All.ps1`: **24 sad PASS**, exit 0, bez runtime chyb a varování.
- 65 misí v modelu i UI, 21 lekcí ve všech třech režimech, 336 výukových UI akcí, 474 kontrol ukládání a 700 kontrol navigace.
- Nové regrese terminálu: 63 kontrol headless i graficky, včetně správného hostitele, undo, výuky, hodnocení, selhání zápisu a ochrany kampaně.
- Samotné toto EXE spuštěné z oddělené složky bez zdrojového projektu: headless i grafický start hlavní scény, oba **exit 0 a čistý log**. Graficky Forward+/Vulkan na Intel UHD Graphics.
- Přímo herní data vložená v tomto EXE: **64 kontrol terminálu, 162 kontrol rozhraní, 27 kontrol 3D UI a 39 kontrol servisního průchodu**, vše PASS a bez runtime chyb/varování. Zahrnuté je také 4K a zvětšený text.
- Exportní šablona nepovoluje externí `--script` a `--path`. Podrobné testy proto spouští plný Godot editor přes `--main-pack` nad tímto EXE; přímý start EXE se ověřuje samostatně. Test kontroluje přítomnost zabaleného `project.binary` a nepřítomnost zdrojových testů.
- Testy používají `SaveManager.path_override` a samostatnou konfiguraci. Přímý start EXE používá existující `--test-world`, který obě cesty nastaví před vytvořením hry. Hráčův save zůstal nezměněný.

## Opakované sestavení a kontrola

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
python tools/test_windows.py --godot 'C:/cesta/Godot.exe'
```

Sestavení vyžaduje Python 3 (nebo dostupné uv). V dočasné kopii znovu použije
engine z přibaleného EXE a oficiálním exportérem vloží aktuální data. Před
nahrazením kontroluje PE/PCK strukturu, verzi a velikost. Nepřepisuje zdrojový
projekt ani exportní preset. Vlastní Windows Debug šablonu lze zadat přes
`python tools/build_windows.py --godot ... --template ...`.

Lokální důkazy: `test-output/terminal-fix-test-all.log`,
`test-output/terminal-sessions-gpu.log`, `test-output/windows-build-*.log`
a `test-output/windows-package/`. Screenshoty závěrečného balíčku jsou
v `test-output/windows-package/screenshots/`.
