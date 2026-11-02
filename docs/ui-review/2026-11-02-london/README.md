# English in London — grafická kontrola 2. 11. 2026

Nativní Windows, Godot 4.7.2, NVIDIA RTX 5060, Compatibility. Celá londýnská
matice s reálnými PC kliky a syntetickými XR paprsky: **417 kontrol, 0 selhání**.
Headless stejná sada: 409 kontrol; model samostatně: 979 kontrol.

- `pavilion.png`: prostorové London Eye, NPC Alex, most a Elizabeth Tower.
- `tower.png`: prostorová věž a ciferníky zblízka.
- `dialog-1280-130.png`: skutečné 720p a text 130 %, včetně pomoci a všech akcí.
- `dialog-3840-130.png`: skutečné 4K a text 130 %.

Plná matice 720p/1080p/4K × 100/130 % je v test-output/london-review;
záznam zdrojového GPU testu v test-output/london-world-gpu.log.
Obrázky jsou pod rodičovským .gdignore a nezvětšují herní export.

Kontrola těchto snímků neznamená bezchybnost všech materiálů celé hry.
Uživatel upozornil na vadný vzhled vstupu / dveří Londýna a požádal o následný
audit všech textur. Tento úkol je výslovně součástí PROMPT_ACADEMY_HUB_PC_VR.md.
PICO headset nebyl připojený; snímky nejsou hardwarovou zkouškou VR.
