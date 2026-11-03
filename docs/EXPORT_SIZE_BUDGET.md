# Exportní rozpočet — 3. 11. 2026

Výchozí commit e523eb4: EXE 104 826 336 B, limit 104 857 600 B,
rezerva 31 264 B. Oficiální shodná šablona 4.7.2.stable Debug má
103 176 704 B; Release 109 268 480 B, takže přechod na Release nepomůže.
Vložený pack a zarovnání výchozího EXE zabírají 1 649 632 B.

Windows builder nyní v izolované exportní kopii po bezeztrátovém odstranění
JSON mezer použije nativní Godot FileAccess COMPRESSION_ZSTD. Před nahrazením
každého katalogu znovu dekomprimuje data a porovná všechny bajty. Zdrojové
JSON ani jejich generátory se nemění. ContentReader přijímá obyčejné UTF-8
i nativní GCPF kontejner; save/import tento mechanismus nepoužívají.
Žádná změna PE, UPX, fontů, audia či dostupného obsahu.

První skutečný export: katalogy 725 613 → 269 309 B, EXE 104 371 136 B,
rezerva 486 464 B. Native headless/GPU smoke PASS; audit přesných zabalených
dat 5437 kontrol PASS, 255 souborů, 278 materiálů, každý JSON shodný s referencí.
Jde o průběžný rozpočet; konečné hashe a výsledky budou patřit finálním
exportům po implementaci. Vývojové logy: test-output/windows-content-compression.log,
next-stage-budget-build.log a next-stage-budget-packages.log.

API: https://docs.godotengine.org/en/stable/classes/class_fileaccess.html#class-fileaccess-method-open-compressed
