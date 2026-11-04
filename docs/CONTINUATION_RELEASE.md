# Navazující etapa: ukládání, směny a poslech

Implementace navazuje na e523eb4, zachovává 65 misí, legacy24, 21 IT lekcí, 60 programovacích úloh/28 lekcí, šest B1–B2 situací a London Quiz. Přímý průchod ze serverovny do Londýna je souvislá kolizní stěna; do Londýna vede původní východní chodba rozcestníku.

Aktuální verze **1.5.0** je v **Nastavení** na PC i VR; byla přidaná až po uzavření původního promptu v ec51021. Finální oprava XR ruší držený trigger bez potvrzení při focus/tracking/změně či přemístění panelu.

## Kde co najít

- Menu / IT učebna: **Pokračování**, zvlášť kampaň, směna a uložená výuka. Výukový snímek obnovíš pouze v IT učebně, vždy v původním režimu. Zkouška se nepřemění na learn.
- Programovací učebna: **Rozepsaná práce**, poté Obnovit / Začít znovu / Smazat. Přesné soubory, aktivní soubor, kurzor/výběr/posuv a generovaná varianta mají samostatný klíč. Obnova nic nespustí ani neověří.
- Serverovna / pauza: **Souvislé směny**. Původní tři směny plus SHIFT-RECOVERY a SHIFT-RESILIENCE s pěti souběžnými incidenty každá. Vybrat incident mění kontext, nikoli infrastrukturu. Priorita, dopad a závislosti vysvětlují pořadí práce. Simulační minuta běží pouze výslovným tlačítkem.
- Předání: **Rozbor příčin a ověřeného výsledku**, skutečné hodnoty před/po, odmítnuté zásahy oddělené, současné sondy/ověření, dobrovolná otázka. Uložené rozbory znovu otevře Pokračování.
- Londýn: fyzická tabule **Poslechové procvičování**, 12 vlastních úloh. Normální nebo skutečný pomalý klip → samostatně vybrat význam → vysvětlení. Přepis na vyžádání v learn/practice, ve zkoušce zakázaný. Pomoc a neúplné/ztlumené audio se nezaměňují za doložený poslech bez pomoci.
- Menu / pauza / IT / programování / anglický přehled: **Moje znalosti**. Třináct dovedností odvozených ze stávajících výsledků, nejlepší i poslední pokus, zdroj/režim/pomoc/známé datum. Konkrétní doporučení otevírá existující úlohu v odpovídající místnosti a zachová relevantní koncept nebo původní zkoušku. Žádný souhrnný CEFR certifikát.

## Ovládání a ukládání

PC: myš, Tab/Enter a běžné Esc. Poslech podporuje čísla 1–4. VR: oba paprsky, úplný trigger stisk/uvolnění, scroll/drag a virtuální klávesnice; A/X přemístí panel, B/Y vrací do světa/pauzy. Stejné obrazovky a operace modelu na obou cestách.

CodeEdit ukládá s krátkým odkladem a flush při přechodu, odchodu a běžném ukončení. Stav Ukládám/Uloženo/Neuloženo i čas posledního úspěchu pochází ze skutečného zápisu. Chyba dovoluje opakovat zápis bez opakování operace nebo odměny. Native undo/redo je pouze živé. Nepotvrzený IT formulář je koncept pro stejný pokus/host/VM/akci; nepřenáší souhlas s rizikovou operací.

Limity: 128 sad kódu, 128 KiB na soubor, 2 MiB souhrn; 64 formulářů; 20 uložených rozborů; celý save 8 MiB. Nadlimitní kód se nezkrátí a zůstává neuložený v paměti, s návratem k úpravě. Nemůže přežít pád procesu. Volitelná vadná work větev se archivuje před vynecháním; platná kampaň/výsledky se nezahodí. Vadný import nezmění cílový soubor.

Nové směny používají score_version 2: 100 − 4×nápovědy − 8×chyby − 15×rizika. Počítadla a rozpis jsou trvalé, předchozí ticket se znovu nepenalizuje. Staré známé výsledky a XP zůstávají; chybějící historické nápovědy se nevymýšlejí. XP jen za zlepšení nejlepšího výsledku; retry/restart ani profil/poslech/rozbor je nezdvojí.

## Důkazy

Aktuální konečné počty a přesné distribuční hashe uvádí [TEST_REPORT](../TEST_REPORT.md), [BUILD_INFO](../build/BUILD_INFO.md) a [VERIFICATION](../build/VERIFICATION.json). [Snímky a trvalé logy](ui-review/2026-11-03-continuation/README.md). Funkční commity: 88babab (rozpočet), ed0ab3c (stěna), 52a915f (koncepty), 75895bc (hodnocení), 72cf159 (směny), 451cac6 (rozbor), 424eeaf (poslech/profil), 6305282 (grafická matice/exportní testy).

**PICO hardware: NEPROVEDENO – headset není dostupný.** Android native start, stereo, skutečný tracking a ovladače, optická čitelnost, komfort, výkon a paměť nejsou potvrzené desktopovou simulací. Subjektivní lidský poslech rovněž není doložen. [Checklist](PICO4_HARDWARE_CHECKLIST.md) zůstává nevyplněný. Žádný ADB dotaz, instalace na zařízení ani Git push.

Finální source a6d58e3 a testová fixture 74edf37; úplný runner 46 PASS, přímá grafická matice 351/351 a oba přesné balíčky PASS. Aktuální [snímky a logy](ui-review/2026-11-04-release/README.md), [hashe a manifest](../build/BUILD_INFO.md). Bez push.
