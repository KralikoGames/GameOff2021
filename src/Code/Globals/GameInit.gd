extends Node


signal player_ready
signal skilltree_ready


var player: Player setget _set_player
var skilltree: SkillTree setget _set_skilltree


const trishot_angle = 35 # degrees that spinning scythe will spread out


func _set_player(v): 
	if not player:
		player = v
		emit_signal("player_ready")


func _set_skilltree(v):
	if not skilltree:
		skilltree = v
		emit_signal("skilltree_ready")
