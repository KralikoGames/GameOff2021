extends Enemy

signal create_warning

export var spin_animation_time = 0.4
export var attack_range_med: float = 100
export var attack_range_close: float = 75
export var debug: bool = false
export var dash_speed = 300
export var swipe_slide_speed = 100
export var slash_warning_time = 0.5
export var lunge_warning_time = 0.3
export var dodge_recovery_rate = 0.001
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
var move_position = Vector2()
var acting: bool = false
var dead: bool = false
var dashDir = Vector2()
var dashTime = 0
var dashWeight = 0


func _ready():
	freeze(1)
	connect('onSetTarget', self, "SetTarget")

func SetTarget(t):
	if((t is Player) and (t != target)):
		if t.has_signal("attacked"):
			t.connect("attacked", self, "_considerDodge")

func _physics_process(delta): # target is guarranteed to be assigned
		
	if not is_instance_valid(target): 
		target = null
		return

	flip_to_target()
	
	if not acting and !dead:
		dashWeight+=dodge_recovery_rate
		var dashRoll = randi() % 300
		if(dashWeight > dashRoll):
			#print(str(dashWeight) +">"+ str(dashRoll))
			dashWeight=0
			_dash()
		elif _in_close_range():
			_swipe()
		elif _in_med_range() and ($LungeCooldown.time_left <= 0):
			$LungeCooldown.start()
			_lunge()
		else:
			move_to_target()
			display.play("Walk")

func flip_to_target():
	display.flip_h = target.global_position.x > global_position.x

func _in_close_range()-> bool:
	return target.global_position.distance_to(global_position) <= attack_range_close

func _in_med_range() -> bool:
	return target.global_position.distance_to(global_position) <= attack_range_med

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

func _end_Attack() -> void:
	if !dead:
		display.speed_scale = 1
		display.play("Idle")
	move_dir = Vector2.ZERO
	max_speed = old_speed
	
	postAttackTimer.start()
	yield(postAttackTimer, "timeout")
	
	acting = false
	frozen = false

func _startAttack()->void:
	emit_signal("begin_attack")
	acting = true
	frozen = true
	stop()

func _swipe() -> void:
	#Stop
	_startAttack()
	var saved_knockback_efficiency = knockback_efficiency
	knockback_efficiency = 0;
	
	#Warn the player that they are being attacked.
	_create_warning("circle", true, Vector2.ONE*15, slash_warning_time, global_position, 5, Vector2.ZERO, 0)
	display.speed_scale = 1
	display.play("Windup 2")
	
	attackTimer.start(slash_warning_time)
	yield(attackTimer, "timeout")
	
	#Spin
	if !dead:
		display.speed_scale = 1
		display.play("Spin")
		attackTimer.start(spin_animation_time)
		yield(attackTimer, "timeout")
		
		knockback_efficiency = saved_knockback_efficiency
		_end_Attack()

func _lunge() -> void:
	#Stop and warn the player.
	_startAttack()
	
	target_position = target.global_position
	dashDir = (target_position - global_position)
	
	display.play("Dash windup")
	attackTimer.start(lunge_warning_time)
	yield(attackTimer, "timeout")
	
	#Dash
	old_speed = max_speed
	max_speed = dash_speed
	move_dir += dashDir * dash_speed
	if !dead:
		display.speed_scale = 1
		display.play("Dash")
	dashTimer.start(dashDir.length()/dash_speed)
	yield(dashTimer, "timeout")
	
	#Post attack pause.
	_end_Attack()

func _considerDodge()-> void:
	if acting or dead or randi() % 100 > 20:
		return
	_dash()

func _dash()->void:
	acting = true
	frozen = true
	stop()
	
	var dashDirmult = 1
	if(randi() % 100 > 50):
		dashDirmult = -1
	#Dash
	dashDir = (global_position - target.global_position)
	dashDir = dashDir.rotated(90*dashDirmult * PI / 180).normalized() * 50
	dashTime = dashDir.length()/dash_speed
	old_speed = max_speed
	max_speed = dash_speed
	move_dir += dashDir * dash_speed
	if !dead:
		display.speed_scale = 1
		display.play("Dash")
	dashTimer.start(dashTime)
	yield(dashTimer, "timeout")
	#Reset
	if !dead:
		display.speed_scale = 0
		display.play("Run")
	move_dir = Vector2.ZERO
	max_speed = old_speed
	acting = false
	
	postAttackTimer.start()
	yield(postAttackTimer, "timeout")
	
	display.speed_scale = 1
	frozen = false

func _create_warning(shape, visible ,scale, time, position, damage ,knockback_dir = Vector2.ZERO, knockback_str = 0)->void:
	var effect = attack_tscn.instance()
	effect.useCircleWarning = true
	effect.visible = visible
	effect.shape = shape
	effect.scale = scale
	effect.use_ground_effect_knockback
	effect.knockback_dir = knockback_dir
	effect.wait_time = time
	effect.knockback_amt = knockback_str
	effect.damage_amt = damage
	effect.global_position = position
	
	var EffectsNode = get_tree().get_nodes_in_group("Effects").front()
	EffectsNode.add_child(effect)
	
	emit_signal("create_warning")

 

func _on_Spider_damaged():
	pass # Replace with function body.
