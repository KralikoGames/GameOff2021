extends TextureButton


signal points_changed


export(NodePath) var required_passive_path: NodePath
export(bool) var draggable_skill: bool = false
export(int) var required_points_in_parent: int = 1
export(int) var points: int = 0 setget _set_points
export(int) var max_points: int = 1

export(String, MULTILINE) var skill_description


func _ready():
	add_to_group("passives")
	_update_point_count()
	

func init():
	_update_disabled()
	
	var required_passive = get_node_or_null(required_passive_path)
	if not required_passive:
#		push_warning("no required passive found")
		return # this passive is a root
	
	required_passive.connect("pressed", self, "_on_parent_passive_pressed")






func get_drag_data(_position):
	if not draggable_skill: return
	if points != max_points: return
	
	var t = TextureRect.new()
	var c = Control.new()
	c.add_child(t)
	
	t.texture = texture_normal
	t.expand = true
	t.rect_size = Vector2(30, 30)
	t.rect_position = -0.5 * t.rect_size
	
	set_drag_preview(c)
	
	return {"name":name, "texture":texture_normal}









func _update_disabled():
	if not _can_I_accept_points():
		disabled = true
		return 
	if not is_instance_valid(GameInit.player):
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
	
	if draggable_skill: # try occupying an open ability slot
		var slots = get_tree().get_nodes_in_group("ability_slots")
		for slot in slots:
			if not slot.is_occupied():
				slot.occupy_slot(name, texture_normal)
				break


func _update_point_count():
	$Points.text = "%s/%s" % [str(points), str(max_points)]
	

func _can_I_accept_points() -> bool:
	return points < max_points


func _set_points(v):
	points = v
	emit_signal("points_changed")
	_update_point_count()
	_update_disabled()



### Procedural hover/click for the button

func _darken(): self_modulate *= 0.9
func _lighten(): self_modulate *= 1.1
func _on_PassiveButton_mouse_entered(): if _can_I_accept_points(): _darken()
func _on_PassiveButton_mouse_exited():  if _can_I_accept_points(): _lighten()
func _on_PassiveButton_button_down():   if _can_I_accept_points(): _darken()
func _on_PassiveButton_button_up():     self_modulate = Color(1,1,1,1)
