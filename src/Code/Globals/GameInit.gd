extends Node


signal player_ready
signal skilltree_ready


var player: Player setget _set_player
var skilltree: SkillTree setget _set_skilltree


#Mantis passive constants
const trishot_angle = 35 # degrees that spinning scythe will spread out
const massive_scythe_multiplier = 1.5
const blood_explosion_damage: float = 3.0
const blood_explosion_tscn = preload("res://Code/Attacks/Mantis/Scythe/BloodExplosion/BloodExplosion.tscn")

const bleed_damage_perc = 0.5
const haemophilia_stacks = 8
const bleeding_debuff = preload("res://Code/Attacks/Mantis/Bleeding/Bleeding.tscn")

const bloodplay_ms_increase = 50.0
const bloodplay_buff = preload("res://Code/Attacks/Mantis/Bleeding/Bloodplay/Bloodplay.tscn")



func _on_enemy_died(enemy:Node2D):
	_bloodplay(enemy)
	_gratuitous_violence(enemy)


func _gratuitous_violence(enemy:Node2D):
	var boom = blood_explosion_tscn.instance()
	boom.global_position = enemy.global_position
	enemy.get_parent().add_child(boom)


func _bloodplay(enemy:Node2D):
	var bleeding_debuffs = enemy.get_node_or_null("bleeding_debuffs")
	if not bleeding_debuffs: return 
	if bleeding_debuffs.get_child_count() > 0:
		player._add_bloodplay_stack()
	


func _set_player(v): 
	if not player:
		player = v
		emit_signal("player_ready")


func _set_skilltree(v):
	if not skilltree:
		skilltree = v
		emit_signal("skilltree_ready")
