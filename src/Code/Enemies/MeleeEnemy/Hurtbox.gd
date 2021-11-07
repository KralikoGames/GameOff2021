extends Area2D
signal onTargetFound
func set_target(t: Node2D):
	print("Setting new target to player!")
	emit_signal("onTargetFound", t)
