extends TileMap


onready var tilemap: TileMap = get_parent() as TileMap


export var light_radius: int = 12
export var light_attenuation: int = 5


var last_player_map_pos: Vector2


func _ready():
	yield(get_tree().root, "ready")
	GameInit.player.connect("moved", self, "_on_player_moved")


func _on_player_moved():
	var new_pos: Vector2 = world_to_map(GameInit.player.global_position)
	if not last_player_map_pos: 
		flood_fill(new_pos)
	
	if new_pos.is_equal_approx(last_player_map_pos):
		return
	
	flood_fill(new_pos)
	
	


func flood_fill(map_pos: Vector2):
	
	# fill the visible screen with black tiles.
	var black_fill: int = 15
	for i in range(-black_fill, black_fill):
		for j in range(-black_fill, black_fill):
			set_cellv(map_pos + Vector2(i,j), 0)
	
	last_player_map_pos = map_pos
	var cells = _flood_fill(map_pos, light_radius+light_attenuation+1)
#	print(cells)
	for cell in cells:
		var cell_map = cell[0]
		var cell_dist = cell[1]
		# 0 = black, 9 = clear
		if cell_dist < light_radius:
			set_cellv(cell_map, 9)
		else:
			var d = cell_dist - light_radius
			# map d from 0 -> light_attenuation-1 to 8->0
			var new_d: int = map(d, 0, light_attenuation-1, 8, 0) as int
			if new_d >= 0: # if its valid
				set_cellv(cell_map, new_d)
			else:
				set_cellv(cell_map, 0)


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
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	# This is the array of walkable cells the algorithm outputs.
	var array := []
	var output := []
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
		output.append([current, distance])
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
					output.append([coordinates, distance+1])
				continue
			if coordinates in array:
				continue
			
			# This is where we extend the stack.
			stack.append(coordinates)
			dist.append(distance + 1)
	return output
