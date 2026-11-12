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
   Stejné akce jsou v záložce **Opravy → Kabeláž a porty** jako přesná očíslovaná tlačítka. Opakovaný výběr
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

## Pracovní panel

Hlavička uvádí ticket, režim a skutečný stav pokusu. Pět pracovních záložek je
v jednom řádku: **Ticket, Diagnostika, Opravy, Analyzátor, Rozbor**. Samostatný
**Výběr ticketů** a **Historie** slouží k prohlížení; až výslovné spuštění ticketu
zahájí nový pokus. Přepnutí režimu v seznamu vybírá režim příštího pokusu.

Diagnostika odděluje výběr zařízení od nástrojů. Na širším desktopu jsou vedle
sebe, při větším textu a ve VR pod sebou. Připojení, Adresace, Služby, Kontrolní
měření a Wi-Fi uvádějí zdroj a cíl jednotlivých operací. Obnova DHCP opravdu
obnoví pronájem. Výsledek rozlišuje **— Nezměřeno**, **✓ Úspěšné**, **× Neúspěšné**
a **! Zastaralé**; neúspěšné měření je stále platný důkaz závady, nikoli známka
za ticket. Starší výsledek uvádí původní zdroj i po výběru jiného zařízení.
Technické detaily každého výsledku a celé zapojení se rozbalují na vyžádání.

Opravy zobrazují jednu ze sedmi skupin. Kabeláž ukazuje držený konektor,
skutečnou trasu, zvolený port, obsazenost a VLAN. Oslovení portu ve 3D bez drženého konektoru otevře jeho VLAN; AP otevře skupinu
Wi-Fi. Konfigurační skupiny zobrazují
současný stav odděleně od změnových akcí. Nic nevybírá správné řešení automaticky.
**Vrátit poslední zásah** uvádí název vracené změny. **Obnovit výchozí stav pokusu**
vyžaduje samostatné potvrzení; odmítnutí zachová celou rozpracovanou práci.

Spodní lišta s ověřením, odevzdáním, návratem do 3D a případnou chybou ukládání
zůstává mimo posouvaný obsah. Ve Zkoušce se ověřování a nápověda nenabízejí,
ve Volném tréninku se neodevzdává do hodnocené historie. Odevzdaný pokus zůstává
uzavřený. Opakování skutečně neúspěšného zápisu uloží tentýž výsledek jednou.

Přepínání stránek a návrat do 3D drží zařízení, port, konektor, filtr, vybraný
rámec a rozbalené detaily během návštěvy pavilonu. Posun a fokus se obnovují
podle stabilní identity ovládání. Tab, šipky a Enter doplňují myš; VR používá
oba paprsky, trigger, posouvání pravou páčkou a návrat B/Y.

Tabule topologie má samostatnou sestavu včetně popisků a spojnic a odstup od
zárubně. GSM stůl, model BTS, telefony, fyzická SIM, popisky, cíle a kolize jsou
odsazené společně. Závěs stávajícího křídla je za obložkou, takže její pohyb
neprotíná rám; zavírání nadále čeká při obsazení celé dráhy hráčem.

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

Výběr nabízí **Základní zadání** (původní seed 0) a **Obměněné zadání**.
Spuštění obměny jednou vylosuje seed; generátor verze 1 vybírá jednu ze tří
ověřených obměn každého ticketu podle `(seed - 1) % 3`. Nejde o neomezený počet
různých závad. Opětovné otevření panelu, měření a 3D stav nemění.
**Detail varianty** uvádí seed a verzi. Historie uchovává tuto identitu a nabízí
**Zopakovat tuto variantu**. Staré záznamy bez identity ji nedostávají zpětně.
Reset obnoví stejnou variantu; nový pokus výslovně zahodí rozpracovaný ticket
po potvrzení. Undo vrací konfiguraci a zneplatňuje důkazy, nemění variantu.
Ukázka má odpovídající vlastní síť. Ve Zkoušce je historie s řešením uzavřená.

Obměny mění dostupné porty a zapojení, VLAN konkrétní trasy, vyčerpaný DHCP
rozsah včetně skutečně nabídnuté adresy, starou/aktuální MAC brány, DNS cache
versus záznam, službu versus pravidlo 443 a polohu AP ve fyzickém prostoru.
H kombinuje VLAN+DNS, nedostupný port+cache nebo VLAN+pravidlo HTTPS. Nabídka
příčin je pro všechny varianty stejná; nic předem nevybírá řešení.
Vyhodnocení chrání PC 02, tiskárnu, správu a hostovskou VLAN 20 a přijímá
alternativní dostupný port či opravu VLAN podle skutečného výsledného stavu.

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
Ověření je v [protokolu a snímcích](ui-review/2026-11-11-workshop-layout/README.md).

## Přenosný tester

Tester leží na servisním stole vpravo od monitoru. E jej vezme/vrátí, ve VR jej
uchopí také krátký grip obou ovladačů. Po uvolnění gripu zůstává u hráče.
Vyber konektor PC nebo tiskárny, konkrétní port a tentýž port znovu pro měření.
Opakovaný konektor zruší připojení sond. **Diagnostika → Přenosný tester trasy**
nabízí stejné kroky tlačítky a čitelný celý výsledek. Displej ve 3D ukazuje
koncové body a krátký stav, HUD také úplný naměřený popis.

Nástroj modeluje trasu a dostupnost portu, nikoli jednotlivé páry vodičů.
Rozlišuje úplné spojení, odpojení, nesouhlas konců a nedostupný port. Zelená
trasa sama nepotvrzuje VLAN, IP, DNS nebo aplikaci. Měření správných konců je
stejným důkazem linky jako panelová diagnostika. Chybná trasa tento důkaz
nevytvoří. Změna sítě označí starý displej i důkaz za zastaralý; nové měření
vyhodnotí aktuální zapojení. Ve Zkoušce neobsahuje skrytou příčinu ani pomoc.
Odchod z dílny vrací jediný předmět domů, síťový pokus zůstává během návštěvy
pavilonu. Opuštění pavilonu jej dosavadním způsobem ukončí.

## Zákazník / English support

Na stránce Ticket otevři **Zákazník / English support**. Pět otázek zjišťuje
příznaky, dobu, rozsah, změny a další služby; jsou bez bodové penalizace.
Jde o zákaznická pozorování výchozího incidentu, nikoli laboratorní měření.
Rozbal **Explain the cause and hand over the service** a vyber příčiny i
skutečné zásahy. Uveď provedené ověření a požádej zákazníka o vyzkoušení.
Potvrzení vychází z aktuální služby; neopravená síť neprojde zdvořilou větou.
Vybrané zásahy musí odpovídat skutečné změně, ověření čerstvým důkazům.
Po změně sítě je staré zákaznické potvrzení neaktuální.

Komunikace má vlastní skóre 0–100 vedle původního technického skóre. Nejde o
CEFR certifikát, hodnocení výslovnosti ani nový XP systém. Tři a více běžných
otázek, přesná příčina, skutečný zásah, ověření a platné potvrzení tvoří pět
částí po 20 bodech; nevhodné obviňování snižuje o 5. Česká opora je samostatně
zaznamenaná pomoc; ve Zkoušce není dostupná. Historická skóre bez těchto dat
se nedoplňují. Nový výsledek uchová dialog i samostatné hodnocení právě jednou.
