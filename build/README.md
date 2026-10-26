# IT Support Simulator: Datacenter Academy — Windows build

**[Stáhnout ITSupportSimulator.exe](https://raw.githubusercontent.com/nacelnik028/IT_support/main/build/ITSupportSimulator.exe)**

Stáhni tento jediný soubor a spusť ho dvojklikem ve Windows 10/11 (64bit).
Celá hra je uvnitř EXE; nemusíš nic instalovat ani ručně rozbalovat.
Soubor má **104 340 256 bajtů (přibližně 99,5 MiB)**.

EXE je nyní uložené přímo v Gitu. Úplná binárka je tedy také ve staženém
zdrojovém repozitáři ve složce `build`; Git LFS ke stažení hry nepotřebuješ.

Použita oficiální Windows Debug šablona Godot 4.7.2 pro x86_64.
Podrobnosti o sestavení a ověření jsou v `BUILD_INFO.md`, kontrolní součty
v `SHA256SUMS` a licence enginu v `GODOT-LICENSE.txt`.

Pro grafické karty bez vhodné podpory Vulkan lze použít PowerShell:

```powershell
.\ITSupportSimulator.exe --rendering-method gl_compatibility
```
