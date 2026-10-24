# Pokračování projektu

Nejdřív přečti PROGRESS.md a README.md. Navazuj na existující projekt; nevytvářej jej znovu.
Pro práci s Godotem používej dostupný Godot MCP a přímé změny souborů podle potřeby.
Po funkční etapě otestuj změny, aktualizuj PROGRESS.md a vytvoř Git commit.
Testy musí používat SaveManager.path_override, nikoli hráčův academy_save.json.
tools/build_content.py přegeneruje katalog JSON; změny udržuj konzistentní.
Rozšíření centra se generuje přes tools/build_extension.py a tools/extension_catalog.py.
Neměň prvních24 definic ani legacy_campaign.json bez výslovného požadavku; test hlídá shodu.
Výukové relace a náhodné série nesmějí přepsat odloženou kampaň. Test-All.ps1 nyní ověřuje i všechny3 výukové režimy.
