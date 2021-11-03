extends KinematicBody2D


signal direction_reversed


export var speed: float = 300
export var damage: float = 30


var creator: Node2D
var dir_reversed = false


const speed_decay: float = 300.0



func init(source: Node2D, procedural:bool=false):
	creator = source
	if not procedural:
		_trishot()
	


func _physics_process(delta):
	if speed < 0 and creator: # home in on the player
		if not dir_reversed:
			dir_reversed = true
			emit_signal("direction_reversed")
		
		rotation = global_position.angle_to_point(creator.global_position)
		if global_position.distance_squared_to(creator.global_position) < 150:
			die()
	
	var vel = Vector2(1,0).rotated(rotation) * speed
	speed -= speed_decay * delta
	
	move_and_slide(vel)


func _trishot():
	if GameInit.skilltree.passives["Tri_Shot"].points > 0:
		print("Tri Shot enabled")
		for i in [-1,1]:
			var attack_tscn = load(filename)
			var attack = attack_tscn.instance()
			attack.global_position = global_position
			attack.global_rotation = global_rotation + deg2rad(GameInit.trishot_angle * i)
			get_parent().add_child(attack)
			
			attack.init(creator, true)


func die():
	queue_free()


func _on_DeathTimer_timeout():
	die()
