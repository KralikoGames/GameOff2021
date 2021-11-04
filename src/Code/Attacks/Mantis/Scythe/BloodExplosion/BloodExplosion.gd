extends Area2D


var damage: float setget , get_damage


func get_damage() -> float:
	return GameInit.blood_explosion_damage



func _on_Timer_timeout():
	queue_free()
