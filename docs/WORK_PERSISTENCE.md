# Pokračování rozepsané práce

Menu → **Pokračování / výuka a rozepsaná práce**, také IT učebna →
**Pokračování / uložená výuka**. Kampaň, směna a dobrovolné obnovení výuky
jsou samostatné volby. Správná místnost je podmínkou obnovy výukového snímku.
Opuštění místnosti dál vyčistí živé UI, vedení a cvičnou infrastrukturu.
Snímek uchová skutečný sandbox, krok, režim, chyby a nápovědy. Zkouška se
neobnoví jako jiný režim. Praktický úvod ani náhodná IT série se takto neobnovují.

V programovací učebně otevři **Rozepsaná práce**. **Obnovit rozepsanou práci**
načte přesné soubory, aktivní soubor, kurzor, výběr, posuv a podmínky pokusu.
Generovaná série uchová seed, kategorii, obtížnost, počet a pozici; zadání se
znovu deterministicky ověří. Režim, lekce/úloha a přesná varianta mají vlastní klíč.
Obnova nespouští program, testy ani odměnu. Předchozí ověření se nepřenáší.
**Začít znovu** nahradí jen vybraný koncept počátečním zadáním;
**Smazat koncept** zachová dosažené výsledky. Nativní undo/redo zůstává pouze
v živých bufferech, neobnovuje se po restartu.

Zápis po psaní má odklad přibližně jednu sekundu. Změna úlohy, odchod a běžné
ukončení čekající zdroje zapisují. **Ukládám / Uloženo / Neuloženo** odlišuje
čekající změny a potvrzený zápis. Čas pochází jen z úspěchu. Chyba zůstane viditelná
s opakováním a nepovolí předstírat úspěšné ukončení. Programovací koncept má limit
128 souborových sad, 128 KiB na jednotlivý soubor a celkem 2 MiB. Nadlimitní kód
se nezkrátí; zůstane v paměti s možností obnovit ho k úpravě nebo výslovně smazat.
Není uložený přes pád/ukončení procesu. Celý save má limit 8 MiB.

IT formuláře uchovají i nepoužitý číselný text. Klíč obsahuje konkrétní pokus,
konzoli, hostitele, VM a operaci/verzi. Obnova hodnot nic nepoužije v modelu;
potvrzení nebezpečné operace se nikdy neukládá. Jiné zařízení dostane vlastní
koncept. Chybějící cíl je odmítnutý s vysvětlením. Nejvýše 64 formulářů,
8192 znaků v textovém poli; potvrzená operace svůj koncept vymaže.

Schéma save zůstává 2. Nové větve `work` a `programming.drafts` jsou volitelné
pro staré platné soubory a validované pro nové. Import/export je přenáší.
Neplatné logické cesty, obsah/verze a nadlimitní koncepty se odmítají.
Pokud je poškozená jen volitelná rozepsaná práce, načtení nezahodí platnou
kampaň/výsledky: nejprve zachová všechny původní bajty v `.invalid-work-*.bak`,
vynechá koncepty a ukáže upozornění. Samotné načtení originál nepřepisuje.
Import poškozené větve se odmítne bez změny cílového save.

PC: myš nebo Tab/Enter. XR používá stejná skutečná tlačítka a virtuální
klávesnici na stávajícím monitoru; hardwarová čitelnost a tracking PICO nejsou
ověřené. Testy vždy nastavují vlastní save a obě konfigurace před GameManagerem.
