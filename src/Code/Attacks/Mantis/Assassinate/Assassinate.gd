extends Area2D


var damage: float = 10
var input_lock: float


func get_class(): return "Assassinate"


func _ready():
	var anim = $Sprite.animation
	var new_fps = $Sprite.frames.get_frame_count(anim) / $Timer.wait_time
	$Sprite.frames.set_animation_speed(anim, new_fps)
	$Sprite.play(anim)
	input_lock = $Timer.wait_time


func can_damage(_enemy_hit: Node2D):
	return true # can hit all enemies


func _on_Timer_timeout():
	queue_free()
