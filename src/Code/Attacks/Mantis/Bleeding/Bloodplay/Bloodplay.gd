extends Timer


var target: Node2D


func _ready():
	if not target:
		push_error("Bloodplay has not target, doesn't do anything")
		queue_free()
		return
	
	target.max_speed += GameInit.bloodplay_ms_increase
	


func _on_Bloodplay_timeout():
	target.max_speed -= GameInit.bloodplay_ms_increase
	queue_free()
