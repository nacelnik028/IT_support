# Aktuální sestavení UI/UX — 2. 11. 2026

- Název: **IT Support Simulator: Training academy**.
- Základ zdrojů: `99c201215f83408f333829ed05aa0489253acc14` + nová UI/UX etapa.
- Editor a oficiální šablona: `4.7.2.stable.official.ed1daf0bf`.
  Oba původní archivy ověřeny proti oficiálním SHA512; TLS zůstalo zapnuté.
- Export: **Windows x86_64 Debug**, herní data vložená v EXE.
- Soubor: `build/ITSupportSimulator.exe`, **104 720 824 bajtů**.
- Limit: 104 857 600 bajtů; rezerva **136 776 bajtů**.
- SHA256: `daf7d88bd7b340df3055f3309ed9f1d1e55f9c654073bee6eb0e184cf5c5b74b`.
- Ověřen x86_64 PE, sekce packu, GDPC hlavička/footer a vložený pack 1 544 108 B.
  EXE není LFS pointer; úplný Git blob má 104 720 824 B a shodný SHA256.
- Přesné přejmenované EXE v samostatné složce bez PCK, spuštěné z jiné pracovní
  složky: Wine headless smoke PASS (65/21, 60/28, západní učebna, Python, web,
  návrat kampaně). Grafické ověření: Wine/Xvfb/Mesa skutečné menu 1600×900 zachyceno a prohlédnuto, běžné zavření i funkční export smoke exit 0. Nejde o nativní Windows.
- Přesný vložený pack prošel 12 regresními sadami Linux editoru, včetně nového
  ui_workflow 357 kontrol, programování, XR, terminálu, UI, fyzického průchodu
  a opakované návštěvy západní učebny. Všech 12 exit 0 a čisté logy.
- Sestavení vytvořil tools/build_windows.py oficiálním exportérem bez úprav PE,
  UPX či vynechání obsahu. Shodný SHA256 je v SHA256SUMS a BUILD_INFO.json.
- Nativní Windows, fyzický headset a následné stažení z GitHubu nebyly ověřeny.
  Bez Authenticode podpisu; archivní Windows ZIP a PICO APK nejsou aktualizované.
