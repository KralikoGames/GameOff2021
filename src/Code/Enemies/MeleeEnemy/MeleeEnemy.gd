extends KinematicBody2D

var vel: Vector2 = Vector2()
var knockback_dir: Vector2 = Vector2()
export var move_dir: Vector2 = Vector2()
var target_dir: Vector2 = Vector2()

export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 500, 10) var move_friction: float = 200
export(float, 0, 500, 10) var knockback_friction = 200
export(float, 0, 1000, 10) var max_speed: float = 400.0
export(float, 0, 1, 0.025) var damping: float = 0.80

func _physics_process(delta):
	if move_dir != Vector2.ZERO:
		vel = vel.move_toward(move_dir * max_speed, acceleration * delta)
		print(str(vel))
		vel = vel.clamped(max_speed)
		
		#Inform the animator which direction we are facing. Let the states handle things otherwise.
		
	else:
		vel = Vector2.ZERO
		
	vel = move_and_slide(vel)
