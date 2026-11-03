"""Twelve authored comprehension tasks for existing exact offline clips."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]

def build():
    rows=[
      ('Na co se zákazník ptá?', 'ticket_options', 'Jaké možnosti vstupenek jsou k dispozici na dnešní odpoledne.', [('river_trip','Jak dlouho trvá víkendová plavba po řece.'),('refund','Jak získat peníze zpět za již použitou vstupenku.'),('closing','V kolik hodin se dnes zavírá věž.')], 'Zákazník zjišťuje dostupné možnosti vstupenek na odpoledne. Nezazněla cena ani potvrzení konkrétního času.'),
      ('Co chce prodavač zjistit?', 'ticket_choice', 'Jaké vstupenky si zákazník přeje.', [('pay_now','Zda zákazník právě zaplatil celou objednávku.'),('route','Kudy se zákazník dostane pěšky k věži.'),('age_proof','Jestli má každý dospělý průkaz totožnosti.')], 'Prodavač se ptá na požadované vstupenky. Žádnou konkrétní cenu ani věkové podmínky v této replice neuvádí.'),
      ('Jaké informace zákazník žádá?', 'family_ages', 'Rodinnou nabídku a věkové podmínky dětských vstupenek.', [('family_queue','Místo srazu rodiny a délku fronty na mostě.'),('discount_code','Slevový kód a přesnou konečnou cenu objednávky.'),('cancel_family','Zrušení již zaplacené rodinné návštěvy.')], 'Ptá se na rodinnou možnost a na věk opravňující k dětskému vstupnému. Samotná replika žádné konkrétní věkové rozmezí nepotvrzuje.'),
      ('Jaký je záměr této zdvořilé žádosti?', 'clarify', 'Požádat o opětovné objasnění předchozí informace.', [('confirm','Potvrdit bez výhrad obsah celé objednávky.'),('speed_up','Požádat o rychlejší platbu u terminálu.'),('leave','Oznámit, že zákazník odchází z prohlídky.')], 'Mluvčí žádá, aby byla informace znovu objasněna. Nejde o potvrzení platby ani o přijetí všech podmínek.'),
      ('Co chce zákazník znát před rozhodnutím?', 'compare_total', 'Porovnání celkové ceny Standard a Flex.', [('unit_child','Pouze jednotkovou cenu jedné dětské vstupenky.'),('refund_days','Počet dnů do vyřízení vrácení peněz.'),('train_cost','Cenu vlakového spojení z Londýna.')], 'Zákazník žádá srovnání celkových nákladů obou nabídek před výběrem. Konkrétní částky v klipu nezazněly.'),
      ('Podle čeho má zákazník nabídky zvážit?', 'price_conditions', 'Podle ceny i podmínek a vhodnosti pro vlastní plán.', [('cheapest_only','Pouze podle nejnižší uvedené ceny.'),('flex_always','Flex je vždy správný bez ohledu na plán.'),('already_paid','Obě nabídky už byly zaplacené současně.')], 'Prodavač doporučuje zohlednit cenu i podmínky a vlastní plán. Neříká, že jedna varianta je vždy lepší.'),
      ('Jaká situace nastala a co mluvčí nabízí?', 'sold_later', 'Zvolený čas je vyprodaný a nabízí se pozdější termín.', [('all_day_full','Celý den je vyprodaný a neexistuje žádná alternativa.'),('early_only','Pozdější termín neexistuje, lze přijít jen dříve.'),('free_entry','Návštěva je bez vstupenky zdarma.')], 'Vyprodaný je dotčený čas. Mluvčí nabízí pozdější termín, ale žádnou konkrétní hodinu v této replice neuvádí.'),
      ('Na jakou informaci se zákazník ptá?', 'next_slot', 'Na nejbližší další dostupný čas.', [('next_bus','Na příští odjezd autobusu k nádraží.'),('last_payment','Na okamžik poslední provedené platby.'),('opening_year','Na rok otevření londýnské památky.')], 'Jde o žádost o další dostupný termín. Klip sám žádný čas nepotvrzuje.'),
      ('Kdy a co chce zákazník udělat?', 'change_before_pay', 'Změnit objednávku ještě před zaplacením.', [('refund_after','Vrátit peníze až po uskutečněné návštěvě.'),('pay_twice','Zaplatit stejnou objednávku dvakrát.'),('keep_order','Ponechat celou objednávku beze změny.')], 'Zákazník chce nejprve změnu a teprve potom platit. Nezaznělo, jaká konkrétní položka se mění.'),
      ('Co prodavač od zákazníka potřebuje?', 'preferred_time', 'Jeho preferovaný čas návštěvy.', [('card_number','Číslo skutečné platební karty.'),('tower_height','Odhad výšky Elizabeth Tower.'),('children_names','Jména všech dětí ve skupině.')], 'Prodavač se ptá na preferovaný čas. Nevyžaduje údaje karty ani nepotvrzuje konkrétní termín.'),
      ('Co mluvčí nabízí?', 'offer_directions', 'Pomoc s orientací a nalezením cesty.', [('sell_flex','Prodej dražší varianty vstupenek.'),('check_ticket','Kontrolu platnosti zaplacené vstupenky.'),('announce_close','Oznámení okamžitého uzavření mostu.')], 'Mluvčí nabízí pomoc s cestou. Konkrétní trasu v této krátké replice ještě nevysvětluje.'),
      ('Jakou cestu a jaké vysvětlení zákazník žádá?', 'walk_landmarks', 'Pěší cestu k Elizabeth Tower vysvětlenou pomocí orientačních bodů.', [('taxi_eye','Cestu taxíkem od věže k London Eye.'),('train_station','Vlakové spojení k nejbližšímu letišti.'),('bridge_history','Historický výklad o všech londýnských mostech.')], 'Cílem je Elizabeth Tower, způsobem chůze a oporou při vysvětlení mají být orientační body. Klip sám ještě neobsahuje konkrétní trasu.')]
    tasks=[]
    for i,(prompt,answer,text,wrong,explanation) in enumerate(rows,1):
        tasks.append(dict(id=f'LONL{i:02}',clip=f'LONA{i:02}',prompt=prompt,
                          options=[dict(id=answer,text=text)]+[dict(id=k,text=v) for k,v in wrong],
                          answer=answer,explanation=explanation))
    return dict(content_version=1,tasks=tasks)

if __name__=='__main__':
    (ROOT/'data/english/listening.json').write_text(json.dumps(build(),ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
