extends Slot


export(Item.ItemType) var item_type = Item.ItemType.JUNK


func init():
	var mouse_slot: Slot = get_inventory_controller().get_mouse_slot()
	
	mouse_slot.connect("populated", self, "_on_mouse_populated", [mouse_slot])
	mouse_slot.connect("emptied", self, "_on_mouse_emptied")


func will_accept_item(_inv_item: InventoryItem) -> bool:
	return _inv_item.item.type == item_type


func _on_mouse_populated(mouse_slot: Slot):
	if not can_receive_item(mouse_slot.inv_item) and not can_swap_item(mouse_slot):
		set_focus_mode(Control.FOCUS_NONE)
		highlight(Color("#999999"))


func _on_mouse_emptied(_inv_item):
	set_focus_mode(Control.FOCUS_ALL)
	highlight()




