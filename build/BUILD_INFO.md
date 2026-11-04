# Training academy 1.5.0 — ověřené distribuce, 4. 11. 2026

Godot 4.7.2.stable.official.ed1daf0bf. Herní zdroj `a6d58e3caf4072defac47d03d98abfb4fbd97be8`, testová fixture `74edf37`. Obě platformy mají shodný deterministický manifest 269 zdrojů: `3723c98d56314e39be0b5f56b891ba510c63a76a03fa11914620f3f7b029f022`. Zobrazení verze bylo přidané po dokončení původního promptu v ec51021.

- **ITSupportSimulator.exe**: Windows x86_64 Debug, vložený PCK, **104454336 B**, rezerva **403264 B** pod 104857600 B. SHA256 `7e8caea9d12a0771c65c15b553c8e96630c521f5935307f295bd124ebb39c366`. Samotný přejmenovaný EXE bez projektu/PCK/editoru, native headless/Compatibility/Forward+ a 27 externích sad PASS. Nativní smoke hlásí game_version=1.5.0.
- **pico4/ITSupportSimulator-PICO4.apk**: podepsaný ARM64 Debug, **1.5.0 / code 6**, **90829657 B**. SHA256 `bed5560e0aeaec612f8724e7a1a25347b0dadd65ba09139cc698d37b37e846ef`. Původní certifikát `3449ce02012b69d3d0b9d19eea1706521e290fac48ab7ff1d5d20bea8c003997`, podpis/CRC/manifest PASS. Dva desktopové smoke a 20 externích sad PASS nad skutečnými APK prostředky.

46 zdrojových sad PASS; navíc deset cílených sad na každý přesný balíček a aktuální programovací trackerová fixture 765 PASS na obou. Grafická matice 351/351 Compatibility/Forward+, 224 PNG. Obsah Windows 5616 / APK 5563 kontrol, 282/286 souborů a 277 materiálů. Hodnoty JSON i skutečné audio ověřené; Windows katalogy mají bezeztrátové nativní ZSTD v izolované exportní kopii. Žádné testovací save, soukromé klíče ani pracovní TTS model/WAV.

Aktuální verzi najdeš v Nastavení na PC i VR. Přímý průchod serverovna–Londýn je zazděný, cesta vede přes hub. Ukládání/obnova, pět směn, rozbor, 12 poslechů a 13 dovedností popisuje [návod](../docs/CONTINUATION_RELEASE.md). [Úplné logy a snímky](../docs/ui-review/2026-11-04-release/README.md).

**PICO hardware NEPROVEDENO – headset není dostupný.** Android native start, stereo, tracking, optika, komfort a FPS/paměť nebyly ověřené desktopovou simulací. Subjektivní lidský poslech neprovedený. Bez ADB a bez Git push. Přesná data VERIFICATION.json a SHA256SUMS.
