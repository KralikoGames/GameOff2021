extends InventoryController


func _on_slot_populated(slot: Slot):
	var world_item : WorldItem = slot.inv_item.item.instance_world_item()
	emit_signal("item_dropped", world_item)

	slot.void_item()
#	slot.highlight(Color("#ffffff00"))





