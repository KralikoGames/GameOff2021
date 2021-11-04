extends Timer


"""
This is an uncontrollable dash

Intended use: place as a child of a Player. and call the init method.
"""


var target: Player
var dir: Vector2
var dist: float


func _ready():
	target = get_parent() as Player
	if not target:
		push_warning("Dash was placed on a non-player, doesn't do anything")
		return
	
	target.input_lock = true
	
	start()


func init(direction: Vector2, speed: float, max_distance: float):
	dir = direction
	wait_time = max_distance / speed
	dist = max_distance


func _physics_process(delta):
	var col: KinematicCollision2D = target.move_and_collide(delta * dir * dist / wait_time)
	if col:
		end_effect()


func end_effect():
	queue_free()
	target.input_lock = false


func _on_Dash_timeout():
	end_effect()
