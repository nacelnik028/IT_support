# Samostatná Windows hra — 2026-10-26

- Zdrojový commit herního obsahu: `f5acc3f065ba65dd187dfc2194990b19858e88b7`.
- Engine: oficiální Godot 4.7.2.stable.official.ed1daf0bf.
- Platforma: Windows x86_64; herní PCK je vložené přímo v `ITSupportSimulator.exe`.
- Varianta exportu: Debug (`--export-debug`) s oficiální Windows šablonou. Tato varianta se i s herními daty vejde pod GitHub limit 100 MiB, takže umožňuje uložit skutečnou binárku přímo v běžném Gitu. Obsahuje diagnostické funkce Godotu.
- Velikost EXE: 104 339 040 bajtů. Ve složce `build` není distribuční ZIP ani vedlejší PCK.
- `build/.gitattributes` vypíná LFS filtr pro EXE. Přímé raw stažení i archiv aktuálního repozitáře tak mohou obsahovat celé spustitelné EXE.
- Export proběhl v dočasné kopii projektu. Původní zdrojové soubory, testy, katalogy a exportní preset jsou nezměněné. Originální stažené Godot archivy byly ověřeny pevně připnutými SHA512 součty.

## Ověření

- Původní úplná sada 23 testů nad stejnými herními zdroji prošla bez chyb a varování: 65 misí v modelu i UI, 21 lekcí ve třech režimech, 336 výukových UI akcí a 474 kontrol ukládání.
- Toto nové EXE prošlo spuštěním jako Windows binárka přes Wine 10.0: `--headless --quit-after 30`, načtení hlavní scény, ukončení s kódem 0 a bez Godot runtime chyb a varování. Wine má samostatný prefix mimo uživatelské herní uložené pozice.
- Přímo herní data zabalená v tomto EXE prošla dalšími 34 kontrolami servisního průchodu, 27 kontrolami herního UI a 162 kontrolami rozhraní. Tyto testy běžely Linux Godot editorem přes `--main-pack`, mají vlastní SaveManager.path_override a DisplaySettings.path_override.
- Ověřena struktura PE x86_64, vložený PCK, velikost pod 100 MiB a SHA256 distribuce.
- Grafické hraní na fyzickém Windows počítači nebylo v tomto cloudovém prostředí ověřeno.

Opakované sestavení: `/workspace/.cloud-setup/it-support/build-release.py`.
Windows kontrola: `/workspace/.cloud-setup/it-support/test-windows.py`.
Instalace a aktivace nástrojů jsou uložené v nastavení prostředí.
