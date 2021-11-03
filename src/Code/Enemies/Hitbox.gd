extends Area2D

var invincible = false setget set_invincible

onready var timer = $Timer
onready var collisionShape = $Shape

signal invincibility_started
signal invincibility_ended

func set_target(t: Node2D):
	get_parent().set_target(t)

func set_invincible(value):
	print("Setting Invincible!")
	invincible = value
	if invincible == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func _on_Timer_timeout():
	self.invincible = false

func _on_Hitbox_invincibility_ended():
	collisionShape.disabled = false

func _on_Hitbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)


func _on_Enemy_damaged():
	start_invincibility(0.4)
