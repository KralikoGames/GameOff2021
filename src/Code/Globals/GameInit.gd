extends Node


signal player_ready
signal skilltree_ready
signal enemy_died(enemy)

### Scenes ###

var scenes = {
	"world" : preload("res://Worlds/Level1/Level1.tscn"),
	"menu" : preload("res://Code/Menu/Main_Menu.tscn"),
}

var current_scene = null

### Scenes ###


var player: Player setget _set_player
var skilltree: SkillTree setget _set_skilltree

var keybinds = {}

#Mantis passive constants
const trishot_angle = 20 # degrees that spinning scythe will spread out
const massive_scythe_multiplier = 0.1 # a percent
const blood_explosion_damage: float = 3.0
const blood_explosion_size_multiplier: float = 0.15 # a percent
const blood_explosion_tscn = preload("res://Code/Attacks/Mantis/Scythe/BloodExplosion/BloodExplosion.tscn")

const bleed_damage_perc = 0.5
const bleed_duration = 4.0 # seconds
const haemophilia_stacks = 2
const bleeding_debuff = preload("res://Code/Attacks/Mantis/Bleeding/Bleeding.tscn")

const base_bloodplay_ms_increase = 50.0 # base amount of ms
const bloodplay_ms_increase = 15.0 # per point increase
const bloodplay_buff = preload("res://Code/Attacks/Mantis/Bleeding/Bloodplay/Bloodplay.tscn")

const gratuitous_violence_size_multiplier = 0.25

const exsanguinate_bleed_dps_percentage = 0.5

const cloaked_in_blood_tscn = preload("res://Code/Attacks/Mantis/Assassinate/Cloaked_In_Blood/Cloaked_In_Blood.tscn")
const cloaked_in_blood_duration = 0.5

const shadow_hop_dash_speed: float = 800.0
const shadow_hop_dash_distance: float = 32.0

#Other
const dash_buff_tscn = preload("res://Code/Attacks/Movement/Dash.tscn")

var active_ability_names = ["Spinning_Scythe", "Assassinate", "Shadow_Hop"]
var attacks = {
	"Spinning_Scythe":preload("res://Code/Attacks/Mantis/Scythe/Scythe.tscn") , 
	"Assassinate":preload("res://Code/Attacks/Mantis/Assassinate/Assassinate.tscn"), 
#	"Shadow_Hop": ,
}
var attack_cooldowns = {
	"Spinning_Scythe":0.4, 
	"Assassinate":0.4, 
	"Shadow_Hop":1.5,
}


func _ready():
	_create_ability_timers()
	var root = get_tree().root
	yield(root, "ready")
	current_scene = root.get_child(root.get_child_count()-1)


func _unhandled_input(event):
	if not is_instance_valid(player): return
	if player.input_lock: return
	
	_cast_abilities(event)


########################## Scene Handling ##########################


func change_scene(scene_name):
	if not scene_name in scenes:
		push_error("can't change to scene %s. Scene does not exist.")
		return

	var new_scene = scenes[scene_name].instance()
	current_scene.queue_free()
	get_tree().root.add_child(new_scene)
	current_scene = new_scene
	
	for keybind in keybinds:
		keybinds[keybind] = ""
		var t: Timer = get_node("timer_%s" % keybind)
		t.wait_time = 0


########################## Scene Handling ##########################

########################## Abilities ##########################


func _create_ability_timers():
	for n in ["timer_attack", "timer_attack2", "timer_attack3"]:
		var t = Timer.new()
		t.name = n
		t.one_shot = true
		add_child(t)


func _cast_abilities(event):
	for keybind in keybinds:
		if not event.is_action_pressed(keybind): continue
		
		# get the timers and start them
		var t: Timer = get_node("timer_%s" % keybind)
		if not t.is_stopped(): continue # ability is on cooldown
		if(keybinds[keybind] != ""):
			t.start()
		
		match keybinds[keybind]:
			"Spinning_Scythe", "Assassinate":
				player.spawn_selected_attack(attacks[keybinds[keybind]])
			"Shadow_Hop":
				player.dash(shadow_hop_dash_speed, shadow_hop_dash_distance)


func set_ability(keybind, attack_name):
	keybinds[keybind] = attack_name
	var t: Timer = get_node("timer_%s" % keybind)
	t.wait_time = attack_cooldowns[attack_name]


########################## Abilities ##########################

########################## On death Effects ##########################


func _on_enemy_died(source:String, enemy:Enemy):
	if _is_enemy_bleeding(enemy):
		_bloodplay(enemy)
		_gratuitous_violence(enemy)
		_path_of_blood(enemy)
	_cloaked_in_blood(enemy, source)
	
	emit_signal("enemy_died", enemy)


func _path_of_blood(_enemy: Enemy):
	if skilltree.passives["Path_Of_Blood"].points > 0:
		for key in keybinds:
			if keybinds[key] == "Shadow_Hop":
				var t: Timer = get_node("timer_%s" % key)
				t.stop()


func _cloaked_in_blood(_enemy: Enemy, source: String):
	if skilltree.passives["Cloaked_In_Blood"].points > 0 and \
		source == "Assassinate":
		player._add_cloaked_in_blood_stack()


func _gratuitous_violence(enemy: Enemy):
	if skilltree.passives["Gratuitous_Violence"].points > 0:
		var boom = blood_explosion_tscn.instance()
		boom.global_position = enemy.global_position
		boom.scale *= 1 + gratuitous_violence_size_multiplier * skilltree.passives["Gratuitous_Violence"].points
		enemy.get_parent().add_child(boom)


func _bloodplay(_enemy: Enemy):
	if skilltree.passives["Bloodplay"].points > 0:
		player._add_bloodplay_stack()


func _is_enemy_bleeding(enemy: Enemy):
	var bleeding_debuffs = enemy.get_node_or_null("bleeding_debuffs")
	if not bleeding_debuffs: return false 
	return bleeding_debuffs.get_child_count() > 0


########################## On death Effects ##########################


func _set_player(v): 
	player = v
	emit_signal("player_ready")


func _set_skilltree(v):
	skilltree = v
	emit_signal("skilltree_ready")
