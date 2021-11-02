extends Node

""" This class loads WorldItems into the inventory database

Access items in the database with either syntax:

ItemDB.items[item_id].description     	* Preferable so editor can catch errors
ItemDB.items[item_id]['description']

Fields are defined in Item.gd

"""


const item_dir = "res://src/inventory/items/"

var items: Dictionary


func _ready() -> void:
	for dir in Util.list_dir(item_dir):
		for file_name in Util.list_dir(item_dir + dir, "*.tres"):
			var item = load(item_dir + dir + "/" + file_name)
			items[item.id] = item


func increase(item_id: int, amount: int) -> int:
	items[item_id].current_quantity = clamp(items[item_id].current_quantity + amount, 0, items[item_id].max_quantity)
	return items[item_id].current_quantity


func decrease(item_id: int, amount: int) -> int:
	items[item_id].current_quantity = clamp(items[item_id].current_quantity - amount, 0, items[item_id].max_quantity)
	return items[item_id].current_quantity


func spawn_item(item_id: int) -> WorldItem:
	return load(items[item_id].world_item_path).instance()
