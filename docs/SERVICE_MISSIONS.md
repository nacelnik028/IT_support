# Společné servisní mise

Rozcestník → 05 / Počítačové sítě → vzadu vpravo Tréninková dílna → servisní
stůl. Vyber **Výuka / Procvičování / Zkouška**, potom **Zahájit misi**.
**Pokračovat v misi** obnoví uložený incident v jeho původním režimu. Vstup do
místnosti ani prohlížení seznamu nic automaticky nespouští. Tab v pavilonu
otevře aktuální společný incident. Běžné tickety A–H mají stále vlastní model.

## Dvě hratelné situace

**Firemní portál po změně sítě / SERVICE-PORTAL** začíná zákazníkovým popisem,
že se přihlásí lokálně, ale portál se neotevře. Zjisti rozsah, dohledávej linku,
DHCP, překlad, TCP/HTTPS, tisk a kontrolní PC. Virtuální diagnostický log
představuje skutečný snímek téže sítě. Python funkce `failed_checks(rows)` vrací
ve vstupním pořadí `check` položek s `ok == False`. Můžeš analyzovat výchozí
poruchu i pozdější stav; po opravě musí být analýza aktuální.

**Přesunuté pracoviště a tisk / SERVICE-MOVE** propojuje nedostupný port PC 04
a tiskárnu v jiném segmentu. Změř vadnou fyzickou trasu testerem, oprav dostupné
zapojení i konfiguraci a ověř obě stanice, tisk a portál. Python funkce
`affected_clients(rows)` vrací ve vstupním pořadí `id` klientů bez linky nebo
mimo VLAN 10. Vstupní slovníky mají `id`, `link`, `port`, `vlan`. Tiskárnu lze
opravit před nebo po PC; není předepsané jediné pořadí zásahů. Tester musí
skutečně doložit výchozí nedostupnou i závěrečnou funkční trasu.

Oba scénáře používají katalog verze 1, základ dílenské obměny se seedem 1 a
verzí generátoru 1. Zdroj `tools/build_service_missions.py` uvádí i přesnou
konfiguraci tiskárny. Technický seed je v detailu pokusu, nikoli v herním cíli.

## Editor a virtuální data

**Ticket → Python / analyzovat virtuální data incidentu** otevře původní editor
CodeEdit s run/test, zoomem, diagnostikou, výstupem a VR klávesnicí. Editor má
jediný `main.py` tohoto incidentu; původní programovací úlohy a koncepty se tím
nepřepínají. **Celé zadání** ukáže přesné virtuální `logs` / `clients` a
`initial_logs` / `initial_clients`. Nejde o skutečné logy systému ani přístup
na síťové zařízení nebo do souborů počítače.

**Aktualizovat virtuální data** vytvoří nový snímek aktuální sítě bez její
změny. Síťová revize, identita pokusu, hash vstupu a zdrojového souboru vážou
analýzu k incidentu. Změna sítě, undo nebo kódu označí starý výsledek za
neaktuální; je třeba znovu obnovit data a ověřit program. Testy spouštějí
bezpečný původní PythonRuntime a vyhodnocují návratovou hodnotu nad skutečnými
aktuálními i výchozími daty, obráceným pořadím a bezchybnou kontrolou.
Pevné `return []` po opravě nestačí. Více implementací je platných, například
for i while. Nevyžaduje se shoda se vzorem ani nová konstrukce interpretu.
Výuka má vysvětlení a ukázku; Procvičování dobrovolnou nápovědu; Zkouška pomoc
a očekávané výstupy skrývá. Režim patří celé misi, nelze jej změnit jen v editoru.

## Zákazník, výsledek a profil

**Zákazník / English support** používá společné londýnské ovládání replik.
Doptání na příznaky není nápověda ani technický důkaz. Před předáním vyber
přesnou příčinu, skutečný zásah, popis čerstvých ověření a požádej zákazníka o
vyzkoušení. Zákazník potvrzuje pouze skutečně fungující služby; pozdější
změna jeho potvrzení zneplatní. Jazyková opora se zaznamená, ve Zkoušce chybí.
Nejde o hodnocení celé CEFR úrovně ani výslovnosti.

**Odevzdat servisní misi** znovu ověří aktuální síť, povinná měření, analýzu i
předání. Pokus se uzavře a zapíše právě jednou i při neúspěchu. Rozbor shrne
příčinu, zásahy, jednotlivá měření, výstup Pythonu a nové ověření. Technika a
komunikace mají oddělené skóre. Technický úspěch začíná na 100, každé neúspěšné
technické ověření odečte 10, síťová nápověda 5 a programovací nápovědy nejvýše
20; minimum 0. Komunikace používá samostatnou metodiku v dokumentaci dílny.
Komunikační chyba se neodečítá jako technická chyba.

Jednorázové XP vznikají jen při úspěchu celé mise: 2× zlepšení dosavadního
nejlepšího technického skóre dané mise. Samostatný program ani dílenská síť
nevytvářejí další výsledek/odměnu. Čtení historie či profilu a opakování zápisu
XP nepřidává. Společný profil využívá jeden výsledek pro Sítě, Diagnostiku,
Python a samostatně anglickou komunikaci. Staré výsledky nemají odhadnuté
nové důkazy ani pomoc. Historie nabízí konkrétní původní procvičování B / VLAN,
PY30 / serverové logy a LON01 / doptávání podle neúspěšné části. Rozbory jsou
uzavřené i při odložené neodevzdané servisní zkoušce.

## Odložení, pokračování a hranice

Samostatná volitelná větev `service_missions` ve schématu save 2 obsahuje dva
koncepty (po jednom na misi), nejvýše 50 výsledků a nejlepší již zaplacené skóre.
Ukládá skutečnou síť a její důkazy, výchozí stav, kód, pohled editoru, režim,
pokus, pomoc, dialog a vazby analýzy. Zápis po editaci využívá stávající odklad;
odchod a tlačítko **Odložit celou servisní misi** pořídí snímek celé práce.
Po restartu aplikace se obnoví hlavní práce; servisní misi obnovíš výslovně
u stolu. Samotná obnova nespouští kód, měření ani odměnu.

Kampaň, směna, původní učebna, běžná dílna, programovací koncepty a jiné
výsledky zůstávají oddělené. **Restart celé mise** nebo potvrzený reset obnoví
celý incident včetně kódu a dialogu, nikoli ostatní práci. Undo je místní pro
živou síť; po obnovení aplikace zůstane seznam skutečných zásahů, ne živý undo
zásobník. Snímek ukládá jeden společný analyzátor místo opakovaných kopií rámců.
Kód má limit 128 KiB, nová větev celkem 4 MiB v původním save limitu 8 MiB.
Nadlimitní kód se nezkrátí; zůstane v paměti s chybou zápisu k opravě.

Skutečné selhání zápisu ponechá poslední platné bajty, nejnovější stav a jedinou
odměnu v paměti. Spodní lišta i editor nabízejí **Zkusit uložit znovu**. Retry
opakovaně jen serializuje tentýž výsledek. Starý platný profil bez této větve
má prázdné koncepty/historii; původní skóre a významy se nemigrují na nová.

## Ovládání a ověření

PC: stávající přemapovatelné E, myš, Tab/šipky/Enter, Esc. VR: oba paprsky,
trigger, stick pro posuv, B/Y a existující klávesnice; tester také oba gripy.
Tlačítkové repliky nevyžadují mikrofon. Snímky ověřují 720p/1080p/4K při
100/130 % textu a skutečný SubViewport 1600×1200 v obou rendererech.

`service_missions.gd` zahrnuje obě mise × tři režimy, chybný i alternativní
program, zastaralost, chybějící důkazy, oddělení komunikace, restart aplikace,
kampaň/směnu, nový/starý profil a skutečný write failure/retry s jedinými XP.
`service_missions_ui.gd` provádí šest úplných PC průchodů a syntetické XR,
`service_continuation.gd` skutečná tlačítka resetu/replay/odložení/obnovy/retry.
Všechny patří do Test-All a používají SaveManager.path_override i vlastní CFG.
[Snímky a surové logy](ui-review/2026-11-12-service-missions/).
Fyzický headset, jeho tracking, optika a výkon nebyly ověřené; PICO APK se
v této etapě nepřestavuje. Automatické PCM testy nejsou lidským poslechem.
