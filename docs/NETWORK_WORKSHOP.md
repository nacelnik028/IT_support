# 05 / Síťová tréninková dílna

Z rozcestníku projdi severním vstupem **05 / Počítačové sítě**, v učebně pokračuj
vpravo kolem terminálu k označeným dveřím **Tréninková dílna**. Ovladač je vedle
dveří na obou stranách. Servisní stůl za dveřmi nabízí výslovný výběr ticketu,
režimu a historie; vstup sám nic nespouští. Vstupy 05 v hlavním menu i v pauze
zůstávají společné pro celý pavilon.

## Pracovní postup

1. U servisního stolu vyber režim a ticket. Přečti ročník, obtížnost, službu a
   požadované důkazy. Ve Výuce sleduj postup založený na skutečných měřeních;
   komentovaná ukázka používá vlastní kopii sítě.
2. Změř výchozí stav. Zásuvky Z04/Z02/Z07 mají pevné trasy k PP04/PP02/PP07.
   Vyber konektor na PC, zásuvce nebo patch panelu a potom konkrétní port switche.
   Stejné akce jsou v Diagnostice jako přesná očíslovaná tlačítka. Opakovaný výběr
   konektor odloží; obsazený port zachová dosavadní zapojení a vysvětlí odmítnutí.
3. Oprav konfiguraci nebo přepojení. Panel vždy ukazuje zařízení, stav,
   konfiguraci, zdroj a cíl měření. Linka a brána mohou měřit zvolené zařízení;
   DHCP/ARP/DNS/TCP/HTTPS pracují s PC 04, kontrolní test s PC 02, W1/W2 s
   modelovým Wi-Fi klientem. Modelové adresy a služby jsou offline.
4. Po každé změně zopakuj požadované služby. Staré výsledky zůstanou označené
   jako zastaralé. Analyzátor filtruje rámce a výběr ukáže jejich cestu v racku.
5. **Ověřit řešení** vyhodnotí aktuální síť a čerstvé důkazy. **Odevzdat ticket**
   uzavře a zapíše jeden výsledek. Ve Zkoušce je dostupné pouze odevzdání;
   nápověda a rozbor příčiny jsou dostupné až po něm. Chyba zápisu je viditelná
   a lze ji bezpečně zopakovat bez druhého výsledku.

PC používá stávající přemapovatelnou interakci, myš, Tab/šipky/Enter a Esc.
VR používá teleport, oba paprsky, trigger a B/Y. Otevřený panel zastaví pohyb.
Povinné hodnoty mají tlačítka a předvolby, není potřeba psát.

## Tickety

- **A / PC 04 bez linky**: zásuvka → patch → vadný port 08; oprava libovolným
  volným funkčním portem VLAN 10, měření linky, brány a PC 02.
- **B / Zásuvka ve špatné VLAN**: linka bez DHCP; oprava přiřazením VLAN nebo
  přesunem na vhodný volný port. Port 05 zůstává hostovská VLAN 20.
- **C / DHCP po změně rozsahu**: vyčerpaný rozsah .20–.49; obnovení rozsahu a
  skutečného pronájmu s adresou, maskou, bránou a DNS. Pevná adresa nestačí.
- **D / Stará ARP položka**: porovnání staré cache s MAC vyměněné brány,
  obnova souseda a nová ARP odpověď; zvlášť místní tiskárna a vzdálená cesta.
- **E / Portál se přestěhoval**: stará cache klienta při správném DNS záznamu;
  obnova cache a HTTPS podle jména.
- **F / DNS odpovídá, HTTPS selže**: správný překlad, neodpovídající TCP 443;
  spuštění služby při zachování pravidel správy a oddělení.
- **G / Wi-Fi v zadní části**: porovnání W1 a W2, přesun AP na středový úchyt;
  nový signál, připojení, DHCP i HTTPS a funkční kabelová kontrola.
- **H / Závěrečná směna**: nesprávná VLAN a starý DNS záznam; oprava celé
  cesty, DHCP, DNS, TCP/HTTPS, měření tiskárny a PC 02 a výběr obou příčin.

Každý ticket má jednu opakovatelnou výchozí variantu, seed 0. Alternativní porty
se hodnotí podle skutečného stavu. Náhodné kosmetické varianty se negenerují.

## Relace a ukládání

Učebna, její ukázka, dílna a dílenská ukázka mají samostatné instance sítě.
Při přechodu učebna ↔ dílna zůstávají pokusy zachované během jedné návštěvy.
Práh dílny má prostorovou rezervu 0,2 m, takže drobný pohyb režim nepřepíná.
Odchod z celého pavilonu pěšky, teleportem, pauzou či do menu pokusy ukončí.
Odložená kampaň a směna se vrátí stávajícím bezpečným postupem.

Volný trénink nabízí zdravou síť nebo závadu A–H, vrácení konkrétního posledního
zásahu a obnovení výchozího stavu. Do hodnocené historie nic nezapisuje.
Odevzdané výsledky, zásahy a důkazy jsou ve větvi `network_workshop`, odděleně od
`network_lab`, kampaně a směn. Historie má nejvýše 100 záznamů a detail výsledku
je znovu přístupný u servisního stolu. Starý profil má prázdnou dílenskou historii.

## Odpovědnosti a omezení modelu

`LabRoom` vlastní učebnu a `WorkshopRoom` připojenou dílnu. `LabSession` a
`WorkshopSession` oddělují pokusy, ukázky a výsledky. `WorkshopNetwork` rozšiřuje
`LabNetwork` bez změny původních úloh a vadného portu 08. `GameShell` směruje
společné PC/XR interakce; `GameManager` odkládá hlavní práci při překročení
hranice pavilonu. `TrainingZone` nadále spravuje samostatnou IT učebnu.

Jde o zjednodušený deterministický model Ethernetu, VLAN, DHCP, ARP, DNS a
TCP/HTTPS, nikoli síťový emulátor. Wi-Fi používá dvě měřicí místa a dva úchyty
AP; DHCP dvě předvolby rozsahu. TLS v analyzátoru uvádí popis rozbalené zprávy.
Pravidla se týkají pouze uzavřené laboratoře. Neprobíhá žádný skutečný síťový
provoz ani spouštění příkazů operačního systému.

Katalog vytváří `tools/build_network_workshop.py`. Původní katalog 40 úloh,
23 karet, prvních 24 misí, legacy katalog a jejich generátory jsou zachované.
Ověření je v [protokolu a snímcích](ui-review/2026-11-11-network-workshop/README.md).
