extends Control
class_name SkillTree


var passives = {} # key passive id, value reference to the node.


func _ready():
	get_tree().call_group("passives", "init")
	_populate_passives_dictionary()
	
	yield(GameInit, "player_ready")
	
	GameInit.player.connect("passive_points_changed", self, "_on_player_passive_points_changed")
	
	_on_player_passive_points_changed()
	
	GameInit.skilltree = self


func _on_player_passive_points_changed():
	$Skillpoints/Skillpoints.text = str(GameInit.player.passive_points)
	get_tree().call_group("passives", "_update_disabled")


func _populate_passives_dictionary():
	var ps = get_tree().get_nodes_in_group("passives")
	for p in ps:
		if p.id in passives:
			push_error("Two passives have the same ID")
		passives[p.id] = p
