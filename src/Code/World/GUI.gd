extends CanvasLayer


func _ready():
	$Control/HUD.show()


func _input(event):
#	if event.is_action_pressed("open_equipment"):
#		$Equipment.show() if not $Equipment.is_visible_in_tree() else $Equipment.hide()
#	if event.is_action_pressed("open_inventory"):
#		$Backpack.show() if not $Backpack.is_visible_in_tree() else $Backpack.hide()
	if event.is_action_pressed("open_skilltree"):
		var _o = $Control/Skilltree.show() if not $Control/Skilltree.is_visible_in_tree() else $Control/Skilltree.hide()
	
