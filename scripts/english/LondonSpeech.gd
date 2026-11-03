extends AudioStreamPlayer

var shell
var mapping=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/english/audio.json"))
var spoken_revision=-1
var line_id=""

func _ready():
	if AudioServer.get_bus_index("Speech")<0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count-1,"Speech")
		AudioServer.set_bus_send(AudioServer.bus_count-1,"Master")
	bus="Speech"
	volume_db=-3.0

func find_line(text: String, speaker: String) -> Dictionary:
	var session=shell.ui.game.english.session
	if session.is_empty(): return {}
	for line in mapping.lines:
		if line.scenario==session.id and line.speaker==speaker and line.text==text: return line
	return {}

func speak(text: String, speaker: String, slow: bool = false) -> bool:
	stop()
	var line=find_line(text,speaker)
	if line.is_empty() or shell.mode!="english": stream=null; line_id=""; return false
	stream=load(line.slow if slow else line.normal)
	if stream==null: return false
	line_id=line.id
	spoken_revision=shell.ui.game.english.revision
	pitch_scale=1.0
	play()
	return true

func _process(_delta):
	if playing and (shell.mode!="english" or shell.ui.game.english.revision!=spoken_revision or shell.ui.game.english.session.is_empty()): stop()
