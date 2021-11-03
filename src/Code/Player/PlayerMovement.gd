extends KinematicBody2D


signal moved
signal stopped
signal died
signal health_changed
signal mana_changed
signal direction_changed


export var wasd_movement: bool = true
export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 1, 0.025) var damping: float = 0.80
export(float, 0, 1000, 10) var max_speed: float = 400.0
export(float, 0, 1, 0.05) var knockback_decay: float = 0.5
export(float, 0, 20, 1) var max_health: float = 3
export var immortal: bool = false


var move_dir: Vector2 = Vector2()
var look_dir: Vector2 = Vector2()
var vel: Vector2 = Vector2()
var knockback: Vector2 = Vector2()

var mana = 0 setget _set_mana
var health = 0 setget _set_health
var is_dead = false
var air_jump_counter = 0
var input_lock = false



func _ready():
	_set_health(max_health)
	_set_mana(0)
	_reset_move_target()


func _physics_process(delta):
	_set_move_target()
	look_dir = _get_dir_to_mouse()
	$aimer.rotation = look_dir.angle()
	
	_apply_knockback()
	if not input_lock:
		_move_player()


func _unhandled_input(event):
	if input_lock:
		return
	if event.is_action_pressed("attack"):
		_spawn_selected_attack()
	pass


func damage(amt:float, dir:Vector2, knockback_amt:float=0):
	if immortal: return 
	
	immortal = true
	
	_set_health(health - amt)
	
	if health <= 0:
		die()
		return
	
	$anim.play("I-Frames")
	knockback += dir * knockback_amt
	emit_signal("health_changed")


func die(delay: float=0.0):
	if is_dead: return 
	is_dead = true
#	set_physics_process(false)
	set_process_input(false)
	set_block_signals(true)
	
	
	# delay for animations?
	if delay > 0:
		yield(get_tree().create_timer(delay), "timeout")
	
	set_block_signals(false)
	emit_signal("died")
	
	# apply post death effects (corpse etc...)
	
	queue_free()


func freeze_player(time: float):
	input_lock = true
	yield(get_tree().create_timer(time), "timeout")
	input_lock = false


func unfreeze_player():
	input_lock = false






func _spawn_selected_attack():
	var attack_tscn = _get_selected_attack()
	var attack = attack_tscn.instance()
	attack.global_position = $aimer/offset.global_position
	attack.global_rotation = $aimer/offset.global_rotation
#	$aimer/offset.add_child(attack)
	get_parent().add_child(attack)
	
#	if attack.has_method("multiply_size"): attack.multiply_size(1.0)
#	if attack.has_method("multiply_damage"): attack.multiply_damage(1.0) # for later
	
	if "input_lock" in attack: freeze_player(attack.input_lock)


func _get_selected_attack() -> PackedScene:
	return preload("res://Code/Attacks/Attack/Attack.tscn")


func _apply_knockback():
	if is_dead: return 
	move_and_slide(knockback)
	knockback *= knockback_decay


func _move_player() -> void:
	var move_dir = _get_input_dir() if wasd_movement else _get_dir_to_target() 
	vel += move_dir * acceleration
	vel = vel.clamped(max_speed)
	
	vel = move_and_slide(vel)
	
	vel *= damping
	
	if vel.length_squared() < 10:
		_reset_move_target()
	
	if move_dir.dot(vel) < 0: emit_signal("direction_changed")
	if not move_dir.is_equal_approx(Vector2()): emit_signal("moved")
	else: emit_signal("stopped")


func _set_mana(v):
	mana = clamp(v, 0, 100)
	emit_signal("mana_changed")


func _set_health(v):
	health = clamp(v, 0, max_health)
	emit_signal("health_changed")


func _get_input_dir() -> Vector2:
#	return _get_dir_to_mouse()
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized() if (not input_lock and not is_dead) else Vector2()


func _set_move_target():
	if Input.is_action_pressed("move_to"):
		$Node/move_target.global_position = get_global_mouse_position()


func _reset_move_target():
	$Node/move_target.global_position = global_position


func _get_dir_to_target() -> Vector2:
	var t = ($Node/move_target.global_position - global_position)
	if t.length() < 10: return Vector2()
	return t.normalized()


func _get_dir_to_mouse() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

