# Ověřené sestavení — 2. 11. 2026

- Engine a oficiální šablona: `4.7.2.stable.official.ed1daf0bf`.
- Export: **Windows x86_64 Debug**, herní data vložená v EXE.
- Soubor: `build/ITSupportSimulator.exe`, **104,713,528 bajtů**.
- Limit GitHubu: 104 857 600 bajtů; rezerva **144,072 bajtů**.
- SHA256: `ea2b6a5fedf2d0ba390269c4d4c513e28f62aafc8a29b2cc2f3afaad83604c41`.
- Ověřený x86_64 PE, sekce PCK a platné GDPC záhlaví i footer;
  vložený pack má 1,536,812 bajtů. Soubor není Git LFS pointer.
- Přesné EXE přejmenované v oddělené složce bez PCK a z jiné pracovní
  složky: Wine headless smoke PASS, exit 0. Obsah 65/21 a 60/28,
  západní učebna, Python, HTML/JS náhled a návrat do kampaně.
- Přesný vložený pack: všech 11 vybraných regresních sad PASS,
  včetně 114 kontrol skutečného průchodu a 31 kontrol world_ui.
  Testy spouštěl Linux editor s `--main-pack`, nikoli Windows runtime.
- Skutečné Windows EXE otevřené graficky ve Wine/Xvfb/Mesa: menu
  prohlédnuto a zachyceno, standardní zavření okna exit 0.
  Wine hlásí nepodporovaný dotaz na SDR white level; některé symbolové
  fallbacky fontů se liší od Linuxu. Nejde o nativní Windows ověření.
- Screenshot: `docs/ui-review/2026-11-02/windows-exe-wine.png`.
- Bez Authenticode podpisu. SmartScreen se neobchází.
- Starý Windows ZIP a PICO APK v builds/ nebyly přestavěny.

Postup sestavení je verzovaný v `tools/build_windows.py`; PS1 wrapper
používá stejnou implementaci. Detailní příkazy jsou v `build/README.md`.
Commit `99c2012` byl 2. 11. 2026 publikován do GitHub main bez force push.
Přímé stažení EXE i EXE ve zdrojovém archivu tohoto commitu prošly kontrolou
MZ, velikosti a výše uvedeného SHA256. Oba obsahují plnou binárku bez LFS.
Toto ověření nemění uvedená omezení nativního Windows a PICO testování.
