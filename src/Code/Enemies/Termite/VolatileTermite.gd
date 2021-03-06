extends Enemy

signal summoned_explosion

export var attack_range_close: float = 75
export var debug: bool = false

onready var attackTimer = $AttackTimer
onready var display = $Display
onready var deathTimer = $DeathTimer

var explosion_tscn = preload("res://Code/Attacks/Explosion_Effect/Explosion.tscn")
var attack_tscn = preload("res://Code/Attacks/Telegraphed_Ground_Effect/Ground_Effect.tscn")
var corpse_tscn = preload("res://Code/Enemies/Corpse.tscn")
var attacking: bool = false
var dead: bool = false


func _ready():
	freeze(1)


func _physics_process(delta): # target is guarranteed to be assigned
	if not is_instance_valid(target): 
		target = null
		return

	if not attacking and !dead:
		if _in_close_range():
			_attack()
		else:
			move_to_target()
			flip_to_target()
			display.play("Run")


func flip_to_target():
	display.flip_h = move_dir.x > 0


func _in_close_range() -> bool:
	return target.global_position.distance_to(global_position) <= attack_range_close

func die(abilitysource):
	if !dead:
		dead = true
		frozen = true
		move_dir = Vector2.ZERO
		corpse()
		.die(abilitysource)

func corpse():
	var corpse = corpse_tscn.instance()
	var root = get_tree().get_root()
	
	corpse.global_position = global_position
	display.global_position = global_position

	root.add_child(corpse)
	remove_child(display)
	corpse.add_child(display)

	display.play("Die")
	
	var tween = corpse.get_node("Tween")
	tween.interpolate_property(display, "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 3.0, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	
	
	

func _attack() -> void:
	emit_signal("begin_attack")
	
	attacking = true
	frozen = true
	stop()
	
	_attack_warning()
	display.play("Explode")
	
	attackTimer.start()
	yield(attackTimer, "timeout")
	
	_create_explosion()
	attacking = false
	emit_signal("attacked")
	queue_free()


func _create_explosion():
	var explosion = explosion_tscn.instance()
	explosion.global_position = global_position
	get_tree().get_root().add_child(explosion)


func _attack_warning():
	var effect = attack_tscn.instance()
	effect.shape = "circle"
	effect.scale = Vector2(7.5, 7.5)
	effect.wait_time = 1
	effect.knockback_amt = 350.0
	effect.damage_amt = 5.0
	effect.global_position = global_position
	effect.rotation = _get_dir_to_target().angle()
	get_tree().get_root().add_child(effect)
	emit_signal("summoned_explosion")
