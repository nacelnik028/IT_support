extends AudioStreamPlayer

var shell
var mapping=JSON.parse_string(preload("res://scripts/core/ContentReader.gd").text("res://data/english/audio.json"))
var spoken_revision=-1
var line_id=""
var context="dialog"
var play_generation=0
var completion_callback=Callable()

func _ready():
	if AudioServer.get_bus_index("Speech")<0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count-1,"Speech")
		AudioServer.set_bus_send(AudioServer.bus_count-1,"Master")
	bus="Speech"
	volume_db=-3.0

func stop_speech():
	play_generation+=1
	if completion_callback.is_valid() and finished.is_connected(completion_callback): finished.disconnect(completion_callback)
	completion_callback=Callable()
	stop()

func complete_listening_clip(token: int, generation: int):
	if context=="listening" and generation==play_generation and token==spoken_revision:
		shell.ui.game.english.listening.completed_clip(token)

func find_line(text: String, speaker: String) -> Dictionary:
	var session=shell.ui.game.english.session
	if session.is_empty(): return {}
	for line in mapping.lines:
		if line.scenario==session.id and line.speaker==speaker and line.text==text: return line
	return {}

func speak(text: String, speaker: String, slow: bool = false) -> bool:
	context="dialog"
	stop_speech()
	var line=find_line(text,speaker)
	if line.is_empty() or shell.mode!="english": stream=null; line_id=""; return false
	stream=load(line.slow if slow else line.normal)
	if stream==null: return false
	line_id=line.id
	spoken_revision=shell.ui.game.english.revision
	pitch_scale=1.0
	play()
	return true

func audible() -> bool:
	for name_value in ["Speech","Master"]:
		var index=AudioServer.get_bus_index(name_value)
		if index>=0 and (AudioServer.is_bus_mute(index) or AudioServer.get_bus_volume_db(index)<=-75): return false
	return volume_db> -75

func listen(task_id: String, slow: bool = false) -> bool:
	stop_speech()
	var listening=shell.ui.game.english.listening
	if shell.mode!="english" or not listening.allowed() or listening.session.get("id","")!=task_id: return false
	var task=listening.definition(task_id)
	var line={}
	for item in mapping.lines:
		if item.id==task.get("clip",""): line=item; break
	if line.is_empty(): return false
	context="listening"; spoken_revision=listening.revision; line_id=line.id
	stream=load(line.slow if slow else line.normal); pitch_scale=1.0
	if stream==null: return false
	# Bind the finished evidence to this exact play, rather than reading mutable
	# player fields later. AudioStreamPlayer.playing can still be true while its
	# finished signal is dispatched; that property is not a second end signal.
	var token=spoken_revision; var generation=play_generation
	completion_callback=func(): call_deferred("complete_listening_clip",token,generation)
	finished.connect(completion_callback,CONNECT_ONE_SHOT)
	play()
	if playing and not listening.session.completed: listening.played(spoken_revision,slow,not audible())
	return playing

func _process(_delta):
	if playing and context=="listening":
		var listening=shell.ui.game.english.listening
		if shell.mode!="english" or listening.revision!=spoken_revision or listening.session.is_empty(): stop_speech()
		elif not audible() and not listening.session.muted: listening.session.muted=true; listening.store()
		return
	if playing and (shell.mode!="english" or shell.ui.game.english.revision!=spoken_revision or shell.ui.game.english.session.is_empty()): stop_speech()
