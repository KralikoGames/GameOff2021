extends Control


func _input(event):
	if event.is_action_pressed("exit_game"):
		get_tree().quit()


func _on_Play_pressed():
	GameInit.change_scene("world")


func _on_Exit_pressed():
	get_tree().quit()
