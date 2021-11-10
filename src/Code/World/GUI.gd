extends CanvasLayer


func _ready():
	$Control/HUD.show()
	DialogueManager.connect("dialogue_started", self, "_on_dialogue_started")


func _input(event):
#	if event.is_action_pressed("open_equipment"):
#		$Equipment.show() if not $Equipment.is_visible_in_tree() else $Equipment.hide()
#	if event.is_action_pressed("open_inventory"):
#		$Backpack.show() if not $Backpack.is_visible_in_tree() else $Backpack.hide()
	if get_tree().paused: return
	
	if event.is_action_pressed("open_quest_log"):
		var _o = $QuestLog/Panel.show() if not $QuestLog/Panel.is_visible_in_tree() else $QuestLog/Panel.hide()
	if event.is_action_pressed("open_skilltree"):
		var _o = $Control/Skilltree.show() if not $Control/Skilltree.is_visible_in_tree() else $Control/Skilltree.hide()
	

func _on_dialogue_started():
	hide_gui()


func hide_gui():
	$QuestLog/Panel.hide()
	$Control/Skilltree.hide()
