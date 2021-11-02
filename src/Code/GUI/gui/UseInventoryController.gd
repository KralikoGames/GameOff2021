extends InventoryController


func _on_slot_emptied(inv_item: InventoryItem):
	pass # don't save to the inventory


func _on_slot_populated(slot: Slot):
	var item: Item = slot.inv_item.item
	var mouse_slot: Slot = slot.get_mouse_slot()
	if item.current_quantity >= 1:
		var suc = slot.give_item(mouse_slot)
		if not suc:
			push_warning("Failed to return used item to the mouse")
	else:
		slot.void_item()
	
	# give the item back to the mouse with one less quantity
	if not item.is_stackable():
		return
	
	use_item(item)
	item.current_quantity -= 1


func use_item(item: Item) -> void:
	match item.type:
		item.ItemType.CONSUMABLE:
			_use_consumable_item(item)
		_: #Item.ItemType.JUNK:
			pass


func _use_consumable_item(item) -> void:
	match item.name:
		'Health Potion':
			# if you don't separate this line, GameInit sets player to itself. Wot?
			#  like GameInit.player = GameInit.player
			var player = GameInit.player 
			player.stats.health += item.power
		'Speed Potion':
			pass
		'Strength Potion':
			pass
