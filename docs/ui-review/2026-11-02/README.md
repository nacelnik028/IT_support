# Ověření aktuální hry — 2. 11. 2026

Čerstvé snímky z Linuxu, Godot 4.7.2, Xvfb a OpenGL Compatibility / Mesa
llvmpipe. Jde o skutečně vykreslené framebuffery, ne návrhy rozhraní.
Nejde o nativní Windows ani měření herního GPU.

- `server-room-before.png`: výchozí repozitář, kamera (6.6, 0.02, 4.2),
  cíl (-0.7, 1.45, -3), 1600×900, mise 53 (index 52).
- `server-room-after.png`: stejná kamera a rozlišení po přesunu.
- `west-classroom.png`: pohled od přední uličky na racky s otevřenou
  programovací učebnou po levé ruce.

Průchod ověřuje `tests/programming_location.gd`: běžná chůze ze spawnu
k západnímu vstupu, raycast a skutečné E, obě pracoviště, kliknutí na
vyhodnocení zdrojového kódu a návrat. Celá návštěva se opakuje.
Původní severní vstup je uzavřený; původní místnost se negeneruje podruhé.
Veškeré vybavení, kolize i interakce mají společnou transformaci místnosti.

Další aktuální snímky všech rozlišení a velikostí textu jsou v ignorované
složce `test-output/`: `design-final-*`, `design-world-*`, `*-4k-native.png`.
Přesné výsledky a omezení uvádí nová sekce v `TEST_REPORT.md`.

Finální grafický průchod: 114 kontrol, 0 selhání. Snímky používají skutečné
RenderingServer.force_draw v režimu --disable-render-loop; všechny čekací
layout/input snímky dál běží. Nedochází k nahrazování renderu maketou.
`windows-exe-wine.png` zachycuje skutečné Windows EXE ve Wine (menu), nikoli
Linux editor. Standardní zavření exit 0; některé symbolové fallbacky Wine
se liší. Nativní Windows toto prostředí neověřuje.

Reprodukce finálních pohledů (stejná mise a kamera jako baseline):

```sh
godot-4.7.2 --path . --rendering-method gl_compatibility --audio-driver Dummy --disable-render-loop --script tests/visual_capture.gd -- --programming-only --manual-capture
```

Grafická matice skutečné 3D scény dokončila 31 kontrol bez selhání.
