# Tréninkové centrum — ovládání a rozšíření

Centrum používá stejný InfrastructureSimulator, konzole, formuláře, terminál,
síť, storage a hodnocení jako kampaň. Neobsahuje samostatné makety administrace.

## Výukové režimy

| Režim | Vedení | Nápověda | Vyhodnocení |
|---|---|---|---|
| Učím se | Instrukce, proč, šipka a skutečný prvek | Ano | Stav a potvrzené události jednotlivých kroků |
| Procvičování | Zadání a výsledné požadavky | Dobrovolná | Skutečná konfigurace a závěrečné ověření |
| Zkouška | Zadání bez zvýraznění | Vypnutá i v API lekce | Skóre0–100, chyby, rizika a doporučené lekce |

Učení samo o sobě neuděluje stav „Zvládnuto bez nápovědy“. Ten vyžaduje
samostatné procvičování nebo zkoušku bez nápovědy a chyb, alespoň90 bodů.
Nejlepší výsledek se neztratí při zopakování lekce.

Při odchodu použij Uložit a opustit lekci. Můžeš ji otevřít znovu ve stejném
režimu; obnoví se krok i potvrzená konfigurace. Restart je výslovné vrácení
laboratoře do počáteční situace. Dosavadní výsledky i kampaň zůstávají zachované.

## Lekce

| ID | Obsah |
|---|---|
| 1001 | Instalace a první nastavení Proxmoxu |
| 1002 | WEB01:9 kroků od racku po ověřenou VM |
| 1003 | Bridge, IP a VLAN |
| 1004 | ZFS mirror z nových datových disků |
| 1005 | PBS, Verify a izolovaná obnova |
| 1006 | Diagnostika VM bez sítě |
| 1007 | Role Hyper-V, restart a VMMS |
| 1008 | External / Internal / Private a správný uplink |
| 1009 | Generation2 VM |
| 1010 | Dynamic Memory a rezerva hostitele |
| 1011 | Datový VHDX a jeho filesystem |
| 1012 | Production checkpoint, aktualizace, návrat a nezávislá obnova |
| 1013 | RAID1 |
| 1014 | Kapacita RAID5/6/10 a vytvoření odpovídajícího pole |
| 1015 | Nový logický disk přes RAID řadič |
| 1016 | Online, GPT a NTFS volume |
| 1017 | Locate, správný slot/serial, výměna a rebuild |
| 1018 | Pool → logical → host filesystem → VHDX → guest filesystem |
| 1019 | Quorum, QDevice, fencing a HA restart |
| 1020 | iSCSI mapping a test výpadku jedné MPIO cesty |
| 1021 | Minimální role, MFA a omezený API token |

Kategorie centra pokrývají Proxmox, Hyper-V, RAID/storage, sítě, zálohy a diagnostiku.

## Jak se kroky ověřují

`TutorialManager` drží aktuální lekci, režim, index kroku, nápovědy a chyby.
`TutorialValidator` kontroluje `checks` přes stejný ObjectiveEvaluator jako mise.
Pokud krok očekává `event`, musí navíc přijít potvrzená událost skutečného UI
nebo úspěšně provedené operace. Není zde tlačítko Další, které by změnilo stav.

Průvodce WEB01 zapisuje přímo `vms.101`: po uložení4096MiB má VM skutečně
`ram_mib=4096` a `ram=4`. Pouhé napsání hodnoty bez potvrzení nestačí.
Před instalací má disk filesystem0; instalace vytvoří filesystem a fyzicky
spotřebuje bloky v poolu. Přislíbená a skutečně obsazená kapacita jsou oddělené.

`TutorialOverlay` vykresluje neblokující rámeček a šipku kolem registrovaného
prvku. Registr používá stabilní klíče, např. `rack:PVE-01`, `tree:PVE-01`,
`field:vm_resources:ram_mib` nebo `action:verify`. Posun konzole zahrne cílový
prvek do viditelné části. Při jiné stránce se zvýrazní navigace; tlačítko
Zobrazit potřebný panel obnoví odpovídající konzoli bez resetu infrastruktury.
Restart a odchod jsou dostupné i při nedostupném prvku.

## Přidání lekce

Datový katalog je `data/training/lessons.json`. Doporučený zdroj pro trvalé
změny je `tools/extension_catalog.py`, potom `python tools/build_extension.py`.
Nová lekce obsahuje běžné zadání mise, počáteční stav, cíle, nápovědy a `steps`:

```json
{
  "title": "CPU a paměť",
  "text": "VM101 přiděl2 vCPU a4096MiB, potom ulož.",
  "why": "Hostitel potřebuje vlastní paměťovou rezervu.",
  "target": "field:vm_resources:ram_mib",
  "page": "Proxmox",
  "tab": "Průvodce VM",
  "event": {"type":"action_applied","action":"vm_resources"},
  "checks": [
    {"path":"vms.101.cpu","value":2,"label":"2vCPU"},
    {"path":"vms.101.ram_mib","value":4096,"label":"4096MiB"}
  ]
}
```

Více cílových ovládacích prvků v jednom kroku lze definovat přes `targets`:
každý záznam má `checks` a `target`. První dosud nesplněná podmínka určí
zvýraznění (např. Instalovat → Start → Ověřit).

Referenční cestu přidej do `tests/lesson_solutions.json`. Testy musí prokázat
správný výchozí stav, jednotlivé změny, finální cíle a obnovu uložené relace.

## Náhodné úlohy

`PracticeGenerator` vybírá z kampaně a vytváří parametrizované varianty:
VMID, jméno, vCPU, RAM, disk, storage, kombinace VLAN/DNS/prefix nebo RAID,
počet členů a jejich kapacita. Chybějící vyšší obtížnosti skládá z více
skutečných příčin, např. chybného uplinku a vyčerpaných dat/metadat poolu.

Každý scénář se před nabídkou přehraje v novém simulátoru podle validačního
receptu. Kontroluje se i to, že není splněn už na začátku. Neplatný scénář
se nezařadí do série. Seed umožňuje opakovatelné testy. Nevznikají náhodné
odpovědi terminálu ani náhodně uznávané výsledky.

Jedna série má1–20 úloh. Fronta, pozice, povolení nápovědy, výsledky a aktuální
konfigurace se ukládají. Série i lekce zachovávají odloženou kampaň.

## Uložení a kompatibilita

`SaveManager` přijímá schema1 i2. Zápis používá schema2 a atomické přejmenování
dočasného souboru. Původní schema1 je před první změnou zálohované.

- `progress`: původní XP, nejlepší skóre, achievementy a chyby.
- `session`: právě otevřená konfigurace; typ campaign/lesson/random.
- `session.tutorial`: krok, režim a výuková metadata oddělená od `state`.
- `suspended_campaign`: původní rozehraná kampaň.
- `education.sessions`: uložené lekce podle ID a režimu.
- `education.lessons`: nejlepší výsledky a stav zvládnutí.
- `education.attempts`: posledních200 dokončených pokusů a zkoušek.
- `education.random`: fronta a rozehraný stav série.

ID jsou interně normalizovaná na celá čísla. Staré klíče skóre jako`1.0`
se sjednotí s`1` při zachování nejlepšího výsledku. Importovaná skóre pomáhají
znalostnímu přehledu; bez historického důkazu se z nich neodvozuje nulový počet nápověd.

## Meze výukového modelu

Přenosy a instalace jsou zrychlené stavové operace. Offline převod zachovává
ověřené disky, identitu a data, ale neprovádí skutečný qemu-img ani Windows.
RAW incident má konkrétní diagnostikovatelnou chybu I/O cesty; jeho postup
není univerzální návod na obnovu všech poškozených disků. Ochrana cache se
opravuje pouze ve fiktivním podporovaném servisním scénáři.

Správná VLAN pro aplikační síť zůstává20; generátor obměňuje chyby a další
konfiguraci uvnitř dostupné topologie. Nejde o generátor libovolné reálné LAN.
Ceph, úplný CSV cluster a obecná síťová emulace zůstávají mimo tento model.

Zálohy Hyper-V zde představují kompatibilní externí backup software s VSS.
Společný model BACKUP-01 není tvrzením, že Hyper-V Manager má nativní
integraci s PBS; reálný postup závisí na konkrétním zálohovacím řešení.
