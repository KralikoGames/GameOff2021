extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self, "_on_DamagePlayerArea_area_entered")

func _on_DamagePlayerArea_area_entered(area):
	var player = area.get_parent() as Player
	if(player != null):
		player.damage(10, Vector2.ZERO, 0)
