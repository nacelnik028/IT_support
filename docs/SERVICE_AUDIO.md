# Zvuk prostředí a servisních událostí

Nastavení → Zvuk obsahuje původní Master/ztlumení a nové **Prostředí / racky**
a **Efekty / kroky a servis**. Speech zůstává samostatná pod Master. Během řeči
prostředí a efekty plynule klesnou na čtvrtinu, pak se vrátí. Důkazy i chyby
jsou dostupné vizuálně. Nové audio nepodmiňuje žádnou správnou odpověď.

ServiceAudio vlastní 11 prostorových zdrojů v hlavní scéně: čtyři racky,
čtyři sdílené jednorázové efekty a tři dveře. Rack zahrnuje skutečně běžící
napájená zařízení v daném stojanu. Plynule utichá při vypnutí. Kroky vycházejí
ze skutečného posunu CharacterBody3D po zemi, včetně XR chůze; teleport,
stání a otevřený UI je nevytvářejí. Dveře sledují pohyb křídla, takže odmítnuté
zavření nemá motorový zvuk. Zvuky kabelu a disku vzniknou až z úspěšné změny
modelu. Tester pípne při měření také při neúspěšném výsledku, bez tvrzení opravy.
Pauza, ztráta focus/tracking a menu zastaví zdroje. Zánik scény je uvolní.
Při zániku vlastník výslovně zastaví streamy a počká na dvě skutečné hranice
mixeru (nejvýše 100 ms). Godot stop frontuje do audio vlákna; rychlé headless
snímky samotné jeho doběhnutí nezaručují. Čekání není součástí chůze, přepnutí
panelu, místnosti ani pauzy. Regrese sleduje slabé reference všech čtyř živých
loopovaných přehrávačů po zániku, bez dodatečného časovače v testu.

## Původ a reprodukce

`python tools/build_service_audio.py` vytvoří sedm mono PCM WAV (16 kHz, 16 bit)
a `data/service_audio.json` se SHA256 a přesnými délkami. Používá pouze Python
standard library, deterministický šum se seedem 42051, harmonické tóny a obálky.
Jde o vlastní syntézu pro projekt, žádné externí samply. Vygenerované vlny jsou
poskytnuté pod CC0-1.0; zdrojový generátor zůstává součástí projektu.
Rack používá celočíselné frekvence v přesně sekundové periodě. Godot načítá
WAV jako sdílené prostředky, rack nastavuje na LOOP_FORWARD. Export obsahuje
importované PCM a manifest. Runtime nepotřebuje Python ani internet.

## Ověření

`tests/service_audio.gd` kontroluje načtení, skutečné dekódování nenulových PCM,
spuštěné AudioStreamPlayer3D a vazby událostí v grafické scéně. Také původní
London Speech, ztišení, nastavení a úklid. Automatická kontrola nenahrazuje
subjektivní lidský poslech; ten nebyl provedený. Fyzický headset nebyl použitý.
`tests/service_audio_benchmark.gd` používá pevnou kameru (2,0.02,1), cíl
(0,1.4,-3), 1920×1080, 90 zahřívacích a 240 měřených snímků, VSync off.
Před zvukem 51ca3e5 / po zvuku: Compatibility 3,790→3,862 ms,
Forward+ 3,722→3,887 ms na RTX 5060. Snímky a surové logy:
[ověření](ui-review/2026-11-12-service-missions/). Nejde o CPU/GPU profil ani PICO FPS.
