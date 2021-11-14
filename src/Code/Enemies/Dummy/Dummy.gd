extends "res://Code/Enemies/Enemy.gd"


func set_target(_t):
	pass


func _process(delta):
	$bleed_stacks.text = "bleeding stacks: %s" % str($bleeding_debuffs.get_child_count())
