class_name Item
extends Resource


"""
Base Item class for all items.
"""


#signal item_changed
signal quantity_changed


enum ItemType { WEAPON, SHIELD, BODY, LEGS, HELMET, CONSUMABLE, JUNK }


export var id: int  # Internal identifier for the item
export var name: String  # Name of the item
export var description: String  # Description of the item
export var power: int  # How strong at the role (offense/defense/buff) the item is
export var sell_value: int  # How much gold the item is worth
export var current_quantity: int = 1 setget set_quant
export var max_quantity: int  # Most amount of items that can be carried
export var item_icon: Texture  # 2D Icon for GUI
export (ItemType) var type
export var world_item_path: String = 'res://'  # Directory path to in-game world item for this item

export var slot_id: String
export var buff : Resource


func set_quant(new_quant):
	current_quantity = new_quant
	emit_signal("quantity_changed")


func is_same_as(other) -> bool:
	return other.id == id


func is_stackable() -> bool:
	return max_quantity > 1


func instance_inv_item():
	var inv_item = load("res://src/inventory/InventoryItem.tscn").instance()
	inv_item.init(self)
	return inv_item


func instance_world_item():
	var world_item = load(world_item_path).instance()
	world_item.item = self
	return world_item
