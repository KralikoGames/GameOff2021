extends KinematicBody2D
class_name Enemy

signal damaged
signal died

export(float, 1, 100, 1) var health = 3
export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 1, 0.025) var damping: float = 0.80
export(float, 0, 1000, 10) var max_speed: float = 400.0
export(float, 0, 500, 10) var friction: float = 200

var target: Node2D
#var knockback_dir: Vector2 = Vector2()
var move_dir: Vector2 = Vector2() setget set_move_dir
var look_dir: Vector2 = Vector2()
var vel: Vector2 = Vector2()
var frozen: bool = false


func _ready():
	$hp.max_value = health
	connect("died", GameInit, "_on_enemy_died", [self])
	set_physics_process(false)


func _physics_process(delta):
	if Engine.editor_hint:
		update()
		return
	
	_move()


func set_target(t: Node2D):
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
	health -= amt
	_update_hp()
	if health <= 0:
		die(ability_source)
	else:
		emit_signal("damaged")


func die(ability_source):
	queue_free()
	emit_signal("died", ability_source)


func _move():
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
		vel += (global_position - area.global_position).normalized() * area.knockback
#		knockback_dir = (global_position - area.global_position).normalized() * area.knockback


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
	var max_bleeds = GameInit.haemophilia_stacks if GameInit.skilltree.passives["Haemophilia"].points > 0 else 1
	for i in range($bleeding_debuffs.get_child_count()):
		if i >= max_bleeds:
			$bleeding_debuffs.get_child(i).queue_free()


