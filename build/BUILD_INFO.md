# Aktuální sestavení — rozcestník a B1–B2, 3. 11. 2026

- **IT Support Simulator: Training academy**. Odekorovaný hub i všechny místnosti,
  opravené londýnské průchody/cedule/postavy, 6 situací B1–B2, zákaznické dotazy
  a samostatný kvíz s 20 ověřenými otázkami.
- Herní zdroje: `0cb87a31baace36a34b7f686e1e36f95d0df5d51`; následující změny
  testů a dokumentace nemění zabalený herní obsah.
- Editor/šablona: `4.7.2.stable.official.ed1daf0bf`, Windows x86_64 **Debug**,
  oficiální šablona a vložený PCK. Pouze mezery JSON jsou bezeztrátově odebrané
  v izolované exportní kopii, žádný obsah nebyl vypuštěn.
- **EXE 104 579 568 B**, rezerva **278 032 B** do 100 MiB.
  SHA256 `96510e62937792be20d8977936a8ab907f6b0444ad7f875921bfb2c38e208562`.
- Nativní headless/GPU start samotného EXE mimo projekt a všech 17 balíčkových
  sad nakonec PASS. Počáteční nečisté ukončení nového auditu i cílené opravy
  testovacího čekání zůstávají uvedené v TEST_REPORT a VERIFICATION.
- **PICO APK 90 508 612 B**, signed Debug ARM64, **1.3.0 / versionCode 4**.
  SHA256 `aefaddcb03b5c4f246344136bac18cb838c5f6ff9866468c1166eadb93bc5940`.
- Podpis v2, shodný certifikát s předchozím APK, CRC a OpenXR/PICO manifest PASS.
  Oba desktopové smoke běhy nad skutečnými prostředky APK a 10 externích sad PASS.
  PICO BUILD_INFO obsahuje otisky aktuálních herních zdrojů a katalogů.
- Skutečné packy: 188/192 souborů, všechny JSON hodnoty zachované, žádné pracovní
  adresáře. GPU audit 5033/5057 kontrol PASS, 278 počátečních materiálů bez
  chybějících přiřazení, platné shadery a vygenerované normálové textury.
- Celý aktuální zdrojový Test-All: **36 sad PASS**. Hub 52, B1–B2 model 1809,
  kvíz 527, svět 1043 headless / 1063 GPU. IT katalogy, generátory a legacy24 stejné.
- Compatibility i Forward+ audit: každý 49 snímků, 280 materiálových instancí
  po interakcích, 27 strukturálních stěn a 0 koplanárních překryvů.
- Žádný autorizovaný PICO headset: Android start, reálný tracking, komfort,
  optická čitelnost a FPS zůstávají neověřené. Syntetické XR se za hardware nevydává.
- EXE není Authenticode podepsané. SHA256SUMS obsahuje oba současné artefakty.
