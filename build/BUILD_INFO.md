# Training academy — Windows EXE 5. 11. 2026

Aktuální `ITSupportSimulator.exe` obsahuje novou pauzu i všechny zdrojové opravy rozhraní a konstrukcí.
Godot 4.7.2.stable.official.ed1daf0bf; Windows x86_64 Debug, vložený PCK. Herní zdroj `a403a406865f8849e209a66918330eb7b951d5e0`.
Verze hry zůstává 1.5.0; nové sestavení rozliší datum a hash.

- Velikost **104480112 B**, rezerva **377488 B** pod 100 MiB.
- SHA256 `831f5540f0e18a8427cf19eb412cd1cedaf355a1582067b1e0b676b30dd8e170`.
- Nativní EXE-only smoke a přímá Windows UI kontrola Esc / Kam jít / návrat PASS.
- Přesný EXE pack: pause_repair 217 headless / 239 Compatibility / 239 Forward+ PASS.
  Audit obsahu 5674 PASS, 292 souborů, 275 materiálů; katalogy zachované.
- Celý zdrojový runner 51 PASS je pro stejné nezměněné herní zdroje.

[Snímky a protokol](../docs/ui-review/2026-11-05-exe-menu/README.md). Přesná metadata v BUILD_INFO.json a VERIFICATION.json.

PICO APK zůstává předchozí 1.5.0 / code 6, zdroj `a6d58e3caf4072defac47d03d98abfb4fbd97be8`,
SHA256 `bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`. Tuto novou UI etapu neobsahuje a jeho manifest není shodný s Windows.
Původní ověření je archivované v docs/ui-review/2026-11-05-exe-menu/verification/previous-distributions.json.
Fyzické PICO nebylo dostupné.
