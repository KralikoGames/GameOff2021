extends Camera2D

"""

Intended Usage:

Drag and drop this script onto a Camera2D that is a child of the root.

To get the camera shake. Call the add_trauma(amount) from elsewhere.
	amount == a number between 0 and 1


"""

export var decay = 0.8  # How quickly the shaking stops [0, 1].
export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var target  # Assign the node this camera will follow.
export(float, 0, 1, 0.02) var max_trauma = 1  # max trauma

var zooming = 0.0
var zoom_vel = 0.0
var max_zoom = 0.2
var zoom_decay = 1.6
var zoom_factor = 0.28

var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].

onready var noise = OpenSimplexNoise.new()
var noise_y = 0

func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2


func _process(delta):
	if target:
		var t = get_node_or_null(target)
		if t:
			global_position = t.global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	if zooming:
		zooming = max(zooming - zoom_decay * delta, 0)
		do_zoom()


func add_zoom(amount):
	zooming = min(zooming+amount*zoom_factor, max_zoom)


func do_zoom():
	var amount = 1-pow(zooming, 2)
	zoom = Vector2(amount, amount)


func add_trauma(amount, max_t=1):
	trauma = min(trauma + amount, max_t)


func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)

