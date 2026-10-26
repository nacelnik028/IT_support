extends RefCounted

const Runtime=preload("res://scripts/programming/PythonRuntime.gd")

func evaluate(task: Dictionary, files: Dictionary, hints: int = 0, mode: String = "practice") -> Dictionary:
	var checks=[]
	if task.category=="python":
		for test in task.tests:
			var runtime=Runtime.new()
			var r=runtime.run(files.get("main.py",""),test.get("inputs",[]),test.get("globals",{}),test.get("files",{}),int(test.get("seed",42)))
			var ok=r.ok
			if test.has("output"): ok=ok and r.output.strip_edges()==str(test.output).strip_edges()
			if test.has("call") and r.ok:
				var value=runtime.invoke(test.call.name,test.call.args)
				ok=ok and runtime.error=="" and runtime.equal(value,test.call.value)
			for key in test.get("vars",{}): ok=ok and r.globals.has(key) and runtime.equal(r.globals.get(key),test.vars[key])
			for key in test.get("written",{}): ok=ok and r.files.get(key)==test.written[key]
			for construct in task.get("constructs",[]): ok=ok and r.trace.get(construct,0)>0
			checks.append({"ok":ok,"text":test.get("label","Test "+str(checks.size()+1))+(" ✓" if ok else " · "+(r.error if r.error!="" else "Výsledek neodpovídá zadání. Ověř vstupy, výstup a požadované konstrukce."))})
	else: checks=preload("res://scripts/programming/WebDocument.gd").new().validate(task,files)
	var count=checks.filter(func(c): return c.ok).size()
	var correctness=roundi(100.0*count/maxi(1,checks.size()))
	var score=maxi(0,correctness-mini(20,hints*5))
	var messages=[]
	for check_data in checks: messages.append(check_data.text)
	return {"ok":correctness==100,"score":score,"checks":checks,"text":"Výsledek: %d/100 · %d/%d testů\n%s\n%s" % [score,count,checks.size(),"\n".join(messages),"Všechny požadavky splněny." if correctness==100 else "Doporučení: "+task.explanation],"mode":mode}
