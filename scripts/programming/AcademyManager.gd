extends RefCounted

const Evaluator=preload("res://scripts/programming/CodeEvaluator.gd")
var catalog: Dictionary = {}
var progress: Dictionary = {"results":{},"lessons":{},"attempts":[],"mistakes":{},"xp":0,"settings":{"font_size":22},"drafts":{},"unlocked":["python","web"]}
var current: Dictionary = {}
var files: Dictionary = {}
var mode="learn"
var hints=0
var step=0
var last_run: Dictionary = {}
var last_result: Dictionary = {}
var available=Callable()
var persist=Callable()
var reward=Callable()
var queue: Array = []
var position=0
var is_lesson=false
var edited_after_run=false
var series_mode="practice"
var series_recipe={}
var views={}
var active_file="main.py"
var draft_dirty=false
var draft_error=""
var pending_drafts={}
var changed=Callable()
var drafts=preload("res://scripts/programming/CodeDrafts.gd").new()

func mark_draft():
	draft_dirty=true
	if changed.is_valid(): changed.call()

func draft_record() -> Dictionary:
	if current.is_empty(): return {}
	return {"version":1,"content":drafts.content_version(),"id":current.id,"mode":mode,"lesson":is_lesson,"series":series_recipe.duplicate(true),"position":position if not queue.is_empty() else 0,"files":files.duplicate(true),"views":views.duplicate(true),"active":active_file,"hints":hints,"step":step,"updated":int(Time.get_unix_time_from_system())}

func checkpoint() -> Error:
	if not draft_dirty or current.is_empty(): return OK if pending_drafts.is_empty() else ERR_INVALID_DATA
	var record=draft_record()
	var candidate=progress.drafts.duplicate(true)
	candidate[drafts.key(record)]=record
	if not drafts.valid(candidate):
		pending_drafts[drafts.key(record)]=record
		draft_error="Koncept nelze uložit: nejvýše 128 konceptů, 128 KiB na soubor a celkem 2 MiB. Smaž nepotřebný koncept nebo zkrať zdroj; kód nebyl zkrácen."
		return ERR_INVALID_DATA
	progress.drafts=candidate; draft_dirty=false; pending_drafts.erase(drafts.key(record))
	if pending_drafts.is_empty(): draft_error=""; return OK
	return ERR_INVALID_DATA

func restore_draft(key: String) -> bool:
	if not allowed(): return false
	var pending=pending_drafts.has(key)
	var source=pending_drafts if pending else progress.drafts
	if not source.has(key) or (not pending and not drafts.valid_record(source[key])): return false
	var record=source[key].duplicate(true)
	if draft_dirty and checkpoint()!=OK and drafts.key(draft_record())!=key: return false
	cancel()
	current=drafts.task(record).duplicate(true); files=record.files.duplicate(true)
	mode=record.mode; is_lesson=record.lesson; views=record.views.duplicate(true); active_file=record.active
	hints=int(record.hints); step=int(record.step); series_recipe=record.series.duplicate(true)
	if not series_recipe.is_empty():
		queue=drafts.generated[JSON.stringify(series_recipe)].duplicate(true); position=int(record.position); series_mode=mode
	last_run={}; last_result={}; edited_after_run=false; draft_dirty=pending
	return true

func delete_draft(key: String):
	progress.drafts.erase(key)
	pending_drafts.erase(key)
	if pending_drafts.is_empty(): draft_error=""
	if not current.is_empty() and drafts.key(draft_record())==key: draft_dirty=false
	if persist.is_valid(): persist.call()


func _init():
	var path="res://data/programming/catalog.json"
	if FileAccess.file_exists(path): catalog=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text(path))

func allowed() -> bool: return available.is_valid() and available.call()

func start(id: String, learning_mode: String, lesson: bool = false, preserve_series: bool = false) -> bool:
	if not allowed() or not learning_mode in ["learn","practice","exam"]: return false
	var task={}
	for candidate in catalog.get("missions",[])+catalog.get("debugging",[]):
		if candidate.id==id: task=candidate; break
	if task.is_empty() or checkpoint()!=OK: return false
	cancel(not preserve_series)
	current=task.duplicate(true); files=current.starter.duplicate(true); mode=learning_mode; is_lesson=lesson
	active_file=files.keys()[0]
	return true

func cancel(clear_queue: bool = true):
	var pending=draft_dirty
	checkpoint()
	if pending and draft_error=="" and persist.is_valid(): persist.call()
	current={}; files={}; last_run={}; last_result={}; step=0; hints=0; is_lesson=false; edited_after_run=false
	views={}; active_file="main.py"; draft_dirty=false
	if clear_queue: queue=[]; position=0; series_recipe={}

func edit(filename: String, source: String):
	if not allowed() or current.is_empty() or not files.has(filename): return
	if files[filename]==source: return
	files[filename]=source
	mark_draft()
	if step==0: step=1
	if not last_run.is_empty(): edited_after_run=true

func run_program(inputs: Array = []) -> Dictionary:
	if not allowed() or current.is_empty(): return {"ok":false,"error":"Cvičení není aktivní v Programming Academy."}
	if current.category=="python":
		last_run=preload("res://scripts/programming/PythonRuntime.gd").new().run(files.get("main.py",""),inputs,current.tests[0].get("globals",{}),current.tests[0].get("files",{}),int(Time.get_ticks_usec()))
	else: last_run=preload("res://scripts/programming/WebDocument.gd").new().load_files(files)
	if last_run.ok:
		if step==1: step=2; edited_after_run=false
		elif step==2 and edited_after_run: step=3
	mark_draft()
	return last_run

func test_program() -> Dictionary:
	if not allowed() or current.is_empty(): return {"ok":false,"score":0,"text":"Cvičení není aktivní v této místnosti."}
	last_result=Evaluator.new().evaluate(current,files,hints,mode)
	if is_lesson and mode=="learn" and step<3:
		last_result.ok=false; last_result.text+="\nDokonči praktické kroky: uprav, spusť, změň a znovu spusť kód."
	record(last_result)
	return last_result

func hint() -> String:
	if mode=="exam" or not allowed() or current.is_empty(): return "Ve zkoušce není nápověda dostupná."
	var text=current.hints[mini(hints,current.hints.size()-1)]
	hints+=1
	mark_draft()
	return text

func record(result: Dictionary):
	var id=str(current.get("base_id",current.id))
	var old=progress.results.get(id,{"best":0,"passed":false,"exam":0})
	var gained=0
	if result.ok:
		var paid=int(old.get("paid",old.best if old.passed else 0))
		gained=int(float(maxi(0,int(result.score)-paid))*int(current.reward)/100.0)
		old.paid=maxi(paid,int(result.score))
		old.passed=true
		if is_lesson: progress.lessons[current.lesson]=true
	old.best=maxi(int(old.best),int(result.score))
	if mode=="exam": old.exam=maxi(int(old.exam),int(result.score))
	progress.results[id]=old
	progress.xp+=gained
	if reward.is_valid(): reward.call(gained)
	result.xp=gained
	progress.attempts.append({"id":id,"score":result.score,"mode":mode,"hints":hints,"passed":result.ok,"time":int(Time.get_unix_time_from_system())})
	if progress.attempts.size()>200: progress.attempts.pop_front()
	if not result.ok: progress.mistakes[current.topic]=int(progress.mistakes.get(current.topic,0))+1
	if persist.is_valid():
		result.saved=persist.call()==OK
		if not result.saved: result.text+="\nVýsledek je v paměti. Uložení selhalo; zkus uložit znovu z pauzy."

func dashboard() -> String:
	var py=0; var web=0; var passed=0; var total=0; var best=0
	for id in progress.lessons:
		if id.begins_with("PYL"): py+=1
		else: web+=1
	for record_data in progress.results.values():
		if record_data.passed: passed+=1
		total+=int(record_data.best); best=maxi(best,int(record_data.exam))
	var weak=progress.mistakes.keys()
	weak.sort_custom(func(a,b): return progress.mistakes[a]>progress.mistakes[b])
	var errors=[]; var exams=[]; var result_ids=progress.results.keys()
	for topic in weak.slice(0,3): errors.append(str(topic)+": "+str(progress.mistakes[topic])+" neúspěšných testů")
	result_ids.sort_custom(func(a,b): return progress.results[a].exam>progress.results[b].exam)
	for id in result_ids.slice(0,5):
		if int(progress.results[id].exam)>0: exams.append(str(id)+" "+str(progress.results[id].exam)+"/100")
	return "Moje programátorské znalosti\nPython lekce: %d / 15 · Web lekce: %d / 13\nÚspěšné úlohy: %d / 60 · Průměr nejlepších výsledků: %d %%\nNejlepší zkouška: %d / 100 · XP: %d\nZkoušky: %s\nNejčastější chyby: %s\nDoporučené opakování: %s" % [py,web,passed,int(float(total)/maxi(1,progress.results.size())),best,progress.xp,", ".join(exams),"; ".join(errors),", ".join(weak.slice(0,3)) if not weak.is_empty() else "Vyber první lekci a napiš vlastní řešení."]

func generate_series(category: String, difficulty: String, count: int, seed_value: int) -> bool:
	if not allowed(): return false
	var generated=preload("res://scripts/programming/PracticeGenerator.gd").new().generate(catalog,category,difficulty,count,seed_value)
	if generated.is_empty(): return false
	cancel(); series_recipe={"category":category,"difficulty":difficulty,"count":count,"seed":seed_value}; queue=generated; position=-1; series_mode="exam" if difficulty=="exam" else "practice"
	return next_generated()

func next_generated() -> bool:
	if not allowed() or position+1>=queue.size(): return false
	if position>=0 and (last_result.is_empty() or not last_result.ok): return false
	if checkpoint()!=OK: return false
	position+=1
	var task=queue[position]
	if not start(task.base_id,series_mode,false,true): return false
	current=task.duplicate(true); files=current.starter.duplicate(true); active_file=files.keys()[0]
	return true
