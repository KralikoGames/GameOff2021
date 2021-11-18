extends Enemy

signal create_warning

export var attack_range_med: float = 100
export var attack_range_close: float = 75
export var debug: bool = false
export var dash_speed = 300
export var swipe_slide_speed = 100
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
	print("DASH CD" + str($LungeCooldown.time_left))
	if not acting and !dead:
		dashWeight=dashWeight+0.001
		var dashRoll = randi() % 300
		if(dashWeight > dashRoll):
			#print(str(dashWeight) +">"+ str(dashRoll))
			dashWeight=0
			_dodge()
		elif _in_close_range():
			_swipe()
		elif _in_med_range() and ($LungeCooldown.time_left <= 0):
			$LungeCooldown.start()
			_lunge()
		else:
			move_to_target()
			display.play("Run")


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

func _swipe() -> void:
	#Stop and warn the player.
	emit_signal("begin_attack")
	acting = true
	frozen = true
	stop()
	move_position  = global_position.linear_interpolate(target.global_position, 0.2)
	target_position = target.global_position
	dashDir = (move_position - global_position)
	dashTime = dashDir.length()/swipe_slide_speed
	
	#create a warning.
	var effect = attack_tscn.instance()
	effect.rotation = _get_dir_to_target().angle()
	effect.shape = "cone"
	effect.scale = Vector2(1.5, 6)
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
	acting = false
	
	postAttackTimer.start()
	yield(postAttackTimer, "timeout")
	
	display.speed_scale = 1
	frozen = false

func _lunge() -> void:
	#Stop and warn the player.
	emit_signal("begin_attack")
	acting = true
	frozen = true
	stop()

	target_position = target.global_position
	dashDir = (target_position - global_position)
	dashTime = dashDir.length()/dash_speed
	
	#create a warning.
	var effect = attack_tscn.instance()
	effect.shape = "circle"
	effect.scale = Vector2(2, 2)
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
	acting = false
	
	postAttackTimer.start()
	yield(postAttackTimer, "timeout")
	
	display.speed_scale = 1
	frozen = false

func _considerDodge()-> void:
	if acting or dead or randi() % 100 > 20:
		return
	_dodge()

func _dodge()->void:
	acting = true
	frozen = true
	stop()
	
	var dashDirmult = 1
	if(randi() % 100 > 50):
		dashDirmult = -1
		
	dashDir = (global_position - target.global_position)
	dashDir = dashDir.rotated(90*dashDirmult * PI / 180).normalized() * 50
	dashTime = dashDir.length()/dash_speed
	
	#stop us and our animation
	display.play("Charge")
	display.frame = 0
	display.speed_scale = 0
	
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
	acting = false
	
	postAttackTimer.start()
	yield(postAttackTimer, "timeout")
	
	display.speed_scale = 1
	frozen = false
