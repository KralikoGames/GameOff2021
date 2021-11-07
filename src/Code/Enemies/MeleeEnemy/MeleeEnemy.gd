extends KinematicBody2D

var vel: Vector2 = Vector2()
var knockback_dir: Vector2 = Vector2()
var move_dir: Vector2 = Vector2()
var target_dir: Vector2 = Vector2()

export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 500, 10) var friction: float = 200
export(float, 0, 1000, 10) var max_speed: float = 400.0
export(float, 0, 1, 0.025) var damping: float = 0.80

func _physics_process(delta):
	vel += move_dir * acceleration
	vel = vel.clamped(max_speed)
	vel = move_and_slide(vel * damping)
