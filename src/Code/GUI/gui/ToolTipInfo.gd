extends Control


### Displays item tooltip information 
### also handles item comparisons once the equpabble items become a thing


var prev_slot: Slot


func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_gui_focus_changed")


func _on_gui_focus_changed(node: Control):
	hide()
	
	var slot: Slot = node as Slot
	if not slot:
		return
	
	if prev_slot:
		prev_slot.disconnect("populated", self, "update_tooltip")
		prev_slot.disconnect("emptied", self, "slot_emptied")
	slot.connect("populated", self, "update_tooltip", [slot])
	slot.connect("emptied", self, "slot_emptied")
	prev_slot = slot
	
	update_tooltip(slot)
	

func update_tooltip(slot: Slot):
	if slot.is_empty():
		return
	
	var item: Item = slot.inv_item.item
	
	# write the description of the item in the tooltip
	$VBox/Name.text = item.name
	$VBox/Description.text = item.description
	$VBox/SellValue.text = "Sell Value: %s" % item.sell_value
	$VBox/Power.text = "Power: %s" % item.power
	
	show()


func slot_emptied(_inv_item):
	hide()
