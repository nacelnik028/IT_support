# 05 / Počítačové sítě

Ve Windows spusť [ITSupportSimulator.exe](../build/ITSupportSimulator.exe). Síťová laboratoř je za tyrkysovým portálem v severní stěně rozcestníku. Lze do ní vstoupit také volbou **05 / Počítačové sítě** z hlavní nabídky nebo přes **Pauza → Kam jít → Počítačové sítě**. Zpět vede označený portál do haly. Rozcestník i serverovna jsou dostupné z pauzy.

U plánu napravo od vstupu vyber ročník. Rozdělení lekcí odpovídá podkladům. První ročník pracuje hlavně s topologií, adresami, vrstvami a DNS. Druhý přidává Ethernet, DHCP, ARP, diagnostiku přístupových sítí a GSM. Terminál nabízí všech šest stanovišť, měření, analyzátor, studijní materiál a uložené výsledky.

Za dveřmi vzadu vpravo je samostatná [Síťová tréninková dílna](NETWORK_WORKSHOP.md) s osmi servisními tickety, volným tréninkem a vlastní historií. Dveře mají ovladače na obou stranách.

## Ovládání a pokusy

- Na PC se pohybuj jako ve zbytku akademie a zamiř na zařízení klávesou interakce (výchozí E). Tab otevírá aktuální úlohu a Esc vrací do učebny. V panelu funguje myš, Tab, šipky a Enter.
- Ve VR používej teleport, oba paprsky a trigger. B/Y zavře panel. A/X otevře úlohu, případně přemístí otevřený panel. Všechny potřebné hodnoty, možnosti a pořadí lze vybrat tlačítky.
- Připojení má dva kroky. Vyber konektor stanice a potom volný port switche. Opakovaným výběrem stanice konektor odložíš. Stav kabelu, LED, tabule a analyzátor sdílejí stejný model. Port 08 má v modelu poruchu. Pokud zamíříš na port bez vybraného konektoru, otevře se jeho nastavení.
- **Výuka** nabízí komentované kroky a prostorové zvýraznění. Tlačítko **Pozorovat v 3D** nechá komentář v přehledu a uvolní výhled na označené prvky. Ukázka má samostatnou síť a po ukončení se vrátíš k vlastnímu pokusu. **Procvičování** umožňuje dobrovolnou nápovědu a opakování. **Zkouška** nabídne rozbor po odevzdání a uzavře daný pokus. Za úspěch v tréninkových režimech se odečítá 10 bodů za chybný pokus a 5 bodů za vyžádanou nápovědu. Jedna odevzdaná zkoušková úloha má 0 nebo 100 bodů.
- Reset obnoví výchozí stav aktuální úlohy. Nové zapojení, konfigurace nebo změna odpovědi označí předchozí ověření jako zastaralé. Stejný pokus se zapíše jednou. Save má samostatnou historii až 100 posledních výsledků a schéma 2. Vstup a čtení karet nevytvářejí výsledek.
- Přechod dveřmi do dílny dočasně zachová učební cvičení. Opuštění celého pavilonu ukončí dočasné pokusy učebny i dílny. Kampaň i souvislá směna se obnovují stávajícím postupem. Laboratoř simuluje modelovou učebnu a používá fiktivní údaje. Výklad, ukázky, měření a hodnocení fungují offline. Otevření kapitoly Notionu používá prohlížeč.

## Souvislý průchod

V druhém ročníku vyber **Od zásuvky až k webu**. Připoj PC 04 a tiskárnu do dvou volných funkčních portů ve VLAN 10. PC 02 už připojené je. Obnov DHCP. Změř ARP k tiskárně i k vzdálenému webu. Porovnej **Změřit DNS** a **Změřit TCP na 443**, uprav záznam A a spusť **Otevřít HTTPS**. V analyzátoru můžeš rozkliknout rámce po vrstvách. **Ověřit řešení** zkontroluje zapojení, pronájem, obě ARP cesty a odpověď webu.

## Úlohy a studijní kapitoly

Každá úloha obsahuje odkaz přímo v panelu **Studijní materiál** a v rozboru. Karty a odkazy v katalogu pokrývají všech 23 kapitol ze dvou rozcestníků. [1. ročník](https://app.notion.com/p/411bceb1e4138110a655c7f44b541312) a [2. ročník](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657).

### 1. Kabeláž, topologie a Ethernet

- **PC 04 bez linky** (1. ročník). [01 · Topologie počítačových sítí](https://app.notion.com/p/411bceb1e41381868cfcf1ac8db4a915), [06 · OSI L1 – fyzická vrstva](https://app.notion.com/p/411bceb1e41381c2a8ced16ad01ca4bb), [03 · Síťové prvky, kabeláž a PoE](https://app.notion.com/p/411bceb1e41381a088fed1bcb020c94d).
- **Zařízení a jejich role** (1. ročník). [03 · Síťové prvky, kabeláž a PoE](https://app.notion.com/p/411bceb1e41381a088fed1bcb020c94d).
- **Výpadek celé větve** (1. ročník). [01 · Topologie počítačových sítí](https://app.notion.com/p/411bceb1e41381868cfcf1ac8db4a915).
- **Kamera po přepojení zhasla** (1. ročník). [03 · Síťové prvky, kabeláž a PoE](https://app.notion.com/p/411bceb1e41381a088fed1bcb020c94d), [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed).
- **Komu šel první rámec?** (1. ročník). [02 · Typy vysílání a přenosové módy](https://app.notion.com/p/411bceb1e41381fb87c7e8e458200dca), [05 · Protokoly a MAC adresy](https://app.notion.com/p/411bceb1e41381efa322f55f51c3abb0).
- **Linka spadla na 100 Mb/s** (1. ročník). [06 · OSI L1 – fyzická vrstva](https://app.notion.com/p/411bceb1e41381c2a8ced16ad01ca4bb), [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed).
- **Tři pole rámce** (2. ročník). [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed), [05 · Protokoly a MAC adresy](https://app.notion.com/p/411bceb1e41381efa322f55f51c3abb0), [03 · ARP, cache a ochrana linky](https://app.notion.com/p/411bceb1e41381a1966bfd3ca8343a7b).
- **Co si switch zapamatuje** (2. ročník). [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed), [07 · OSI L2 – linková vrstva](https://app.notion.com/p/411bceb1e413810a80c8c19d8a2fb7dd).
- **Rámec s chybným FCS** (2. ročník). [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed), [07 · OSI L2 – linková vrstva](https://app.notion.com/p/411bceb1e413810a80c8c19d8a2fb7dd), [09 · OSI L4 – transportní vrstva](https://app.notion.com/p/411bceb1e413810f8c82e74ad2c23849).

### 2. IPv4, VLAN a DHCP

- **Přímo, nebo přes bránu?** (1. ročník). [08 · OSI L3 – síťová vrstva](https://app.notion.com/p/411bceb1e41381548206eb485b2b6225), [Počítačové sítě – síťová laboratoř](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657).
- **Adresa pro stanici** (1. ročník). [Počítačové sítě – síťová laboratoř](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657), [08 · OSI L3 – síťová vrstva](https://app.notion.com/p/411bceb1e41381548206eb485b2b6225).
- **První pronájem IPv4** (2. ročník). [02 · DHCPv4 a nastavení stanice](https://app.notion.com/p/411bceb1e413819d95a2e80ed96c892a).
- **Linka svítí, DHCP mlčí** (2. ročník). [Počítačové sítě – síťová laboratoř](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657), [02 · DHCPv4 a nastavení stanice](https://app.notion.com/p/411bceb1e413819d95a2e80ed96c892a), [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed).
- **Pevná adresa tiskárny** (2. ročník). [02 · DHCPv4 a nastavení stanice](https://app.notion.com/p/411bceb1e413819d95a2e80ed96c892a), [Počítačové sítě – síťová laboratoř](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657).
- **Obnova za čtyři hodiny** (2. ročník). [02 · DHCPv4 a nastavení stanice](https://app.notion.com/p/411bceb1e413819d95a2e80ed96c892a).

### 3. ARP a komunikace se sousedem

- **Dvě adresy na cestě** (1. ročník). [05 · Protokoly a MAC adresy](https://app.notion.com/p/411bceb1e41381efa322f55f51c3abb0), [08 · OSI L3 – síťová vrstva](https://app.notion.com/p/411bceb1e41381548206eb485b2b6225).
- **MAC pro první rámec** (2. ročník). [03 · ARP, cache a ochrana linky](https://app.notion.com/p/411bceb1e41381a1966bfd3ca8343a7b), [08 · OSI L3 – síťová vrstva](https://app.notion.com/p/411bceb1e41381548206eb485b2b6225).
- **Podezřelá změna souseda** (2. ročník). [03 · ARP, cache a ochrana linky](https://app.notion.com/p/411bceb1e41381a1966bfd3ca8343a7b).
- **Broadcast v rámcovém obalu** (2. ročník). [03 · ARP, cache a ochrana linky](https://app.notion.com/p/411bceb1e41381a1966bfd3ca8343a7b), [01 · Ethernet a linková vrstva](https://app.notion.com/p/411bceb1e41381a0a211e9b41d1dc6ed).
- **Ověření ARP odpovědí** (2. ročník). [03 · ARP, cache a ochrana linky](https://app.notion.com/p/411bceb1e41381a1966bfd3ca8343a7b).

### 4. Analyzátor provozu, OSI, TCP/IP a DNS

- **Čtení jednoho DNS dotazu** (1. ročník). [13 · TCP/IP a zapouzdření](https://app.notion.com/p/411bceb1e4138140b89ffb6750b43d56), [08 · OSI L3 – síťová vrstva](https://app.notion.com/p/411bceb1e41381548206eb485b2b6225), [09 · OSI L4 – transportní vrstva](https://app.notion.com/p/411bceb1e413810f8c82e74ad2c23849), [12 · OSI L7 – aplikační vrstva](https://app.notion.com/p/411bceb1e41381f69ecbda396a71548d), [14 · DNS, domény a záznamy](https://app.notion.com/p/411bceb1e41381a0af92e56e3ae2c435).
- **Web podle jména nedostupný** (1. ročník). [14 · DNS, domény a záznamy](https://app.notion.com/p/411bceb1e41381a0af92e56e3ae2c435), [09 · TCP, UDP, porty a sokety](https://app.notion.com/p/411bceb1e4138116accedc3a34ca4dd2).
- **Od DNS zprávy k signálu** (1. ročník). [13 · TCP/IP a zapouzdření](https://app.notion.com/p/411bceb1e4138140b89ffb6750b43d56), [06 · OSI L1 – fyzická vrstva](https://app.notion.com/p/411bceb1e41381c2a8ced16ad01ca4bb), [07 · OSI L2 – linková vrstva](https://app.notion.com/p/411bceb1e413810a80c8c19d8a2fb7dd).
- **Přihlášení po změně spojení** (1. ročník). [10 · OSI L5 – relační vrstva](https://app.notion.com/p/411bceb1e413812587d8c9b42ae1aad8).
- **Rozbitá diakritika ve webu** (1. ročník). [11 · OSI L6 – prezentační vrstva](https://app.notion.com/p/411bceb1e4138129a0c9edda88f7b44d), [12 · OSI L7 – aplikační vrstva](https://app.notion.com/p/411bceb1e41381f69ecbda396a71548d).
- **Server odpověděl 404** (1. ročník). [12 · OSI L7 – aplikační vrstva](https://app.notion.com/p/411bceb1e41381f69ecbda396a71548d).
- **Stará IP po přestěhování webu** (1. ročník). [14 · DNS, domény a záznamy](https://app.notion.com/p/411bceb1e41381a0af92e56e3ae2c435).
- **Hovor se spojí, zvuk se seká** (1. ročník). [04 · Hlasové a datové služby](https://app.notion.com/p/411bceb1e41381bca03ff929a8378509), [10 · OSI L5 – relační vrstva](https://app.notion.com/p/411bceb1e413812587d8c9b42ae1aad8), [04 · Přenosové technologie, kapacita a latence](https://app.notion.com/p/411bceb1e4138187bbe2f49f7abe34bb).
- **DNS funguje, port neodpovídá** (2. ročník). [09 · TCP, UDP, porty a sokety](https://app.notion.com/p/411bceb1e4138116accedc3a34ca4dd2), [14 · DNS, domény a záznamy](https://app.notion.com/p/411bceb1e41381a0af92e56e3ae2c435), [12 · OSI L7 – aplikační vrstva](https://app.notion.com/p/411bceb1e41381f69ecbda396a71548d).
- **Od zásuvky až k webu** (2. ročník). [Počítačové sítě – síťová laboratoř](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657), [01 · Topologie počítačových sítí](https://app.notion.com/p/411bceb1e41381868cfcf1ac8db4a915), [02 · DHCPv4 a nastavení stanice](https://app.notion.com/p/411bceb1e413819d95a2e80ed96c892a), [03 · ARP, cache a ochrana linky](https://app.notion.com/p/411bceb1e41381a1966bfd3ca8343a7b), [14 · DNS, domény a záznamy](https://app.notion.com/p/411bceb1e41381a0af92e56e3ae2c435), [09 · TCP, UDP, porty a sokety](https://app.notion.com/p/411bceb1e4138116accedc3a34ca4dd2).
- **Navázání TCP spojení** (2. ročník). [09 · TCP, UDP, porty a sokety](https://app.notion.com/p/411bceb1e4138116accedc3a34ca4dd2), [Počítačové sítě – síťová laboratoř](https://app.notion.com/p/411bceb1e41381f8a634da0e29546657), [09 · OSI L4 – transportní vrstva](https://app.notion.com/p/411bceb1e413810f8c82e74ad2c23849).

### 5. DSL, WLAN a kvalita přenosu

- **Kam až data dojdou?** (2. ročník). [05 · DSL a připojení po telefonním vedení](https://app.notion.com/p/411bceb1e4138148ac40f7ea1e212e07), [06 · WLAN, Wi‑Fi a přístupový bod](https://app.notion.com/p/411bceb1e413819da9e0e617d8a43b78), [02 · DHCPv4 a nastavení stanice](https://app.notion.com/p/411bceb1e413819d95a2e80ed96c892a).
- **Zpomalení při záloze** (2. ročník). [04 · Přenosové technologie, kapacita a latence](https://app.notion.com/p/411bceb1e4138187bbe2f49f7abe34bb).
- **Tři přípojné body splitteru** (2. ročník). [05 · DSL a připojení po telefonním vedení](https://app.notion.com/p/411bceb1e4138148ac40f7ea1e212e07).
- **Ztráty u zadní stěny** (2. ročník). [06 · WLAN, Wi‑Fi a přístupový bod](https://app.notion.com/p/411bceb1e413819da9e0e617d8a43b78), [05 · DSL a připojení po telefonním vedení](https://app.notion.com/p/411bceb1e4138148ac40f7ea1e212e07).

### 6. GSM a identity

- **Hovor mezi dvěma buňkami** (2. ročník). [07 · GSM, buňky a architektura mobilní sítě](https://app.notion.com/p/411bceb1e413817eb93cffd70d5eefc2).
- **Stejná SIM v jiném telefonu** (2. ročník). [08 · SIM, eSIM a identity v mobilní síti](https://app.notion.com/p/411bceb1e413811c9cb4e6b58b57333e).
- **Kdo obsluhuje hovor?** (2. ročník). [07 · GSM, buňky a architektura mobilní sítě](https://app.notion.com/p/411bceb1e413817eb93cffd70d5eefc2).
- **Dočasná identita GSM** (2. ročník). [08 · SIM, eSIM a identity v mobilní síti](https://app.notion.com/p/411bceb1e413811c9cb4e6b58b57333e), [07 · GSM, buňky a architektura mobilní sítě](https://app.notion.com/p/411bceb1e413817eb93cffd70d5eefc2).
- **Nový profil bez výměny karty** (2. ročník). [08 · SIM, eSIM a identity v mobilní síti](https://app.notion.com/p/411bceb1e413811c9cb4e6b58b57333e).

## Reprodukce ověření

`tools/Test-All.ps1` spouští `tests/network_lab.gd` i původní sady. Cílený test používá izolovanou cestu `SaveManager.path_override`, syntetické XR trackery a skutečnou hlavní scénu. Grafický běh přidá snímky 720p při 130 % a VR viewportu 1600 × 1200 do `test-output`.

```powershell
& 'C:/cesta/Godot_console.exe' --path . --script tests/network_lab.gd -- --screenshots
```
