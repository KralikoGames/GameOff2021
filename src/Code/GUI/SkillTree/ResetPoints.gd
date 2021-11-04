extends Button




func _on_ResetPoints_pressed():
	var passives = get_tree().get_nodes_in_group("passives")
	for passive in passives:
		GameInit.player.passive_points += passive.points
		passive.points = 0
	
	var ability_slots = get_tree().get_nodes_in_group("ability_slots")
	for slot in ability_slots:
		slot.clear_slot()
