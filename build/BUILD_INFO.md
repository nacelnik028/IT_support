# Aktuální sestavení — oprava zdi u programovací učebny, 2. 11. 2026

- Název: **IT Support Simulator: Training academy**.
- Zdrojový základ: `357c3c0` + odstranění duplicitní stěny v AcademyRoom.
- Editor a oficiální šablona: `4.7.2.stable.official.ed1daf0bf`.
- Export: **Windows x86_64 Debug**, herní data vložená v EXE.
- Soubor: `build/ITSupportSimulator.exe`, **104 748 344 bajtů**.
- Limit: 104 857 600 bajtů; rezerva **109 256 bajtů**.
- SHA256: `a80b189fcfc5600a4940731b5b13f3ce592da1fe734b8a6cc5369f3165f45f3c`.
- PE a vložený PCK ověřeny oficiálním exportním postupem tools/build_windows.py.
  Přejmenované samotné EXE bez PCK mimo projekt: nativní Windows headless
  smoke PASS. Nativní GPU Compatibility smoke rovněž PASS: 65 misí, 21 lekcí,
  obě učebny, 60 úloh/28 lekcí programování, Python, web a návrat do serverovny.
- Stejná geometrická kontrola přímo nad vloženým packem potvrdila nula
  překrývajících se ploch u dveří. Oba renderery ověřeny také graficky ve zdrojích.
- Cílené regrese a jejich rozsah uvádějí TEST_REPORT.md a VERIFICATION.json.
  Starší úplné regresní běhy zůstávají popsané v historických sekcích reportu.
- Aktualizované PICO APK je v pico4/; podpis a zabalená geometrie ověřeny,
  skutečný headset není připojený. Jeho otisky zdrojů uvádí pico4/BUILD_INFO.json.
- EXE zůstává bez Authenticode podpisu. Shodný hash je v SHA256SUMS a BUILD_INFO.json.
