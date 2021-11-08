extends Node2D


onready var ge: PackedScene = preload("res://Code/Attacks/Telegraphed_Ground_Effect/Ground_Effect.tscn")


func _on_Timer_timeout():
	spawn_effect()


func spawn_effect():
	var effect = ge.instance()
	
	effect.shape = ["cone", "rect", "circle"][randi() % 3]
	var r = rand_range(1, 15)
	effect.scale = Vector2(r, r)
	effect.wait_time = rand_range(0.5, 1.5)
	effect.knockback_amt = rand_range(100, 1000)
	
	effect.global_position = Vector2(rand_range(50,400), rand_range(50,230))
	add_child(effect)
