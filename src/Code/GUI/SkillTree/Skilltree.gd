extends Control


func _ready():
	get_tree().call_group("passives", "init")
	
	yield(GameInit, "player_ready")
	
	GameInit.player.connect("passive_points_changed", self, "_on_player_passive_points_changed")
	
	_on_player_passive_points_changed()


func _on_player_passive_points_changed():
	$Skillpoints/Skillpoints.text = str(GameInit.player.passive_points)
	get_tree().call_group("passives", "_update_disabled")


