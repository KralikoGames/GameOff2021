extends PanelContainer


func _ready():
	var passives = get_tree().get_nodes_in_group("passives")
	for p in passives:
		p.connect("mouse_entered", self, "_on_passive_hovered", [p])
		p.connect("mouse_exited", self, "_on_passive_exited", [p])


func _on_passive_hovered(passive):
	show()
	# update the text
	$VBoxContainer/skilldesc.text = passive.skill_description
	$VBoxContainer/skillname.text = passive.name.replace("_", " ")


func _on_passive_exited(_passive):
	hide()
