"""Authoritative offline London questions. Independent of the IT catalogues."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCES = {
    "parliament": "https://www.parliament.uk/about/living-heritage/building/palace/architecture/palacestructure/towers-of-parliament/",
    "jubilee": "https://www.parliament.uk/about/living-heritage/building/palace/big-ben/building-clock-tower/key-dates-/",
    "eye": "https://www.londoneye.com/plan-your-visit/information-and-support/faqs/",
    "directions": "https://www.londoneye.com/plan-your-visit/before-you-visit/directions/",
    "bridges": "https://www.citybridgefoundation.org.uk/what-we-do/bridges",
    "tfl": "https://tfl.gov.uk/travel-information/visiting-london/getting-around-london/best-ways-for-visitors-to-pay",
    "gallery": "https://www.nationalgallery.org.uk/visiting/plan-your-visit",
}

# The first authored option is the answer; runtime uses stable option IDs and
# shuffles both questions and options. This ordering never reaches the UI.
ROWS = [
    ("landmarks", "What does the name Big Ben refer to precisely?", "Co přesně označuje Big Ben?", ["The main bell", "The whole palace", "A bridge", "A clock hand"], "Big Ben is the main bell inside Elizabeth Tower.", "Big Ben je hlavní zvon uvnitř Elizabeth Tower.", "parliament"),
    ("landmarks", "Which building contains Elizabeth Tower?", "Ke které budově patří Elizabeth Tower?", ["The Palace of Westminster", "Buckingham Palace", "The National Gallery", "County Hall"], "The tower forms part of the Palace of Westminster.", "Věž je součástí Westminsterského paláce.", "parliament"),
    ("history", "The Clock Tower was renamed in 2012. Which occasion did this honour?", "Jakou událost připomíná přejmenování v roce 2012?", ["Elizabeth II's Diamond Jubilee", "The opening of the Underground", "The first bridge lift", "The end of the Second World War"], "The new name marked the Queen's Diamond Jubilee.", "Nové jméno připomíná diamantové jubileum Alžběty II.", "jubilee"),
    ("landmarks", "You walk around Elizabeth Tower. How many clock faces can you see in total?", "Kolik ciferníků má věž celkem?", ["Four", "Two", "One", "Eight"], "Its clock has a face on each of four sides.", "Ciferník je na každé ze čtyř stran.", "parliament"),
    ("landmarks", "Which description fits the London Eye?", "Který popis odpovídá London Eye?", ["A 135-metre observation wheel", "A 135-metre clock tower", "An underground art gallery", "A bridge across the Thames"], "The Eye is an observation wheel, 135 metres tall.", "Jde o vyhlídkové kolo vysoké 135 metrů.", "eye"),
    ("visiting", "Allow about half an hour for one rotation. Approximately how long is that?", "Kolik času přibližně vyhradit na jednu otáčku?", ["30 minutes", "10 minutes", "60 minutes", "90 minutes"], "A standard rotation takes about 30 minutes.", "Běžná otáčka trvá přibližně 30 minut.", "eye"),
    ("landmarks", "The real Eye has more pods than this simplified game model. How many are in its design?", "Kolik kabinek má skutečné kolo, na rozdíl od herní zkratky?", ["32", "24", "12", "60"], "The real wheel has 32 pods; the game is simplified.", "Skutečné kolo má 32 kabinek; hra je zjednodušená.", "eye"),
    ("visiting", "Unless you book a private pod, what should you expect?", "Co očekávat bez objednání soukromé kabinky?", ["You may share with other visitors", "You must travel alone", "Every group gets its own pod", "You have to operate the wheel"], "Regular pods may be shared with other guests.", "Běžnou kabinku mohou sdílet další návštěvníci.", "eye"),
    ("geography", "On which bank of the Thames is the London Eye?", "Na kterém břehu Temže je London Eye?", ["The South Bank", "The North Bank", "An island in the middle", "Neither: it is outside London"], "The Eye stands on the South Bank.", "Kolo stojí na jižním břehu.", "directions"),
    ("geography", "Which river separates the Eye from the Houses of Parliament?", "Která řeka odděluje kolo od parlamentu?", ["The Thames", "The Severn", "The Avon", "The Trent"], "The Thames runs between these landmarks.", "Mezi těmito památkami protéká Temže.", "directions"),
    ("transport", "You arrive at Waterloo and want to walk to the Eye. Which signs should you follow?", "Které značení sledovat z Waterloo ke kolu?", ["South Bank", "Tower of London", "Heathrow Airport", "Camden Town"], "The Eye's directions tell Waterloo visitors to follow South Bank signs.", "Oficiální trasa vede podle značek South Bank.", "directions"),
    ("geography", "A friend asks where to find the Eye's ticket office. Which neighbouring building should you name?", "Ve které sousední budově je pokladna?", ["County Hall", "The Palace of Westminster", "The National Gallery", "St Paul's Cathedral"], "The ticket office is inside County Hall next to the Eye.", "Pokladna sídlí v sousední County Hall.", "directions"),
    ("bridges", "Tower Bridge and London Bridge appear separately on a map. What should you conclude?", "Co vyvodit ze dvou názvů mostů na mapě?", ["They are different bridges", "They are names for the same bridge", "London Bridge is a tower", "Tower Bridge is outside London"], "The bridge authority maintains them as separate Thames crossings.", "Správce uvádí dva samostatné mosty přes Temži.", "bridges"),
    ("bridges", "Tower Bridge's central road sections rise. Why is this useful?", "Proč se zvedají střední části Tower Bridge?", ["To let tall vessels pass", "To stop the river flowing", "To move the bridge downstream", "To turn the road into a railway"], "Its bascules lift to allow river traffic through.", "Zvedací části umožňují průjezd lodí.", "bridges"),
    ("history", "Tower Bridge opened in 1894. Which period does that place its opening in?", "Do kterého století patří otevření roku 1894?", ["The nineteenth century", "The seventeenth century", "The eighteenth century", "The twentieth century"], "1894 falls in the nineteenth century.", "Rok 1894 patří do devatenáctého století.", "bridges"),
    ("transport", "On the Tube you touch in with your phone. How should you touch out?", "Přiložíš při vstupu do metra telefon. Čím se odbavit na výstupu?", ["With the same phone", "With any bank card", "With a different Oyster card", "You should never touch out"], "Use the same card or device at both ends of a Tube journey.", "Na obou koncích cesty metrem použij stejné zařízení.", "tfl"),
    ("transport", "You board a London bus using pay as you go. What is the correct touching procedure?", "Jak se odbavit v londýnském autobusu při pay as you go?", ["Touch in only", "Touch out only", "Touch in and out", "Touch twice before sitting down"], "Buses require a touch in, without a touch out.", "V autobuse se přikládá jen při nástupu.", "tfl"),
    ("transport", "You want to pay only for the journeys you make. Which option describes this?", "Jak se nazývá platba za skutečně uskutečněné cesty?", ["Pay as you go", "A reserved seat", "A museum membership", "A private pod"], "Pay as you go uses contactless or Oyster for journeys taken.", "Pay as you go využívá bezkontaktní platbu nebo Oyster.", "tfl"),
    ("culture", "You are meeting at the National Gallery. Which square should you head for?", "Na které náměstí zamířit k National Gallery?", ["Trafalgar Square", "Parliament Square", "Leicester Square", "Russell Square"], "The National Gallery faces Trafalgar Square.", "National Gallery stojí na Trafalgar Square.", "gallery"),
    ("culture", "A notice says: general admission is free; some exhibitions have a charge. What does this mean?", "Co znamená bezplatný běžný vstup a placené některé výstavy?", ["Some special exhibitions may cost extra", "Every exhibition is free", "You must pay for every room", "Only staff may enter for free"], "Free general entry does not include every temporary exhibition.", "Běžný vstup zdarma nezahrnuje každou dočasnou výstavu.", "gallery"),
]

def build():
    questions = []
    for i, (topic, prompt, translation, options, explanation, cs, source) in enumerate(ROWS, 1):
        questions.append(dict(id=f"LONQ{i:02}", topic=topic, prompt=prompt, translation=translation,
                              options=[dict(id=f"o{j}", text=t) for j, t in enumerate(options)], answer="o0",
                              explanation=explanation, explanation_cs=cs, source=SOURCES[source], verified="2026-11-02"))
    path = ROOT / "data/english/london_quiz.json"
    path.write_text(json.dumps(dict(version=1, level="B1–B2", questions=questions), ensure_ascii=False, indent=2)+"\n", encoding="utf-8")

if __name__ == "__main__":
    build()
