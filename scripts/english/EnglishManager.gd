extends RefCounted

# All UI actions use semantic IDs and a revision, never text or button indices.
const IDS = ["LON01","LON02","LON03","LON04","LON05","LON06"]
var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/english/scenarios.json"))
var progress: Dictionary = {"results":{},"attempts":[],"phrases":[],"intro_seen":false}
var session: Dictionary = {}
var revision = 0
var available = Callable()
var persist = Callable()
var location = Callable()
var rng = RandomNumberGenerator.new()

func allowed() -> bool:
	return not available.is_valid() or available.call()

func cancel():
	session.clear()
	revision += 1

func start(id: String, mode: String, variant: int = -1) -> bool:
	if not allowed() or not id in IDS or not mode in ["learn","practice","exam"]: return false
	if not session.is_empty() and not session.get("completed",false): return false
	var definition = catalog.scenarios[IDS.find(id)]
	var index = variant if variant >= 0 else (0 if mode=="learn" else rng.randi_range(0,definition.variants.size()-1))
	if index >= definition.variants.size(): return false
	var goal = definition.variants[index].duplicate(true)
	session = {"id":id,"mode":mode,"variant":index,"goal":goal,"node":"greeting","cart":{"adult":0,"child":0,"time":""},"confirmed":false,"paid":false,"ticket":{},"spent":0,"payments":0,"errors":[],"hints":0,"history":[],"phrases":[],"asked_price":false,"asked_sold":false,"changed":false,"directions":false,"thanked":false,"completed":false,"feedback":"","npc":"Hello! How can I help you?","translation":"Dobrý den! Jak vám mohu pomoci?"}
	if id=="LON05":
		session.cart={"adult":2,"child":0,"time":goal.time}
		session.node="confirm"
		summary()
	if id=="LON06":
		session.node="ask_directions"
		session.npc="Hello! Do you need directions?"
		session.translation="Dobrý den! Potřebujete poradit cestu?"
	revision += 1
	return true

func definition() -> Dictionary:
	return catalog.scenarios[IDS.find(session.id)] if not session.is_empty() else {}

static func money(pence: int) -> String:
	return "£%d.%02d" % [pence/100,pence%100]

func task() -> String:
	if session.is_empty(): return ""
	return definition().task.format({"adult":int(session.goal.adult),"child":int(session.goal.child),"time":session.goal.time,"sold":session.goal.get("sold",""),"budget":money(int(session.goal.budget))})+" Ceny jsou fiktivní výukové údaje."

func total() -> int:
	return int(session.cart.adult)*int(catalog.prices.adult)+int(session.cart.child)*int(catalog.prices.child) if not session.is_empty() else 0

static func order_words(adults: int, children: int) -> String:
	var words=["no","one","two","three"]
	var text=words[clampi(adults,0,3)]+" adult ticket"+("s" if adults!=1 else "")
	if children>0: text+=" and "+words[clampi(children,0,3)]+" child ticket"+("s" if children!=1 else "")
	return text

static func time_words(slot: String) -> String:
	return {"14:00":"two o'clock","15:00":"three o'clock","16:00":"four o'clock"}.get(slot,slot)

func choice(id: String, text: String, intent: String, values: Dictionary = {}) -> Dictionary:
	return {"id":id,"text":text,"intent":intent,"values":values}

func choices() -> Array:
	if session.is_empty() or session.completed: return []
	var list: Array=[]
	match session.node:
		"greeting", "order":
			if session.id=="LON03" and not session.asked_price:
				list=[choice("price","How much is an adult ticket?","price"),choice("where","Where is the ticket office?","wrong"),choice("hours","What time do you close?","wrong")]
			else:
				var adult=int(session.goal.adult); var child=int(session.goal.child)
				list=[choice("order","I'd like "+order_words(adult,child)+", please.","order",{"adult":adult,"child":child}),choice("order_alt","Can I have "+order_words(adult,child)+", please?","order",{"adult":adult,"child":child}),choice("two","I'd like two adult tickets, please.","order",{"adult":2,"child":0}),choice("child","One child ticket, please.","order",{"adult":0,"child":1})]
		"time":
			for slot in catalog.slots: list.append(choice("time_"+slot,time_words(slot).capitalize()+", please.","time",{"time":slot}))
			if session.asked_sold: list.append(choice("next","What is the next available time?","next"))
		"confirm":
			list=[choice("confirm","That's right. Can I pay by card?","confirm"),choice("change","Let me change that, please.","change"),choice("change_time","Can I change the time, please?","change_time"),choice("cash","Can I pay in cash?","cash")]
		"pay":
			list=[choice("change","Let me change that before I pay.","change"),choice("change_time","Can I change the time, please?","change_time")]
		"thanks":
			list=[choice("thanks","Thank you. Have a nice day!","thanks"),choice("thanks_alt","Thanks for your help. Goodbye!","thanks"),choice("price","How much is an adult ticket?","wrong")]
		"ask_directions":
			list=[choice("directions","Excuse me, where is Elizabeth Tower?","directions"),choice("directions_alt","Could you tell me the way to Elizabeth Tower?","directions"),choice("price","How much is a ticket?","wrong"),choice("time","What time is it?","wrong")]
		"understand":
			list=[choice("route","Straight ahead, across the bridge, then left. Thank you!","route"),choice("wrong_route","Turn right before the bridge. Thank you!","wrong"),choice("wrong_place","I'll stay at the ticket office. Thanks!","wrong")]
	# Shuffle once per rendered node with a stable seed, without revealing intent.
	var random=RandomNumberGenerator.new(); random.seed=hash(str(revision)+session.id+str(session.variant))
	for i in range(list.size()-1,0,-1):
		var j=random.randi_range(0,i); var item=list[i]; list[i]=list[j]; list[j]=item
	return list

func reject(text: String, linguistic: bool = true) -> bool:
	session.feedback=text
	if session.errors.size()<1000: session.errors.append({"text":text,"language_ok":linguistic})
	return false

func summary():
	session.npc=order_words(int(session.cart.adult),int(session.cart.child)).capitalize()+" at "+time_words(session.cart.time)+". That's "+money(total())+". Is that right?"
	session.translation="Zkontroluj počet, druh, čas a součet objednávky."

func set_cart(adult: int, child: int, slot: String):
	session.cart={"adult":adult,"child":child,"time":slot}
	session.confirmed=false
	if session.id=="LON05" and adult==1 and child==0: session.changed=true

func act(id: String, expected_revision: int) -> bool:
	if not allowed() or session.is_empty() or expected_revision!=revision or session.completed: return false
	var selected={}
	for item in choices():
		if item.id==id: selected=item; break
	if selected.is_empty(): return false
	revision+=1
	session.feedback=""
	session.history.append({"node":session.node,"intent":selected.intent,"text":selected.text})
	if session.history.size()>100: session.history.pop_front()
	var ok=true
	match selected.intent:
		"price":
			session.asked_price=true; session.node="order"
			session.npc="An adult ticket is "+money(int(catalog.prices.adult))+". A child ticket is "+money(int(catalog.prices.child))+". What would you like?"
			session.translation="Dospělý lístek stojí uvedenou cenu, dětský také. Co si přejete?"
		"order":
			set_cart(int(selected.values.adult),int(selected.values.child),"")
			session.node="time"; session.npc="What time would you like to visit?"; session.translation="V kolik hodin chcete přijít?"
		"time", "next":
			var slot=selected.values.get("time",session.goal.time)
			if slot==session.goal.get("sold",""):
				session.asked_sold=true; session.npc="I'm sorry, that time is sold out. Would you like a later time?"; session.translation="Omlouvám se, tento čas je vyprodaný. Chcete pozdější čas?"
			else:
				set_cart(int(session.cart.adult),int(session.cart.child),slot)
				session.node="confirm"; summary()
		"change":
			session.confirmed=false; session.node="order"; session.npc="Of course. What tickets would you like?"; session.translation="Samozřejmě. Jaké lístky chcete?"
		"change_time":
			session.confirmed=false; session.node="time"; session.npc="Of course. What time would you prefer?"; session.translation="Samozřejmě. Jaký čas byste raději?"
		"confirm":
			if not valid_cart(): ok=reject("Objednávka není dostupná, úplná nebo se nevejde do rozpočtu. Oprav ji.")
			else:
				session.confirmed=true; session.node="pay"; session.npc="Certainly. Please tap your practice card on the payment terminal."; session.translation="Jistě. Přiložte cvičnou kartu k platebnímu terminálu."
		"cash":
			session.npc="This exercise accepts cards only. Would you like to pay by card?"; session.translation="V tomto cvičení přijímáme pouze karty. Chcete zaplatit kartou?"
			ok=reject("Replika je jazykově vhodná, ale zadání vyžaduje platbu kartou.")
		"thanks":
			session.thanked=true; session.node="gate"; session.npc="You're welcome. Please show your ticket at the entrance."; session.translation="Rádo se stalo. U vstupu předložte vstupenku."
		"directions":
			session.node="understand"; session.npc="Go straight ahead, cross the bridge, then turn left. Elizabeth Tower is on your left."; session.translation="Jděte rovně, přejděte most a pak zahněte vlevo. Elizabeth Tower je vlevo."
		"route":
			session.directions=true; session.node="walk"; session.npc="That's right. Follow the signs to the tower. Have a lovely day!"; session.translation="Správně. Sledujte značení k věži. Hezký den!"
		"wrong":
			session.npc="Could you try that again, please?"; session.translation="Můžete to prosím zkusit znovu?"
			ok=reject("Věta je srozumitelná, ale v tomto kroku neodpovídá otázce ani cíli. Zkus jinou repliku.")
	if ok and not selected.text in session.phrases: session.phrases.append(selected.text)
	return ok

func valid_cart() -> bool:
	return not session.is_empty() and int(session.cart.adult)+int(session.cart.child)>0 and session.cart.time in catalog.slots and session.cart.time!=session.goal.get("sold","") and total()<=int(session.goal.budget)

func at_station(station: String) -> bool:
	return location.is_valid() and location.call(station)

func pay(expected_revision: int) -> bool:
	if not allowed() or session.is_empty() or expected_revision!=revision or session.node!="pay" or session.paid or not session.confirmed: return false
	revision+=1
	if not at_station("terminal"): return reject("Pro platbu dojdi k označenému terminálu u přepážky.")
	if not valid_cart(): return reject("Platba zamítnuta: neplatný košík nebo nedostatečný rozpočet.")
	session.spent=total(); session.paid=true; session.payments+=1
	session.ticket={"id":"LON-"+str(Time.get_ticks_usec()),"adult":session.cart.adult,"child":session.cart.child,"time":session.cart.time,"pence":total(),"valid":true,"used":false}
	session.node="thanks"; session.npc="Here's your ticket. Enjoy your visit!"; session.translation="Tady je vaše vstupenka. Užijte si návštěvu!"
	return true

func objectives_met() -> bool:
	var s=session
	if s.id=="LON06": return s.directions and at_station("tower")
	return s.paid and s.thanked and s.cart.adult==s.goal.adult and s.cart.child==s.goal.child and s.cart.time==s.goal.time and (s.id!="LON03" or s.asked_price) and (s.id!="LON04" or s.asked_sold) and (s.id!="LON05" or s.changed)

func present_ticket() -> bool:
	if not allowed() or session.is_empty() or not at_station("gate"): return false
	var ticket=session.ticket
	if ticket.is_empty() or not ticket.get("valid",false) or ticket.get("used",true): return reject("Kontrola odmítla chybějící, neplatnou nebo již použitou vstupenku.")
	if ticket.adult!=session.cart.adult or ticket.child!=session.cart.child or ticket.time!=session.cart.time or ticket.pence!=session.spent: return reject("Údaje vstupenky nesouhlasí s platbou.")
	if not objectives_met(): return reject("Lístek neplní zadání nebo chybí poděkování. Restartuj situaci a zkontroluj počet, čas i požadované kroky.")
	ticket.used=true
	return finish()

func arrive_tower() -> bool:
	if not allowed() or session.is_empty() or session.id!="LON06" or session.node!="walk" or not objectives_met(): return false
	return finish()

func hint() -> String:
	if session.is_empty() or session.mode=="exam": return ""
	session.hints+=1
	return definition().hint

func finish() -> bool:
	if session.completed: return false
	session.completed=true; session.node="result"; revision+=1
	var score=maxi(0,100-session.errors.size()*10-int(session.hints)*5)
	var record={"id":session.id,"mode":session.mode,"variant":session.variant,"score":score,"hints":session.hints,"errors":session.errors.duplicate(true)}
	session.result=record
	var old=progress.results.get(session.id,{"best":0,"completed":0,"hints":0})
	progress.results[session.id]={"best":maxi(int(old.best),score),"completed":int(old.completed)+1,"hints":int(old.hints)+int(session.hints)}
	progress.attempts.append(record)
	if progress.attempts.size()>100: progress.attempts.pop_front()
	for phrase in session.phrases:
		if not phrase in progress.phrases and progress.phrases.size()<100: progress.phrases.append(phrase)
	if persist.is_valid(): persist.call()
	return true
