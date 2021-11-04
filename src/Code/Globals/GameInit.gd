extends Node


signal player_ready
signal skilltree_ready


var player: Player setget _set_player
var skilltree: SkillTree setget _set_skilltree

var keybinds = {}

#Mantis passive constants
const trishot_angle = 35 # degrees that spinning scythe will spread out
const massive_scythe_multiplier = 1.5
const blood_explosion_damage: float = 3.0
const blood_explosion_tscn = preload("res://Code/Attacks/Mantis/Scythe/BloodExplosion/BloodExplosion.tscn")

const bleed_damage_perc = 0.5
const bleed_duration = 4.0 # seconds
const haemophilia_stacks = 8
const bleeding_debuff = preload("res://Code/Attacks/Mantis/Bleeding/Bleeding.tscn")

const bloodplay_ms_increase = 50.0
const bloodplay_buff = preload("res://Code/Attacks/Mantis/Bleeding/Bloodplay/Bloodplay.tscn")

const exsanguinate_bleed_dps_percentage = 0.5

const cloaked_in_blood_tscn = preload("res://Code/Attacks/Mantis/Assassinate/Cloaked_In_Blood/Cloaked_In_Blood.tscn")
const cloaked_in_blood_duration = 0.5

#Other
const dash_buff_tscn = preload("res://Code/Attacks/Movement/Dash.tscn")

var active_ability_names = ["Spinning_Scythe", "Assassinate", "Shadow_Hop"]
var attacks = {
	"Spinning_Scythe":preload("res://Code/Attacks/Mantis/Scythe/Scythe.tscn") , 
	"Assassinate":preload("res://Code/Attacks/Mantis/Assassinate/Assassinate.tscn"), 
#	"Shadow_Hop": ,
}
var attack_cooldowns = {
	"Spinning_Scythe":1.3, 
	"Assassinate":0.2, 
	"Shadow_Hop":1.5,
}


func _ready():
	for n in ["timer_attack", "timer_attack2", "timer_attack3"]:
		var t = Timer.new()
		t.name = n
		t.one_shot = true
		add_child(t)
		


func _unhandled_input(event):
	if player.input_lock: return
	
	for keybind in keybinds:
		if not event.is_action_pressed(keybind): continue
		
		# get the timers and start them
		var t: Timer = get_node("timer_%s" % keybind)
		if not t.is_stopped(): continue # ability is on cooldown
		t.start()
		
		match keybinds[keybind]:
			"Spinning_Scythe", "Assassinate":
				player.spawn_selected_attack(attacks[keybinds[keybind]])
			"Shadow_Hop":
				player.dash()


func set_ability(keybind, attack_name):
	keybinds[keybind] = attack_name
	var t: Timer = get_node("timer_%s" % keybind)
	t.wait_time = attack_cooldowns[attack_name]
	


func _on_enemy_died(source:String, enemy:Node2D):
	if _is_enemy_bleeding(enemy):
		_bloodplay(enemy)
		_gratuitous_violence(enemy)
		_path_of_blood(enemy)
	_cloaked_in_blood(enemy, source)


func _path_of_blood(enemy: Node2D):
	if skilltree.passives["Path_Of_Blood"].points > 0:
		for key in keybinds:
			if keybinds[key] == "Shadow_Hop":
				var t: Timer = get_node("timer_%s" % key)
				t.stop()


func _cloaked_in_blood(enemy: Node2D, source: String):
	if skilltree.passives["Cloaked_In_Blood"].points > 0 and \
		source == "Assassinate":
		player._add_cloaked_in_blood_stack()


func _gratuitous_violence(enemy:Node2D):
	if skilltree.passives["Gratuitous_Violence"].points > 0:
		var boom = blood_explosion_tscn.instance()
		boom.global_position = enemy.global_position
		enemy.get_parent().add_child(boom)


func _bloodplay(enemy:Node2D):
	if skilltree.passives["Bloodplay"].points > 0:
		player._add_bloodplay_stack()


func _is_enemy_bleeding(enemy):
	var bleeding_debuffs = enemy.get_node_or_null("bleeding_debuffs")
	if not bleeding_debuffs: return false 
	return bleeding_debuffs.get_child_count() > 0


func _set_player(v): 
	if not player:
		player = v
		emit_signal("player_ready")


func _set_skilltree(v):
	if not skilltree:
		skilltree = v
		emit_signal("skilltree_ready")
