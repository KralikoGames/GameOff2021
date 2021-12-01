extends CanvasLayer


onready var questlog = $QuestLog/Panel
onready var skilltree = $Control/Skilltree
onready var pausemenu = $PauseMenu


func _ready():
	$Control/HUD.show()
	DialogueManager.connect("dialogue_started", self, "_on_dialogue_started")

func _process(delta):
	get_tree().paused = is_any_menu_visible()

func _input(event):
	if pausemenu.is_visible_in_tree(): return
	
	if event.is_action_pressed("open_quest_log"):
		if not questlog.is_visible_in_tree() && not get_tree().paused:
			questlog.show()
			skilltree.hide()
		else:
			questlog.hide()
	if event.is_action_pressed("open_skilltree"):
		if not skilltree.is_visible_in_tree() && not get_tree().paused:
			skilltree.show()
			questlog.hide()
		else:
			skilltree.hide()


func is_any_menu_visible() -> bool:
	return questlog.is_visible_in_tree() or skilltree.is_visible_in_tree() or DialogueManager.isOn


func _on_dialogue_started():
	skilltree.hide()
	questlog.hide()
