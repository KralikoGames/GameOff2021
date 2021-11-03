extends Button




func _on_ResetPoints_pressed():
	var passives = get_tree().get_nodes_in_group("passives")
	for passive in passives:
		GameInit.player.passive_points += passive.points
		passive.points = 0
	pass # Replace with function body.
