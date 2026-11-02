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
	Saves.path_override="user://academy_test_english_model_%d.json" % OS.get_process_id()
	Display.path_override="user://academy_test_english_model_%d.cfg" % OS.get_process_id()
	Saves.save_game({},true)
	call_deferred("run")

func check(ok: bool, caption: String):
	checks+=1
	if not ok: failures+=1; push_error(caption)

func act(id: String):
	check(m.act(id,m.revision),"Replika "+id+" v "+str(m.session.get("id","")))

func buy(id: String, mode: String, variant: int):
	m.cancel()
	check(m.start(id,mode,variant),"Start "+id+mode+str(variant))
	check(not m.start(id,mode,variant),"Bez souběžné relace")
	if mode=="exam": check(m.hint()=="" and m.session.hints==0,"Zkouška bez pomoci")
	else: check(m.hint()!="" and m.session.hints==1,"Nápověda zaznamenána")
	if id=="LON06":
		act("directions_alt"); act("route")
		station="info"; check(not m.arrive_tower(),"Replika nenahrazuje příchod")
		station="tower"; check(m.arrive_tower(),"Skutečný příchod dokončí úkol")
	else:
		if id=="LON05": act("change")
		if id=="LON03": act("price")
		var token=m.revision
		act("order_alt")
		check(not m.act("order_alt",token),"Starý UI token nesmí zopakovat akci")
		if id=="LON04":
			act("time_"+m.session.goal.sold)
			check(m.session.asked_sold and m.session.node=="time" and m.session.cart.time=="","Vyprodaný čas vyvolá upřesnění")
			act("next")
		else: act("time_"+m.session.goal.time)
		check(m.total()==3000+(2000 if id=="LON02" else 0),"Cena podle košíku")
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
	m.cancel(); m.start("LON03","practice",0); act("price"); act("two"); act("time_14:00")
	check(not m.act("confirm",m.revision) and m.session.ticket.is_empty(),"Nadlimitní objednávka zamítnuta")
	check(not m.pay(m.revision),"Nepotvrzená platba zamítnuta")
	act("change"); act("order"); act("time_14:00"); act("confirm")
	check(m.session.confirmed,"Potvrzený košík")
	act("change_time")
	check(not m.session.confirmed,"Změna zrušila potvrzení")
	act("time_15:00")
	check(m.total()==3000 and not m.session.confirmed and m.session.cart.time=="15:00","Nový součet a čas")
	station="terminal"; check(not m.pay(m.revision),"Změna potřebuje potvrzení")
	act("change"); act("two"); act("time_14:00"); check(m.total()==6000,"Nové množství aktualizuje cenu")
	m.cancel(); m.start("LON04","learn",0); act("order"); act("time_14:00")
	check(not m.session.confirmed and not m.pay(m.revision),"Vyprodaný čas nelze zaplatit")
	station="gate"; check(not m.present_ticket(),"Chybějící lístek odmítnut")
	check(not m.act("made_up",m.revision),"Neznámý záměr odmítnut")
	m.cancel(); m.start("LON01","learn",0)
	check(not m.act("child",m.revision-1),"Neplatná revize")
	act("child"); act("time_15:00"); act("confirm"); station="terminal"; m.pay(m.revision); act("thanks"); station="gate"
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
	game.enter_english(); m.cancel(); m.start("LON01","learn",0); act("order"); act("time_15:00"); act("confirm"); station="terminal"; m.pay(m.revision); act("thanks"); station="gate"
	var original=Saves.path_override
	Saves.path_override="user://missing_english_directory_%d/save.json" % OS.get_process_id()
	check(m.present_ticket() and game.unsaved and game.save_message!="","Pravdivá chyba zápisu")
	Saves.path_override=original; check(game.save()==OK and not game.unsaved,"Opakování uložení")
	game.leave_training()
	print("ENGLISH MODEL: %d checks, %d failures" % [checks,failures])
	m.location=Callable(); m=null; game=null; restored=null
	quit(1 if failures else 0)
