# Poslechové procvičování

V Londýně použij tabuli Poslechové procvičování nebo odkaz z anglického přehledu. Vyber jednu z 12 úloh a režim Učit se, Procvičovat nebo Zkouška. Poslechnout / zopakovat a Pomaleji používají původní offline MP3 z audio.json; pitch 1.0. Odpověď vybíráš samostatně podle významu. Konec ani zopakování zvuku ji nevybere.

Přepis je skrytý. V learn/practice jej můžeš vyžádat jako pomoc, ve zkoušce je nedostupný. Samostatný poslech vyžaduje celý slyšitelný normální klip. Přepis, pomalá varianta, ztlumení nebo odpověď bez úplného přehrání se evidují jako pomoc. Lze tak cvičení dokončit přístupně, bez falešného tvrzení o doloženém poslechu.

Ukládají se samostatná ID LONL01–12, nejlepší výsledek, posledních 100 pokusů s pomocí/režimem/časem a nabídka výslovné obnovy rozpracované úlohy. Zkouška obnoví původní pravidla i pořadí sémantických odpovědí. Nákup, platba, původní dialog ani London Quiz se nemění. Poslech nepřidává XP.

Myš a Tab/Enter, čísla 1–4 nebo oba XR paprsky s úplným stiskem/uvolněním triggeru. Zvuk sdílí jediný LondonSpeech přehrávač, Speech/Master nastavení a vypnutou výchozí automatiku. Nová úloha, pauza, odchod, ztráta focus/tracking či zánik scény zastaví starý klip.

Generátor: python tools/build_listening.py. Očekávané významy jsou nezávisle stanovené v tests/london_listening.gd, 515 základních kontrol v headless i GPU. Hash/dekódování/PCM a stav přehrávače nejsou subjektivní lidský poslech. PICO optika, skutečný zvuk a ovládání na zařízení: NEPROVEDENO – headset není dostupný. Licence a přesné texty původních 24 klipů viz LONDON_AUDIO.md.

Finished signál má token/generaci konkrétního přehrání. Stop odpojí vazbu a zneplatní čekající callback. Grafický test může navíc zaznamenat skutečný desktop focus-out a výslovné opakování kliknutím; produkce sama řeč po návratu neobnoví.
