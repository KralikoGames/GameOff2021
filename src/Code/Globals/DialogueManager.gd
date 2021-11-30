extends Node


signal dialogue_started

var isOn = false

func _ready():
	pause_mode = PAUSE_MODE_PROCESS


func start_dialogue(dialogue_name: String):
	if(isOn):
		return 
	print("ON")
	isOn = true
	var conversation = Dialogic.start(dialogue_name)
	conversation.connect("tree_exited", self, "on_conversation_complete")
	add_child(conversation)
	emit_signal("dialogue_started")


func on_conversation_complete():
	print("Off")
	isOn = false


func get_skillpoint():
	GameInit.player.passive_points += 1
