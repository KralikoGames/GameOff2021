extends TextureRect


export(String, "attack", "attack2", "attack3") var keybind = "attack"
var curr_text: Texture
var curr_name: String
var default_text: Texture = preload("res://Art/white_square.png")


func is_occupied() -> bool:
	return curr_name != ""


func occupy_slot(n: String, t: Texture):
	curr_text = t
	curr_name = n
	texture = t
	GameInit.set_ability(keybind, n)


func clear_slot():
	curr_name = ""
	curr_text = null
	texture = default_text
	GameInit.get_node("timer_%s" % keybind).stop() # reset the cooldown on the timer


func can_drop_data(_position, data):
	# data should be a string of an active ability
	return data["name"] in GameInit.active_ability_names


func drop_data(_position, data):
	occupy_slot(data["name"], data["texture"])


func get_drag_data(_position):
	if not curr_name or not curr_text: return
	
	var t = TextureRect.new()
	var c = Control.new()
	c.add_child(t)
	
	t.texture = curr_text
	t.expand = true
	t.rect_size = Vector2(30, 30)
	t.rect_position = -0.5 * t.rect_size
	
	set_drag_preview(c)
	
	var data = {"name":curr_name, "texture":curr_text}
	
	clear_slot()
	
	return data

func _process(_delta):
	var timer: Timer = GameInit.get_node("timer_%s" % keybind)
	$cooldown.max_value = timer.wait_time
	$cooldown.value = timer.time_left
