extends RefCounted

# A bounded lexer and recursive descent / Pratt parser. No Expression.execute,
# GDScript.load or host-language evaluation is used for student source.
var tokens: Array = []
var pos = 0
var error = ""
var depth = 0
const PRECEDENCE = {"or":1,"and":2,"==":3,"!=":3,"<":3,">":3,"<=":3,">=":3,"in":3,"not in":3,"+":4,"-":4,"*":5,"/":5,"//":5,"%":5,"**":7}

func fail(message: String):
	if error == "": error = "SyntaxError · řádek %d: %s" % [peek().line,message]

func peek(offset: int = 0) -> Dictionary:
	return tokens[clampi(pos+offset,0,tokens.size()-1)] if not tokens.is_empty() else {"v":"EOF","line":1,"t":"EOF"}

func take() -> Dictionary:
	var t=peek()
	pos+=1
	return t

func accept(value: String) -> bool:
	if peek().v != value: return false
	pos+=1
	return true

func expect(value: String):
	if not accept(value): fail("Očekáváno '%s', nalezeno '%s'." % [value,peek().v])

func emit(kind: String, value, line: int):
	tokens.append({"t":kind,"v":value,"line":line})

func lex(source: String):
	tokens=[]; pos=0; error=""; depth=0
	if source.length()>32768: fail("Zdroj smí mít nejvýše 32 768 znaků."); return
	var indents=[0]
	var brackets=[]
	var lines=source.replace("\r","").split("\n")
	for n in lines.size():
		var line=lines[n]
		var i=0
		while i<line.length() and line[i] in [" ","\t"]:
			if line[i]=="\t": fail("Použij mezery místo tabulátoru."); return
			i+=1
		if i==line.length() or line[i]=="#": continue
		if brackets.is_empty():
			if i>indents.back(): indents.append(i); emit("op","INDENT",n+1)
			while i<indents.back(): indents.pop_back(); emit("op","DEDENT",n+1)
			if i!=indents.back(): fail("Odsazení neodpovídá předchozímu bloku."); return
		while i<line.length():
			var c=line[i]
			if c==" ": i+=1; continue
			if c=="#": break
			var formatted=c in ["f","F"] and i+1<line.length() and line[i+1] in ["'",'"']
			if c in ["'",'"'] or formatted:
				if formatted: i+=1; c=line[i]
				var quote=c
				i+=1
				var value=""
				while i<line.length() and line[i]!=quote:
					if line[i]=="\\":
						i+=1
						if i>=line.length(): break
						value+={"n":"\n","t":"\t","r":"\r"}.get(line[i],line[i])
					else: value+=line[i]
					i+=1
				if i>=line.length(): fail("Neuzavřený řetězec na řádku "+str(n+1)); return
				i+=1; emit("format" if formatted else "string",value,n+1)
			elif c.is_valid_int() or (c=="." and i+1<line.length() and line[i+1].is_valid_int()):
				var start=i
				i+=1
				while i<line.length() and (line[i].is_valid_int() or line[i]=="."): i+=1
				var number=line.substr(start,i-start)
				if not number.is_valid_float(): fail("Neplatné číslo."); return
				emit("number",number,n+1)
			elif c=="_" or c.to_upper()!=c.to_lower():
				var start=i
				i+=1
				while i<line.length() and (line[i]=="_" or line[i].to_upper()!=line[i].to_lower() or line[i].is_valid_int()): i+=1
				emit("name",line.substr(start,i-start),n+1)
			else:
				var pair=line.substr(i,2)
				if pair in ["==","!=","<=",">=","+=","-=","*=","/=","//","**"]: emit("op",pair,n+1); i+=2
				elif c in "()[]{}:,.=+-*/%<>":
					if c in "([{": brackets.append(c)
					elif c in ")]}":
						if brackets.is_empty() or "([{".find(brackets.pop_back())!=")] }".replace(" ","").find(c): fail("Nesouhlasí závorky."); return
					emit("op",c,n+1); i+=1
				else: fail("Nepodporovaný znak '%s' na řádku %d." % [c,n+1]); return
			if tokens.size()>8192 or brackets.size()>48: fail("Překročen limit velikosti nebo zanoření zdroje."); return
		if brackets.is_empty(): emit("op","NEWLINE",n+1)
	if not brackets.is_empty(): fail("Neuzavřené závorky."); return
	while indents.size()>1: indents.pop_back(); emit("op","DEDENT",lines.size())
	emit("EOF","EOF",lines.size())

func parse(source: String) -> Array:
	lex(source)
	var body=[]
	while error=="" and peek().v!="EOF": body.append(statement())
	return body

func suite() -> Array:
	expect(":"); expect("NEWLINE"); expect("INDENT")
	var body=[]
	depth+=1
	if depth>48: fail("Příliš hluboké zanoření.")
	while error=="" and not peek().v in ["DEDENT","EOF"]: body.append(statement())
	expect("DEDENT")
	depth-=1
	if body.is_empty(): fail("Prázdný blok; použij pass.")
	return body

func statement() -> Dictionary:
	var line=peek().line
	var node={"k":"","line":line}
	if accept("if") or accept("elif"):
		node.k="if"; node.test=expression(); node.body=suite(); node.other=[]
		if peek().v=="elif": node.other=[statement()]
		elif accept("else"): node.other=suite()
		return node
	if accept("while"):
		node.k="while"; node.test=expression(); node.body=suite(); return node
	if accept("for"):
		node.k="for"; node.target=expression(4)
		if accept(","): node.target={"k":"tuple","items":[node.target,expression(4)]}
		expect("in"); node.iter=expression(); node.body=suite(); return node
	if accept("def"):
		node.k="def"; node.name=take().v; expect("("); node.params=[]
		while error=="" and peek().v!=")":
			var param={"name":take().v}
			if accept("="): param.default=expression()
			node.params.append(param)
			if not accept(","): break
		expect(")"); node.body=suite(); return node
	if accept("try"):
		node.k="try"; node.body=suite(); node.handlers=[]
		while accept("except"):
			var kind="Exception" if peek().v==":" else str(take().v)
			node.handlers.append({"kind":kind,"body":suite()})
		if node.handlers.is_empty(): fail("try potřebuje except.")
		return node
	if accept("with"):
		node.k="with"; node.value=expression(); expect("as"); node.name=take().v; node.body=suite(); return node
	if accept("import"):
		node.k="import"; node.name=take().v
	elif accept("return"):
		node.k="return"; node.value={"k":"literal","value":null} if peek().v=="NEWLINE" else expression()
	elif peek().v in ["break","continue","pass"]: node.k=take().v
	else:
		var left=expression()
		if accept(","):
			var items=[left,expression()]
			while accept(","): items.append(expression())
			left={"k":"tuple","items":items}
		if peek().v in ["=","+=","-=","*=","/= ".strip_edges()]:
			node.k="assign"; node.op=take().v; node.target=left; node.value=expression()
		else: node.k="expr"; node.value=left
	expect("NEWLINE")
	return node

func expression(minimum: int = 0) -> Dictionary:
	depth+=1
	if depth>48: fail("Příliš hluboký výraz."); depth-=1; return {"k":"literal","value":null}
	var left=atom()
	while error=="":
		var op=str(peek().v)
		if op=="not" and peek(1).v=="in": op="not in"
		if not PRECEDENCE.has(op) or PRECEDENCE[op]<minimum: break
		take()
		if op=="not in": take()
		var right=expression(PRECEDENCE[op]+(0 if op=="**" else 1))
		left={"k":"binary","op":op,"left":left,"right":right}
	depth-=1
	return left

func atom() -> Dictionary:
	var t=take()
	var node={"k":"literal","value":null}
	if t.t=="number": node.value=float(t.v) if "." in t.v else int(t.v)
	elif t.t=="string": node.value=t.v
	elif t.t=="format": node={"k":"format","value":t.v}
	elif t.v in ["True","False","None"]: node.value={"True":true,"False":false,"None":null}[t.v]
	elif t.v in ["-","+","not"]: node={"k":"unary","op":t.v,"value":expression(3 if t.v=="not" else 6)}
	elif t.v in ["(","[","{"]:
		var close={"(":")","[":"]","{":"}"}[t.v]
		var items=[]
		var pairs=[]
		var is_dict=false
		if peek().v!=close:
			var first=expression()
			if t.v=="[" and accept("for"):
				var target=take().v; expect("in"); var iter=expression()
				var condition=expression() if accept("if") else {"k":"literal","value":true}
				expect("]")
				return {"k":"comprehension","value":first,"name":target,"iter":iter,"test":condition}
			items.append(first)
			if t.v=="{" and accept(":"): is_dict=true; pairs.append([first,expression()])
			if t.v=="(" and peek().v!=",": expect(")"); return postfix(first)
			while accept(",") and error=="" and peek().v!=close:
				var next=expression(); items.append(next)
				if is_dict: expect(":"); pairs.append([next,expression()])
		expect(close)
		node={"k":"dict","items":pairs} if t.v=="{" and (is_dict or items.is_empty()) else {"k":{"(":"tuple","[":"list","{":"set"}[t.v],"items":items}
	elif t.t=="name": node={"k":"name","name":t.v}
	else: fail("Očekáván výraz, nalezeno '%s'." % t.v)
	return postfix(node)

func postfix(initial: Dictionary) -> Dictionary:
	var node=initial
	while error=="":
		if accept("("):
			var args=[]; var kwargs={}
			while error=="" and peek().v!=")":
				if peek().t=="name" and peek(1).v=="=":
					var key=take().v; take(); kwargs[key]=expression()
				else: args.append(expression())
				if not accept(","): break
			expect(")"); node={"k":"call","fn":node,"args":args,"kwargs":kwargs}
		elif accept("."):
			node={"k":"attr","base":node,"name":take().v}
		elif accept("["):
			var start={"k":"literal","value":null} if peek().v==":" else expression()
			if accept(":"):
				var stop={"k":"literal","value":null} if peek().v=="]" else expression()
				node={"k":"slice","base":node,"start":start,"stop":stop}
			else: node={"k":"index","base":node,"index":start}
			expect("]")
		else: break
	return node
