extends RefCounted

const TOPICS=["options","family","included","availability","recommend","change","total","payment","repeat"]

static func wording(m, topic: String) -> String:
	match topic:
		"options": return "What ticket options are available for this afternoon?"
		"family": return "Is there a family option for our group, and which ages qualify for child tickets?"
		"included": return "Could you clarify what the price includes and whether there are any extra charges?"
		"availability": return "Which time slots are still available? We need to visit between %s and %s." % [m.session.goal.earliest,m.session.goal.latest]
		"recommend": return "If %s is sold out, what would you recommend within our time limit?" % m.session.goal.get("sold",m.session.goal.time)
		"change": return "Would it be possible to change the number of tickets before I pay?"
		"total": return "Could you confirm the total price and the time of our visit?"
		"payment": return "Can I pay by card, and where should I show the tickets afterwards?"
		"repeat": return "I'm not sure I understood that. Could you explain it again, please?"
	return ""

static func response(m, topic: String) -> Dictionary:
	var g=m.session.goal
	var group=m.order_words(int(g.adult),int(g.child))
	var standard=m.money(m.group_price("standard",int(g.adult),int(g.child)))
	var flex=m.money(m.group_price("flex",int(g.adult),int(g.child)))
	var slots=[]
	for slot in m.catalog.slots:
		if slot!=g.get("sold",""): slots.append(slot)
	match topic:
		"options": return {"npc":"For %s, Standard is %s and Flex is %s. Both include one observation visit. Flex costs more and permits a time change before payment; neither can be changed after payment in this exercise." % [group,standard,flex],"translation":"Standard má pevný termín; Flex stojí více a dovolí změnu termínu před platbou. Po platbě zde změny nejsou.","yes":"Standard is fixed; Flex allows a change before payment.","no":"Either option lets us change the time after paying.","other":"Flex includes a river cruise as well."}
		"family": return {"npc":"There is no separate family discount in this scenario. Children aged 6 to 15 use child tickets and must have an adult with them. Your group is %s, so Standard totals %s. These are fictional training rules." % [group,standard],"translation":"Cvičné pravidlo: děti 6–15 let mají dětský lístek s doprovodem. Žádná rodinná sleva není.","yes":"We need the stated adult and child tickets, with no family discount.","no":"Everyone in our group qualifies for a child ticket.","other":"A family ticket lets the children visit without an adult."}
		"included": return {"npc":"The stated price covers one observation visit, without a river cruise. There is no compulsory fee. Flex adds %s per adult and %s per child to Standard. The basket total is %s." % [m.money(1000),m.money(500),m.money(m.total())],"translation":"Cena zahrnuje jednu návštěvu bez plavby. Povinný poplatek není; Flex přidá £10 za dospělého a £5 za dítě.","yes":"The visit is included, but a river cruise is not.","no":"A river cruise is included in the quoted total.","other":"We must add an unspecified compulsory fee."}
		"availability": return {"npc":"Available today in this exercise: %s. %sYour visit must start between %s and %s, as you requested." % [", ".join(slots),"The "+g.sold+" slot is sold out. " if g.has("sold") else "",g.earliest,g.latest],"translation":"Dostupné časy jsou uvedené; vyprodaný termín nelze koupit. Respektuj své časové rozmezí.","yes":"I still need a slot within our stated time window.","no":"Any available slot will fit our schedule.","other":"A sold-out slot can still be reserved by paying more."}
		"recommend": return {"npc":"I would recommend %s: it is available and fits your window of %s to %s. The earliest available time is %s, but availability alone does not mean it fits your plans." % [g.time,g.earliest,g.latest,slots[0]],"translation":"Doporučený čas je dostupný a vyhovuje tvému rozmezí. První dostupný čas nemusí být vhodný.","yes":"I'll choose %s because it meets our time limit." % g.time,"no":"I'll take the sold-out time because it was my first choice.","other":"I'll ignore our time limit and choose any later slot."}
		"change": return {"npc":"Yes. Before payment, tell me exactly which tickets you want instead. I will recalculate the total and cancel the old confirmation. After payment this exercise requires a new attempt.","translation":"Před platbou lze změnit položky; přepočítá se cena a staré potvrzení přestane platit.","yes":"We must check and confirm the revised order before paying.","no":"The old confirmation stays valid after any change.","other":"We can change a paid ticket without starting again."}
		"total": return {"npc":"Your basket contains %s, %s, at %s. The total is %s. No payment has been taken by this question." % [m.order_words(int(m.session.cart.adult),int(m.session.cart.child)),m.session.cart.product,m.session.cart.time if m.session.cart.time!="" else "a time not yet selected",m.money(m.total())],"translation":"Součet a čas pocházejí ze skutečného košíku. Dotaz sám nic nepotvrzuje ani neplatí.","yes":"The current total is %s; I still need to confirm the order." % m.money(m.total()),"no":"The current total is %s and has already been charged." % m.money(m.total()+500),"other":"Asking about the total has issued our tickets."}
		"payment": return {"npc":"Pay by practice card at the marked terminal next to this counter. Then thank me and show the issued ticket at the entrance checkpoint. This is an offline exercise, with no real charge.","translation":"Zaplať cvičnou kartou u terminálu, poděkuj a ukaž vydaný lístek u kontroly.","yes":"I'll use the terminal, then show the ticket at the entrance.","no":"I can enter by showing an unconfirmed basket.","other":"This question has already charged my bank account."}
		"repeat":
			if m.session.id=="LON06": return {"npc":g.route,"translation":g.route_cs,"yes":g.route_reply,"no":"I'll turn right before the bridge and avoid crossing the river.","other":"The ticket counter is the final destination."}
			return response(m,"options")
	return {}
