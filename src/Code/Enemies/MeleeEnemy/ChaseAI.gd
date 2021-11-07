extends Node2D

export var associatedAnimation = ""
export var distanceToTarget = 0
export var attack_range = 0
export var finishOnRangeEnter = true

onready var body = get_parent()

var target : Node2D setget set_target

signal changeAnimation
signal onEnterAttackRange
signal onStartChase

func _process(delta):
	chase(delta)

func set_target(t: Node2D):
	target = t
	if(t!=null):
		emit_signal("OnChaseStart")

func chase(delta):
	if(target != null):
		_chaseAnimation()
		body.move_dir = _get_dir_to_target(target) # _get_input_dir() if not is_dead else Vector2()
		distanceToTarget = global_position.distance_to(target.global_position);
		if(distanceToTarget < attack_range):
			emit_signal("onEnterAttackRange", target)
			if(finishOnRangeEnter):
				target = null
	else:
		body.move_dir = Vector2.ZERO

func _get_dir_to_target(target: Node2D) -> Vector2:
	if target:
		var t = (target.global_position - global_position)
		if t.length() < 10: return Vector2()
		return t.normalized()
	return Vector2()


func _chaseAnimation():
	emit_signal("changeAnimation", associatedAnimation)
	
	
