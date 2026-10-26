# Kontrola úplnosti projektu — 26. 10. 2026

Původní kontrola se týkala zdrojového projektu a současného rozsahu výukového
simulátoru. Uživatel následně zadal opravu zjištěných chyb, ověření EXE a push
na GitHub; tento dokument proto obsahuje také stav po opravě. Katalogy a
definice misí se neměnily.

## Stav po opravě

Obě níže popsané chyby jsou opravené. Diagnostika čte skutečně zvoleného
hostitele; `GameManager.execute_terminal()` předává měnící příkazy do stejné
herní cesty jako formuláře. Ta spravuje undo, výukové události, hodnocení chyb,
ukládání a kontrolu aktuální místnosti. Diagnostické dotazy nevytvářejí undo.
Nová sada `tests/terminal_sessions.gd` je součástí `Test-All.ps1`.

Celá sada nyní obsahuje **24 sad PASS**, bez runtime chyb a varování. Nová
sada má 63 kontrol headless i graficky; nad vloženým PCK přidává kontrolu,
že se skutečně používají zabalená herní data. Obnovena byla také Git historie
původního repozitáře. Výsledky historické kontroly EXE shrnuje `TEST_REPORT.md`;
distribuční složka `build/` se již v repozitáři neuchovává.

## Co je přítomné

| Oblast | Ověřený obsah |
|---|---|
| Hra | Hlavní 3D scéna, pohyb, kolize, interakce, fyzický servis, dveře a samostatná akademie |
| Kampaň | 65 misí; prvních 24 odpovídá `legacy_campaign.json` |
| Výuka | 21 lekcí, režimy Učím se / Procvičování / Zkouška, náhodné série a přehled znalostí |
| Studijní materiály | 50 článků, slovník a čtyři lokální kopie podkladů Notion |
| Administrace | Proxmox, Hyper-V, síť, RAID/ZFS, zálohy a obnova, simulovaný terminál |
| Postup | Skóre, XP, odemykání, historie výsledků a doporučení |
| Ukládání | Validace, atomický zápis, zálohy, obnova po chybě a oddělení kampaně od výuky |
| Rozhraní | Konzole, průvodce VM, hledání, nastavení, klávesy a zvětšení textu |
| Údržba | Generátory obsahu a automatické testy včetně všech tří režimů lekcí |

V odkazech `res://` ve skriptech a herních scénách nebyl nalezen chybějící
soubor. Všechny akce používané misemi a lekcemi mají formulářové definice.
Identifikátory misí i lekcí jsou jedinečné. Opakovaná ID některých formulářů
jsou sdílené operace pro různé konzole, například `verify` nebo `network`.

`tools/build_content.py` byl spuštěn v dočasné kopii mimo projekt. Obnovené
JSON mají stejný datový obsah jako současné katalogy; bajtové rozdíly se týkají
formátování souborů. Původní katalogy nebyly přepsány.

## Původní reprodukce opravených chyb

### 1. Některé diagnostické příkazy čtou jiného hostitele

V [TerminalParser.gd](../scripts/simulation/TerminalParser.gd) čte
`pveversion -v` repozitář a stav aktualizace vždy z `PVE-01`. `Get-VMHost`
čte stav VMMS vždy z `HV-01`, i když uživatel vybral druhého hostitele.

Reprodukce na izolovaném modelu:

- `HV-01.vmms = false`, `HV-02.vmms = true`; `Get-VMHost` nad `HV-02`
  vypíše `VMMS false`, zatímco `Get-Service vmms` správně vypíše `Running`.
- `PVE-01.repo = HOST-ONE`, `PVE-02.repo = HOST-TWO`; `pveversion -v`
  nad `PVE-02` vypíše `Repo: HOST-ONE`.

Dopad: diagnostika může hráče navést na opravu nesprávné závady.
Oprava: oba příkazy čtou vybraný `context`; nová regrese kontroluje rozdílné
stavy obou hostitelů. Původní regrese převážně ověřovala neprázdný výpis.

### 2. Změna přes terminál nepatří do historie pro vrácení zásahu

[UIController.gd](../scripts/ui/UIController.gd) předává příkazy parseru přímo
nad simulátorem a následně ukládá. Obchází tak historii, kterou vytváří
`GameManager.apply()`.

Reprodukce přes skutečný vstupní prvek terminálu v UI:

1. Spustit čtvrtou misi ve volném tréninku; VM100 běží, historie undo je prázdná.
2. Odeslat `qm shutdown 100` na `PVE-01`.
3. VM100 se vypne a stav se uloží, historie undo zůstane prázdná;
   `game.undo()` vrátí `false`.

Dopad: možnost „Vrátit poslední zásah“ nefunguje pro zásahy příkazy terminálu.
Oprava: měnící příkazy procházejí herní vrstvou pro historii, události výuky
a hodnocení; diagnostické dotazy historii zásahů nepřekrývají.

Obě reprodukce jsou v `test-output/audit_terminal.gd` a `audit-terminal.log`.
Používají vlastní `SaveManager.path_override` a nastavení.

## Rozsah a další rozšíření

Pro současnou výuku správy datacentra jsou hlavní části přítomné. Pokročilé
oblasti bez úplných samostatných praktických průvodců zahrnují Ceph,
Failover Cluster/CSV a výměnu bootovacího ZFS rpoolu. Jsou popsané mezi mezemi
v README. Simulace používá připravenou topologii, zrychlené operace a omezenou
historii záloh; nenahrazuje skutečný operační systém ani úplnou síťovou laboratoř.

## Ověření tohoto auditu

- Godot 4.7.2.stable.official.ed1daf0bf; čistý headless import, exit 0.
- Úplná sada `tools/Test-All.ps1`: všech 23 sad PASS, exit 0, bez runtime chyb
  a varování. Obsahuje 65 misí v modelu i přes formuláře, 21 lekcí ve všech
  třech režimech (1075 kontrol), 336 výukových UI akcí, 474 kontrol ukládání,
  124 kontrol relací, 700 kontrol výukové navigace a fyzické průchody ve 3D.
  Tento původní běh ještě nezachycoval dvě chyby terminálu; následná oprava
  přidala 24. sadu s jejich regresním ověřením.
- Grafický `ui_design.gd`: 162 kontrol, 0 selhání, čistý log.
- Grafický `world_ui.gd`: 27 kontrol, 0 selhání, čistý log.
- Grafický `render_quality.gd`: 8 kontrol, 0 selhání, skutečný 4K framebuffer
  a SVG textura 38 × 38 pixelů.
- Grafické běhy použily Forward+/Vulkan na Intel UHD Graphics. Prohlédnuty
  aktuální snímky konzole a lekcí v 720p se 130% textem i HUD ve 3D akademii.
- Všechny testy a reprodukce používají oddělené save a konfigurace.
  Hráčův `academy_save.json` se nepoužívá.
- Godot MCP nebyl v tomto sezení dostupný; kontrola běžela místním Godotem.

Podklady jsou v `test-output/audit-content.log`, `audit-import.log`,
`audit-test-all-console.log`, `audit-gpu-*.log` a `audit-terminal.log`.
Adresář `test-output` je podle existujícího `.gitignore` pouze lokální.
Původní kopie neměla `.git`; před následným commitem byla obnovena skutečná
historie repozitáře `nacelnik028/IT_support`.
