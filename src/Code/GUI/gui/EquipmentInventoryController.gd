extends InventoryController


func drop_item(_slot: Slot):
	return # overriding this prevents you from dropping items that are equipped


func _on_slot_populated(slot: Slot):
	._on_slot_populated(slot)
	
	# these two are for when the player starts the game with items equiped
	if not GameInit.player: yield(get_tree().root, "ready")
	if not GameInit.player.stats: yield(get_tree().root, "ready")
	
	# Equip the item if it is a weapon
	var world_item: WorldItem = slot.inv_item.item.instance_world_item()
	var suc = GameInit.player.equip_equipment(world_item)
	
	# give the player the buff if one exists
	if slot.inv_item.item.buff and suc:
		slot.inv_item.item.buff.apply_buff(GameInit.player.stats)


func _on_slot_emptied(inv_item: InventoryItem):
	._on_slot_emptied(inv_item)
	
	# delete the spawned item from the world if it exists - this could be done better?
	if GameInit.player.current_weapon and inv_item.item == GameInit.player.current_weapon.item:
		GameInit.player.current_weapon.queue_free()
	if GameInit.player.current_shield and inv_item.item == GameInit.player.current_shield.item:
		GameInit.player.current_shield.queue_free()
	
	# remove the buff from the player if one exists
	if inv_item.item.buff:
		inv_item.item.buff.remove_buff(GameInit.player.stats)


