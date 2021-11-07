extends Node

onready var animationPlayer = $AnimationPlayer

func _on_Hitbox_invincibility_started():
	animationPlayer.play("Start")

func _on_Hitbox_invincibility_ended():
	animationPlayer.play("Stop")
