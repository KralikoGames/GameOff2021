extends Area2D

export (float, 0,200,5) var knockback = 100;

var damage: float setget , get_damage
var enemies_damaged = []


func get_damage() -> float:
	return get_parent().damage


func can_damage(node: Node2D):
	if node in enemies_damaged:
		return false
	else:
		enemies_damaged.append(node)
		return true


func _on_Scythe_direction_reversed():
	enemies_damaged = []
	
	$Shape.set_deferred("disabled", true)
	yield(get_tree().create_timer(0.01), "timeout") # Janky but makes sure that the on_area_entered methods trigger again.
	$Shape.set_deferred("disabled", false)
