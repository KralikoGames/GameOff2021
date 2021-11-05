extends ProgressBar

var health = 0
export(int, 1, 500, 10) var max_health = 5 setget _update_max_hp
signal die


func _ready():
	health = max_health
	max_value = max_health
	value = max_health
	

func _update_max_hp(newmaxhealth):
	max_health = newmaxhealth
	max_value = newmaxhealth


func damage(amt: float, ability_source:String=""):
	print("damaging!")
	health -= amt
	if health <= 0:
		emit_signal("die", ability_source)
		get_parent().queue_free()
	else:
		value = health
		emit_signal("damaged")


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


func DamageEnemy(area):
	if "damage" in area:
		if area.has_method("can_damage") and area.can_damage(self):
			damage(area.damage, area.get_class())
			_on_hit_effects(area)
