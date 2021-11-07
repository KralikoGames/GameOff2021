extends Control


func _ready():
	hide()


func _input(event):
	if event.is_action_pressed("pause_game"):
		if not visible:
			show()
			get_tree().paused = true
		else:
			hide()
			get_tree().paused = false


func _on_ToMainMenu_pressed():
	get_tree().paused = false
	GameInit.change_scene("menu")
