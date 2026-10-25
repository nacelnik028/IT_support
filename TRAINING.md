# Tréninkové centrum — ovládání a rozšíření

Centrum používá vlastní instanci InfrastructureSimulator se stejnými konzolemi,
formuláři, terminálem, sítí, storage a hodnocením jako kampaň. Jeho změny nemění
hlavní infrastrukturu. Fyzické racky, LED a monitory čtou stav příslušné místnosti.

## IT Training Academy ve3D

Do samostatné místnosti dojdeš dveřmi napravo od serverovny. Pevný nástěnný
panel z obou stran přes E otevírá i zavírá; po zasunutí křídla zůstává přístupný.
Stejné místo otevírá hlavní menu i pauza. Katalog21 původních lekcí najdeš
u virtuálního instruktora a zkušebního počítače. Výběr lekce vytvoří nebo obnoví
oddělenou relaci, včetně fyzických zařízení, disků a inventáře. Návštěva
akademie pozastaví rozehranou kampaň a přepne jediný režim z MAIN na TRAINING.
Lekci ani náhodnou sérii nelze spustit mimo centrum; produkční zařízení jsou
během tréninku nepřístupná. V centru zvol lekci u instruktora nebo zkušebního PC.

V režimu Učím se instruktor nejdříve ukáže cvičný server; směr a vzdálenost
počítá podle skutečné pozice hráče. Příchod se potvrdí až v dosahu zařízení.
E na PVE-TRAIN-01 validuje původní výběr PVE-01. Otevření managementu naváže
na původní ověřované kroky: uzel, průvodce, formuláře a skutečná konfigurace.
Z konzole se vracíš Escape nebo tlačítkem Zpět do 3D prostředí. Instruktora
otevírá tlačítko vpravo nahoře; **← Konfigurace** obnoví formulář. Strom a sekce
zůstávají vlevo, vpravo je jedna vybraná operace. Průvodce VM ukládá postupně
Identitu → ISO → CPU/RAM → Disk → Síť → Shrnutí/instalaci. V posledním kroku
můžeš VM také spustit a ověřit. Rozepsaná čísla a výběry zůstanou při návratu.
Hledání a filtr dokončení v nabídce usnadňují výběr ze všech 21 lekcí.

V režimu **Učím se** zůstává aktuální instrukce nad formulářem.
**Zobrazit krok** otevře příslušnou sekci a operaci; v průvodci vybere jeho
správný krok, včetně závěrečného startu a ověření VM. Hostitele lze potvrdit
kliknutím nebo Enterem i tehdy, když už je ve stromu předvybraný.
Podrobný instruktor má vlastní posuv a **Zobrazit potřebný panel** vrací přímo
konfiguraci. Navigace zachovává rozepsané hodnoty a sama nepotvrzuje žádný
výukový krok. Chybná, ale bezpečná konfigurace nechá instrukci na stejném kroku.


Cvičné racky, RAID i ZFS sloty, síťový switch a servisní skříň používají
tentýž model aktuální lekce. Jsou dostupné také pro Procvičování a Zkoušku,
které nezobrazují směrové vedení ani zlaté zvýraznění. Zkouška nepovoluje
nápovědu. Tab ukáže zadání, výsledný stav a předání lekce s rozborem chyb;
v nabídce lze lekci zopakovat. Návrat do kampaně obnoví i její fyzický stav.

## Výukové režimy

| Režim | Vedení | Nápověda | Vyhodnocení |
|---|---|---|---|
| Učím se | Instrukce, proč, šipka a skutečný prvek | Ano | Stav a potvrzené události jednotlivých kroků |
| Procvičování | Zadání a výsledné požadavky | Dobrovolná | Skutečná konfigurace a závěrečné ověření |
| Zkouška | Zadání bez zvýraznění | Vypnutá i v API lekce | Skóre0–100, chyby, rizika a doporučené lekce |

Učení samo o sobě neuděluje stav „Zvládnuto bez nápovědy“. Ten vyžaduje
samostatné procvičování nebo zkoušku bez nápovědy a chyb, alespoň90 bodů.
Nejlepší výsledek se neztratí při zopakování lekce.

Při fyzickém odchodu se lekce okamžitě ruší: kroky, šipky, zvýraznění, formuláře,
inventář, dočasné závady i cvičná infrastruktura se vyčistí. Obnoví se MAIN a
odložený pracovní ticket. Stejnou ochranu používá teleport, načtení pozice mimo
oblast, návrat do menu a zánik scény. Nová návštěva nezačne předchozí lekci.
Dokončené lekce, zkoušky, statistiky, nejlepší skóre a kariérní XP zůstanou.

Tlačítko **Zpět k nabídce lekcí (průběh zůstane)** otevírá výběr uvnitř stejné místnosti.
Pouze během této návštěvy lze obnovit rozpracovaný krok. Restart hry začíná
bez dočasné lekce. Trvalé výsledky jsou v `education.lessons` a `education.attempts`,
dočasné kroky v `session` a `education.sessions`; odchod tyto kroky odstraní.
Série uchovává výsledky, její rozpracovaný scénář se po odchodu neobnovuje.

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
- `education.sessions`: dočasné lekce podle ID a režimu, pouze do opuštění místnosti.
- `education.lessons`: nejlepší výsledky a stav zvládnutí.
- `education.attempts`: posledních200 dokončených pokusů a zkoušek.
- `education.random`: fronta a trvalé výsledky série; dočasný `session` se při odchodu odstraní.

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
