extends Area2D


var damage: float = 10


func get_class():
	return "Assassinate"



func can_damage(enemy_hit: Node2D):
	return true # can hit all enemies


func _on_Timer_timeout():
	queue_free()
