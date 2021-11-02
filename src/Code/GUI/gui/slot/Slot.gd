extends NinePatchRect
class_name Slot


signal populated 
signal emptied(inv_item)
signal quantity_changed


export var disable_highlight: bool = false


var inv_item: InventoryItem
var inventory_controller


func _ready():
	if not is_connected("mouse_entered", self, "_on_mouse_entered"):
		connect("mouse_entered", self, "_on_mouse_entered")
	if not is_connected("mouse_exited", self, "_on_mouse_exited"):
		connect("mouse_exited", self, "_on_mouse_exited")
	
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	
	# Texture rects by default let the mouse pass.
	mouse_filter = MOUSE_FILTER_STOP
	
	set_focus_mode(FOCUS_ALL)
	
	rect_pivot_offset = rect_min_size / 2


func get_id():
	return name


###############################################################################
###############################################################################
###############################################################################


func swap_item(_slot: Slot):
	if not can_swap_item(_slot):
		return false                   # fails if either slot can't swap
	
	var temp = chuck_item()            # both slots have items so swap them
	
	var is_success = _slot.give_item(self)
	if is_success:
		return _slot.receive_item(temp, self)
	
	push_warning("Should never reach here. Your can_swap method isn't working right. Trying to repair the damage...")
	
	#try to give the item back to self
	is_success = receive_item(temp, _slot, false)
	if is_success:
		return false # false since we already failed and are now repairing the damage
	
	push_error("Swap inv_item operation failed destructively.")
	return false


func give_item(_slot: Slot):
	if not can_give_item(_slot):
		return false                # fail if can't give inv_item over
	var temp = chuck_item()         # always chuck before receive
	_slot.receive_item(temp, self)        # otherwise pass inv_item over
	return true


#func stack_item(_slot: Slot):
#	# safer way of stacking items.
#	var _inv_item: InventoryItem = _slot.inv_item
#
#	var success = _stack_item(_inv_item)
#	if not success:
#		return false
#
#	# delete the items if they have 0 quantity - not needed anymore
##	if inv_item.item.current_quantity <= 0: 
##		void_item()
##	if _slot.inv_item.item.current_quantity <= 0: 
##		_slot.void_item()
#
#	return success


# WARN: this method can create zero stack items. should be handled elsewhere
func stack_item(_inv_item: InventoryItem): 
	if not can_stack(_inv_item):
		return false
	
	var original_quantity = inv_item.item.current_quantity
	inv_item.item.current_quantity = min(original_quantity + _inv_item.item.current_quantity, inv_item.item.max_quantity) as int
	_inv_item.item.current_quantity -= inv_item.item.current_quantity - original_quantity
	
	# update the numbers on both inv_items
#	inv_item.update_quantity(inv_item.item.current_quantity)
#	_inv_item.update_quantity(_inv_item.item.current_quantity)
	
	emit_signal("quantity_changed")
	return true
	

func receive_item(_inv_item: InventoryItem, _source_slot=null, _signal=true):
	# tries to receive an inv_item. 
	#  returns false if it can't
	if not can_receive_item(_inv_item):
		return false
	
	if inv_item:
		inv_item.disconnect("quantity_changed", self, "_on_item_quantity_changed")
	inv_item = _inv_item
	inv_item.item.slot_id = get_id() # WARN: storing scenes hard crashes on save resource
	inv_item.connect("quantity_changed", self, "_on_item_quantity_changed")
	
	# reposition the inventory item to the center of the slot. Done through reparenting
	_reparent(inv_item, self)
	
	if _signal:
		emit_signal("populated")
	return true


func give_some(_slot: Slot, percent: float = 0.5) -> bool:
	if not can_give_some(_slot):
		return false
	
	# give the slot a duplicated version and then stack
	var dupped_item: Item = inv_item.item.duplicate()
	dupped_item.current_quantity = ceil(inv_item.item.current_quantity * (percent)) as int
	var suc = _slot.receive_item(dupped_item.instance_inv_item(), self)
	if suc:
		var new_amount = floor(inv_item.item.current_quantity * (1 - percent)) as int
		inv_item.item.current_quantity = new_amount
		return true
	else:
		push_warning("Your can_give_some method is faulty.")
		return false
	


###############################################################################
###############################################################################
###############################################################################

### more important helpers ###


func chuck_item(_signal=true): # have to chuck item before you receive
#	assert(not is_empty(), "slot: %s attempted to chuck a null" % [get_id()])
	if is_empty():
		push_error("slot: %s attempted to chuck a null" % [get_id()])
	
	inv_item.disconnect("quantity_changed", self, "_on_item_quantity_changed")
	var item_temp = inv_item
	inv_item = null
	if _signal: 
		emit_signal("emptied", item_temp) 
	return item_temp


func void_item(_signal=true):
	var item_resource = chuck_item(_signal)
	item_resource.queue_free()


### more important helpers ###

### helpers ###


func _reparent(obj, new_parent):
	var old_parent = obj.get_parent()
	if old_parent: old_parent.remove_child(obj)
	new_parent.add_child(obj)


func is_empty():
	return inv_item == null


func get_mouse_slot() -> Slot:
	var mouse_slots = get_tree().get_nodes_in_group("mouse_slot")
	
	if mouse_slots.size() == 0:
		push_error("No mouse slot found")
		return null
	elif mouse_slots.size() == 1:
		# pickup/drop/swap/stack items
		return mouse_slots[0]
	else:
		push_warning("More then one mouse slot. Using first one.")
		return mouse_slots[0]


func get_inventory_controller() -> Control:
	return inventory_controller
#	return get_parent() as Control


### helpers ###

### Checkers ###


func can_receive_item(_inv_item: InventoryItem) -> bool: 
	# regular slot can receive any inv_item as long as it is empty
	return is_empty() and will_accept_item(_inv_item)


func can_stack(_inv_item: InventoryItem) -> bool:
	if not is_empty() and _inv_item:
		return (inv_item.item.is_same_as(_inv_item.item) and
			inv_item.item.is_stackable())
	return false


func can_give_item(_slot: Slot) -> bool:
	return not is_empty() and _slot.can_receive_item(inv_item)


func can_swap_item(_slot: Slot) -> bool: 
	if is_empty() or _slot.is_empty():
		return false # both slots need an item
	return will_accept_item(_slot.inv_item) and _slot.will_accept_item(inv_item)


func will_accept_item(_inv_item: InventoryItem) -> bool:
	return true  # default slot can hold any item type


func can_give_some(_slot: Slot) -> bool:
	return can_give_item(_slot) and inv_item.item.is_stackable()


### Checkers ###

### Mouse stuff ###

func _on_item_quantity_changed() -> void:
	if not inv_item:
		return
	if inv_item.item.current_quantity == 0:
		void_item()


func _on_mouse_entered() -> void:
	if focus_mode != Control.FOCUS_NONE:
		grab_focus()


func _on_mouse_exited() -> void:
#	if is_empty():
#		return
	
#	inv_item.hide_tooltip()
	pass


func _on_focus_entered():
	if is_empty():
		pass
		highlight(Color(0.95, 0.95, 0.95))
	else:
		highlight(Color(1, 1, 0.7))


func _on_focus_exited():
	highlight() # return to default highlight


func highlight(color: Color = Color(1,1,1,1)) -> void:
	if not disable_highlight:
		self_modulate = color


### Mouse stuff ###


#	unimplemented
func display_tooltip(info, offset):
	# info is a string/onject representing what needs to be printed
	#  offset is x,y vector from top left of slot - where mouse was
	pass
