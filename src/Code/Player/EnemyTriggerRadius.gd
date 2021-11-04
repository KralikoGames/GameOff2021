extends Area2D




func _on_EnemyTriggerRadius_area_entered(area):
	if area.has_method("set_target"):
		area.set_target(get_parent())
