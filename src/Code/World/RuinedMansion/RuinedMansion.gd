extends Node2D

func _ready():
	# hide the skills in the skilltree
	var passives = get_tree().get_nodes_in_group("passives")
	for p in passives:
		if p.name == "Spinning_Scythe":
			p.show()
		else:
			p.hide()
	
