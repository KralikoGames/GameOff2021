extends StaticBody2D


func _ready():
	$Label.self_modulate = Color(1,1,1,0)


func _on_Area2D_area_entered(_area):
	$anim.play("show")


func _on_Area2D_area_exited(_area):
	$anim.play("hide")
