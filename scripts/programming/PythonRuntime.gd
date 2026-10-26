extends RefCounted

const Parser = preload("res://scripts/programming/PythonParser.gd")
const MAX_ITEMS = 2048
const MAX_TEXT = 32768
const MAX_OUTPUT = 8192
const MAX_STEPS = 16000
class Value extends RefCounted:
	var kind: String
	var data
	func _init(k: String, d): kind=k; data=d

var globals: Dictionary = {}
var files: Dictionary = {}
var inputs: Array = []
var output = ""
var error = ""
var error_line = 1
var steps = 0
var allocated = 0
var started = 0
var call_depth = 0
var ast: Array = []
var rng = RandomNumberGenerator.new()
var trace: Dictionary = {}
var fatal = false
const BUILTINS = ["print","input","int","float","str","bool","type","len","sum","min","max","sorted","abs","round","range","enumerate","zip","list","tuple","set","dict","open"]

func fail(kind: String, message: String):
	if error=="": error=kind+": "+message
	if kind in ["LimitError","SandboxError"]: fatal=true
	return null

func tick() -> bool:
	steps+=1
	if steps>MAX_STEPS or Time.get_ticks_msec()-started>200:
		fail("LimitError","Program byl zastaven: limit kroků nebo 200 ms. Zkontroluj cyklus.")
	return error==""

func bounded(value):
	var size=0
	if value is String:
		size=value.length()
		if size>MAX_TEXT: return fail("LimitError","Řetězec je příliš dlouhý.")
	elif value is Array or value is Dictionary:
		size=value.size()*24
		if value.size()>MAX_ITEMS: return fail("LimitError","Kolekce smí mít nejvýše 2048 položek.")
	elif value is float or value is int:
		if not is_finite(float(value)) or absf(float(value))>1.0e12: return fail("LimitError","Číslo je mimo výukový rozsah ±10^12.")
	allocated+=size+16
	if allocated>2097152: return fail("LimitError","Vyčerpán rozpočet paměti 2 MiB.")
	return value

func run(source: String, test_inputs: Array = [], initial: Dictionary = {}, virtual_files: Dictionary = {}, seed_value: int = 42) -> Dictionary:
	globals=normalize(initial); files=virtual_files.duplicate(true); inputs=test_inputs.duplicate()
	output=""; error=""; steps=0; allocated=0; call_depth=0; fatal=false; trace={}; error_line=1
	started=Time.get_ticks_msec(); rng.seed=seed_value
	var parser=Parser.new()
	ast=parser.parse(source)
	trace.comment=parser.comments
	if parser.error!="": error=parser.error
	else:
		var flow=block(ast,globals)
		if error=="" and flow.kind!="normal": fail("SyntaxError","return, break nebo continue mimo povolený blok.")
	return result()

func result() -> Dictionary:
	return {"ok":error=="","output":output,"error":error,"line":error_line,"globals":globals,"files":files,"steps":steps,"ast":ast,"trace":trace}

func normalize(v):
	if v is float and is_finite(v) and v==floor(v) and absf(v)<=1.0e12: return int(v)
	if v is Array:
		var result_items=[]
		for item in v: result_items.append(normalize(item))
		return result_items
	if v is Dictionary:
		var result_items={}
		for key in v: result_items[key]=normalize(v[key])
		return result_items
	return v

func invoke(name: String, args: Array):
	if not globals.has(name): return fail("NameError","Chybí funkce "+name)
	return call_value(globals[name],args,{})

func block(body: Array, env: Dictionary) -> Dictionary:
	for node in body:
		if not tick(): break
		error_line=int(node.line)
		trace[node.k]=int(trace.get(node.k,0))+1
		var flow=execute(node,env)
		if error!="" or flow.kind!="normal": return flow
	return {"kind":"normal","value":null}

func execute(n: Dictionary, env: Dictionary) -> Dictionary:
	var normal={"kind":"normal","value":null}
	match n.k:
		"expr": evaluate(n.value,env)
		"assign":
			var value=evaluate(n.value,env)
			if n.op!="=": value=binary(n.op[0],evaluate(n.target,env),value)
			assign(n.target,value,env)
		"if": return block(n.body if truth(evaluate(n.test,env)) else n.other,env) if error=="" else normal
		"while":
			while tick() and truth(evaluate(n.test,env)) and error=="":
				var flow=block(n.body,env)
				if flow.kind=="break": break
				if flow.kind=="return": return flow
		"for":
			var values=sequence(evaluate(n.iter,env))
			for value in values:
				if not tick(): break
				assign(n.target,value,env)
				var flow=block(n.body,env)
				if flow.kind=="break": break
				if flow.kind=="return": return flow
		"def":
			var defaults={}
			for param in n.params:
				if param.has("default"): defaults[param.name]=evaluate(param.default,env)
			env[n.name]=Value.new("function",{"params":n.params,"defaults":defaults,"body":n.body})
		"return": return {"kind":"return","value":evaluate(n.value,env)}
		"break", "continue": return {"kind":n.k,"value":null}
		"import":
			if not n.name in ["math","random"]: fail("SandboxError","Povolené jsou pouze moduly math a random.")
			else: env[n.name]=Value.new("module",n.name)
		"try":
			var flow=block(n.body,env)
			if error!="" and not fatal:
				var kind=error.get_slice(":",0)
				for handler in n.handlers:
					if handler.kind in [kind,"Exception"]:
						error=""; return block(handler.body,env)
			return flow
		"with":
			var file=evaluate(n.value,env)
			if not file is Value or file.kind!="file": fail("TypeError","with podporuje jen virtuální open().")
			else:
				env[n.name]=file
				var flow=block(n.body,env)
				file.data.closed=true
				return flow
	return normal

func assign(target: Dictionary, value, env: Dictionary):
	if error!="": return
	if target.k=="name":
		if target.name in ["True","False","None"]: fail("SyntaxError","Nelze přepsat konstantu."); return
		env[target.name]=value
	elif target.k=="tuple":
		var items=sequence(value)
		if items.size()!=target.items.size(): fail("ValueError","Počet hodnot neodpovídá počtu proměnných."); return
		for i in items.size(): assign(target.items[i],items[i],env)
	elif target.k=="index":
		var base=evaluate(target.base,env); var index=evaluate(target.index,env)
		if contains_reference(value,base): fail("ValueError","Cyklické kolekce nejsou podporované."); return
		if base is Dictionary:
			if not hashable(index): return
			base[index]=value; bounded(base)
		elif base is Array and is_integer(index):
			var at=int(index); at=at+base.size() if at<0 else at
			if at<0 or at>=base.size(): fail("IndexError","Index seznamu je mimo rozsah.")
			else: base[at]=value
		else: fail("TypeError","Tento objekt nelze měnit indexem.")
	else: fail("SyntaxError","Neplatný cíl přiřazení.")

func evaluate(n: Dictionary, env: Dictionary):
	if not tick(): return null
	call_depth+=1
	if call_depth>48: call_depth-=1; return fail("LimitError","Příliš hluboké volání nebo výraz.")
	var value=eval_node(n,env)
	call_depth-=1
	return bounded(value) if error=="" else null

func eval_node(n: Dictionary, env: Dictionary):
	trace[n.k]=int(trace.get(n.k,0))+1
	match n.k:
		"literal": return n.value
		"name":
			if env.has(n.name): return env[n.name]
			if globals.has(n.name): return globals[n.name]
			if n.name in BUILTINS: return Value.new("builtin",n.name)
			return fail("NameError","Proměnná '%s' není definovaná." % n.name)
		"format":
			var text=str(n.value); var result_text=""; var i=0
			while i<text.length() and tick():
				if text.substr(i,2) in ["{{","}}"]: result_text+=text[i]; i+=2; continue
				if text[i]=="{":
					var end=text.find("}",i+1)
					if end<0: return fail("SyntaxError","Neuzavřený výraz v f-stringu.")
					var parser=Parser.new(); parser.lex(text.substr(i+1,end-i-1))
					var expression=parser.expression()
					if parser.error!="" or not parser.peek().v in ["NEWLINE","EOF"]: return fail("SyntaxError","Nepodporovaný výraz ve f-stringu.")
					result_text+=display(evaluate(expression,env)); i=end+1
				else: result_text+=text[i]; i+=1
			return result_text
		"list","tuple","set":
			var items=[]
			for item in n.items: items.append(evaluate(item,env))
			if n.k=="list": return items
			return Value.new(n.k,unique(items) if n.k=="set" else items)
		"dict":
			var items={}
			for pair in n.items:
				var key=evaluate(pair[0],env)
				if not hashable(key): return null
				items[key]=evaluate(pair[1],env)
			return items
		"binary":
			trace[n.op]=int(trace.get(n.op,0))+1
			var left=evaluate(n.left,env)
			if n.op=="and": return evaluate(n.right,env) if truth(left) else left
			if n.op=="or": return left if truth(left) else evaluate(n.right,env)
			return binary(n.op,left,evaluate(n.right,env))
		"compare":
			var previous=evaluate(n.first,env)
			for pair in n.pairs:
				var next=evaluate(pair.value,env)
				if not truth(binary(pair.op,previous,next)): return false
				previous=next
			return true
		"unary":
			trace[n.op]=int(trace.get(n.op,0))+1
			var value=evaluate(n.value,env)
			if n.op=="not": return not truth(value)
			if not number(value): return fail("TypeError","Znaménko vyžaduje číslo.")
			return -value if n.op=="-" else value
		"attr":
			var base=evaluate(n.base,env)
			if str(n.name).begins_with("_"): return fail("SandboxError","Vnitřní atributy nejsou dostupné.")
			if base is Value and base.kind=="module" and n.name in ["pi","e"] and base.data=="math": return PI if n.name=="pi" else exp(1.0)
			return Value.new("bound",{"base":base,"name":n.name})
		"call":
			var fn=evaluate(n.fn,env); var args=[]; var kwargs={}
			for arg in n.args: args.append(evaluate(arg,env))
			for key in n.kwargs: kwargs[key]=evaluate(n.kwargs[key],env)
			if error!="": return null
			return call_value(fn,args,kwargs)
		"index": return index_value(evaluate(n.base,env),evaluate(n.index,env))
		"slice":
			var base=evaluate(n.base,env); var start=evaluate(n.start,env); var stop=evaluate(n.stop,env)
			var values=sequence(base)
			if (start!=null and not is_integer(start)) or (stop!=null and not is_integer(stop)): return fail("TypeError","Výřez potřebuje celočíselné indexy.")
			var a=0 if start==null else int(start); var b=values.size() if stop==null else int(stop)
			a=clampi(a+values.size() if a<0 else a,0,values.size()); b=clampi(b+values.size() if b<0 else b,0,values.size())
			var part=values.slice(a,maxi(a,b))
			if base is String: return "".join(part)
			if base is Value and base.kind=="tuple": return Value.new("tuple",part)
			return part
		"comprehension":
			var values=sequence(evaluate(n.iter,env)); var result_items=[]; var local=env.duplicate()
			for value in values:
				if not tick(): break
				local[n.name]=value
				if truth(evaluate(n.test,local)): result_items.append(evaluate(n.value,local))
			return result_items
	return fail("SyntaxError","Nepodporovaný výraz.")

func is_integer(v) -> bool: return v is int or v is bool
func number(v) -> bool: return v is int or v is float or v is bool
func hashable(v) -> bool:
	if v==null or v is String or number(v): return true
	fail("TypeError","Klíče slovníku a položky množiny podporují pouze skalární hodnoty."); return false

func truth(v) -> bool:
	if v==null: return false
	if v is Value: return not v.data.is_empty() if v.kind in ["tuple","set"] else true
	return bool(v)

func unique(items: Array) -> Array:
	var values=[]
	for item in items:
		if not hashable(item): return []
		if not item in values: values.append(item)
	return values

func sequence(v) -> Array:
	if v is Array: return v.duplicate()
	if v is Dictionary: return v.keys()
	if v is String:
		var items=[]
		for c in v: items.append(c)
		return items
	if v is Value and v.kind in ["tuple","set"]: return v.data.duplicate()
	fail("TypeError","Objekt není iterovatelná kolekce."); return []

func index_value(base, index):
	if error!="": return null
	if base is Dictionary:
		if not hashable(index): return null
		if not base.has(index): return fail("KeyError","Slovník neobsahuje klíč "+display(index))
		return base[index]
	var values=sequence(base)
	if not is_integer(index): return fail("TypeError","Index musí být celé číslo.")
	var at=int(index); at=at+values.size() if at<0 else at
	if at<0 or at>=values.size(): return fail("IndexError","Index je mimo rozsah.")
	return values[at]

func binary(op: String, a, b):
	if error!="": return null
	if op in ["==","!="]:
		var same=equal(a,b)
		return same if op=="==" else not same
	if op in ["in","not in"]:
		var found=false
		if b is String:
			if not a is String: return fail("TypeError","Členství v řetězci potřebuje text.")
			found=a in b
		else: found=a in sequence(b)
		return found if op=="in" else not found
	if a is bool: a=int(a)
	if b is bool: b=int(b)
	if op in ["<",">","<=",">="]:
		if not ((number(a) and number(b)) or (a is String and b is String)): return fail("TypeError","Tyto typy nelze porovnávat.")
		match op:
			"<": return a<b
			">": return a>b
			"<=": return a<=b
			">=": return a>=b
	if op=="+" and ((a is String and b is String) or (a is Array and b is Array)):
		if (a.length() if a is String else a.size())+(b.length() if b is String else b.size())>(MAX_TEXT if a is String else MAX_ITEMS): return fail("LimitError","Součet kolekcí je příliš velký.")
		return a+b
	if op=="*" and ((a is String or a is Array) and is_integer(b) or is_integer(a) and (b is String or b is Array)):
		if is_integer(a): var swap=a; a=b; b=swap
		var count=maxi(0,int(b)); var size=a.length() if a is String else a.size()
		if count>MAX_ITEMS or size*count>(MAX_TEXT if a is String else MAX_ITEMS): return fail("LimitError","Opakování je příliš velké.")
		if a is String: return a.repeat(count)
		var items=[]
		for i in count: items.append_array(a)
		return items
	if not number(a) or not number(b): return fail("TypeError","Operátor %s potřebuje kompatibilní číselné hodnoty." % op)
	match op:
		"+": return a+b
		"-": return a-b
		"*": return a*b if absf(float(a))*absf(float(b))<=1.0e12 else fail("LimitError","Součin je příliš velký.")
		"/","//","%":
			if float(b)==0.0: return fail("ZeroDivisionError","Nulou nelze dělit.")
			if op=="/": return float(a)/float(b)
			var quotient=floor(float(a)/float(b))
			if op=="//":
				if is_integer(a) and is_integer(b): return int(quotient)
				return quotient
			return a-b*int(quotient)
		"**":
			if absf(float(b))>32 or (float(a)<0 and float(b)!=floor(float(b))) or (float(a)==0 and float(b)<0): return fail("ValueError","Mocnina je mimo podporovaný rozsah.")
			var value=pow(float(a),float(b))
			if is_integer(a) and is_integer(b) and b>=0 and absf(value)<=1.0e12: return bounded(int(value))
			return bounded(value)
	return fail("SyntaxError","Nepodporovaný operátor "+op)

func equal(a,b) -> bool:
	if a is Value and b is Value:
		if a.kind!=b.kind: return false
		if a.kind=="set": return a.data.size()==b.data.size() and a.data.all(func(v): return v in b.data)
		if a.kind=="tuple": return equal(a.data,b.data)
		return a==b
	if a is Array and b is Array:
		if a.size()!=b.size(): return false
		for i in a.size():
			if not equal(a[i],b[i]): return false
		return true
	if typeof(a)!=typeof(b) and not (number(a) and number(b)): return false
	return a==b

static func display(v, nested: bool = false, level: int = 0) -> String:
	if level>16: return "…"
	if v==null: return "None"
	if v is bool: return "True" if v else "False"
	if v is String: return "'"+v.replace("'","\\'").replace("\n","\\n")+"'" if nested else v
	if v is float:
		var text=str(v)
		return text+".0" if not "." in text and not "e" in text else text
	if v is Array or (v is Value and v.kind in ["tuple","set"]):
		var items=v if v is Array else v.data
		var parts=[]
		for item in items: parts.append(display(item,true,level+1))
		if v is Array: return "["+", ".join(parts)+"]"
		if v.kind=="tuple": return "("+", ".join(parts)+("," if parts.size()==1 else "")+")"
		return "set()" if parts.is_empty() else "{"+", ".join(parts)+"}"
	if v is Dictionary:
		var parts=[]
		for key in v: parts.append(display(key,true,level+1)+": "+display(v[key],true,level+1))
		return "{"+", ".join(parts)+"}"
	if v is Value: return "<"+v.kind+">"
	return str(v)

func arity(args: Array, minimum: int, maximum: int) -> bool:
	if args.size()>=minimum and args.size()<=maximum: return true
	fail("TypeError","Nesprávný počet argumentů (očekáváno %d–%d)." % [minimum,maximum]); return false

func call_value(fn, args: Array, kwargs: Dictionary):
	if not tick(): return null
	if not fn is Value: return fail("TypeError","Objekt není funkce.")
	if fn.kind=="builtin": return builtin(fn.data,args,kwargs)
	if fn.kind=="bound": return method(fn.data.base,fn.data.name,args,kwargs)
	if fn.kind!="function": return fail("TypeError","Objekt není volatelný.")
	var data=fn.data; var local={}; var params=data.params
	if args.size()>params.size(): return fail("TypeError","Příliš mnoho argumentů funkce.")
	for key in kwargs:
		if not params.any(func(p): return p.name==key): return fail("TypeError","Neznámý parametr "+key)
	for i in params.size():
		var name=params[i].name
		if i<args.size():
			if kwargs.has(name): return fail("TypeError","Parametr byl předán dvakrát.")
			local[name]=args[i]
		elif kwargs.has(name): local[name]=kwargs[name]
		elif data.defaults.has(name): local[name]=data.defaults[name]
		else: return fail("TypeError","Chybí parametr "+name)
	call_depth+=1
	if call_depth>32: call_depth-=1; return fail("LimitError","Limit rekurze funkce je 32.")
	var flow=block(data.body,local)
	call_depth-=1
	if flow.kind in ["break","continue"]: return fail("SyntaxError","break/continue mimo cyklus.")
	return flow.value if flow.kind=="return" else null

func builtin(name: String, args: Array, kwargs: Dictionary):
	trace[name]=int(trace.get(name,0))+1
	for key in kwargs:
		if not ((name=="print" and key in ["sep","end"]) or (name=="open" and key=="encoding")): return fail("TypeError","Nepodporovaný pojmenovaný argument "+key)
	if name=="print":
		var sep=kwargs.get("sep"," "); var end=kwargs.get("end","\n")
		if not sep is String or not end is String: return fail("TypeError","sep/end musí být text.")
		var parts=[]
		for arg in args: parts.append(display(arg))
		var text=sep.join(parts)+end
		if output.length()+text.length()>MAX_OUTPUT: return fail("LimitError","Výstup překročil 8192 znaků.")
		output+=text; return null
	if name=="input":
		if not arity(args,0,1): return null
		if inputs.is_empty(): return fail("EOFError","Chybí virtuální vstup. Vyplň vstupní konzoli (jeden vstup na řádek).")
		return str(inputs.pop_front())
	if name in ["int","float","str","bool","list","tuple","set","dict"]:
		if not arity(args,0,1): return null
		var value=args[0] if not args.is_empty() else null
		match name:
			"str": return "" if args.is_empty() else display(value)
			"bool": return truth(value)
			"int","float":
				if value==null and args.is_empty():
					if name=="int": return 0
					return 0.0
				if number(value):
					if name=="int": return int(value)
					return float(value)
				if value is String and (value.strip_edges().is_valid_int() if name=="int" else value.strip_edges().is_valid_float()):
					if name=="int": return bounded(int(value))
					return bounded(float(value))
				return fail("ValueError","Hodnotu nelze převést na "+name+".")
			"dict":
				if args.is_empty(): return {}
				if value is Dictionary: return value.duplicate()
				return fail("TypeError","dict() zde přijímá jen slovník.")
			_:
				var items=[] if args.is_empty() else sequence(value)
				if name=="list": return items
				return Value.new(name,unique(items) if name=="set" else items)
	if name=="type":
		if not arity(args,1,1): return null
		var v=args[0]; var kind="NoneType"
		if v is Value: kind=v.kind
		elif v is bool: kind="bool"
		elif v is int: kind="int"
		elif v is float: kind="float"
		elif v is String: kind="str"
		elif v is Array: kind="list"
		elif v is Dictionary: kind="dict"
		return "<class '%s'>" % kind
	if name=="len":
		if not arity(args,1,1): return null
		return sequence(args[0]).size()
	if name=="range":
		if not arity(args,1,3) or not args.all(is_integer): return fail("TypeError","range vyžaduje celá čísla.")
		var a=0 if args.size()==1 else int(args[0]); var b=int(args[0]) if args.size()==1 else int(args[1]); var step=int(args[2]) if args.size()==3 else 1
		if step==0: return fail("ValueError","Krok range nesmí být nula.")
		if absf(float(b)-a)/absf(step)>MAX_ITEMS: return fail("LimitError","range je příliš velký.")
		var items=[]
		while (a<b if step>0 else a>b): items.append(a); a+=step
		return items
	if name in ["sum","min","max","sorted"]:
		if not arity(args,1,1 if name=="sorted" else 2 if name=="sum" else MAX_ITEMS): return null
		var items=sequence(args[0]) if args.size()==1 or name in ["sum","sorted"] else args.duplicate()
		if error!="": return null
		if name=="sum":
			var total=args[1] if args.size()==2 else 0
			for value in items: total=binary("+",total,value)
			return total
		if items.is_empty() and name!="sorted": return fail("ValueError","Prázdná kolekce nemá minimum ani maximum.")
		if not items.all(number) and not items.all(func(v): return v is String): return fail("TypeError","Řazení potřebuje srovnatelné hodnoty.")
		items.sort_custom(func(a,b): return binary("<",a,b))
		if name=="sorted": return items
		return items[0] if name=="min" else items.back()
	if name in ["abs","round"]:
		if not arity(args,1,2 if name=="round" else 1) or not number(args[0]): return fail("TypeError","Očekáváno číslo.")
		if name=="abs": return abs(args[0])
		if args.size()==2 and not is_integer(args[1]): return fail("TypeError","Počet desetinných míst musí být celé číslo.")
		var digits=int(args[1]) if args.size()==2 else 0
		if digits < -8 or digits > 8: return fail("ValueError","Podporováno -8 až 8 desetinných míst.")
		# Python uses ties to even, including negative values.
		var scale_value=pow(10.0,digits); var scaled=float(args[0])*scale_value; var lo=floor(scaled)
		var rounded=lo if scaled-lo<0.5 or (is_equal_approx(scaled-lo,0.5) and int(lo)%2==0) else lo+1
		if args.size()==1: return int(rounded)
		return rounded/scale_value
	if name in ["enumerate","zip"]:
		if not arity(args,1,2): return null
		if name=="enumerate" and args.size()==2 and not is_integer(args[1]): return fail("TypeError","Počáteční index enumerate musí být celé číslo.")
		var first=sequence(args[0]); var second=sequence(args[1]) if name=="zip" and args.size()==2 else []
		var items=[]; var count=mini(first.size(),second.size()) if name=="zip" and args.size()==2 else first.size()
		for i in count:
			if name=="enumerate": items.append(Value.new("tuple",[i+(int(args[1]) if args.size()==2 else 0),first[i]]))
			else: items.append(Value.new("tuple",[first[i],second[i]] if args.size()==2 else [first[i]]))
		return items
	if name=="open":
		if not arity(args,1,2) or not args[0] is String: return fail("TypeError","open potřebuje název virtuálního souboru.")
		var path=str(args[0]); var mode=str(args[1]) if args.size()==2 else "r"
		if path=="" or path.length()>80 or "/" in path or "\\" in path or ":" in path or path.begins_with("."): return fail("SandboxError","Povoleny jsou jen názvy souborů uvnitř virtuální mise.")
		var encoding=kwargs.get("encoding","utf-8")
		if not encoding is String or not mode in ["r","w","a"] or str(encoding).to_lower()!="utf-8": return fail("ValueError","Podporované režimy: r/w/a, encoding utf-8.")
		if mode=="r" and not files.has(path): return fail("FileNotFoundError","Virtuální soubor neexistuje.")
		if files.size()>=16 and not files.has(path): return fail("LimitError","Nejvýše 16 virtuálních souborů.")
		if mode=="w" or not files.has(path): files[path]=""
		return Value.new("file",{"path":path,"mode":mode,"position":0,"closed":false})
	return fail("NameError","Nepodporovaná funkce "+name)

func method(base, name: String, args: Array, kwargs: Dictionary):
	trace[name]=int(trace.get(name,0))+1
	if not kwargs.is_empty(): return fail("TypeError","Tato metoda nepodporuje pojmenované argumenty.")
	if base is Value and base.kind=="module": return module_call(base.data,name,args)
	if base is String:
		match name:
			"strip","lower","upper":
				if not arity(args,0,0): return null
				if name=="strip": return base.strip_edges()
				return base.to_lower() if name=="lower" else base.to_upper()
			"replace":
				if not arity(args,2,2) or not args.all(func(v): return v is String): return fail("TypeError","replace potřebuje dva texty.")
				if args[0]=="": return fail("ValueError","Prázdný vzor replace není v podmnožině podporován.")
				if base.length()*maxi(1,str(args[1]).length())>MAX_TEXT: return fail("LimitError","Výsledek replace je příliš velký.")
				return base.replace(args[0],args[1])
			"split":
				if not arity(args,0,1): return null
				if not args.is_empty() and (not args[0] is String or args[0]==""): return fail("ValueError","Oddělovač musí být neprázdný text.")
				var parts=base.split(args[0],true) if not args.is_empty() else base.replace("\n"," ").replace("\t"," ").split(" ",false)
				return bounded(Array(parts))
			"startswith","endswith":
				if not arity(args,1,1) or not args[0] is String: return fail("TypeError","Očekáván text.")
				return base.begins_with(args[0]) if name=="startswith" else base.ends_with(args[0])
	if base is Array:
		match name:
			"append","extend","remove":
				if not arity(args,1,1): return null
				if name=="append":
					if contains_reference(args[0],base): return fail("ValueError","Cyklické kolekce nejsou podporované.")
					base.append(args[0])
				elif name=="extend":
					for value in sequence(args[0]):
						if contains_reference(value,base): return fail("ValueError","Cyklické kolekce nejsou podporované.")
						base.append(value)
				else:
					if not args[0] in base: return fail("ValueError","Položka není v seznamu.")
					base.erase(args[0])
				bounded(base); return null
			"sort","reverse":
				if not arity(args,0,0): return null
				if name=="sort":
					if not base.all(number) and not base.all(func(v): return v is String): return fail("TypeError","Nesrovnatelné položky.")
					base.sort()
				else: base.reverse()
				return null
			"pop":
				if not arity(args,0,1): return null
				var at=-1 if args.is_empty() else args[0]
				var value=index_value(base,at)
				if error=="": base.remove_at(int(at)+base.size() if at<0 else int(at))
				return value
			"insert":
				if not arity(args,2,2) or not is_integer(args[0]): return fail("TypeError","insert potřebuje index a hodnotu.")
				if contains_reference(args[1],base): return fail("ValueError","Cyklická kolekce.")
				base.insert(clampi(int(args[0])+base.size() if args[0]<0 else int(args[0]),0,base.size()),args[1]); bounded(base); return null
	if base is Dictionary:
		if name=="get":
			if not arity(args,1,2) or not hashable(args[0]): return null
			return base.get(args[0],args[1] if args.size()==2 else null)
		if name in ["keys","values","items"]:
			if not arity(args,0,0): return null
			if name=="keys": return base.keys()
			if name=="values": return base.values()
			var items=[]
			for key in base: items.append(Value.new("tuple",[key,base[key]]))
			return items
	if base is Value and base.kind=="set" and name=="add":
		if not arity(args,1,1) or not hashable(args[0]): return null
		if not args[0] in base.data: base.data.append(args[0])
		bounded(base.data); return null
	if base is Value and base.kind=="file":
		if base.data.closed: return fail("ValueError","Soubor už je zavřený.")
		var path=base.data.path
		if name=="write":
			if not arity(args,1,1) or not args[0] is String: return fail("TypeError","write potřebuje text.")
			if base.data.mode=="r": return fail("OSError","Soubor je otevřený jen pro čtení.")
			if str(files[path]).length()+args[0].length()>MAX_TEXT: return fail("LimitError","Virtuální soubor je plný.")
			files[path]+=args[0]; return args[0].length()
		if name=="read":
			if not arity(args,0,0): return null
			if base.data.mode!="r": return fail("OSError","Soubor není otevřený pro čtení.")
			var text=str(files[path]).substr(base.data.position); base.data.position=str(files[path]).length(); return text
		if name=="close": base.data.closed=true; return null
	return fail("AttributeError","Metoda '%s' není pro tento typ podporovaná." % name)

func contains_reference(value, target, level: int = 0) -> bool:
	if level>20: return true
	if value is Value and value.kind in ["tuple","set"]: return contains_reference(value.data,target,level+1)
	if value is Array or value is Dictionary:
		if is_same(value,target): return true
		for item in (value.values() if value is Dictionary else value):
			if contains_reference(item,target,level+1): return true
	return false

func module_call(module: String, name: String, args: Array):
	if module=="math":
		if not name in ["sqrt","floor","ceil","sin","cos","fabs"] or not arity(args,1,1) or not number(args[0]): return fail("TypeError","math podporuje sqrt/floor/ceil/sin/cos/fabs s jedním číslem.")
		var v=float(args[0])
		match name:
			"sqrt":
				if v<0: return fail("ValueError","Odmocnina záporného čísla.")
				return sqrt(v)
			"floor": return int(floor(v))
			"ceil": return int(ceil(v))
			"sin": return sin(v)
			"cos": return cos(v)
			"fabs": return absf(v)
	if module=="random":
		if name=="randint":
			if not arity(args,2,2) or not args.all(is_integer) or args[0]>args[1]: return fail("ValueError","randint potřebuje dva uspořádané celočíselné meze.")
			return rng.randi_range(int(args[0]),int(args[1]))
		if name=="choice":
			if not arity(args,1,1): return null
			var items=sequence(args[0])
			return items[rng.randi_range(0,items.size()-1)] if not items.is_empty() else fail("IndexError","choice potřebuje neprázdnou kolekci.")
	return fail("AttributeError","Tato funkce modulu není podporovaná.")
