extends Timer


var target: Node2D
var amount: float


func _ready():
	if not target:
		push_error("Bloodplay has not target, doesn't do anything")
		queue_free()
		return
	
	amount = GameInit.base_bloodplay_ms_increase + GameInit.bloodplay_ms_increase * GameInit.skilltree.passives["Bloodplay"].points
	
	target.max_speed += amount


func _on_Bloodplay_timeout():
	target.max_speed -= amount
	queue_free()
