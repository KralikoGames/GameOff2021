extends TileMap


onready var tilemap: TileMap = get_parent() as TileMap


export(int, 2, 20) var light_radius: int = 10
export(int, 2, 15) var light_attenuation: int = 6


var last_player_map_pos: Vector2
var ts = []
var t_index: int = 0


func _ready():
	for _i in range(3): # kinda sorta makes it less glitchy
		var t = Tween.new()
		add_child(t)
		ts.append(t)
	
	yield(get_tree().root, "ready")
	GameInit.player.connect("moved", self, "_on_player_moved")
	
	_on_player_moved()
	

func set_tile_tween(v: Vector2, id: int):
	var t: Tween = ts[t_index]
	t.interpolate_method(self, "manual_set_cell", Vector3(v.x, v.y, get_cellv(v)), Vector3(v.x, v.y, id),
			 0.2)#, Tween.TRANS_QUART, Tween.EASE_OUT_IN)
	t.start()
	t_index = (t_index + 1) % ts.size()


func manual_set_cell(v: Vector3):
#	print(v)
	var cellv = Vector2(v.x, v.y)
	set_cellv(cellv, int(v.z))


func _on_player_moved():
	var new_pos: Vector2 = world_to_map(GameInit.player.global_position)
	if not last_player_map_pos: 
		flood_fill(new_pos)
	
	if new_pos.is_equal_approx(last_player_map_pos):
		return
	
	flood_fill(new_pos)
	
	


func flood_fill(map_pos: Vector2):
	last_player_map_pos = map_pos
	var cells = _flood_fill(map_pos, light_radius+light_attenuation+1)
	
	var black_fill_x: int = 18
	var black_fill_y: int = 11
	for i in range(-black_fill_x, black_fill_x):
		for j in range(-black_fill_y, black_fill_y):
			var cell: Vector2 = map_pos + Vector2(i,j)
			if not cell in cells:
				set_cellv(cell, 0) # make cell black
				continue
	
			var cell_map = cell
			var cell_dist = cells[cell]
			# 0 = black, 9 = clear
			if cell_dist < light_radius:
	#			set_cellv(cell_map, 9)
				set_tile_tween(cell_map, 9)
			else:
				var d = cell_dist - light_radius
				# map d from 0 -> light_attenuation-1 to 8->0
				var new_d: int = map(d, 0, light_attenuation-1, 8, 0) as int
				if new_d >= 0: # if its valid
	#				set_cellv(cell_map, new_d)
					set_tile_tween(cell_map, new_d)
				else:
	#				set_cellv(cell_map, 0)
					set_tile_tween(cell_map, 0)


func map(value: float, leftMin: float, leftMax: float, rightMin: float, rightMax: float):
#	// Figure out how 'wide' each range is
	var leftSpan: float = leftMax - leftMin;
	var rightSpan: float = rightMax - rightMin;

#	// Convert the left range into a 0-1 range (float)
	var valueScaled = float(value - leftMin) / float(leftSpan);

#	// Convert the 0-1 range into a value in the right range.
	return rightMin + (valueScaled * rightSpan);


const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
# Returns an array with all the coordinates of walkable cells based on the `max_distance`.

func _flood_fill(cell: Vector2, max_distance: int) -> Dictionary:
	# This is the array of walkable cells the algorithm outputs.
	var array := []
	var output := {}
	# The way we implemented the flood fill here is by using a stack. In that stack, we store every
	# cell we want to apply the flood fill algorithm to.
	var stack := [cell]
	var dist := [0]
	# We loop over cells in the stack, popping one cell on every loop iteration.
	while not stack.empty():
		var current = stack.pop_front()
		var distance: int = dist.pop_front()
		
		# For each cell, we ensure that we can fill further.
		#
		# The conditions are:
		# 2. We haven't already visited and filled this cell
		# 3. We are within the `max_distance`, a number of cells.
		if current in array:
			continue

		# This is where we check for the distance between the starting `cell` and the `current` one.
#		var difference: Vector2 = (current - cell).abs()
#		var distance := int(difference.x + difference.y)
#		if distance > max_distance:
#			continue
		if distance > max_distance:
			continue
		
		# If we meet all the conditions, we "fill" the `current` cell. To be more accurate, we store
		# it in our output `array` to later use them with the UnitPath and UnitOverlay classes.
		array.append(current)
#		output.append([current, distance])
		if current in output: push_warning("shit")
		output[current] = distance
		# We then look at the `current` cell's neighbors and, if they're not occupied and we haven't
		# visited them already, we add them to the stack for the next iteration.
		# This mechanism keeps the loop running until we found all cells the unit can walk.
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			# This is an "optimization". It does the same thing as our `if current in array:` above
			# but repeating it here with the neighbors skips some instructions.
			if tilemap.get_cellv(coordinates) >= 0: # if the tile is occupied by something.
				if not coordinates in array:
					array.append(coordinates)
#					output.append([coordinates, distance+1])
					if coordinates in output: push_warning("shit")
					output[coordinates] = distance + 1
				continue
			if coordinates in array:
				continue
			
			# This is where we extend the stack.
			stack.append(coordinates)
			dist.append(distance + 1)
	return output
