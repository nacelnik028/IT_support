# IT Support Simulator: Datacenter Academy — Windows release

Spusť `ITSupportSimulator.exe` ve Windows 10/11 (64bit). Hra funguje offline.
Herní data jsou zabalená přímo v EXE; žádný vedlejší PCK ani editor nejsou potřeba.

Pro grafické karty bez vhodné podpory Vulkan lze použít:

```powershell
.\ITSupportSimulator.exe --rendering-method gl_compatibility
```

EXE je uloženo přes Git LFS, protože překračuje limit 100 MiB pro běžný Git.
Po klonování repozitáře spusť `git lfs pull`; při stažení jednotlivého souboru
z GitHubu použij tlačítko pro stažení původního souboru. Textový LFS pointer není hra.

Sestaveno oficiální release šablonou Godot 4.7.2 pro Windows x86_64.
Zdrojové soubory hry ani původní exportní preset se při sestavení nemění.
Licenci enginu obsahuje `GODOT-LICENSE.txt`.
