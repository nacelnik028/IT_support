# Souvislé směny a praktický úvod

Serverovna → přehled infrastruktury → **Souvislé směny**, nebo pauza v serverovně.
Kampaň má výslovné samostatné obnovení; Pokračovat ve směně obnoví vlastní relaci.
Původní tři směny mají po třech ticketech; nové dvě pokročilé po pěti. Každá má jeden výchozí svět. Další ticket vymaže jen ověření;
zachová konfiguraci, hardware, inventář i dřívější opravy. Předání čte kumulativní
cíle. Opravu lze provést před přijetím dalšího ticketu.

- SHIFT-NET: kabel PVE-01/port 1 → VLAN/IP/brána VM100 → záloha a PBS Verify.
- SHIFT-VM: HV-01/Events → 2 vCPU, startup 4/min 2/max 8 GiB/Dynamic Memory a start VM200 → záloha/Verify.
- SHIFT-DISK: NAS-01/LED/slot 2/DC-002 → fyzické vyjmutí a SAS SPARE-2T → rebuild, služby a monitoring.

PC: WASD/myš/E, formuláře myší nebo Tab/Enter, Tab otevře cíle a předání.
VR: teleport/chůze, ray/trigger, grip disku, obě ruce a virtuální klávesnice.
Fronta a historie jsou v přehledu směn, aktuální cíle v ticketu/Tab.
Restart vyžaduje potvrzení ztráty rozpracované směny. Při ztrátě dat zůstává
konkrétní odmítnutí a možnost restartu; samotný rebuild data nevytvoří.

Vlastní validovaná větev shifts zachovává ID/verzi/index, výsledky a skutečný stav
i inventář po novém vytvoření aplikace. Přechod přes hub či kurz směnu odloží
a návrat obnoví. Kampaň zůstává v suspended_campaign. Historie má nejvýše 50
výsledků; XP jen 3× zlepšení nejlepšího skóre směny. Směny neodemknou kampaň.
Selhání zápisu zůstane NEULOŽENO a lze zopakovat. Starý trigger ticketu ani
opakované odevzdání neudělí další výsledek.

**Úvod:** Pauza → Seznámení s ovládáním → Zahájit praktický úvod. Nabídku lze
přeskočit. V hale se rozhlédni, portálem 01 dojdi na zlatou značku u IT dveří,
použij DOOR-CONTROL-OPS, projdi, otevři TRAIN-PC-PVE a stiskni Ověřit cvičný
přehled. V TRAIN-SPARES vezmi a vrať SPARE-2T, potom pauza a Pokračovat.
Dočasná infrastruktura po dokončení/zrušení obnoví původní relaci, pozici
a koncepty, bez XP. Esc/B/Y nabízí zrušení; opakování je kdykoli v pauze.

Síť → Provést kontrolu cesty VM: VM/hostitel, NIC/kabel/port, virtuální síť/VLAN,
brána/IP a HTTPS/data. Neověřené úseky nemají zelenou. Výsledky používají
NetworkSimulator.probe a stejné fyzické podmínky jako mise. Změna konfigurace
zneplatní důkaz; undo jej obnoví se stavem. Před/po vychází z výchozího stavu
ticketu/směny. Zkouška příčinu skrývá do výsledku. Nejde o plný síťový provoz.

Pauza → Diagnostika výkonu: FPS, interval 1/FPS, renderer, viewport a engine
statistiky, obnova 2×/s. CPU/GPU časy se neměří. Ve VR také na zápěstí.
Komfort VR: panel 80–140 %, vzdálenost 0,9–2 m, reset. Výchozích 1,76×1,32 m /
1,25 m a viewport 1600×1200 zůstaly zachované.

## Hodnocení nových pokusů (metodika 2)

Za každý ticket: základ 100, každý stupeň nápovědy −4, odmítnutý modelový
zásah −8 a riziko navíc −15; minimum 0. Čtení zadání ani otevření UI není
nápověda. Chyby/risika vzniklé v jednom ticketu se znovu neodečítají v dalším.
Nápovědy i hranice počítadel se ukládají přes odchod/restart. Starý callback
nebo oba triggery nemohou započítat stejný stupeň dvakrát.

Historie → **Rozpis hodnocení** ukazuje uložený základ, nápovědy, chyby, rizika,
skóre a skutečně přidané XP. XP stále vznikají až na konci směny, pouze 3×
zlepšení průměrného nejlepšího skóre. Chyba zápisu zachová jedinou přidělenou
odměnu v paměti a retry opakuje jen zápis. Dokončené historické výsledky se
nepřepočítávají. Rozpracované staré pokusy bez score_version zůstávají v
původní metodice 1 s kumulativními chybami/riziky, bez odhadu ztracených nápověd.

## Pokročilé směny a volba priority

- **SHIFT-RECOVERY / dvě služby a zajištění**: současně APP01 se špatnou VLAN
  a zastavená FS01 s nadměrnou RAM. Po prvním aktuálním ověření obou služeb
  se jednou aktivuje REC-PBS-LINK a odpojí uplink BACKUP-01. Oprav port6,
  vytvoř oba skutečné nové body a proveď PBS Verify. Pět samostatných ticketů.
- **SHIFT-RESILIENCE / storage a konzistence**: odpojený PBS, vadný DC-002
  v RAID10 a vypnuté VSS. Při prvním dosažení 50 % skutečného rebuildu jednou
  selže ochrana cache (STO-CACHE-POWER); použij bezpečný Write-through.
  Nové body obou VM, aktuální aplikace a monitoring po poslední změně uzavřou
  pětiticketovou přejímku. Vytažení zdravého DC-003 při vadném DC-002 způsobí
  Failed/data_loss; samotný rebuild není opravou, použij výslovný restart.

Fronta uvádí prioritu, dopad, závislost na skutečných podmínkách a stav.
**Vybrat incident** mění kontext, nikoli svět, konfiguraci nebo ověření.
Opravy lze provést před přijetím jiného ticketu, v několika platných pořadích.
Závěrečné předání ověří znovu všechny současné podmínky, včetně aktuálnosti
monitoringu. Počítadla jsou přidělená právě vybranému ticketu; nápovědy se
při přepínání kontextu zachovají. Undo vrací i plánovač do stejného bodu světa,
nezpřístupňuje opět již udělenou odměnu.

**Posunout simulovaný čas o 1 minutu** je dobrovolný explicitní krok. Pouze
tehdy přibývá čas a při nedostupnosti alespoň jedné aplikace doba výpadku.
Pauza, focus, tracking ani výkon počítače jej neposouvají. Čas zde nevytváří
skrytý časový limit ani další bodovou penalizaci. Dřívější oprava služeb může
skutečně změnit dostupnost i sledovanou dobu výpadku.

Generátor `tools/advanced_shifts.py` (verze1), volaný z build_shifts.py,
uchovává nové definice odděleně od kampaně. Původní tři definice jsou shodné.
Save zachová vybraný ticket, jednotlivá počítadla, reálný svět/inventář,
aktivované události, nové body a explicitní čas. Historie starých směn zůstává.
