extends Node

signal changeAnimation

export var associatedAnimation = ""

func _attack(target):
	print("Receiving attack state!")
	emit_signal("changeAnimation", associatedAnimation)
