extends Node


signal dialogue_started


func _ready():
	pause_mode = PAUSE_MODE_PROCESS


func start_dialogue(dialogue_name: String):
	var conversation = Dialogic.start(dialogue_name)
	conversation.connect("tree_exited", self, "on_conversation_complete")
	get_tree().paused = true
	add_child(conversation)
	emit_signal("dialogue_started")


func on_conversation_complete():
	var tree = get_tree()
	if tree:
		tree.paused = false


func get_skillpoint():
	GameInit.player.passive_points += 1
