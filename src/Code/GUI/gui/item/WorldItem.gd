class_name WorldItem
extends StaticBody

"""
Class that represents an 'Item' in the world.
"""

signal touched(obj)

export var item: Resource
export var offset_location: Vector3
export var offset_rotation: Vector3

var is_weapon = false

func _ready() -> void:
	if not item is Item:
		push_error("World Item initialized without an item resource...deleting")
		queue_free()
		return
	
	if (item as Item).current_quantity == 0:
		push_error("World Item (%s: %s) initialized with an item that has zero quantity...changing quantity to 1" % [name, translation])
		item.current_quantity = 1
	
	if get_node_or_null('HitBox') != null:
		is_weapon = true
		$HitBox/CollisionShape.disabled = true


func pick_up() -> Item:
	emit_signal('touched', self)
	queue_free()
	return item as Item


func equip_weapon():
	translation = offset_location
	rotation_degrees = offset_rotation
	
	set_collision_layer_bit(3, false)
	set_collision_layer_bit(1, false)
#	set_collision_layer_bit(4, true)
#	set_collision_mask_bit(2, true)


func drop_weapon():
	set_collision_layer_bit(3, true)
#	set_collision_layer_bit(4, false)
#	set_collision_mask_bit(2, false)

