# Datacenter Academy — stav vývoje

Datum: 2026-10-24. Nový projekt Godot 4.7.2, pracovní adresář IT_support.

## Zdroje a nástroje
- Godot MCP ověřen: 4.7.2.stable.official.ed1daf0bf; create_scene, add_node, run_project, get_debug_output, stop_project.
- Všechny čtyři Notion stránky načteny; úplné lokální kopie v data/knowledge/notion_*.md.
- Skripty a data se upravují soubory, scény a běh se průběžně ověřují přes MCP.

## Hotovo a ověřeno — etapa 1
- Menu, stylizovaná klikací serverovna, ticket s cíli a stavové konzole.
- Oddělený model infrastruktury, bezpečná validace a ukládání do user://.
- Mise 1: firmware, HBA, UPS, konzole, management síť, diagnostika a ověření.
- Godot headless import bez chyb; tests/stage1.gd PASS včetně odmítnutí nesprávného postupu.
- Projekt spuštěn přes Godot MCP; čtení debug výstupu.

## Probíhá
- Etapa 2: rozšíření datových misí a interakcí na Proxmox, Hyper-V a storage.

## Zbývá
- Přidat a otestovat všech 24 misí, tři konzole, terminál, storage, hodnocení a výuku.
- Kontrolní průchod, README a Windows export, pokud jsou šablony.

## Pokračování
Nejdřív přečíst tento soubor, README a existující skripty. Nevytvářet projekt znovu.
