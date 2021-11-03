extends CanvasLayer


func _input(event):
#	if event.is_action_pressed("open_equipment"):
#		$Equipment.show() if not $Equipment.is_visible_in_tree() else $Equipment.hide()
#	if event.is_action_pressed("open_inventory"):
#		$Backpack.show() if not $Backpack.is_visible_in_tree() else $Backpack.hide()
	if event.is_action_pressed("open_skilltree"):
		$Skilltree.show() if not $Skilltree.is_visible_in_tree() else $Skilltree.hide()
	
