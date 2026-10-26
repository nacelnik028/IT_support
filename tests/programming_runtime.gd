extends SceneTree

const Runtime=preload("res://scripts/programming/PythonRuntime.gd")
var checks=0
var failures=0

func check(ok: bool, message: String):
	checks+=1
	if not ok: failures+=1; print("FAIL ",message)

func _init(): call_deferred("run")
func run():
	var cases=[
		["print('Ahoj, světe!')",[],"Ahoj, světe!\n"],
		["jmeno = input()\nprint('Ahoj,', jmeno)",["Eva"],"Ahoj, Eva\n"],
		["a = 3\na += 4\nprint(a * 2, 7 / 2, -7 // 2, -7 % 2)",[],"14 3.5 -4 1\n"],
		["print(' Klara '.strip().upper())\nprint('Python'[:3])\nprint(f'Rok {2026 + 1}')",[],"KLARA\nPyt\nRok 2027\n"],
		["a = [3, 1, 2]\na.append(4)\na.sort()\nprint(a)\nprint([x * 2 for x in a])",[],"[1, 2, 3, 4]\n[2, 4, 6, 8]\n"],
		["p = {'jmeno': 'Eva', 'skore': 10}\np['skore'] += 5\nprint(p['jmeno'], p.get('zivoty', 3), p['skore'])\nprint(len(set([1, 1, 2])), (10, 20)[1])",[],"Eva 3 15\n2 20\n"],
		["vek = int(input())\nif vek >= 18:\n    print('dospely')\nelif vek >= 15:\n    print('student')\nelse:\n    print('dite')",["16"],"student\n"],
		["n = 3\nwhile n > 0:\n    print(n)\n    n -= 1\nfor x in range(6):\n    if x == 2:\n        continue\n    if x == 4:\n        break\n    print(x)",[],"3\n2\n1\n0\n1\n3\n"],
		["def obsah_obdelniku(sirka, vyska):\n    return sirka * vyska\nprint(obsah_obdelniku(3, 7))\ndef pozdrav(jmeno='svete'):\n    print(f'Ahoj {jmeno}')\npozdrav()",[],"21\nAhoj svete\n"],
		["import math\nimport random\nprint(math.sqrt(81))\nprint(random.randint(1, 1))",[],"9.0\n1\n"],
		["try:\n    print(int(input()))\nexcept ValueError:\n    print('chyba')",["text"],"chyba\n"],
		["with open('poznamky.txt', 'w', encoding='utf-8') as f:\n    f.write('Ahoj')\nwith open('poznamky.txt', 'r') as f:\n    print(f.read())",[],"Ahoj\n"],
		["for i, x in enumerate(['a', 'b']):\n    print(i, x)\nprint(False and 1 / 0)\nprint(round(2.5), round(3.5))",[],"0 a\n1 b\nFalse\n2 4\n"]]
	for c in cases:
		var r=Runtime.new().run(c[0],c[1])
		check(r.ok and r.output==c[2],c[0]+" → "+r.error+" / "+r.output)
	for source in ["if True\n    print(1)","a = [1]\nprint(a[4])","import os","open('../academy_save.json', 'w')","print('x' * 999999999)","while True:\n    pass","def f():\n    return f()\nf()","print(int('text'))","print(1 / 0)","print(range(1000000000))","print((1).__class__)"]:
		var r=Runtime.new().run(source)
		check(not r.ok,"Rejected: "+source)
	var isolated=Runtime.new()
	isolated.run("with open('a.txt', 'w') as f:\n    f.write('secret')")
	check(not isolated.run("open('a.txt')").ok,"VFS resets each run")
	print("PROGRAMMING RUNTIME ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)
