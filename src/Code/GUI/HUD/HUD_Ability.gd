extends TextureRect


export(String, "attack", "attack2", "attack3") var keybind = "attack"


func can_drop_data(position, data):
	# data should be a string of an active ability
	return data in GameInit.active_ability_names


func drop_data(position, data):
	if data == "Spinning_Scythe":
		modulate = Color(1,0.5,1)
	else:
		modulate = Color(0,0.5,1)
	#TODO: set the texture here
	GameInit.set_ability(keybind, data)
	

func _process(delta):
	var timer: Timer = GameInit.get_node("timer_%s" % keybind)
	$cooldown.max_value = timer.wait_time
	$cooldown.value = timer.time_left
