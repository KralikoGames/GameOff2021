extends KinematicBody2D


signal damaged
signal died


export(float, 1, 100, 1) var health = 3
export(float, 0, 1000, 10) var acceleration: float = 300.0
export(float, 0, 1, 0.025) var damping: float = 0.80
export(float, 0, 1000, 10) var max_speed: float = 400.0


var target
var move_dir: Vector2 = Vector2()
var look_dir: Vector2 = Vector2()
var vel: Vector2 = Vector2()


func _ready():
	$hp.max_value = health
	connect("died", GameInit, "_on_enemy_died", [self])
	set_physics_process(false)


func _physics_process(_delta):
	move_dir = _get_dir_to_target() # _get_input_dir() if not is_dead else Vector2()
	vel += move_dir * acceleration
	vel = vel.clamped(max_speed)
	
	vel = move_and_slide(vel)
	
	vel *= damping
	
	vel = move_and_slide(vel)


func set_target(t: Node2D):
	target = t
	print("hiohi")
	set_physics_process(true)


func _get_dir_to_target() -> Vector2:
	if target:
		var t = (target.global_position - global_position)
		if t.length() < 10: return Vector2()
		return t.normalized()
	return Vector2()


func _update_hp():
	$hp.value = health


func _on_Hitbox_area_entered(area):
	if "damage" in area:
		if area.has_method("can_damage"):
			if not area.can_damage(self):
				return
		damage(area.damage)
		_on_hit_effects(area.damage)


func damage(amt: float):
	health -= amt
	_update_hp()
	if health <= 0:
		emit_signal("died")
		die()
	else:
		emit_signal("damaged")


func die():
	_on_death_effects()
	queue_free()


func _on_death_effects():
	_gratuitous_violence()


func _gratuitous_violence():
	pass


func _on_hit_effects(amt: float):
	_blood_rite(amt)
	

func _blood_rite(amt: float):
	if GameInit.skilltree.passives["Blood_Rite"].points > 0:
		add_bleed_debuff(amt)


func add_bleed_debuff(damage_amt: float):
	var bleeding = GameInit.bleeding_debuff.instance()
	bleeding.target = self
	bleeding.dps = GameInit.bleed_damage_perc * damage_amt
	$bleeding_debuffs.add_child(bleeding)
	$bleeding_debuffs.move_child(bleeding, 0)
	
	_haemophilia_bleed_limit()


func _haemophilia_bleed_limit():
	# remove extra bleed stacks
	var max_bleeds = GameInit.haemophilia_stacks if GameInit.skilltree.passives["Haemophilia"].points > 0 else 1
	for i in range($bleeding_debuffs.get_child_count()):
		if i >= max_bleeds:
			$bleeding_debuffs.get_child(i).queue_free()
