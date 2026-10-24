# Ověření hratelné verze

Datum: 24.10.2026. Engine: Godot4.7.2.stable.official.ed1daf0bf, Windows x86_64.

| Kontrola | Výsledek |
|---|---|
| Import a spuštění přes Godot MCP | PASS, bez chyb v debug výstupu |
| První kompletní mise před rozšiřováním | PASS |
| Stavové dokončení všech24 misí | 24/24 PASS |
| UI: formuláře, rizikové dialogy, cíle a předání ticketu | 24/24 PASS |
| UI: dobrovolné otázky a navazující vysvětlení | 24/24 PASS |
| Regrese: cíle, RAID, sítě, parser, rizika, save/load a XP | 88 kontrol PASS |
| Rozšíření: LXC, VSS, VHDX, Replica, spare a kvóty | 35 kontrol PASS |
| Vizuální kontrola1440×900 a1280×720 | PASS |
| Samostatný Windows engine + PCK | PASS, exit code0 |
| Git whitespace check | PASS |

Automatické UI testy vyplňují skutečné Control formuláře a vyvolávají jejich
signály; rizikové operace procházejí potvrzovacími dialogy. Nejde o ruční
odehrání všech misí. Snímky skutečně renderovaných obrazovek jsou v místním
ignorovaném `test-output/`.

Testy ověřují i chyby: RAID10 ve stejném páru, libovolné dvě chyby RAID6,
chybné VLAN/DNS, odlišné možnosti External/Internal/Private, plný pool,
nesprávný slot/serial, původní RAW disk, nechráněnou cache, multiwriter LUN,
konfliktní obnovu, chybějící fencing, zámek VM, selhání VSS a shell injection.
Save/load se zkouší v oddělených testovacích souborech.

Windows balíček není standardní export přes exportní šablonu. Používá
plný lokální Godot engine a vyexportovaný PCK. Rozsah laboratorní simulace
a neimplementované úplné průvodce Ceph/CSV popisuje README.md.

Opakování všech testů:

```powershell
./tools/Test-All.ps1 -GodotPath 'C:/cesta/Godot_console.exe'
```
