extends CanvasLayer


onready var questlog = $QuestLog/Panel
onready var skilltree = $Control/Skilltree
onready var pausemenu = $PauseMenu


func _ready():
	$Control/HUD.show()
	DialogueManager.connect("dialogue_started", self, "_on_dialogue_started")


func _input(event):
	if pausemenu.is_visible_in_tree(): return
	
	if event.is_action_pressed("open_quest_log"):
		if not questlog.is_visible_in_tree():
			questlog.show()
			skilltree.hide()
		else:
			questlog.hide()
	if event.is_action_pressed("open_skilltree"):
		if not skilltree.is_visible_in_tree():
			skilltree.show()
			questlog.hide()
		else:
			skilltree.hide()
	
	get_tree().paused = is_any_menu_visible()


func is_any_menu_visible() -> bool:
	return questlog.is_visible_in_tree() or skilltree.is_visible_in_tree()


func _on_dialogue_started():
	skilltree.hide()
	questlog.hide()
