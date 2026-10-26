extends RefCounted

# Deliberately small grammar: DOM references, click registrations and textContent
# assignments. Every token must be consumed; unknown JS is reported, never run.
var tokens: Array=[]
var pos=0
var error=""
var aliases={}
var handlers=[]

func parse(source: String) -> Dictionary:
	tokens=[]; pos=0; error=""; aliases={}; handlers=[]
	if source.length()>16384: error="JavaScript překročil limit 16 KiB."; return result()
	var pattern=RegEx.new()
	pattern.compile("(?s)\\s+|//[^\\n]*|/\\*.*?\\*/|(?:\"(?:\\\\.|[^\"\\\\])*\"|'(?:\\\\.|[^'\\\\])*')|[A-Za-z_$][A-Za-z0-9_$]*|=>|[{}().,;=+]")
	var offset=0
	for match_data in pattern.search_all(source):
		if match_data.get_start()!=offset: error="Nepodporovaný JavaScript u pozice "+str(offset); return result()
		offset=match_data.get_end()
		var token=match_data.get_string()
		if token.strip_edges()=="" or token.begins_with("//") or token.begins_with("/*"): continue
		tokens.append(token)
	if offset!=source.length(): error="Nepodporovaný JavaScript u pozice "+str(offset); return result()
	tokens.append("EOF")
	while peek()!="EOF" and error=="":
		if accept(";"): continue
		if peek() in ["const","let","var"]:
			take(); var name=take(); expect("="); aliases[name]=dom_reference(); accept(";"); continue
		var target=dom_reference()
		expect(".")
		var member=take()
		if member=="addEventListener":
			expect("("); var event_name=literal(); expect(",")
			if event_name!="click": error="Podporována je událost click."; break
		elif member=="onclick": expect("=")
		else: error="Podporované registrace: addEventListener('click', ...) nebo onclick."; break
		if accept("function"): expect("("); expect(")")
		else: expect("("); expect(")"); expect("=>")
		expect("{"); var actions=[]
		while peek()!="}" and peek()!="EOF" and error=="":
			var destination=dom_reference(); expect("."); expect("textContent"); expect("=")
			var value=literal()
			while accept("+"): value+=literal()
			actions.append({"selector":destination,"text":value}); accept(";")
		expect("}")
		if member=="addEventListener": expect(")")
		accept(";"); handlers.append({"selector":target,"actions":actions})
	return result()

func result() -> Dictionary: return {"ok":error=="","error":error,"handlers":handlers}
func peek() -> String: return str(tokens[mini(pos,tokens.size()-1)]) if not tokens.is_empty() else "EOF"
func take() -> String:
	var token=peek(); pos+=1; return token
func accept(value: String) -> bool:
	if peek()!=value: return false
	pos+=1; return true
func expect(value: String):
	if not accept(value) and error=="": error="JavaScript: očekáváno '%s', nalezeno '%s'." % [value,peek()]
func literal() -> String:
	var token=take()
	if token.length()<2 or not token[0] in ['"',"'"]:
		error="V této podmnožině musí být hodnota textový literál."; return ""
	return token.substr(1,token.length()-2).replace("\\n","\n").replace("\\'","'").replace('\\"','"')
func dom_reference() -> String:
	if aliases.has(peek()): return aliases[take()]
	expect("document"); expect("."); var method=take(); expect("("); var selector=literal(); expect(")")
	if method=="getElementById": return "#"+selector
	if method=="querySelector": return selector
	error="Podporované DOM dotazy: getElementById nebo querySelector."; return ""
