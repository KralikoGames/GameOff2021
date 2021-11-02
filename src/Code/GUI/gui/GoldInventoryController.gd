extends InventoryController


export(NodePath) var trade_inventory_controller #: InventoryController


func transfer_item(slot: Slot):
	# mediate the item transfers
	
	var mouse_slot: Slot = slot.get_mouse_slot()
	
	# If the inventory is gold_locked then the default behavior changes
	if inventory.gold_locked:
		if not get_trade_inventory():
			push_error("Trade inventory not properly initialized. Blocking item purchasing.")
			return
		
		_merchant_item_pickup_behavior(mouse_slot, slot)
		
		return # block the default behavior
	
	.transfer_item(slot)


func _merchant_item_pickup_behavior(mouse_slot: Slot, slot: Slot):
	# mouse must be empty.
	# and the trade inventory must have enough gold
	match [mouse_slot.can_give_item(slot), slot.can_give_item(mouse_slot)]:
		[false, true]: # buying something
			var item_value: int = slot.inv_item.item.sell_value if "sell_value" in slot.inv_item.item else 10 # just for debug
			if item_value == 0: push_warning("Item is free.")
			if get_trade_inventory().can_afford(item_value):
				# try to transfer item to the mouse ... this really shouldn't fail
				var success = slot.give_item(mouse_slot)
				if success: 
					inventory.gold += item_value
					get_trade_inventory().gold -= item_value
				else: 
					push_error("Failed to pickup item from the slot. Your can_give_item method is broken.")
			else:
				push_warning("Not enough gold to buy the item (need %s)." % item_value)
		
		[true, false]: # selling something
			var item_value: int = mouse_slot.inv_item.item.sell_value if "sell_value" in mouse_slot.inv_item.item else 10 # just for debug
			if item_value == 0: push_warning("Item is free.")
			if inventory.can_afford(item_value):
				# try to transfer item to the mouse ... this really shouldn't fail
				var success = mouse_slot.give_item(slot)
				if success: 
					inventory.gold -= item_value
					get_trade_inventory().gold += item_value
				else: 
					push_error("Failed to pickup item from the slot. Your can_give_item method is broken.")
			else:
				push_warning("Not enough gold to sell the item (need %s)." % item_value)
		
		_:
			pass # do nothing.


func get_trade_inventory() -> Inventory:
	if trade_inventory_controller:
		return get_node(trade_inventory_controller).inventory
	return null








