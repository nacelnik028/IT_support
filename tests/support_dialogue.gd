extends "res://tests/workshop_variants.gd"

func say(s, id: String):
	check(s.dialogue.select(id,int(s.dialogue.data.revision),s),"Support intent "+id)

func handover(s):
	for question in ["what","since","others","change","services"]: say(s,"ask:"+question)
	for key in s.dialogue.expected(s):
		say(s,"cause:"+key)
		say(s,"action:"+key)
	say(s,"verify")
	say(s,"confirm")

func run():
	var s = Session.new()
	for learning_mode in ["learn","practice","exam"]:
		for id in ["A","B","C","D","E","F","G","H"]:
			for seed_value in range(4):
				s.mode = learning_mode
				s.start(id,seed_value)
				var state: Dictionary = s.network.snapshot()
				say(s,"ask:services")
				check(s.network.snapshot()==state and s.hints==0,"Observation is not evidence or a hint")
				var token: int = s.dialogue.data.revision
				say(s,"confirm")
				check(not s.dialogue.data.confirmed and not s.dialogue.service_ok(s),"Polite confirmation cannot hide unrepaired service")
				check(not s.dialogue.select("ask:what",token,s),"Old reply callback rejected")
				for kind in s.task.before: s.measure(kind)
				repair(s)
				check(s.assessment().passed and not s.dialogue.assessment(s).passed,"Technical result remains independent")
				handover(s)
				check(s.dialogue.assessment(s).passed,"Accurate handover "+id+str(seed_value)+learning_mode+str(s.dialogue.assessment(s)))
				state = s.network.snapshot()
				say(s,"confirm")
				check(s.network.snapshot()==state,"Customer service check creates no technical proof")
				if learning_mode=="exam":
					check(not s.dialogue.select("translate",int(s.dialogue.data.revision),s) and not s.dialogue.data.assisted,"Exam blocks translation")
				else:
					say(s,"translate")
					check(s.dialogue.data.assisted and s.hints==0,"Language aid tracked separately")
				s.submit()
				var count: int = s.attempts.size()
				s.submit()
				check(s.attempts.size()==count and s.attempts[-1].communication.passed,"Single result with separate communication score")
				check(not s.dialogue.select("confirm",int(s.dialogue.data.revision),s),"Submitted dialogue locked")
	check(Saves.rules().workshop_attempts(s.attempts),"New dialogue results validate")
	s.start("F",3)
	for kind in s.task.before: s.measure(kind)
	repair(s)
	handover(s)
	s.edit("tcp",false)
	check(not s.dialogue.assessment(s).confirmed,"New service fault invalidates customer confirmation")
	check(not s.dialogue.assessment(s).verified,"New configuration invalidates claimed tests")
	print("SUPPORT DIALOGUE: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
