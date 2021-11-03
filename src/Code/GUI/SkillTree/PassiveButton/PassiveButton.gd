extends Button


signal points_changed


export(NodePath) var required_passive_path: NodePath
export(String) var id: String = "None"
export(int) var required_points_in_parent: int = 1
export(int) var points: int = 0 setget _set_points
export(int) var max_points: int = 1


func _ready():
	add_to_group("passives")
	_update_point_count()
	

func init():
	_update_disabled()
	
	var required_passive = get_node_or_null(required_passive_path)
	if not required_passive:
		push_error("no required passive found")
		return # this passive is a root
	
	required_passive.connect("pressed", self, "_on_parent_passive_pressed")


func _update_disabled():
	if not _can_I_accept_points():
		disabled = true
		return 
	
	var parent_passive = get_node_or_null(required_passive_path)
	if parent_passive:
		disabled = not (parent_passive.points >= required_points_in_parent and GameInit.player.has_spare_passive_points())
	else:
		disabled = not GameInit.player.has_spare_passive_points()


func _on_parent_passive_pressed():
	_update_disabled()


func _on_PassiveButton_pressed():
	points += 1
	_update_point_count()
	_update_disabled()
	GameInit.player.passive_points -= 1


func _update_point_count():
	$Points.text = "%s/%s" % [str(points), str(max_points)]
	

func _can_I_accept_points() -> bool:
	return points < max_points


func _set_points(v):
	points = v
	emit_signal("points_changed")
	_update_point_count()
	_update_disabled()
