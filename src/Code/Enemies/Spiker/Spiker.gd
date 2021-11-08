extends Enemy
tool


signal summoned_slam
signal spike_cooldown
signal summoned_spike
signal begin_attack # when the attack starts
signal attacked # when the attack is complete


export var attack_range_close: float = 75
export var attack_range_long: float = 200
export var debug: bool = false
export var number_of_attacks: int = 3


var attack_tscn = preload("res://Code/Attacks/Telegraphed_Ground_Effect/Ground_Effect.tscn")
var attacking: bool = false


func _ready():
	freeze(1)


func _physics_process(delta): # target is guarranteed to be assigned
	if not is_instance_valid(target): 
		target = null
		return
	
	if _in_close_range():
		if not attacking:
			_begin_close_range_attack_sequence()
	elif _in_long_range():
		if not attacking:
			_begin_long_range_attack_sequence()
	else:
		move_to_target()
	if debug:
		update()


func _in_close_range() -> bool:
	return target.global_position.distance_to(global_position) <= attack_range_close
func _in_long_range() -> bool:
	return target.global_position.distance_to(global_position) <= attack_range_long


func _begin_close_range_attack_sequence() -> void:
	_begin_attack()
	
	spawn_slam()
	$SlamTimer.start()
	yield($SlamTimer, "timeout")
	
	_end_attack()


func _begin_long_range_attack_sequence() -> void:
	_begin_attack()
	
	for i in range(number_of_attacks):
		spawn_long_spike()
		$SingleSpikeTimer.start()
		yield($SingleSpikeTimer, "timeout")
	
	emit_signal("spike_cooldown")
	
	$PostSpikeTimer.start()
	yield($PostSpikeTimer, "timeout")
	
	_end_attack()


func spawn_slam():
	var effect = attack_tscn.instance()
	effect.shape = "cone"
	effect.scale = Vector2(7.5, 7.5)
	effect.wait_time = 1.25
	effect.knockback_amt = 350.0
	effect.damage_amt = 5.0
	effect.global_position = global_position
	effect.rotation = _get_dir_to_target().angle()
	$SlamTimer.add_child(effect)
	emit_signal("summoned_slam")


func spawn_long_spike():
	var effect = attack_tscn.instance()
	effect.shape = "rect"
	effect.scale = Vector2(25.0, 2.0)
	effect.wait_time = 0.75
	effect.knockback_amt = 150.0
	effect.damage_amt = 1.0
	effect.global_position = global_position
	effect.rotation = _get_dir_to_target().angle()
	$SingleSpikeTimer.add_child(effect)
	emit_signal("summoned_spike")


func _end_attack():
	attacking = false
	frozen = false
	emit_signal("attacked")


func _begin_attack():
	attacking = true
	frozen = true
	stop()
	emit_signal("begin_attack")


var font = Control.new().get_font("default")
func _draw():
	if not debug: return
	draw_string(font, Vector2(0, -attack_range_long), "attack range")
	draw_arc(Vector2(), attack_range_long, 0, 2*PI, 32, Color(1,1,1))
	draw_arc(Vector2(), attack_range_close, 0, 2*PI, 32, Color(1,1,1))
