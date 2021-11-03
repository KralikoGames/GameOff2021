extends "res://Code/Player/PlayerMovement.gd"
class_name Player


signal passive_points_changed


export(int) var passive_points: int = 0 setget _set_passive_points


func _ready():
	GameInit.player = self


func has_spare_passive_points() -> bool:
	return passive_points > 0


func _set_passive_points(v):
	passive_points = v
	emit_signal("passive_points_changed")
