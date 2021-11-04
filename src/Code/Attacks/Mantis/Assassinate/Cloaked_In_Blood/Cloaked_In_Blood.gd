extends Timer


var target: Node2D


const invisiblility_amount = 0.3


func _ready():
	if not target:
		push_error("Cloaked In Blood has no target, doesn't do anything")
		queue_free()
		return
	
	target.modulate.a = invisiblility_amount
	
	if target.has_signal("attacked"):
		target.connect("attacked", self, "end_effect")
	
	wait_time = GameInit.cloaked_in_blood_duration
	start()
	

func end_effect():
	target.modulate.a = 1
	queue_free()
	


func _on_Cloaked_In_Blood_timeout():
	end_effect()
