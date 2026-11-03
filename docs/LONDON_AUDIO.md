# Offline anglický poslech

12 různých přesných replik, dvě pro každé LON01–LON06; 24 MP3 včetně samostatné
pomalé syntézy. `data/english/audio.json` mapuje ID, situaci, mluvčího, přesný text,
cesty a SHA256. Pokryté jsou vybrané NPC odpovědi a zákaznické otázky;
ostatní dialog zůstává textový.

U Sama nebo Alexe otevři odpovídající situaci. Pod dostupnou replikou jsou
Poslechnout / zopakovat, Pomaleji a Zastavit. PC: myš nebo Tab/Enter;
VR: oba paprsky/trigger, stick posouvá, B/Y zavírá, A/X přemisťuje panel.
Poslech nikdy nevybírá odpověď. Automatika je volitelná a výchozím stavem vypnutá.
Bus Speech (-3 dB) vede do Master a respektuje společnou hlasitost/ztlumení.
Nová replika zastaví starou. Pauza, ztráta focus/tracking, změna relace a odchod
řeč zastaví; návrat ji sám neobnovuje.

Zdroj hlasu: [Jenny (Dioco)](https://github.com/dioco-group/jenny-tts-dataset),
[Piper model card](https://huggingface.co/rhasspy/piper-voices/blob/main/en/en_GB/jenny_dioco/medium/MODEL_CARD).
Podmínky zdroje dovolují distribuci vygenerovaných klipů i komerční užití;
identifikace hlasu zůstává v UI a offline metadatech. Jde o předem vytvořenou
neurální řeč, nikoli lidskou nahrávku pro tento projekt.
Model, Python, ffmpeg ani runtime TTS nejsou součástí exportu.

Reprodukce: `python tools/build_london_audio.py --model cesta/en_GB-jenny_dioco-medium.onnx`
vyžaduje vývojářské piper-tts a ffmpeg. Model SHA256 je v manifestu.
Normální length_scale=1.0, pomalá=1.6; playback pitch vždy 1.0.
Mono MP3 16 kbit/s / 16 kHz: celkem 188 544 B. Pomalejší syntéza nesnižuje výšku hlasu.
Pracovní WAV/model jsou jen v ignorovaném test-output. Syntéza je stochastická;
distribuují se konkrétní ověřené klipy s uloženými hashi.

Testy provádějí import, MP3 dekódování do nenulových PCM vzorků, délku, delší pomalou
variantu, přesné mapování a skutečné přehrání AudioStreamPlayer. To se odlišuje
od subjektivního poslechu člověka. Reproduktory/komfort a výkon PICO čekají na
[hardwarový checklist](PICO4_HARDWARE_CHECKLIST.md).
