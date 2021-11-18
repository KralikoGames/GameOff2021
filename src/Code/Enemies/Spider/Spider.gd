extends Enemy

signal create_warning

export var attack_range_close: float = 75
export var debug: bool = false
export var dash_speed = 5
export var warning_time = 0.5

onready var display = $Display
onready var attackTimer = $AttackTimer
onready var dashTimer = $DashTimer
onready var deathTimer = $DeathTimer
onready var postAttackTimer = $PostAttackTimer

var old_speed = 0
var explosion_tscn = preload("res://Code/Attacks/Explosion_Effect/Explosion.tscn")
var attack_tscn = preload("res://Code/Attacks/Telegraphed_Ground_Effect/Ground_Effect.tscn")
var corpse_tscn = preload("res://Code/Enemies/Corpse.tscn")
var target_position = Vector2()
var attacking: bool = false
var dead: bool = false
var dashDir = Vector2()
var dashTime = 0


func _ready():
	freeze(1)


func _physics_process(delta): # target is guarranteed to be assigned
		
	if not is_instance_valid(target): 
		target = null
		return

	flip_to_target()
	
	if not attacking and !dead:
		if _in_close_range():
			_attack()
		else:
			move_to_target()
			display.play("Run")


func flip_to_target():
	display.flip_h = target.global_position.x > global_position.x


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
	#Stop and warn the player.
	emit_signal("begin_attack")
	attacking = true
	frozen = true
	stop()

	#target_position  = global_position.linear_interpolate(target.global_position, 0.95)
	target_position = target.global_position
	dashDir = (target_position - global_position)
	dashTime = dashDir.length()/dash_speed
	
	#create a warning.
	var effect = attack_tscn.instance()
	effect.shape = "cone"
	effect.scale = Vector2(1, 1)
	effect.use_ground_effect_knockback
	effect.knockback_dir = dashDir
	effect.wait_time = warning_time + dashTime
	effect.knockback_amt = 1000.0
	effect.damage_amt = 5.0
	effect.global_position = target_position
	get_tree().get_root().add_child(effect)
	emit_signal("create_warning")
	
	#stop us and our animation
	display.play("Charge")
	display.frame = 0
	display.speed_scale = 0
	
	#Start waiting for the warning to finish.
	attackTimer.start(warning_time)
	yield(attackTimer, "timeout")
	
	
	old_speed = max_speed
	max_speed = dash_speed
	move_dir += dashDir * dash_speed
	if !dead:
		display.speed_scale = 1
		display.play("Attack")
	
	dashTimer.start(dashTime)
	yield(dashTimer, "timeout")
	
	if !dead:
		display.speed_scale = 0
		display.play("Run")
	
	move_dir = Vector2.ZERO
	max_speed = old_speed
	attacking = false
	
	postAttackTimer.start()
	yield(postAttackTimer, "timeout")
	
	display.speed_scale = 1
	frozen = false
