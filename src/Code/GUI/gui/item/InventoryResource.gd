extends Resource
class_name Inventory


# Inventory is just an array that stores Items
# Supports save and load


signal gold_changed
#  Inventory changed : Whenever an item is added or deleted
signal inventory_changed
#  Inventory reset : When the entire inventory changes. On load for example.
signal inventory_reset

export var inventory_name = "UNNAMED"

export var infinite_gold: bool = false
export var gold_locked: bool = false # will prevent removal of items from the inventory unless another inventory provides gold.


export var gold: int setget set_gold
export var _items: Array = [] setget set_items, get_items


func _init():
	# this doesn't work because arrays and resources don't mesh or something stupid.
	connect("inventory_changed", self, "_save") 
	pass


### Setters and Getters ###

func set_items(new_items) -> void:
	# wipes the old inventory and sets it to a new one.
#	print("setting item infos.\t\told: %s\t\tnew: %s" % [_items, new_items])
	_items = new_items
#	emit_signal("inventory_changed")
	emit_signal("inventory_reset")


func get_items() -> Array:
#	print("getting item infos.\t\t%s" % [_items])
	return _items


func set_gold(new_gold: int):
	gold = new_gold if not infinite_gold else 99999
	emit_signal("gold_changed")


### Setters and Getters ###


func add_item(_item : Item) -> void:
	# This function adds an item to the inventory. It does not conduct any
	#  checks if this is possible. such logic should occur elsewhere.
#	if has(_item):
#		return
	_items.append(_item)
	emit_signal("inventory_changed")


func remove_item(_item : Item) -> void:
	# This function removes an item from the inventory if it exists. It does
	#  not conduct any checks if this is reasonable. such logic should occur
	#  elsewhere.
	assert(has(_item), "Attempted to remove an item not within the inventory")
	_items.erase(_item)
	emit_signal("inventory_changed")


func has(_item: Item):
	# returns true if the _item is inside the inventory
	return _item in _items


func can_afford(amount: int):
	return true if infinite_gold else gold >= amount


func get_item_by_name(item_name: String) -> Item:
	# returns the Item, null if it can't find it
	for item in _items:
		if (item as Item).name == item_name:
			return item
	return null


func get_item_by_id(item_id: int) -> Item:
	# returns the Item, null if it can't find it
	for item in _items:
		if (item as Item).id == item_id:
			return item
	return null


### Save and Load ###


func _save() -> bool:
	# returns true if we succesfully saved the inventory, false otherwise.
	
	var save_path = get_save_path()
#	print_debug("saving %s inv at: %s" % [self, save_path])
	
	var save = ResourceSaver.save(save_path, self)
	
	if save != 0:
		push_error("Failed to save the inventory at %s" % save_path)
		return false
	
	return true



# @Depreciated
func _load() -> bool:
	# returns true if we successfully loaded the inventory from file.
	var existing_inventory = load(get_save_path())

	if existing_inventory:
		print_debug("successfully loaded inventory from %s" % get_save_path())
		set_items(existing_inventory.get_items())
		return true
	else:
		# first time spawn player with some items
		push_warning("Failed to load saved inventory. Creating new empty inventory.")
		return false


func get_save_path() -> String:
	return "user://%s.tres" % inventory_name



### Save and Load ###

