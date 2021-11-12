extends Area2D
tool


export(String, "rect", "circle", "cone") var shape: String = "cone" setget _set_shape
export(float, 0.0, 3.0, 0.02) var wait_time: float = 1.0
export(float) var damage_amt: float = 1.0
export(float) var knockback_amt: float = 1.0
export var use_ground_effect_knockback = true

var knockback_dir = Vector2()

func _ready():
	if Engine.editor_hint: return
	$Tween.connect("tween_all_completed", self, "deal_damage")
	$Tween.interpolate_method(self, "set_perc_dist", 0.0, 1.0, wait_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()


func set_perc_dist(dist: float):
	material.set_shader_param("perc_dist", dist)


func deal_damage():
	for a in get_overlapping_bodies():
		var b: Player = a as Player
		if b:
			if(use_ground_effect_knockback):
				knockback_dir = (b.global_position - global_position)
				
			b.damage(damage_amt, knockback_dir.normalized(), knockback_amt)
	queue_free()


func _process(_delta):
	update()


func _draw():
	# note the other draw functions may not work with shaders
	draw_rect(Rect2(Vector2(-5 if shape=="circle" else 0, -5), Vector2(10,10)), Color.red) 


func _set_shape(v):
	shape = v
	material.set_shader_param("circle", shape=="circle")
	material.set_shader_param("cone", shape=="cone")
	material.set_shader_param("rect", shape=="rect")
	
	_helper("circle")
	_helper("cone")
	_helper("rect")
			

func _helper(s:String="circle"):
	var colshape = get_node_or_null("%s_shape" % s)
	if colshape:
		colshape.set_deferred("disabled", shape!=s)
#		var __ = colshape.hide() if shape!=s else colshape.show()
