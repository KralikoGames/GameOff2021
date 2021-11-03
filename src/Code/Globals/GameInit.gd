extends Node


signal player_ready


var player: Player setget _set_player


func _set_player(v): 
	if not player:
		player = v
		emit_signal("player_ready")

