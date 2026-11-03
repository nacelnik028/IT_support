# Praktický úvod, směny, síť a poslech — 3. 11. 2026

104 skutečných PNG: 52 Compatibility a 52 Forward+ na Windows / RTX 5060.
PC: 1280×720, 1920×1080, 3840×2160, vždy text 100/130 %.
Menu, nabídka i HUD úvodu, ticket směny, síťový přehled a londýnské audio UI.
`vr` znamená obsah skutečného SubViewportu 1600×1200, obě velikosti textu,
se zavřenou i otevřenou virtuální klávesnicí. Testovací LineEdit na hranici
klávesnice slouží pouze k jejímu vyvolání; nové panely psaní nevyžadují.

Matice byla vizuálně prohlédnuta v přehledech všech kombinací a také na původních
snímcích zejména 720p/130 %, 4K/130 % a VR/130 %. Zachován přesný podpis autorů,
čitelný text i dostupné důležité akce; dlouhé přehledy mají skutečný posuv.
Testy používají úplný press/release, oba paprsky, teleport, grip a skutečné operace.

- [Menu 720p/130 %](gl_compatibility-menu-1280-130.png)
- [Praktický úvod ve 3D](gl_compatibility-intro-world-1280-130.png)
- [Ticket souvislé směny](gl_compatibility-shift-1280-130.png)
- [Síťová cesta](gl_compatibility-network-1280-130.png)
- [Poslech v Londýně](gl_compatibility-london-audio-1280-130.png)
- [Síť a otevřená VR klávesnice](gl_compatibility-network-keyboard-vr-130.png)

Původní chyba při 130 %: přidaná velká automatika audia vytlačila Překlad/Nápovědu
z prvního pohledu. Volba nyní sídlí v kompaktním footeru. Původní english_world
prošel 1061 kontrolami; žádná kontrola nebyla odstraněna. Nová grafická sada
gameplay_review prošla po 129 kontrolách v obou rendererech.

Ověření ani snímky **nejsou testem optiky, trackingu nebo výkonu headsetu**.
Hardwarové položky zůstávají NEPROVEDENO v PICO4_HARDWARE_CHECKLIST.md.
Trvalé textové logy a výsledky balíčků jsou ve vedlejší složce `verification/`.
