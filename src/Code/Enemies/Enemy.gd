extends KinematicBody2D

signal damaged
signal died

export(float, 1, 100, 1) var health = 3
export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 1, 0.025) var damping: float = 0.80
export(float, 0, 1000, 10) var max_speed: float = 400.0
export(float, 0, 500, 10) var friction: float = 200

var target
var knockback_dir: Vector2 = Vector2()
var move_dir: Vector2 = Vector2()
var look_dir: Vector2 = Vector2()
var vel: Vector2 = Vector2()
onready var animationPlayer = $AnimationPlayer

func _ready():
	set_physics_process(false)


func _physics_process(delta):
	
	knockback_dir = knockback_dir.move_toward(Vector2.ZERO, friction * delta)
	knockback_dir = move_and_slide(knockback_dir)
	
	var move_dir = _get_dir_to_target() # _get_input_dir() if not is_dead else Vector2()
	vel += move_dir * acceleration
	vel = vel.clamped(max_speed)
	
	vel = move_and_slide(vel)
	
	vel *= damping
	
	vel = move_and_slide(vel)


func set_target(t: Node2D):
	target = t
	print("hiohi")
	set_physics_process(true)


func _on_Hitbox_area_entered(area):
	if "damage" in area:
		_damage(area.damage)
	if "knockback" in area:
		knockback_dir = (global_position - area.global_position).normalized() * area.knockback


func _damage(amt: float):
	health -= amt
	if health <= 0:
		emit_signal("died")
		queue_free()
	else:
		emit_signal("damaged")


func _get_dir_to_target() -> Vector2:
	if target:
		var t = (target.global_position - global_position)
		if t.length() < 10: return Vector2()
		return t.normalized()
	return Vector2()


func _on_Hitbox_invincibility_started():
	print("StartInvincibility")
	animationPlayer.play("Start")


func _on_Hitbox_invincibility_ended():
	print("StopInvincibility") 
	animationPlayer.play("Stop")
