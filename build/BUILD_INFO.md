# Windows release — 2026-10-26

- Zdrojový commit hry: `f5acc3f065ba65dd187dfc2194990b19858e88b7`.
- Engine a oficiální Windows release šablona: Godot 4.7.2.stable.official.ed1daf0bf.
- Platforma: Windows x86_64; herní PCK je vložené v `ITSupportSimulator.exe`.
- Oficiální stažené archivy ověřeny přes SHA512 z Godot release.
- Export proběhl v dočasné kopii; původní herní zdroje a exportní preset jsou nezměněné.
- Všech 23 sad z `tools/Test-All.ps1` prošlo headless na Linuxu, bez runtime chyb a varování.
  Zahrnuje 65 misí v modelu i UI, 21 lekcí ve třech režimech (1075 kontrol),
  336 výukových UI akcí a 474 kontrol ukládání.
- Prostředky zabalené přímo v tomto EXE prošly dalšími 34 kontrolami servisního
  průchodu, 27 kontrolami herního UI a 162 kontrolami rozhraní. Použit Linux
  Godot editor s `--main-pack`; ověřena také PE x86_64 struktura a vložený PCK.
- Grafické spuštění EXE na Windows ani GPU testy nebyly v tomto Linux prostředí provedeny.
- Testy používají oddělené save/config cesty. Kontrolní součty distribuce jsou v `SHA256SUMS`.

Pro opakovaný build v připraveném cloudovém prostředí je uložen
`/workspace/.cloud-setup/it-support/build-release.py` a postup v nastavení prostředí.

## Stažení pro hráče — oprava distribuce

- Potvrzeno, že raw stažení samostatného EXE z GitHubu vracelo 134bajtový textový Git LFS pointer. Uživatel stáhl soubor do 1 KB; Windows jej odmítl spustit.
- `ITSupportSimulator-Windows-x64.zip` je běžný Git soubor pod 100 MiB a obsahuje úplné EXE, licenci a pokyny k rozbalení.
- CRC archivu a SHA256 EXE po rozbalení byly ověřeny. Obsah hry ani binárka EXE se touto opravou nemění.

## Přímé stažení jediného EXE

- Na žádost uživatele je hlavním odkazem přímo celý soubor: https://media.githubusercontent.com/media/nacelnik028/IT_support/main/build/ITSupportSimulator.exe. Jde o standardní GitHub LFS media cestu pro již nahraný a zpětným stažením ověřený objekt.
- EXE je nadále samostatné, obsahuje vložený PCK a nevyžaduje ruční rozbalení ZIPu. Jeho obsah ani architektura se nemění.
- Přímý HTTP požadavek na media.githubusercontent.com není v tomto cloudovém prostředí povolen egress proxy; samotný objekt byl ověřen přes nativní Git LFS.
