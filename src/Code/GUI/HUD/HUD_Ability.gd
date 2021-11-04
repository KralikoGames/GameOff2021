extends TextureRect


export(String, "attack", "attack2", "attack3") var keybind = "attack"
var curr_text: Texture
var curr_name: String
var default_text: Texture = preload("res://Art/white_square.png")


func can_drop_data(position, data):
	# data should be a string of an active ability
	return data["name"] in GameInit.active_ability_names


func drop_data(position, data):
	curr_text = data["texture"]
	curr_name = data["name"]
	texture = data["texture"]
	GameInit.set_ability(keybind, data["name"])


func get_drag_data(position):
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
	
	curr_name = ""
	curr_text = null
	texture = default_text
	
	return data

func _process(delta):
	var timer: Timer = GameInit.get_node("timer_%s" % keybind)
	$cooldown.max_value = timer.wait_time
	$cooldown.value = timer.time_left
