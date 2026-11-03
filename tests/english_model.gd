extends SceneTree

const Saves=preload("res://scripts/progression/SaveManager.gd")
const Display=preload("res://scripts/core/DisplaySettings.gd")
const Game=preload("res://scripts/core/GameManager.gd")
var checks=0
var failures=0
var game
var m
var station=""

func _init():
	preload("res://scripts/xr/VRSettings.gd").path_override="user://academy_test_english_model_"+str(OS.get_process_id())+"_vr.cfg"
	Saves.path_override="user://academy_test_english_model_%d.json" % OS.get_process_id()
	Display.path_override="user://academy_test_english_model_%d.cfg" % OS.get_process_id()
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, caption: String):
	checks+=1
	if not ok: failures+=1; push_error(caption)

func act(id: String):
	check(m.act(id,m.revision),"Replika "+id+" v "+str(m.session.get("id","")))

func ask(topic: String):
	var cart=m.session.cart.duplicate(true); var confirmed=m.session.confirmed
	var page=m.Questions.TOPICS.find(topic)/3
	check(m.open_questions(m.revision,page),"Otevřít otázky "+topic)
	act("q_"+topic)
	check(m.session.cart==cart and m.session.confirmed==confirmed and not m.session.paid,"Dotaz nemění košík ani potvrzení "+topic)
	check(m.session.npc!="" and m.session.translation!="","Skutečná odpověď NPC "+topic)
	act("understood")
	check(topic in m.session.understood,"Porozumění "+topic)

func questions(id: String):
	match id:
		"LON01": ask("options"); ask("included")
		"LON02": ask("family"); ask("included")
		"LON03": ask("options"); ask("included")
		"LON04": ask("availability"); ask("recommend")
		"LON05": ask("change")
		"LON06": ask("repeat")

func buy(id: String, mode: String, variant: int):
	m.cancel()
	check(m.start(id,mode,variant),"Start "+id+mode+str(variant))
	check(not m.start(id,mode,variant),"Bez souběžné relace")
	if mode=="exam": check(m.hint()=="" and m.session.hints==0,"Zkouška bez pomoci")
	else: check(m.hint()!="" and m.session.hints==1,"Nápověda zaznamenána")
	if id=="LON06":
		act("directions_alt"); questions(id); act("route")
		station="info"; check(not m.arrive_tower(),"Replika nenahrazuje příchod")
		station="tower"; check(m.arrive_tower(),"Skutečný příchod dokončí úkol")
	else:
		questions(id)
		if id=="LON05": act("change")
		if id=="LON03": act("price")
		var token=m.revision
		act("order_alt")
		check(not m.act("order_alt",token),"Starý UI token nesmí zopakovat akci")
		act("product_flex" if variant==2 and id in ["LON01","LON03","LON05"] else "product_standard")
		if id=="LON04":
			act("time_"+m.session.goal.sold)
			check(m.session.asked_sold and m.session.node=="time" and m.session.cart.time=="","Vyprodaný čas vyvolá upřesnění")
			act("next")
			var later=m.catalog.slots.filter(func(slot): return slot>m.session.goal.sold)
			if variant==2:
				check(m.session.node=="negotiate" and m.session.cart.time=="","Nejbližší dostupných 15:00 nesplní časové omezení varianty")
				act("decline"); act("time_16:00")
			else: check(m.session.cart.time==later[0],"Next available opravdu znamená nejbližší dostupný pozdější čas")
		else: act("time_"+m.session.goal.time)
		var expected=int(m.session.goal.adult)*3000+int(m.session.goal.child)*2000
		if variant==2 and id in ["LON01","LON03","LON05"]: expected+=1000
		check(m.total()==expected,"Cena podle skutečného počtu dospělých, dětí a příplatku Flex")
		if id in ["LON03","LON05"]: ask("total")
		act("confirm")
		station="tickets"; check(not m.pay(m.revision) and m.session.ticket.is_empty(),"Bez terminálu nelze zaplatit")
		station="terminal"; token=m.revision
		check(m.pay(token),"Cvičná platba")
		check(not m.pay(token) and m.session.payments==1,"Platba právě jednou")
		var t=m.session.ticket
		check(t.adult==m.session.cart.adult and t.child==m.session.cart.child and t.time==m.session.cart.time and t.pence==m.session.spent,"Vstupenka odpovídá platbě")
		station="gate"; check(not m.present_ticket(),"Před poděkováním nesplněný cíl")
		act("thanks_alt")
		check(m.present_ticket(),"Lístek u kontroly dokončí situaci")
		check(not m.present_ticket(),"Spotřebovaný lístek odmítnut")
	check(m.session.completed and m.progress.results.has(id),"Trvalý výsledek "+id)
	check(not m.finish(),"Výsledek právě jednou")

func run():
	game=Game.new(); m=game.english
	m.location=func(key): return key==station
	check(game.start_mission(6),"Rozpracovaná kampaň")
	var campaign=game.snapshot().duplicate(true)
	check(game.enter_english() and game.game_mode.current==3,"Vlastní režim se stabilním enum")
	for mode in ["learn","practice","exam"]:
		for variant in 3:
			for id in m.IDS: buy(id,mode,variant)
	check(m.progress.results.size()==6 and m.progress.attempts.size()==54,"Všech 54 kombinací dokončeno")
	m.cancel(); m.start("LON01","practice",0)
	act("order"); act("product_standard"); act("time_15:00")
	check(not m.act("confirm",m.revision),"Správný košík bez komunikace nedokončí B1–B2")
	m.open_questions(m.revision); act("q_options")
	check(not m.act("misunderstood",m.revision) and not "options" in m.session.understood,"Nepochopená nabídka není komunikační úspěch")
	act("clarify"); act("understood"); ask("included")
	check(not m.act("confirm_wrong_total",m.revision) and not m.session.confirmed,"Chybný součet není potvrzení")
	act("confirm")
	for topic in m.Questions.TOPICS: ask(topic)
	check(m.session.confirmed and m.session.payments==0 and m.session.ticket.is_empty(),"Všech devět dotazů zachová potvrzený košík bez skryté platby")
	m.cancel(); m.start("LON03","practice",0); questions("LON03"); act("price"); act("two"); act("product_standard"); act("time_14:00")
	check(not m.act("confirm",m.revision) and m.session.ticket.is_empty(),"Nadlimitní objednávka zamítnuta")
	check(not m.pay(m.revision),"Nepotvrzená platba zamítnuta")
	act("change"); act("order"); act("product_standard"); act("time_14:00"); ask("total"); act("confirm")
	check(m.session.confirmed,"Potvrzený košík")
	check(not m.act("change_time",m.revision),"Potvrzený Standard nemá možnost změny času")
	act("change"); act("order"); act("product_flex")
	# A changed basket is unconfirmed even if the new product exceeds this budget.
	act("time_14:00")
	check(not m.session.confirmed,"Změna zrušila potvrzení")
	check(m.total()==4000 and not m.session.confirmed and not "total" in m.session.understood,"Nový součet a zrušené porozumění starému součtu")
	station="terminal"; check(not m.pay(m.revision),"Změna potřebuje potvrzení")
	act("change"); act("two"); act("product_standard"); act("time_14:00"); check(m.total()==6000,"Nové množství aktualizuje cenu")
	m.cancel(); m.start("LON04","learn",0); act("order"); act("product_standard"); act("time_14:00")
	check(not m.session.confirmed and not m.pay(m.revision),"Vyprodaný čas nelze zaplatit")
	station="gate"; check(not m.present_ticket(),"Chybějící lístek odmítnut")
	check(not m.act("made_up",m.revision),"Neznámý záměr odmítnut")
	m.cancel(); m.start("LON01","learn",0)
	check(not m.act("child",m.revision-1),"Neplatná revize")
	questions("LON01"); act("child"); act("product_standard"); act("time_15:00"); act("confirm"); station="terminal"; m.pay(m.revision); act("thanks"); station="gate"
	check(not m.present_ticket() and not m.session.completed,"Zdvořilá chybná objednávka neplní zadání")
	m.cancel(); m.start("LON01","learn",0); check(m.act("order",m.revision),"První správná formulace")
	m.cancel(); m.start("LON01","learn",0); check(m.act("order_alt",m.revision),"Ekvivalentní formulace")
	check(game.leave_training(),"Odchod obnoví kampaň")
	check(game.snapshot()==campaign,"Kampaň, ticket a infrastruktura beze změny")
	var restored=Game.new()
	check(restored.english.progress.results.size()==6 and restored.english.session.is_empty(),"Výsledky po restartu, žádný nákup")
	check(JSON.parse_string(JSON.stringify(restored.snapshot()))==JSON.parse_string(JSON.stringify(campaign)),"Restart obnoví původní kampaň")
	var valid=Saves.load_game(); check(Saves.rules().valid(valid),"Validovaný skutečný save")
	var old=valid.duplicate(true); old.erase("english"); check(Saves.rules().valid(old),"Starý save bez angličtiny")
	for bad in [{"results":{"WRONG":{"best":100,"completed":1,"hints":0}}},{"results":{"LON01":{"best":101,"completed":1,"hints":0}}},{"phrases":[false]},{"intro_seen":"yes"},{"attempts":[{"id":"LON01","mode":"exam","variant":10,"score":100,"hints":0,"errors":[]}]}]:
		var invalid=valid.duplicate(true); invalid.english=bad
		check(not Saves.rules().valid(invalid),"Neplatná větev odmítnuta")
	game.enter_english(); m.cancel(); m.start("LON01","learn",0); questions("LON01"); act("order"); act("product_standard"); act("time_15:00"); act("confirm"); station="terminal"; m.pay(m.revision); act("thanks"); station="gate"
	var original=Saves.path_override
	Saves.path_override="user://missing_english_directory_%d/save.json" % OS.get_process_id()
	check(m.present_ticket() and game.unsaved and game.save_message!="","Pravdivá chyba zápisu")
	Saves.path_override=original; check(game.save()==OK and not game.unsaved,"Opakování uložení")
	game.leave_training()
	print("ENGLISH MODEL: %d checks, %d failures" % [checks,failures])
	m.location=Callable(); m=null; game=null; restored=null
	quit(1 if failures else 0)
