extends Area2D




func _on_EnemyTriggerRadius_area_entered(area):
	if area.has_method("set_target"):
		area.set_target(get_parent())
	else:
		if area.get_parent().has_method("set_target"):
			area.get_parent().set_target(get_parent())
			
