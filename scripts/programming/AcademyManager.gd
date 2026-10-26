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

func _init():
	var path="res://data/programming/catalog.json"
	if FileAccess.file_exists(path): catalog=JSON.parse_string(FileAccess.get_file_as_string(path))

func allowed() -> bool: return available.is_valid() and available.call()

func start(id: String, learning_mode: String, lesson: bool = false, preserve_series: bool = false) -> bool:
	if not allowed() or not learning_mode in ["learn","practice","exam"]: return false
	var task={}
	for candidate in catalog.get("missions",[])+catalog.get("debugging",[]):
		if candidate.id==id: task=candidate; break
	if task.is_empty(): return false
	cancel(not preserve_series)
	current=task.duplicate(true); files=current.starter.duplicate(true); mode=learning_mode; is_lesson=lesson
	return true

func cancel(clear_queue: bool = true):
	current={}; files={}; last_run={}; last_result={}; step=0; hints=0; is_lesson=false; edited_after_run=false
	if clear_queue: queue=[]; position=0

func edit(filename: String, source: String):
	if not allowed() or current.is_empty() or not files.has(filename): return
	if files[filename]==source: return
	files[filename]=source
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
	progress.attempts.append({"id":id,"score":result.score,"mode":mode,"hints":hints,"passed":result.ok})
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
	cancel(); queue=generated; position=-1; series_mode="exam" if difficulty=="exam" else "practice"
	return next_generated()

func next_generated() -> bool:
	if not allowed() or position+1>=queue.size(): return false
	if position>=0 and (last_result.is_empty() or not last_result.ok): return false
	position+=1
	var task=queue[position]
	if not start(task.base_id,series_mode,false,true): return false
	current=task.duplicate(true); files=current.starter.duplicate(true)
	return true
