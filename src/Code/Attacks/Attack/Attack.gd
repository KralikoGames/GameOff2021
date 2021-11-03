extends Area2D

export (float, 0,200,5) var knockback = 100;
export(float, 0, 1) var input_lock = 0.1
export(float) var damage = 1.0


func _ready():
	pass


func multiply_size(perc: float):
	scale *= perc


func multiply_damage(perc: float):
	damage *= perc


func _on_DeathTimer_timeout():
	queue_free()
