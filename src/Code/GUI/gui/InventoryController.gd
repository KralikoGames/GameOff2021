extends Control
class_name InventoryController

# Contains all of the information to facillitate interactions between 
#  the inventory object and the slots that contain the inventory items.


signal item_dropped(world_item)


export(NodePath) var mouse_slot_path
export(NodePath) var additional_slots # can be a slot or the parent of slots


onready var selected_slot: Slot = get_child(0)


var inventory: Inventory
var editing_slots = false


func _ready():
	connect_slots()


func connect_slots() -> void:
	for slot in get_slots():
		slot.connect("emptied", self, "_on_slot_emptied") 
		slot.connect("populated", self, "_on_slot_populated", [slot]) 
		
		slot.connect("focus_entered", self, "_on_slot_selected", [slot]) 
#		slot.connect("focus_entered", self, "_on_slot_selected", [slot]) 
		
#		slot.connect("quantity_changed", self, "_on_slot_quantity_changed") 
		
		slot.inventory_controller = self


func load_inventory(inv: Inventory) -> bool:
	if not inv:
		return false
	
#	print("setting inventory to", inv)
	
	for slot in get_slots():
		if slot.has_method("init"):
			slot.init()
	
	inventory = inv
	reload_inventory()
	return true


func reload_inventory():
	editing_slots = true
	clear_slots()
	fill_slots()
	editing_slots = false


func load_unit_inventory(object: Unit) -> bool:
	# fills the slots with the objects in the inventory that the object contains.
	if "backpack" in object: # CHANGE THIS ONCE YOU REFACTOR THE PLAYER
		return load_inventory(object.backpack)
	else:
		push_error("Failed to load unit's (%s) inventory" % object.name)
		return false


# Note this assumes that all the children of the additional slot are of type Slot
func get_slots() -> Array:
	var slots = []
	var slot1 = get_node_or_null(additional_slots)
	
	for c in get_children():
		var a = c as Slot
		if a:
			slots.append(a)
	
	if slot1:
		if slot1 is Slot:
			slots.append(slot1 as Slot)
		else:
			for c in slot1.get_children():
				var a = c as Slot
				if a:
					slots.append(a)
	
	return slots
	


func get_mouse_slot() -> Slot:
	return get_node(mouse_slot_path).get_child(0) as Slot


### Signal Triggered Methods ###


func _on_slot_emptied(inv_item: InventoryItem):
	# remove item from the inventory
	if editing_slots: # don't add items to the inventory if we are the ones doing it
		return 
	
	if inventory:
#		print("removing item from inventory")
		inventory.remove_item(inv_item.item)
	else:
		push_warning("SlotGUI: slots changed without an attached inventory. Changes won't save")


func _on_slot_populated(slot: Slot):
	# add the item to the inventory
	if editing_slots: # don't add items to the inventory if we are the ones doing it
		return 
	
	if inventory:
#		print("adding item to inventory")
		inventory.add_item(slot.inv_item.item)
	else:
		push_warning("SlotGUI: slots changed without an attached inventory. Changes won't save")



func _on_selected_slot_gui_input(event):
	if event.is_action_pressed("pick_up_item"):
		# pick up the item
		transfer_item(selected_slot)
#	if event.is_action_pressed("drop_item"):
#		drop_item(selected_slot)
#		pass


func _on_slot_selected(new_slot: Slot):
	if selected_slot.is_connected("gui_input", self, "_on_selected_slot_gui_input"):
		selected_slot.disconnect("gui_input", self, "_on_selected_slot_gui_input")
	selected_slot = new_slot
	selected_slot.connect("gui_input", self, "_on_selected_slot_gui_input")


func transfer_item(slot: Slot):
	# mediate the item transfers
	
	var mouse_slot: Slot = slot.get_mouse_slot()
	
	# Default behavior
	# 4 (6 lol) cases. I find it easier to read true as the slot has an item
	match [not mouse_slot.is_empty(), not slot.is_empty()]:
		[true, true]:
			#try to stack the items
			var success = slot.stack_item(mouse_slot.inv_item)
			if not success:
				# try to swap the items
				success = mouse_slot.swap_item(slot)
				if not success: push_warning("Failed to stack/swap items")
		[true, false]:
			# try to transfer item to the slot
			var success = mouse_slot.give_item(slot)
			if not success: push_warning("Failed to give item to the slot")
		[false, true]:
			# try to transfer item to the mouse
			if GameInit.can_split_item_stack:
				var amount_to_give: float = 1.0 / slot.inv_item.item.current_quantity
				var success = slot.give_some(mouse_slot, amount_to_give)
				if not success: push_warning("Failed to split item stack")
			else:
				var success = slot.give_item(mouse_slot)
				if not success: push_warning("Failed to pickup item from the slot")
		[false, false]:
			pass # clicked on an empty slot. do nothing


#func drop_item(slot: Slot):
#	if slot.is_empty():
#		push_warning("Tried to drop an item from an empty slot")
#		return
#
#	var world_item : WorldItem = slot.inv_item.item.instance_world_item()
#	emit_signal("item_dropped", world_item)
#
#	slot.void_item()


func insert_item_in_first_available_slot(item: Item) -> bool:
	var inv_item = item.instance_inv_item()
	add_child(inv_item)
	
	# check if any slot can stack with the item
	for slot in get_slots():
#		slot = slot as Slot
		if slot.stack_item(inv_item):
			return true
	
	for slot in get_slots():
#		slot = slot as Slot
		if slot.receive_item(inv_item):
			return true
	return false
	

### Signal Triggered Methods ###


### Subroutines ###


func clear_slots():
	for slot in get_slots():
		var s: Slot = slot as Slot
		if not s.is_empty():
			s.void_item(false)


func fill_slots():
	# empties the slots, and repopulates them with the items in the inventory.
	if not inventory:
		push_warning("SlotsGUI failed to fill slots. No inventory attached")
		return
	
	var to_remove = []
	var mouse_item: Item
	for item in inventory.get_items():
		var i: Item = item as Item
		
		if i.slot_id == "MouseSlot":
			mouse_item = i
			continue
		
		var slot: Slot = get_node(i.slot_id)
		
		if not slot:
			push_warning("tried to fill a slot with an item where the slot doesn't exist.")
			to_remove.append(item)
			continue
		
		var inv_item = i.instance_inv_item()
		add_child(inv_item)
		
		var suc = slot.receive_item(inv_item)
		if not suc:
			push_warning("tried to fill a slot that couldn't receive an item when loading an inventory")
			to_remove.append(item)
	
	if mouse_item:
		var success = insert_item_in_first_available_slot(mouse_item)
		if not success:
			to_remove.append(mouse_item)
			push_warning("Item on mouse deleted because it couldn't finid a slot to be placed into")
	
	for item in to_remove:
		inventory.remove_item(item)
		push_warning("Removing %s from inventory because it couldn't be added to the slots" % item.name)



### Subroutines ###


