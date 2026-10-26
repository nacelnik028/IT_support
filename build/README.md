# IT Support Simulator: Datacenter Academy — Windows release

[Stáhnout hru v ZIPu](https://raw.githubusercontent.com/nacelnik028/IT_support/main/build/ITSupportSimulator-Windows-x64.zip)

Rozbal archiv a ve složce `ITSupportSimulator` spusť `ITSupportSimulator.exe`.
Hra je pro Windows 10/11 (64bit), funguje offline a herní data má uvnitř EXE.
Godot editor ani vedlejší soubor PCK nejsou potřeba.

ZIP je uložený přímo v Gitu a obsahuje úplné EXE, licenci a pokyny.
Je vhodný i pro stažení z webu bez instalace Git LFS.

Samostatné `build/ITSupportSimulator.exe` je kvůli velikosti nad 100 MiB
uložené přes Git LFS. Soubor o velikosti přibližně 1 KB je pouze textový
odkaz a ve Windows nejde spustit. Skutečné EXE má 110 430 816 bajtů.
Při klonování repozitáře spusť `git lfs pull`; pro běžné hraní stáhni výše uvedený ZIP.

Pro grafické karty bez vhodné podpory Vulkan lze použít PowerShell:

```powershell
.\ITSupportSimulator.exe --rendering-method gl_compatibility
```

Sestaveno oficiální release šablonou Godot 4.7.2 pro Windows x86_64.
Licenci enginu obsahuje `GODOT-LICENSE.txt`; kontrolní součty jsou v `SHA256SUMS`.
