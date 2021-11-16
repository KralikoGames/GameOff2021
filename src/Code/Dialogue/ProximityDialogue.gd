extends Area2D
tool


export var one_shot: bool = true


func _get_configuration_warning():
	var result = Dialogic._get_timeline_file_from_name(name)
	if not result:
		return "dialogue name is not valid"
	return ""


func _on_ProximityDialogue_body_entered(body: Player):
	if Engine.editor_hint: 
		return
	
	if not body is Player:
		push_warning("A non-player is on the player collision layer")
		return
	
	if body.has_method("entered_area"): body.entered_area(self)
	
	DialogueManager.start_dialogue(name)
	
	if one_shot: queue_free()
