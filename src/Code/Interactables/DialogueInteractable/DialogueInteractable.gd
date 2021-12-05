extends Node2D
tool


export var one_shot: bool = true
var isOn = false

func _get_configuration_warning():
	var result = Dialogic._get_timeline_file_from_name(name)
	if not result:
		return "dialogue name is not valid"
	return ""

func _ready():
	$Sprite.self_modulate = Color(1,1,1,0)


func _input(event):
	if Engine.editor_hint: return
	
	if event.is_action_pressed("interact") and isOn:
		DialogueManager.start_dialogue(name)
		if one_shot: queue_free()


func _on_Area2D_area_entered(_area):
	isOn = true
	$Sprite/anim.play("fade_in")


func _on_Area2D_area_exited(_area):
	isOn = false
	$Sprite/anim.play("fade_out")
