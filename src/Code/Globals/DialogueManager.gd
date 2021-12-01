extends Node


signal dialogue_started

var isOn = false

func _ready():
	pause_mode = PAUSE_MODE_PROCESS


func start_dialogue(dialogue_name: String):
	if(isOn):
		return 
	isOn = true
	var conversation = Dialogic.start(dialogue_name)
	conversation.connect("tree_exited", self, "on_conversation_complete")
	add_child(conversation)
	emit_signal("dialogue_started")


func on_conversation_complete():
	isOn = false


func get_skillpoint():
	GameInit.player.passive_points += 5
