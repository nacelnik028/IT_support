extends RefCounted

# All UI actions use semantic IDs and a revision, never text or button indices.
const IDS = ["LON01","LON02","LON03","LON04","LON05","LON06"]
const Questions=preload("res://scripts/english/CustomerQuestions.gd")
var listening=preload("res://scripts/english/LondonListening.gd").new()
var quiz=preload("res://scripts/english/LondonQuiz.gd").new()
var catalog: Dictionary = JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/english/scenarios.json"))
var progress: Dictionary = {"content_version":2,"results":{},"attempts":[],"phrases":[],"intro_seen":false,"archive":{},"quiz":{},"listening":{}}
var session: Dictionary = {}
var revision = 0
var available = Callable()
var persist = Callable()
var location = Callable()
var rng = RandomNumberGenerator.new()
var run_serial=0

func _init():
	var ref=weakref(self)
	listening.available=func(): return ref.get_ref()!=null and ref.get_ref().allowed()
	listening.persist=func(): return ref.get_ref().persist.call() if ref.get_ref()!=null and ref.get_ref().persist.is_valid() else OK
	quiz.available=func(): return ref.get_ref()!=null and ref.get_ref().allowed()
	quiz.persist=func(): return ref.get_ref().persist.call() if ref.get_ref()!=null and ref.get_ref().persist.is_valid() else OK
	progress.quiz=quiz.progress
	progress.listening=listening.progress

func load_progress(data: Dictionary):
	if data.is_empty(): return
	if not data.has("content_version"):
		progress.archive=data.duplicate(true)
		progress.intro_seen=data.get("intro_seen",false)
	else:
		progress.merge(data,true)
		quiz.progress.merge(data.get("quiz",{}),true)
		listening.progress.merge(data.get("listening",{}),true)
	progress.quiz=quiz.progress
	progress.listening=listening.progress

func allowed() -> bool:
	return not available.is_valid() or available.call()

func cancel():
	listening.cancel()
	session.clear()
	quiz.cancel()
	revision += 1

func start(id: String, mode: String, variant: int = -1) -> bool:
	if not allowed() or not id in IDS or not mode in ["learn","practice","exam"]: return false
	if not session.is_empty() and not session.get("completed",false): return false
	var definition = catalog.scenarios[IDS.find(id)]
	var index = variant if variant >= 0 else (0 if mode=="learn" else rng.randi_range(0,definition.variants.size()-1))
	if index >= definition.variants.size(): return false
	var goal = definition.variants[index].duplicate(true)
	quiz.cancel()
	run_serial+=1
	session = {"id":id,"mode":mode,"variant":index,"goal":goal,"node":"greeting","cart":{"adult":0,"child":0,"time":"","product":"standard"},"confirmed":false,"paid":false,"ticket":{},"spent":0,"payments":0,"errors":[],"hints":0,"translation_used":false,"history":[],"phrases":[],"asked_price":false,"asked_sold":false,"changed":false,"directions":false,"thanked":false,"completed":false,"feedback":"","asked":[],"understood":[],"question_page":0,"question_topic":"","return_node":"","declined":false,"npc":"Good afternoon. Tell me about your plans, and feel free to ask about our ticket options before you decide.","translation":"Dobrý den. Řekněte mi svůj plán a před rozhodnutím se ptejte na nabídku."}
	session.run_id=run_serial
	if id=="LON05":
		session.cart={"adult":2,"child":0,"time":goal.time,"product":"standard"}
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
	var values=session.goal.duplicate(true); values.adult=int(values.adult); values.child=int(values.child); values.budget=money(int(values.budget))
	return definition().task.format(values)+" Ceny a pravidla jsou fiktivní výukové údaje."

func total() -> int:
	return group_price(session.cart.product,int(session.cart.adult),int(session.cart.child)) if not session.is_empty() else 0

func group_price(product: String, adults: int, children: int) -> int:
	var prices=catalog.products[product]
	return adults*int(prices.adult)+children*int(prices.child)

func open_questions(token: int, page: int = 0) -> bool:
	if not allowed() or session.is_empty() or session.completed or session.get("exam_ended",false) or session.paid or token!=revision or page<0 or page>2: return false
	if not session.node in ["questions","answer"]: session.return_node=session.node
	session.question_page=page; session.node="questions"; revision+=1
	return true

func communication_met() -> bool:
	for topic in definition().required:
		if not topic in session.understood: return false
	return true

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
	if session.is_empty() or session.completed or session.get("exam_ended",false): return []
	var list: Array=[]
	match session.node:
		"questions":
			for topic in Questions.TOPICS.slice(session.question_page*3,session.question_page*3+3):
				list.append(choice("q_"+topic,Questions.wording(self,topic),"question",{"topic":topic}))
			list.append(choice("questions_next","Could I ask about something else?","questions_next"))
		"answer":
			var response=Questions.response(self,session.question_topic)
			list=[choice("understood",response.yes,"understood"),choice("misunderstood",response.no,"misunderstood"),choice("misunderstood_other",response.other,"misunderstood"),choice("clarify","Could you clarify that once more, please?","clarify")]
		"greeting", "order":
			if session.id=="LON03" and not session.asked_price:
				list=[choice("price","Before I decide, could you compare the total cost of Standard and Flex for me?","price"),choice("where","Could you reserve the most expensive option without telling me the price?","wrong"),choice("hours","I'd rather ignore the budget and decide after paying.","wrong")]
			else:
				var adult=int(session.goal.adult); var child=int(session.goal.child)
				var reason=catalog.reasons[session.id][session.variant]
				list=[choice("order","I'd like "+order_words(adult,child)+" because "+reason+".","order",{"adult":adult,"child":child}),choice("order_alt","Could you arrange "+order_words(adult,child)+"? The reason is that "+reason+".","order",{"adult":adult,"child":child}),choice("two","Please arrange two adult tickets; I'd prefer not to include any children.","order",{"adult":2,"child":0}),choice("child","I'd prefer a single child ticket, without any adult tickets in the order.","order",{"adult":0,"child":1})]
		"product":
			list=[choice("product_standard","I'd prefer Standard because our visit time is fixed and it costs less.","product",{"product":"standard"}),choice("product_flex","I'd prefer Flex because we may need to change the time before paying.","product",{"product":"flex"}),choice("product_cruise","I'd like a river cruise included at the same price, please.","wrong")]
		"time":
			for slot in catalog.slots: list.append(choice("time_"+slot,"Would "+time_words(slot)+" work? I'd like to confirm whether it is available.","time",{"time":slot}))
			if session.asked_sold: list.append(choice("next","What is the next available time?","next"))
		"negotiate":
			list=[choice("decline","I'm afraid that doesn't fit our schedule. Could we consider a time within our stated window?","decline"),choice("accept_unsuitable","That sounds convenient; please ignore our original time limit.","wrong"),choice("repeat_offer","Could you explain why that time would not work for us?","repeat_offer")]
		"confirm":
			list=[choice("confirm","That's correct: "+money(total())+" at "+session.cart.time+". I'd like to pay by card.","confirm"),choice("change","There seems to have been a misunderstanding. Could I correct the tickets before paying?","change"),choice("change_time","Would it be possible to change the visit time before I pay?","change_time"),choice("confirm_wrong_total","I agree to the total of "+money(total()+500)+" for this order.","wrong_total")]
		"pay":
			list=[choice("change","Let me change that before I pay.","change"),choice("change_time","Can I change the time, please?","change_time")]
		"thanks":
			list=[choice("thanks","Thank you. Have a nice day!","thanks"),choice("thanks_alt","Thanks for your help. Goodbye!","thanks"),choice("price","How much is an adult ticket?","wrong")]
		"ask_directions":
			list=[choice("directions","Excuse me, I'm trying to reach Elizabeth Tower on foot. Could you explain the route using landmarks?","directions"),choice("directions_alt","Could you help me find Elizabeth Tower? I'd prefer clear landmarks so I don't take the wrong turning.","directions"),choice("price","Could you sell me a ticket instead of giving me directions?","wrong"),choice("time","I'd rather stay here; please confirm that I've already reached the tower.","wrong")]
		"understand":
			list=[choice("route",session.goal.route_reply,"route"),choice("wrong_route","I'll turn right before the bridge, so I won't need to cross the river.","wrong"),choice("wrong_place","I'll follow the queue to the viewing entrance instead of going to the tower.","wrong")]
	# Shuffle once per rendered node with a stable seed, without revealing intent.
	var random=RandomNumberGenerator.new(); random.seed=hash(str(revision)+session.id+str(session.variant))
	for i in range(list.size()-1,0,-1):
		var j=random.randi_range(0,i); var item=list[i]; list[i]=list[j]; list[j]=item
	return list

func reject(text: String, linguistic: bool = true) -> bool:
	session.feedback=text
	session.action_recorded=true
	if session.errors.size()<1000: session.errors.append({"text":text,"language_ok":linguistic})
	return false

func summary():
	session.npc=order_words(int(session.cart.adult),int(session.cart.child)).capitalize()+", "+session.cart.product+", at "+time_words(session.cart.time)+". The full total is "+money(total())+". Please check the details before confirming."
	session.translation="Zkontroluj počet, druh, čas a součet objednávky."

func set_cart(adult: int, child: int, slot: String):
	var previous=session.cart.duplicate(true)
	session.cart={"adult":adult,"child":child,"time":slot,"product":previous.get("product","standard")}
	session.confirmed=false
	if session.cart!=previous: session.understood.erase("total")
	if session.id=="LON05" and adult==session.goal.adult and child==session.goal.child and session.cart!=previous: session.changed=true

func act(id: String, expected_revision: int) -> bool:
	if not allowed() or session.is_empty() or expected_revision!=revision or session.completed or session.get("exam_ended",false): return false
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
		"question":
			session.question_topic=selected.values.topic
			if not session.question_topic in session.asked: session.asked.append(session.question_topic)
			var response=Questions.response(self,session.question_topic)
			session.npc=response.npc; session.translation=response.translation; session.node="answer"
		"questions_next": session.question_page=(int(session.question_page)+1)%3
		"understood":
			if session.question_topic=="total" and (session.cart.time=="" or int(session.cart.adult)+int(session.cart.child)==0):
				ok=reject("Nejprve vytvoř košík s časem, teprve potom ověř jeho konečnou cenu.")
			else:
				if not session.question_topic in session.understood: session.understood.append(session.question_topic)
				session.node=session.return_node
				if session.node=="confirm": summary()
				else: session.npc="Thank you for checking. We can continue with your request."; session.translation="Děkuji za ověření. Pokračuj ve své objednávce nebo cestě."
		"misunderstood": ok=reject("Replika je jazykově vhodná, ale neodpovídá informaci prodavače. Znovu porovnej podmínky.")
		"clarify":
			var response=Questions.response(self,session.question_topic)
			session.npc="Let me explain that again. "+response.npc; session.translation=response.translation
		"price":
			session.asked_price=true; session.node="order"
			session.npc=Questions.response(self,"options").npc
			session.translation="Porovnej Standard a Flex; doptej se na nabídku a služby a ověř porozumění."
		"order":
			set_cart(int(selected.values.adult),int(selected.values.child),"")
			session.node="product"; session.npc="Would Standard or Flex suit your plans better? Please consider the conditions as well as the price."; session.translation="Vyber Standard nebo Flex podle podmínek i ceny."
		"product":
			session.cart.product=selected.values.product; session.confirmed=false; session.understood.erase("total")
			session.node="time"; session.npc="Which visit time would fit your plans? Let me check the availability for you."; session.translation="Který čas vyhovuje tvému plánu? Ověřím dostupnost."
		"time", "next":
			var later=catalog.slots.filter(func(slot): return slot>session.goal.get("sold","") and slot!=session.goal.get("sold",""))
			var slot=selected.values.get("time",later[0] if not later.is_empty() else "")
			if slot==session.goal.get("sold",""):
				session.asked_sold=true; session.npc="I'm sorry, that time is sold out. Would you like a later time?"; session.translation="Omlouvám se, tento čas je vyprodaný. Chcete pozdější čas?"
			elif slot<session.goal.earliest or slot>session.goal.latest:
				session.node="negotiate"; session.npc="That slot is available, but it falls outside your window of %s to %s. Shall we look at another option?" % [session.goal.earliest,session.goal.latest]; session.translation="Termín je dostupný, ale nevyhovuje tvému časovému rozmezí. Vyjednej jinou možnost."
			else:
				set_cart(int(session.cart.adult),int(session.cart.child),slot)
				session.node="confirm"; summary()
		"change":
			session.confirmed=false; session.node="order"; session.npc="Of course. What tickets would you like?"; session.translation="Samozřejmě. Jaké lístky chcete?"
		"change_time":
			if session.confirmed and session.cart.product=="standard":
				ok=reject("Potvrzený Standard má pevný čas. Pro změnu znovu vyber nabídku, nebo použij Flex.")
			else:
				session.confirmed=false; session.node="time"; session.npc="Of course. What time would you prefer?"; session.translation="Samozřejmě. Jaký čas byste raději?"
		"decline":
			session.declined=true; session.node="time"; session.npc="I understand. Please choose an available slot that also fits your schedule."; session.translation="Vyber dostupný čas, který vyhovuje i tvému plánu."
		"repeat_offer":
			session.npc="An available slot outside your stated window would conflict with your other plans. We can consider another time."; session.translation="Dostupný termín mimo rozmezí by kolidoval s tvým plánem."
		"wrong_total": ok=reject("Potvrzený součet nesouhlasí se skutečnou cenou košíku. Ověř cenu všech položek a příplatků.")
		"confirm":
			if not valid_cart(): ok=reject("Objednávka není dostupná, úplná nebo se nevejde do rozpočtu. Oprav ji.")
			elif not communication_met(): ok=reject("Chybí požadovaný zákaznický dotaz nebo správné porozumění odpovědi. Použij Zeptat se na nabídku… podle zadání.")
			else:
				session.confirmed=true; session.node="pay"; session.npc="Certainly. Please tap your practice card on the payment terminal."; session.translation="Jistě. Přiložte cvičnou kartu k platebnímu terminálu."
		"cash":
			session.npc="This exercise accepts cards only. Would you like to pay by card?"; session.translation="V tomto cvičení přijímáme pouze karty. Chcete zaplatit kartou?"
			ok=reject("Replika je jazykově vhodná, ale zadání vyžaduje platbu kartou.")
		"thanks":
			session.thanked=true; session.node="gate"; session.npc="You're welcome. Please show your ticket at the entrance."; session.translation="Rádo se stalo. U vstupu předložte vstupenku."
		"directions":
			session.node="understand"; session.npc=session.goal.route; session.translation=session.goal.route_cs
		"route":
			if not communication_met(): ok=reject("Zadání vyžaduje vlastní žádost o zopakování a ověření odpovědi, ne pouze závěrečnou cestu.")
			else:
				session.directions=true; session.node="walk"; session.npc="That's right. Follow the signs to the tower. Have a lovely day!"; session.translation="Správně. Sledujte značení k věži. Hezký den!"
		"wrong":
			session.npc="Could you try that again, please?"; session.translation="Můžete to prosím zkusit znovu?"
			ok=reject("Věta je srozumitelná, ale v tomto kroku neodpovídá otázce ani cíli. Zkus jinou repliku.")
	if ok and not selected.text in session.phrases: session.phrases.append(selected.text)
	if ok:
		if selected.intent=="order" and (session.cart.adult!=session.goal.adult or session.cart.child!=session.goal.child):
			reject("Jazykově vhodná žádost, ale počet dospělých nebo dětí neodpovídá zadání. Před platbou oprav objednávku.")
		elif selected.intent=="product" and session.cart.product!=session.goal.product:
			reject("Jazykově vhodná volba, ale produkt neodpovídá požadovaným podmínkám. Před platbou znovu vyber nabídku.")
		elif session.feedback=="": session.feedback="✓ Volba odpovídá tomuto kroku. "+current_step()
	session.action_recorded=true
	return ok

func current_step() -> String:
	if session.is_empty(): return "Vyber situaci."
	return {"greeting":"Zjisti požadované podmínky a objednej.","order":"Vyber správné počty vstupenek.","product":"Porovnej produkt s podmínkami zadání.","time":"Vyber dostupný čas v daném rozmezí.","negotiate":"Vyjednej čas, který vyhovuje tvému plánu.","questions":"Polož požadovaný zákaznický dotaz.","answer":"Vlastními slovy ověř porozumění.","confirm":"Zkontroluj položky a potvrď skutečný součet.","pay":"Dojdi k terminálu a zaplať cvičnou kartou.","thanks":"Vrať se k Samovi a poděkuj.","gate":"Dojdi ke kontrole a předlož vydaný lístek.","ask_directions":"Požádej Alexe o cestu k věži.","understand":"Upřesni pokyny a potvrď porozumění.","walk":"Přejdi most a u věže potvrď příchod.","result":"Situace je dokončená."}.get(session.node,"")

func visible_feedback() -> String:
	if session.is_empty() or not session.get("action_recorded",false): return ""
	if session.mode=="exam": return "• Volba zaznamenána. Hodnocení uvidíš ve výsledku."
	if session.mode=="learn": return session.feedback
	return "✓ Krok zaznamenán." if session.feedback.begins_with("✓") else "! Zkontroluj volbu podle zadání."

func goal_status() -> Array:
	if session.is_empty(): return []
	var s=session; var goals=[]
	var names={"options":"nabídka Standard / Flex","family":"věk a doprovod dětí","included":"obsah ceny","availability":"dostupnost","recommend":"doporučená alternativa","change":"možnost opravy","total":"skutečná celková cena","payment":"platba a použití lístku","repeat":"zopakování pokynů"}
	for topic in definition().required:
		goals.append({"label":"Dotaz a porozumění: "+names[topic],"met":topic in s.understood})
	if s.id=="LON06":
		goals.append({"label":"Potvrdit trasu podle orientačních bodů","met":s.directions})
		goals.append({"label":"Dojít přes most a potvrdit příchod u věže","met":s.completed})
	else:
		goals.append({"label":"Počty vstupenek podle zadání","met":s.cart.adult==s.goal.adult and s.cart.child==s.goal.child})
		goals.append({"label":"Produkt, čas a rozpočet podle zadání","met":s.cart.product==s.goal.product and s.cart.time==s.goal.time and valid_cart()})
		if s.id=="LON03": goals.append({"label":"Porovnat cenu před rozhodnutím","met":s.asked_price})
		if s.id=="LON04": goals.append({"label":"Vyřešit vyprodaný původní termín","met":s.asked_sold})
		if s.id=="LON05": goals.append({"label":"Opravit původní chybnou objednávku","met":s.changed})
		goals.append({"label":"Potvrdit objednávku","met":s.confirmed})
		goals.append({"label":"Zaplatit jednou u terminálu","met":s.paid and s.payments==1})
		goals.append({"label":"Poděkovat a použít lístek u kontroly","met":s.thanked and s.ticket.get("used",false)})
	return goals

func attempt_score() -> int:
	if session.is_empty(): return 0
	if session.completed: return int(session.result.score)
	var goals=goal_status(); var met=goals.filter(func(goal): return goal.met).size()
	return maxi(0,roundi(100.0*met/maxi(1,goals.size()))-session.errors.size()*10-int(session.hints)*5)

func review_attempt():
	if not allowed() or session.is_empty() or session.completed or session.mode!="exam" or session.get("exam_ended",false): return
	session.exam_ended=true; revision+=1
	var record={"id":session.id,"mode":session.mode,"variant":session.variant,"score":attempt_score(),"hints":session.hints,"errors":session.errors.duplicate(true),"translation":false,"time":int(Time.get_unix_time_from_system()),"passed":false}
	progress.attempts.append(record)
	if progress.attempts.size()>100: progress.attempts.pop_front()
	if persist.is_valid(): persist.call()

func valid_cart() -> bool:
	return not session.is_empty() and int(session.cart.adult)+int(session.cart.child)>0 and session.cart.time in catalog.slots and session.cart.time!=session.goal.get("sold","") and session.cart.time>=session.goal.earliest and session.cart.time<=session.goal.latest and total()<=int(session.goal.budget)

func at_station(station: String) -> bool:
	return location.is_valid() and location.call(station)

func pay(expected_revision: int) -> bool:
	if not allowed() or session.is_empty() or expected_revision!=revision or session.get("exam_ended",false) or session.node!="pay" or session.paid or not session.confirmed: return false
	revision+=1
	if not at_station("terminal"): return reject("Pro platbu dojdi k označenému terminálu u přepážky.")
	if not valid_cart(): return reject("Platba zamítnuta: neplatný košík nebo nedostatečný rozpočet.")
	session.spent=total(); session.paid=true; session.payments+=1
	session.ticket={"id":"LON-"+str(Time.get_ticks_usec()),"adult":session.cart.adult,"child":session.cart.child,"time":session.cart.time,"product":session.cart.product,"pence":total(),"valid":true,"used":false}
	session.node="thanks"; session.npc="Here's your ticket. Enjoy your visit!"; session.translation="Tady je vaše vstupenka. Užijte si návštěvu!"
	session.feedback="✓ Platba proběhla jednou a lístek je v peněžence. Vrať se k Samovi a poděkuj."; session.action_recorded=true
	return true

func objectives_met() -> bool:
	var s=session
	if s.id=="LON06": return s.directions and at_station("tower")
	return s.paid and s.thanked and communication_met() and s.cart.adult==s.goal.adult and s.cart.child==s.goal.child and s.cart.time==s.goal.time and s.cart.product==s.goal.product and (s.id!="LON03" or s.asked_price) and (s.id!="LON04" or s.asked_sold) and (s.id!="LON05" or s.changed)

func present_ticket() -> bool:
	if not allowed() or session.is_empty() or session.get("exam_ended",false) or not at_station("gate"): return false
	var ticket=session.ticket
	if ticket.is_empty() or not ticket.get("valid",false) or ticket.get("used",true): return reject("Kontrola odmítla chybějící, neplatnou nebo již použitou vstupenku.")
	if ticket.adult!=session.cart.adult or ticket.child!=session.cart.child or ticket.time!=session.cart.time or ticket.product!=session.cart.product or ticket.pence!=session.spent: return reject("Údaje vstupenky nesouhlasí s platbou.")
	if not objectives_met(): return reject("Lístek neplní zadání nebo chybí poděkování. Restartuj situaci a zkontroluj počet, čas i požadované kroky.")
	ticket.used=true
	return finish()

func arrive_tower() -> bool:
	if not allowed() or session.is_empty() or session.get("exam_ended",false) or session.id!="LON06" or session.node!="walk" or not objectives_met(): return false
	return finish()

func hint() -> String:
	if session.is_empty() or session.mode=="exam": return ""
	session.hints+=1
	return definition().hint

func finish() -> bool:
	if session.completed: return false
	session.completed=true; session.node="result"; revision+=1
	var score=maxi(0,100-session.errors.size()*10-int(session.hints)*5)
	var record={"id":session.id,"mode":session.mode,"variant":session.variant,"score":score,"hints":session.hints,"errors":session.errors.duplicate(true),"translation":session.get("translation_used",false),"time":int(Time.get_unix_time_from_system())}
	session.result=record
	var old=progress.results.get(session.id,{"best":0,"completed":0,"hints":0})
	progress.results[session.id]={"best":maxi(int(old.best),score),"completed":int(old.completed)+1,"hints":int(old.hints)+int(session.hints)}
	progress.attempts.append(record)
	if progress.attempts.size()>100: progress.attempts.pop_front()
	for phrase in session.phrases:
		if not phrase in progress.phrases and progress.phrases.size()<100: progress.phrases.append(phrase)
	if persist.is_valid(): persist.call()
	return true
