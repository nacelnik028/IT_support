# Training academy — gameplay PC/PICO, 3. 11. 2026

Godot 4.7.2.stable.official.ed1daf0bf. Herní implementace `8e931aa` navazuje na
`cda0a5f` a `f6b05d8`. Přesný seznam 240 zdrojů a SHA256 je v obou BUILD_INFO.json,
včetně vygenerovaných UID. Shodný deterministický manifest:
`77a19d821a39954afe9f657aaf7c5776af5cdaaf5e954b30552b70a4a5c6a8fe`.

- ITSupportSimulator.exe: Windows x86_64 Debug, vložená data, **104 826 336 B**.
  Rezerva **31 264 B** do 104 857 600 B. SHA256:
  `e194ae3ef1f8b95e5665bc746efd3fb5c6ceb9e348971925634c70f85df1ac1c`.
- pico4/ITSupportSimulator-PICO4.apk: podepsaný ARM64 Debug, **1.4.0 / code 5**,
  **90 743 347 B**. SHA256:
  `8d9a39fd8f13ff9d8b3888778f6f707eb0c827cd12e3a8883263b467195aacaf`.

EXE byl spuštěn z cizí pracovní složky, přejmenovaný a bez PCK/editoru.
Nativní headless/GPU smoke a 20 externích balíčkových sad PASS. APK podpis,
původní certifikát, CRC, manifest a prostředky PASS; dva desktopové smoke běhy
 a 13 externích sad PASS. Dodatečně nad oběma přesnými balíčky: shifts 136,
gameplay 212 a XR 116 PASS, včetně skutečných MP3 dat proti SHA256.
Celý aktuální zdrojový Test-All: 39 sad PASS, bez runtime chyb a varování.

Nový obsah: praktický úvod, tři směny po třech navazujících ticketech, vysvětlení
sítě, 12 mluvených replik a pomalé varianty, panel/diagnostika. Zachováno 65/21 IT,
programování, Londýn, podpis a postup. Offline řeč; žádný TTS model, pracovní WAV,
testovací save ani soukromé klíče v distribuci.

**PICO hardware NEPROVEDENO – headset není dostupný.** Android native start,
tracking, stereo, optika, komfort, FPS a paměť čekají na zařízení. Desktopové
APK testy to nenahrazují. Subjektivní lidský poslech není doložen; automatické
PC dekódování/přehrávání ano. Detaily: VERIFICATION.json, TEST_REPORT.md
a docs/PICO4_HARDWARE_CHECKLIST.md.
