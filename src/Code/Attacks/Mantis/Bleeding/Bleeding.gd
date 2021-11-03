extends Timer


var dps: float
var target: Node2D


func _process(delta):
	if not target:
		set_process(false)
		push_error("Debuff has not target, won't do anything")
		return
	
	if target.has_method("damage"):
		target.damage(dps * delta)


func _on_Bleeding_timeout():
	queue_free()
