extends Timer


"""
This is an uncontrollable dash

Intended use: place as a child of a Player. and call the init method.
"""


var target: Player
var dir: Vector2
var dist: float
var sprite: AnimatedSprite


var silhouette_tscn = preload("res://Code/Attacks/Movement/silhouette.tscn")


func _ready():
	target = get_parent() as Player
	if not target:
		push_warning("Dash was placed on a non-player, doesn't do anything")
		return
	
	target.input_lock = true
	
	start()
	
	if sprite:
		$SilhouetteTimer.start()


func init(direction: Vector2, speed: float, max_distance: float, _sprite: AnimatedSprite=null):
	dir = direction
	wait_time = max_distance / speed
	$SilhouetteTimer.wait_time = wait_time / 4.0
	dist = max_distance
	sprite = _sprite
	


func _physics_process(delta):
	var col: KinematicCollision2D = target.move_and_collide(delta * dir * dist / wait_time)
	if col:
		end_effect()


func end_effect():
	queue_free()
	target.input_lock = false


func _on_Dash_timeout():
	end_effect()


func _on_SilhouetteTimer_timeout():
	spawn_silhouette()


func spawn_silhouette():
	var s = silhouette_tscn.instance()
	s.init_animated_sprite(sprite)
	target.get_parent().add_child(s)


func get_animated_sprite_texture(s: AnimatedSprite) -> Texture:
	return s.frames.get_frame(s.animation, s.frame)
