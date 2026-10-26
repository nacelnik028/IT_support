extends RefCounted

const Evaluation=preload("res://scripts/programming/CodeEvaluator.gd")
var rng=RandomNumberGenerator.new()

func generate(catalog: Dictionary, category: String, difficulty: String, count: int, seed_value: int) -> Array:
	if count<1 or count>20 or not category in ["python","html","css","javascript","mixed"] or not difficulty in ["beginner","advanced","exam"]: return []
	rng.seed=seed_value
	var candidates=catalog.missions.filter(func(task):
		var match_category=category=="mixed" or task.category==category or category=="html" and task.category=="web"
		return match_category and (difficulty=="exam" or int(task.difficulty)==(1 if difficulty=="beginner" else 2)))
	# JavaScript currently has one introductory event task. It remains available
	# at either level; generated structure requirements still vary.
	if candidates.is_empty(): candidates=catalog.missions.filter(func(task): return task.category==category)
	if candidates.is_empty(): return []
	var queue=[]
	for index in count:
		var task=candidates[rng.randi_range(0,candidates.size()-1)].duplicate(true)
		task.base_id=task.id; task.id="GEN-%d-%d" % [seed_value,index]; task.title+=" · varianta "+str(index+1)
		if task.category=="python": vary_python(task)
		else:
			var token="zadani_"+str(rng.randi_range(1000,9999))
			var text="Tým "+str(rng.randi_range(1,99))
			task.description+=" Navíc přidej h2 s id='"+token+"' a textem '"+text+"'."
			task.tests.append({"kind":"text","selector":"#"+token,"value":text,"label":"Dynamický nadpis "+text})
			task.example["index.html"]=str(task.example["index.html"]).replace("</body>","<h2 id='"+token+"'>"+text+"</h2></body>")
		if not Evaluation.new().evaluate(task,task.example).ok: return []
		queue.append(task)
	return queue

func vary_python(task: Dictionary):
	var id=str(task.base_id)
	var a=rng.randi_range(2,15); var b=rng.randi_range(2,8)
	match id:
		"PY05": task.tests=[test([str(a)],str(a+1)+"\n"),test([str(b)],str(b+1)+"\n")]
		"PY06":
			a=b*rng.randi_range(2,5)
			task.tests=[test([str(a),str(b)],"%d\n%d\n%d\n%.1f\n" % [a+b,a-b,a*b,float(a)/b])]
		"PY07": task.tests=[test([str(a)],"sude\n" if a%2==0 else "liche\n"),test([str(a+1)],"sude\n" if (a+1)%2==0 else "liche\n")]
		"PY09": task.tests=[test([" Lab "+str(a)+" "],"lab %d\nLAB %d\n" % [a,a])]
		"PY10": task.tests=[test(["Ada",str(a)],"Ada: %d let\n" % a)]
		"PY12": task.tests=[test([],"['server%d', 'disk']\n" % a,{"nakup":["server"+str(a)]})]
		"PY13","PY14","PY24":
			var values=[a,-b,a+b]; var sorted_values=values.duplicate(); sorted_values.sort()
			var out=""
			if id=="PY13": out=str(sorted_values)+"\n%d %d %d\n" % [-b,a+b,2*a]
			if id=="PY14": out=str([a*2,-b*2,(a+b)*2])+"\n"
			if id=="PY24": out="3\n%d\n%d\n%d\n%s\n" % [2*a,-b,a+b,str(sorted_values)]
			task.tests=[test([],out,{"cisla":values})]
		"PY20":
			var numbers=[]
			for i in range(b,0,-1): numbers.append(str(i))
			task.tests=[test([str(b)],"\n".join(numbers)+"\n")]
		"PY22": task.tests=[{"call":{"name":"obsah_obdelniku","args":[a,b],"value":a*b}},{"call":{"name":"obsah_obdelniku","args":[a+1,b+2],"value":(a+1)*(b+2)}}]
		"PY25": task.tests=[test([str(a*a)],str(float(a))+".0\n" if not "." in str(float(a)) else str(float(a))+"\n")]
		"PY27": task.tests=[test([str(a)],str(a+1)+"\n"),test(["neplatne"+str(a)],"Zadej číslo\n")]
		"PY28": task.tests=[test(["Incident "+str(a)],"Incident %d\n" % a)]; task.tests[0].written={"poznamky.txt":"Incident "+str(a)}
		"PY29": task.tests=[test([str(b)],"spravne\n",{"tajne":b}),test(["1","1","1","1","1"],"vyssi\n".repeat(5)+"konec\n",{"tajne":b})]
		"PY30":
			var logs=[]; var errors=rng.randi_range(0,5); var warnings=rng.randi_range(0,5)
			for i in errors: logs.append("ERROR incident "+str(i))
			for i in warnings: logs.append("WARNING kapacita "+str(i))
			logs.append("INFO vše v pořádku")
			task.tests=[test([],"ERROR %d\nWARNING %d\n" % [errors,warnings],{"logs":logs})]
	if not task.tests.is_empty() and task.tests[0].has("globals"): task.description+=" Vstupní data se v této variantě mění; použij dodané proměnné."

func test(inputs: Array, output: String, initial: Dictionary = {}) -> Dictionary:
	return {"inputs":inputs,"output":output,"globals":initial}
