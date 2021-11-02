extends TextureRect
class_name InventoryItem


# This scene handles the visualization of an item inside the inventory
signal quantity_changed

var item: Item

onready var quantity : Label = $Quantity


func _ready():
	if item.current_quantity == 0:
		push_error("Inventory Item improperly initialized. Has 0 quantity.")
		return
	
	if not item:
		push_warning("%s has a null item" % name)
	
	update_quantity(item.current_quantity)
	
	if item.is_stackable():
		quantity.show()
	else:
		quantity.hide()


# WARN: requires the node to be in the scene tree already!!
func init(_item : Item):
	item = _item
	texture = item.item_icon
#	print("max stack size: %s" % [item.max_quantity])
#	print("init a new InvItem.\n\tTexturePath: %s - %s" % [GameManager.ItemTexturePath + item.texture_path, texture])
	
	item.connect("quantity_changed", self, "_on_item_quantity_changed", [], CONNECT_DEFERRED)
	


func update_quantity(new_quant: int):
#	item.current_quantity = new_quant
	quantity.text = str(item.current_quantity)
	emit_signal("quantity_changed")



## ------------------------ Helpers ------------------------ ##

func get_size():
	return texture.get_size()
func get_shape():
	return item.shape
func get_type():
	return item.type


func _on_item_quantity_changed():
	update_quantity(item.current_quantity)


func show_tooltip():
	pass


func hide_tooltip():
	pass

