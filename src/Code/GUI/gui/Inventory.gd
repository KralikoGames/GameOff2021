extends Panel

"""
Script to handle inventory management
"""

signal inventory_item_used
signal inventory_item_added(item_id, amount)
signal ui_closed
signal item_dropped(world_item)


export var drag_and_drop: bool = false


onready var mouse_slot: Slot = $MouseSlot/MouseSlot


func _ready() -> void:
	add_to_group("ui")
	reset_ui()


func init():
	
	$Backpack.load_inventory(GameInit.player.backpack)
	$Equipment.load_inventory(GameInit.player.equipment)
	GameInit.player.backpack.connect("gold_changed", self, "update_gold")
	update_gold()
	
	for c in get_children():
		if c.has_signal("item_dropped"):
			c.connect("item_dropped", self, "_on_item_dropped")
	
#	$MerchantSlots.trade_inventory_controller = $Backpack
#	$Backpack.trade_inventory_controller = $MerchantSlots


# Used by call_group("ui", "reset_ui") to reset all UI elements back to their default state. 
# Optionally exclude this node, usually when enabling visibility and drawing element.
func reset_ui(caller:Node = null) -> void:
	if caller != self:
		visible = false
		hide_inventory()


func _input(event):
	# Drag and drop code: Stupid race condition.
	if drag_and_drop and event.is_action_released("pick_up_item") and mouse_slot.inv_item:
		yield(get_tree().create_timer(0.05), "timeout") # wait for a slot to grab focus
		var focused_slot = get_focus_owner() as Slot
		if focused_slot:
			focused_slot.get_inventory_controller().transfer_item(focused_slot)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('inventory'):
		if not visible:
			open()
		else:
			close()


func open():
	get_tree().call_group("ui", "reset_ui", self)
	visible = true
	GameInit.ui_open = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$Backpack.get_child(0).grab_focus()


func close():
	get_tree().call_group("ui", "reset_ui")
	GameInit.ui_open = false
	emit_signal("ui_closed")
	
	hide_inventory()


func hide_inventory():
	$MerchantSlots.hide()
	# if we are holding an item return it to where it was last
	mouse_slot.return_item()


func update_gold():
	$Gold.text = GameInit.player.backpack.gold as String


func initiate_trade(inv: Inventory):
	$MerchantSlots.load_inventory(inv)
	$MerchantSlots.show()
	open()


func pickup_item(item: Item, show_message=true) -> bool:
	var suc = $Backpack.insert_item_in_first_available_slot(item)
	if suc:
		if show_message:
			GameInit.player.osn.notify('You received %d %s' % [item.current_quantity, item.name])
		emit_signal('inventory_item_added', item.id, item.current_quantity)
	return suc


func spawn_in_item(item_id: int, qty: int=1, show_message=true) -> bool:
	var item: Item = ItemDB.items[item_id].duplicate()
	item.current_quantity = qty
	return pickup_item(item, show_message)


func _on_item_dropped(world_item: WorldItem):
	emit_signal("item_dropped", world_item)

