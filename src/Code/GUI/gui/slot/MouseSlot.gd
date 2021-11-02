extends Slot


## WARN: intended to be used with a Node2D as a parent
export var parent_path : NodePath = ".."


onready var parent: Node2D = get_node(parent_path)


# time in ms before the mouse slot will resume snapping to the mouse should the keyboard/controller be used
const TIME_TO_SNAP = 1000 / 10 


var last_slot: Slot
var time_since_last_mouse_motion = 0
onready var viewport = get_viewport()


func _ready():
	add_to_group("mouse_slot")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	viewport.connect("gui_focus_changed", self, "_on_gui_focus_changed")
	rect_scale = Vector2(1.2, 1.2)


func _input(event):
	if event is InputEventMouseMotion:
		parent.global_position = event.position # get_global_mouse_position()
		time_since_last_mouse_motion = OS.get_system_time_msecs()


func return_item():
	if not is_empty() and last_slot:
		var inv_controller = (last_slot as Slot).get_inventory_controller()
		inv_controller.transfer_item(last_slot)
		last_slot.grab_focus()


func receive_item(_inv_item: InventoryItem, _source_slot=null, _signal=true):
	var success = .receive_item(_inv_item, _source_slot, _signal)
	
	if success and _source_slot:
		last_slot = _source_slot
		# move to the source slots position
		parent.global_position = _source_slot.rect_global_position + (_source_slot.rect_size / 2)
		
	else:
		push_warning("Mouse slot received an item that wasn't held in a slot. Mouse slot won't be able to return the item.")
	
	return success


func _on_gui_focus_changed(node: Control):
	if not node is Slot:
		return
	
	if not is_inside_tree(): # protect against scene changer mouse_slot duplications because ui is inside player
		viewport.disconnect("gui_focus_changed", self, "_on_gui_focus_changed")
		return 
	
	# if mouse moved recently then don't snap to slot - fixes fluttering
	if OS.get_system_time_msecs() - time_since_last_mouse_motion > TIME_TO_SNAP:
		# Move to the slot that is being focused
		parent.global_position = node.rect_global_position + (node.rect_size / 2)
	
	
