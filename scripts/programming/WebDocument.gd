extends RefCounted

const VOID=["area","base","br","col","embed","hr","img","input","link","meta","param","source","track","wbr"]
const OPTIONAL=["html","head","body","p","li","dt","dd","thead","tbody","tfoot","tr","td","th","option","optgroup","colgroup"]
var nodes: Array=[]
var errors: Array=[]
var rules: Array=[]
var handlers: Array=[]
var has_doctype=false
var source_files: Dictionary={}

func add_node(tag: String, attrs: Dictionary, parent: int, content: String = "") -> int:
	var id=nodes.size()
	nodes.append({"tag":tag,"attrs":attrs,"parent":parent,"children":[],"text":content,"style":{}})
	if parent>=0: nodes[parent].children.append(id)
	return id

func load_files(files: Dictionary) -> Dictionary:
	nodes=[]; errors=[]; rules=[]; handlers=[]; has_doctype=false; source_files=files.duplicate()
	var source=str(files.get("index.html",""))
	if source.length()>32768 or str(files.get("style.css","")).length()>16384: return {"ok":false,"error":"Web překročil limit velikosti zdroje.","output":""}
	add_node("document",{},-1)
	var stack=[0]; var i=0
	var tag_regex=RegEx.new(); tag_regex.compile("^<\\s*(/?)\\s*([A-Za-z][A-Za-z0-9-]*)([^>]*?)>")
	while i<source.length() and nodes.size()<512:
		if source.substr(i,4)=="<!--":
			var comment_end=source.find("-->",i+4)
			if comment_end<0: errors.append("Neuzavřený HTML komentář."); break
			i=comment_end+3; continue
		if source.substr(i,9).to_lower()=="<!doctype":
			var doctype_end=source.find(">",i)
			if doctype_end<0: errors.append("Neuzavřený DOCTYPE."); break
			has_doctype=source.substr(i,doctype_end-i+1).to_lower().strip_edges()=="<!doctype html>"
			i=doctype_end+1; continue
		if source[i]!="<":
			var text_end=source.find("<",i)
			if text_end<0: text_end=source.length()
			add_node("#text",{},stack.back(),entities(source.substr(i,text_end-i))); i=text_end; continue
		# A quote-aware scan permits > inside attribute values.
		var end=i+1; var quote=""
		while end<source.length():
			var c=source[end]
			if quote!="":
				if c==quote: quote=""
			elif c in ['"',"'"]: quote=c
			elif c==">": break
			end+=1
		if end>=source.length(): errors.append("Neuzavřená HTML značka."); break
		var raw=source.substr(i,end-i+1)
		# Replace > inside quotes just for the name recognizer; attributes use raw.
		var name_regex=RegEx.new(); name_regex.compile("^<\\s*(/?)\\s*([A-Za-z][A-Za-z0-9-]*)")
		var match_data=name_regex.search(raw)
		if match_data==null: errors.append("Neplatná značka u pozice "+str(i)); i=end+1; continue
		var tag=match_data.get_string(2).to_lower(); var closing=match_data.get_string(1)=="/"
		i=end+1
		if closing:
			var found=-1
			for index in range(stack.size()-1,0,-1):
				if nodes[stack[index]].tag==tag: found=index; break
			if found<0: errors.append("Uzavření bez otevření: "+tag); continue
			while stack.size()>found:
				var popped=nodes[stack.pop_back()].tag
				if popped!=tag and not popped in OPTIONAL: errors.append("Špatné vnoření: "+popped+" před </"+tag+">.")
			continue
		var top=nodes[stack.back()].tag
		if (tag=="li" and top=="li") or (tag in ["td","th"] and top in ["td","th"]) or (tag=="tr" and top=="tr") or (tag=="option" and top=="option") or (top=="p" and tag in ["p","div","section","h1","h2","ul","ol","table","form"]): stack.pop_back()
		if tag=="body" and nodes[stack.back()].tag=="head": stack.pop_back()
		var attrs=parse_attrs(raw.substr(match_data.get_end(),raw.length()-match_data.get_end()-1).trim_suffix("/"))
		var id=add_node(tag,attrs,stack.back())
		if tag in ["script","style"]:
			var close=source.to_lower().find("</"+tag,i)
			if close<0: errors.append("Chybí </"+tag+">."); break
			nodes[id].text=source.substr(i,close-i)
			var close_end=source.find(">",close)
			if close_end<0: errors.append("Neuzavřený "+tag); break
			i=close_end+1
		elif not tag in VOID: stack.append(id)
	while stack.size()>1:
		var tag=nodes[stack.pop_back()].tag
		if not tag in OPTIONAL: errors.append("Chybí uzavírací značka </"+tag+">.")
	if nodes.size()>=512: errors.append("Nejvýše 512 HTML uzlů.")
	var unique_ids={}
	for id in range(1,nodes.size()):
		var node=nodes[id]
		var parent_tag=nodes[node.parent].tag
		var parents={"li":["ul","ol"],"td":["tr"],"th":["tr"],"tr":["table","thead","tbody","tfoot"],"caption":["table"],"thead":["table"],"tbody":["table"],"tfoot":["table"],"option":["select","optgroup"],"head":["html","document"],"body":["html","document"]}
		if parents.has(node.tag) and not parent_tag in parents[node.tag]: errors.append("Nesprávný rodič elementu "+node.tag)
		if node.attrs.has("id"):
			if unique_ids.has(node.attrs.id): errors.append("Duplicitní id: "+str(node.attrs.id))
			unique_ids[node.attrs.id]=true
		if node.tag=="style": parse_css(node.text)
		if node.tag=="link" and "stylesheet" in str(node.attrs.get("rel","")).to_lower().split(" "):
			if node.attrs.get("href","")=="style.css": parse_css(str(files.get("style.css","")))
			else: errors.append("Náhled načítá jen lokální style.css.")
		if node.tag=="script":
			var script=node.text
			if node.attrs.has("src"):
				if node.attrs.src!="script.js": errors.append("Náhled načítá jen lokální script.js."); continue
				script=str(files.get("script.js",""))
			var result=preload("res://scripts/programming/LearningJavaScript.gd").new().parse(script)
			if not result.ok: errors.append(result.error)
			else: handlers.append_array(result.handlers)
	for id in range(1,nodes.size()): nodes[id].style=compute_style(id)
	return {"ok":errors.is_empty(),"error":"\n".join(errors),"output":"Náhled aktualizován. "+str(nodes.size()-1)+" uzlů."}

func parse_attrs(raw: String) -> Dictionary:
	var regex=RegEx.new(); regex.compile("([A-Za-z_:][A-Za-z0-9_:.-]*)(?:\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)'|([^\\s\"'=<>`]+)))?")
	var result={}
	for match_data in regex.search_all(raw):
		var key=match_data.get_string(1).to_lower()
		if result.has(key): errors.append("Duplicitní atribut "+key)
		var value=""
		for group in [2,3,4]:
			if match_data.get_start(group)>=0: value=entities(match_data.get_string(group)); break
		result[key]=value
	return result

func entities(text: String) -> String:
	var regex=RegEx.new(); regex.compile("&(#x[0-9a-fA-F]+|#[0-9]+|lt|gt|amp|quot|apos|nbsp|copy);")
	var result=text
	var entity_matches=regex.search_all(text)
	entity_matches.reverse()
	for match_data in entity_matches:
		var name=match_data.get_string(1); var value=""
		if name.begins_with("#"):
			var number=name.substr(2).hex_to_int() if name.begins_with("#x") else int(name.substr(1))
			value=String.chr(number) if number>0 and number<=0x10ffff else "�"
		else: value={"lt":"<","gt":">","amp":"&","quot":'"',"apos":"'","nbsp":" ","copy":"©"}[name]
		result=result.substr(0,match_data.get_start())+value+result.substr(match_data.get_end())
	return result

func query(selector: String, within: int = 0) -> Array:
	var result=[]
	for id in range(1,nodes.size()):
		if matches(id,selector) and (within==0 or descendant(id,within)): result.append(id)
	return result

func descendant(id: int, ancestor: int) -> bool:
	var parent=int(nodes[id].parent)
	while parent>0:
		if parent==ancestor: return true
		parent=int(nodes[parent].parent)
	return false

func matches(id: int, selector: String) -> bool:
	var parts=selector.strip_edges().split(" ",false)
	if parts.is_empty() or not simple_match(id,parts[-1]): return false
	var parent=int(nodes[id].parent)
	for i in range(parts.size()-2,-1,-1):
		while parent>0 and not simple_match(parent,parts[i]): parent=int(nodes[parent].parent)
		if parent<=0: return false
		parent=int(nodes[parent].parent)
	return true

func simple_match(id: int, selector: String) -> bool:
	var node=nodes[id]
	if node.tag=="#text": return false
	if selector=="*": return true
	var regex=RegEx.new(); regex.compile("^([A-Za-z][A-Za-z0-9-]*)?((?:[.#][A-Za-z_][A-Za-z0-9_-]*)*)$")
	var m=regex.search(selector)
	if m==null: return false
	if m.get_string(1)!="" and node.tag!=m.get_string(1).to_lower(): return false
	var suffix=RegEx.new(); suffix.compile("([.#])([A-Za-z_][A-Za-z0-9_-]*)")
	for p in suffix.search_all(m.get_string(2)):
		if p.get_string(1)=="#" and node.attrs.get("id","")!=p.get_string(2): return false
		if p.get_string(1)=="." and not p.get_string(2) in str(node.attrs.get("class","")).split(" ",false): return false
	return true

func text_content(id: int) -> String:
	var text=str(nodes[id].text)
	for child in nodes[id].children: text+=text_content(child)
	return text

func parse_css(source: String):
	var comments=RegEx.new(); comments.compile("(?s)/\\*.*?\\*/"); source=comments.sub(source,"",true)
	var regex=RegEx.new(); regex.compile("([^{}]+)\\{([^{}]*)\\}")
	for m in regex.search_all(source):
		for selector in m.get_string(1).split(","):
			var s=selector.strip_edges()
			rules.append({"selector":s,"props":declarations(m.get_string(2)),"specificity":s.count("#")*100+s.count(".")*10+s.split(" ",false).size()})
	if rules.size()>128: errors.append("Nejvýše 128 CSS pravidel."); rules=rules.slice(0,128)

func declarations(source: String) -> Dictionary:
	var props={}
	for declaration in source.split(";"):
		var colon=declaration.find(":")
		if colon<0: continue
		var property=declaration.substr(0,colon).strip_edges().to_lower()
		var value=declaration.substr(colon+1).strip_edges()
		if valid_css(property,value): props[property]=value
	return props

func valid_css(property: String, value: String) -> bool:
	if property in ["color","background-color","background"]: return Color.from_string(value,Color(-1,-1,-1,-1))!=Color(-1,-1,-1,-1)
	if property=="display": return value in ["block","none","flex","grid"]
	if property=="flex-direction": return value in ["row","column"]
	if property=="grid-template-columns":
		var regex=RegEx.new(); regex.compile("^(?:repeat\\([1-4],\\s*1fr\\)|(?:[0-9]+(?:px|fr)\\s*){1,4})$")
		return regex.search(value)!=null
	if property in ["margin","padding","gap","border-radius","font-size","width","max-width"]:
		var parts=value.split(" ",false)
		return not parts.is_empty() and parts.size()<=4 and Array(parts).all(func(part): return part.trim_suffix("px").is_valid_float() and float(part.trim_suffix("px"))>=0 and float(part.trim_suffix("px"))<=800)
	if property=="border":
		var parts=value.split(" ",false)
		return parts.size()==3 and valid_css("padding",parts[0]) and parts[1]=="solid" and valid_css("color",parts[2])
	return false

func compute_style(id: int) -> Dictionary:
	var result={}; var priorities={}
	var parent=int(nodes[id].parent)
	if parent>0:
		for property in ["color","font-size","font-family"]:
			if nodes[parent].style.has(property): result[property]=nodes[parent].style[property]
	for rule in rules:
		if matches(id,rule.selector):
			for key in rule.props:
				if int(rule.specificity)>=int(priorities.get(key,-1)): result[key]=rule.props[key]; priorities[key]=rule.specificity
	result.merge(declarations(str(nodes[id].attrs.get("style",""))),true)
	return result

func click(id: int) -> bool:
	var changed=false
	for handler in handlers:
		if matches(id,handler.selector):
			for action in handler.actions:
				var targets=query(action.selector)
				if not targets.is_empty():
					var target=int(targets[0]); nodes[target].text=action.text; nodes[target].children=[]; changed=true
	return changed

func accessibility() -> bool:
	var ids={}
	for id in range(1,nodes.size()):
		var node=nodes[id]
		if node.attrs.has("id"):
			if ids.has(node.attrs.id): return false
			ids[node.attrs.id]=true
		if node.tag=="img" and not node.attrs.has("alt"): return false
		if node.tag in ["input","textarea","select"] and node.attrs.get("type","") not in ["hidden","submit"] and not has_label(id): return false
	return true

func has_label(id: int) -> bool:
	var parent=int(nodes[id].parent)
	while parent>0:
		if nodes[parent].tag=="label" and text_content(parent).strip_edges()!="": return true
		parent=int(nodes[parent].parent)
	for label_id in query("label"):
		if nodes[id].attrs.get("id","")!="" and nodes[label_id].attrs.get("for","")==nodes[id].attrs.id and text_content(label_id).strip_edges()!="": return true
	return false

func validate(task: Dictionary, files: Dictionary) -> Array:
	var loaded=load_files(files)
	var checks=[{"ok":loaded.ok,"text":"HTML/CSS/JS struktura: "+("✓" if loaded.ok else loaded.error)}]
	for test in task.tests:
		var found=query(test.get("selector","*")); var ok=false
		match test.kind:
			"document": ok=has_doctype and query("title").size()==1 and text_content(query("title")[0]).strip_edges()!=""
			"exists":
				var meaningful=found
				if str(test.get("selector","")).get_slice(" ",str(test.get("selector","")).count(" ")) in ["h1","h2","p","li","td","th","caption","button","option"]: meaningful=found.filter(func(id): return text_content(id).strip_edges()!="")
				ok=meaningful.size()>=int(test.get("count",1))
			"element":
				ok=found.any(func(id):
					for key in test.attrs:
						if not nodes[id].attrs.has(key): return false
						var expected=test.attrs[key]; var actual=str(nodes[id].attrs[key])
						if expected is Array:
							if not expected.all(func(token): return token in actual.to_lower().split(" ")): return false
						elif expected is String and actual.to_lower()!=expected.to_lower(): return false
					return true)
			"radio":
				var radios=found.filter(func(id): return nodes[id].attrs.get("type","")=="radio")
				ok=radios.size()>=2 and str(nodes[radios[0]].attrs.get("name",""))!="" and radios.all(func(id): return nodes[id].attrs.get("name","")==nodes[radios[0]].attrs.name)
			"attr":
				ok=found.any(func(id):
					var attrs=nodes[id].attrs
					if not attrs.has(test.attr): return false
					return str(test.value).to_lower() in str(attrs[test.attr]).to_lower().split(" ") if test.get("contains",false) else str(attrs[test.attr]).to_lower()==str(test.value).to_lower() if test.has("value") else true)
			"nonempty": ok=found.any(func(id): return text_content(id).strip_edges()!="")
			"text": ok=found.any(func(id): return text_content(id).strip_edges()==test.value)
			"image": ok=found.any(func(id): return nodes[id].attrs.get("src","")!="" and nodes[id].attrs.get("alt","").strip_edges()!="")
			"labels": ok=not found.is_empty() and found.all(has_label)
			"accessibility": ok=accessibility()
			"anchor":
				ok=found.any(func(id): return str(nodes[id].attrs.get("href","")).begins_with("#") and not query(str(nodes[id].attrs.href)).is_empty())
			"css": ok=found.any(func(id): return nodes[id].style.has(test.property) and (not test.has("value") or str(nodes[id].style[test.property]).to_lower()==str(test.value).to_lower()))
			"stylesheet": ok=query("link").any(func(id): return "stylesheet" in str(nodes[id].attrs.get("rel","")).to_lower().split(" ") and nodes[id].attrs.get("href","")=="style.css") and str(files.get("style.css","")).strip_edges()!=""
			"entity": ok="&lt;" in str(files.get("index.html","")) and "<" in text_content(0) and "<!--" in str(files.get("index.html",""))
			"click":
				if not found.is_empty():
					var targets=query(test.target)
					if not targets.is_empty():
						var before=text_content(targets[0]); click(found[0]); var after=text_content(targets[0])
						ok=before!=after and (not test.has("value") or after==test.value)
		checks.append({"ok":ok,"text":test.get("label",str(test.kind)+" "+test.get("selector",""))+(" ✓" if ok else " · Chybí požadovaná struktura, atribut nebo reakce.")})
	return checks
