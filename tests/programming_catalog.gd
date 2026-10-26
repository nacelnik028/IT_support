extends SceneTree

const Evaluation=preload("res://scripts/programming/CodeEvaluator.gd")
var checks=0
var failures=0
func _init(): call_deferred("run")
func check(ok: bool, text: String):
	checks+=1
	if not ok: failures+=1; print("FAIL ",text)
func run():
	var data=JSON.parse_string(FileAccess.get_file_as_string("res://data/programming/catalog.json"))
	check(data.missions.size()==60,"All 60 tasks")
	check(data.lessons.size()==28,"All 28 lessons")
	check(data.debugging.size()>=10,"Debugging variants")
	for task in data.missions+data.debugging:
		for field in ["id","title","description","category","difficulty","starter","tests","objectives","hints","explanation","reward"]: check(task.has(field),task.id+" "+field)
		var good=Evaluation.new().evaluate(task,task.example)
		check(good.ok and good.score==100,task.id+" reference: "+good.text)
		var bad=Evaluation.new().evaluate(task,task.starter)
		check(not bad.ok and bad.score<100,task.id+" rejects starter")
		var empty={"main.py":"print('hotovo')","index.html":"<p>hotovo</p>","style.css":"","script.js":""}
		check(not Evaluation.new().evaluate(task,empty).ok,task.id+" rejects unrelated code")
	for lesson in data.lessons:
		check(data.missions.any(func(t): return t.id==lesson.mission),lesson.id+" has executable task")
		check(not lesson.explanation.is_empty() and not lesson.example.is_empty() and lesson.steps.size()==4,lesson.id+" has teaching content")
	# Equivalent solutions and valid HTML variants must pass.
	var equivalent={"main.py":"def obsah_obdelniku(sirka, vyska):\n    plocha = vyska * sirka\n    return plocha"}
	check(Evaluation.new().evaluate(data.missions[21],equivalent).ok,"Equivalent Python accepted")
	var web=data.missions[59].example.duplicate(true)
	web["index.html"]=web["index.html"].replace('"',"'").replace("<html","<HTML").replace("</html>","</HTML>").replace("</li>","").replace("</td>","")
	check(Evaluation.new().evaluate(data.missions[59],web).ok,"Single quotes, case and optional end tags")
	var js=data.missions[57].example.duplicate(true)
	js["script.js"]="const b = document.querySelector('#tlacitko');\nb.addEventListener('click', () => { document.querySelector('#vysledek').textContent = 'Ahoj!'; });"
	check(Evaluation.new().evaluate(data.missions[57],js).ok,"Alternative actual JS event")
	var hardcoded={"main.py":"errors = 2\nwarnings = 1\nprint('ERROR', errors)\nprint('WARNING', warnings)"}
	check(not Evaluation.new().evaluate(data.missions[29],hardcoded).ok,"Log variants reject hardcoded counts")
	print("PROGRAMMING CATALOG ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
