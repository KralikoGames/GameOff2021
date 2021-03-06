extends KinematicBody2D
class_name Enemy
tool


signal damaged
signal died
signal onSetTarget

export(String) var id: String = ""
export(float, 1, 100, 1) var health = 3
export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 1, 0.025) var damping: float = 0.80
export(float, 0, 1000, 10) var max_speed: float = 400.0
export(float, 0.0, 2.0, 0.05) var knockback_efficiency: float = 1.0


var target: Node2D
onready var hit_feedback = $OnHitFeedback
var move_dir: Vector2 = Vector2() setget set_move_dir
var look_dir: Vector2 = Vector2()
var vel: Vector2 = Vector2()
var frozen: bool = false
var knockback_dir = Vector2.ZERO

func _get_configuration_warning():
	if not id:
		return "Enemy requires an ID to function"
	return ""


func _ready():
	if Engine.editor_hint: return
	
	$hp.max_value = health
	connect("died", GameInit, "_on_enemy_died", [self])
	set_physics_process(false)


func _physics_process(_delta):
	if Engine.editor_hint:
		update()
		set_physics_process(false)
		return
	
	_move(_delta)


func set_target(t: Node2D):
	emit_signal("onSetTarget", t)
	target = t
	set_physics_process(target!=null)


func freeze(duration:float):
	frozen = true
	yield(get_tree().create_timer(duration), "timeout")
	frozen = false


func move_to_target():
	set_move_dir(_get_dir_to_target())

func stop():
	set_move_dir(Vector2())


func damage(amt: float, ability_source:String=""):
	if(hit_feedback):
		hit_feedback.play("OnHit")
		
	health -= amt
	_update_hp()
	if health <= 0:
		die(ability_source)
	else:
		emit_signal("damaged")


func die(ability_source):
	if(GameInit.player != null):
		GameInit.player.passive_points += 1
	queue_free()
	emit_signal("died", ability_source)


func _move(delta):
#	knockback_dir = knockback_dir.move_toward(Vector2.ZERO, damping * _delta)
	knockback_dir = move_and_slide(knockback_dir)
	knockback_dir *= damping
	
	vel += move_dir * acceleration
	vel = vel.clamped(max_speed)
	vel *= damping
	vel = move_and_slide(vel)


func _get_dir_to_target() -> Vector2:
	if target:
		var t = (target.global_position - global_position)
		if t.length() < 10: return Vector2()
		return t.normalized()
	return Vector2()


func _update_hp():
	$hp.value = health


func set_move_dir(v):
	move_dir = v if not frozen else Vector2()


func _on_Hitbox_area_entered(area):
	if "damage" in area:
		if area.has_method("can_damage"):
			if not area.can_damage(self):
				return
		damage(area.damage, area.get_class())
		_on_hit_effects(area)
	if "knockback" in area:
		knockback_dir = (global_position - area.global_position).normalized() * area.knockback * knockback_efficiency


func _on_hit_effects(area: Area2D):
	_blood_rite(area.damage)
	_exsanguinate(area) # ORDER MATTERS HERE.


func _exsanguinate(area: Area2D):
	if area.get_class() != "Assassinate": return
	if not GameInit.skilltree.passives["Exsanguinate"].points > 0: return

	# removes all bleeding stacks and does half the damage immediately
	for bleed in $bleeding_debuffs.get_children():
		bleed.queue_free()
		damage(bleed.time_left * bleed.dps * GameInit.exsanguinate_bleed_dps_percentage, "Assassinate")


func _blood_rite(amt: float):
	if GameInit.skilltree.passives["Blood_Rite"].points > 0:
		add_bleed_debuff(amt)


func add_bleed_debuff(damage_amt: float):
	var bleeding = GameInit.bleeding_debuff.instance()
	bleeding.target = self
	bleeding.dps = GameInit.bleed_damage_perc * damage_amt / GameInit.bleed_duration
	bleeding.wait_time = GameInit.bleed_duration
	$bleeding_debuffs.add_child(bleeding)
	$bleeding_debuffs.move_child(bleeding, 0)

	_haemophilia_bleed_limit()


func _haemophilia_bleed_limit():
	# remove extra bleed stacks
	var max_bleeds = 1 + GameInit.haemophilia_stacks * GameInit.skilltree.passives["Haemophilia"].points
	for i in range($bleeding_debuffs.get_child_count()):
		if i >= max_bleeds:
			$bleeding_debuffs.get_child(i).queue_free()


