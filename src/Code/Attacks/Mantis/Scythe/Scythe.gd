extends KinematicBody2D


signal direction_reversed


export var speed: float = 380
export var damage: float = 30
export var input_lock: float = 0.25


var creator: Node2D
var dir_reversed = false


const speed_decay: float = 640.0

func get_class(): return "Spinning_Scythe"


func _ready():
	$Sprite.playing = true


func init(source: Node2D, procedural:bool=false):
	creator = source
	_massive_scythes()
	if not procedural:
		_trishot()
	


func _physics_process(delta):
	var vel = Vector2(1,0).rotated(rotation) * speed
	speed -= speed_decay * delta
	
	if speed < 0 and creator: # home in on the player
		if not dir_reversed:
			dir_reversed = true
			_spawn_blood_explosion()
			emit_signal("direction_reversed")
		
		rotation = global_position.angle_to_point(creator.global_position)
		if _close_to_player():
			die()
		move_and_slide(vel)
		_die_if_colliding_with_wall_for_duration()
	else: # forward motion
		move_and_slide(vel)


func _die_if_colliding_with_wall_for_duration():
	if get_slide_count() == 0 and not $WallHitTimer.is_stopped(): 
		$WallHitTimer.stop()
	elif $WallHitTimer.is_stopped(): 
		$WallHitTimer.start()


func _close_to_player() -> bool:
	return global_position.distance_squared_to(creator.global_position) < 150


func _trishot():
	var attack_tscn = load(filename)
	var angs = [-1,1,-2,2,-3,3,-4,4,-5,5,-6,6,-7,7,-8,8,-9,9]
	for point_i in range(GameInit.skilltree.passives["Tri_Shot"].points):
		var i = angs[point_i % angs.size()]
		var attack = attack_tscn.instance()
		attack.global_position = global_position
		attack.global_rotation = global_rotation + deg2rad(GameInit.trishot_angle * i)
		get_parent().add_child(attack)
		
		attack.init(creator, true)


func _massive_scythes():
	if GameInit.skilltree.passives["Massive_Scythes"].points > 0:
		scale *= 1 + GameInit.massive_scythe_multiplier * GameInit.skilltree.passives["Massive_Scythes"].points


func _spawn_blood_explosion():
	if GameInit.skilltree.passives["Blood_Explosion"].points > 0:
		var b = GameInit.blood_explosion_tscn.instance()
		b.global_position = global_position
		b.scale *= 1 + GameInit.blood_explosion_size_multiplier * GameInit.skilltree.passives["Blood_Explosion"].points
		get_parent().add_child(b)


func die():
	queue_free()


func _on_DeathTimer_timeout():
	die()


func _on_WallHitTimer_timeout():
	die()
