extends Node


var tiles_horizontal = 27
var tiles_vertical = 15

var num_cells_x = int(tiles_horizontal / 2)
var num_cells_y = int(tiles_vertical / 2)

# map internal logic to tilemap indices (-1 is unset)
var tiles = [
	-1,
	1,
	3,
	4,
	0,
	10,
	12,
	9,
	2,
	13,
	11,
	7,
	5,
	8,
	6,
	14
]

# cells for the maze generation logic. each cell has booleans for visited, wall
# to cell below, wall to cell on the right
var cells = []

# grid containing boolean for wall yes/no in each cell
var wall_grid = []

# grid containing the necessary tiles to represent the walls
# (half tile offset to wall grid in both directions)
var tileset_grid = []

var rng = null

# percentage of walls that will be removed after maze generation is completed
# only removes walls between maze cells, so they always create new connections
export var swiss_cheese_factor = 0.15

const build_animation_path = preload("res://Scenes/Objects/BuildWall.tscn")
const destroy_animation_path = preload("res://Scenes/Objects/ExplodeWall.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize RNG
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# calculate maze for the first time, update all corresponding data
	# structures and the TileMap
	reset_cells()
	iterative_dfs()
	swiss_cheese()
	update_wall_grid()
	update_tileset_grid()
	update_tiles()
	
	# connect the ten second timer to the maze change method
	# warning-ignore:return_value_discarded
	get_node("/root/LevelBase/Timer").connect("timeout", self, "change_maze")
	

func _on_destroy(position, velocity):
	# is called when a projectile hits a wall. calculates position in wall grid,
	# removes wall if possible and updates the tileset
	
	# upward shots have collisions slightly below the correct wall grid tile
	# due to the hitboxes of the tilemap
	if velocity.y < 0:
		position -= Vector2(0, 24)

	var wall_index = global_position_to_wall_grid(position)
	
	if remove_wall_from_grid_if_allowed(wall_index):
		var animation_position = wall_grid_to_local_position(wall_index)
		var destroy_animation = destroy_animation_path.instance()
		destroy_animation.position = animation_position
		destroy_animation.play()
		add_child(destroy_animation)
	
	update_tileset_grid()
	update_tiles()
	
	
func _on_build(player_nr, position, direction_player):
	# is called when a player pushes the build button. calculates position in
	# wall grid, places wall if possible and updates the tileset
	
	var grid_vec = global_position_to_wall_grid(position) - direction_player.normalized()
	if add_wall_to_grid_if_allowed(grid_vec):
		var animation_position = wall_grid_to_local_position(grid_vec)
		var build_animation = build_animation_path.instance()
		build_animation.position = animation_position
		build_animation.play()
		add_child(build_animation)
	
	update_tileset_grid()
	update_tiles()
	

func reset_cells():
	# initialize cells with status (visited, wall_down, wall_right)
	# set to (false, true, true)
	cells = []
	for i in range(num_cells_x):
		cells.append([])
		for _j in range(num_cells_y):
			cells[i].append([false, true, true])


func iterative_dfs():
	# generate a maze using randomized depth first search. this creates a
	# minimum spanning tree, guaranteeing a perfect maze (no loops, one way
	# between start and finish)
	
	# stack to prevent maximum recursion depth for large grids
	var stack = []
	# start with random cell, mark as visited and push to stack
	var x = rng.randi_range(0, num_cells_x - 1)
	var y = rng.randi_range(0, num_cells_y - 1)
	mark_visited(x, y)
	stack.push_back([x, y])
	
	var cell = []
	while not stack.empty():
		# pop last cell
		cell = stack.pop_back()
		x = cell[0]
		y = cell[1]
		var neighbors = unvisited_neighbors(x, y)
		# if there are unvisited neighbors push current cell back to stack,
		# choose random unvisited neighbor as new cell, remove the wall between
		# the two, mark new cell as visited and push it to the stack
		if not neighbors.empty():
			stack.push_back([x, y])
			# choose random unvisited neighbor
			var neighbor = neighbors[rng.randi_range(0, len(neighbors) - 1)]
			var x_n = neighbor[0]
			var y_n = neighbor[1]
			remove_wall(x, y, x_n, y_n)
			mark_visited(x_n, y_n)
			stack.push_back([x_n, y_n])


func update_wall_grid():
	# update the wall_grid using the cells array
	# initialize expanded cells with a double ring of only walls
	wall_grid = []
	for i in range(num_cells_x * 2 + 3):
		wall_grid.push_back([])
		for j in range(num_cells_y * 2 + 3):
			wall_grid[i].push_back(true)
			
	# transfer information from cells to expanded cells
	var x_exp = 2
	var y_exp = 2
	for x in range(num_cells_x):
		x_exp = x * 2 + 2
		for y in range(num_cells_y):
			y_exp = y * 2 + 2
			# cell itself is never wall
			wall_grid[x_exp][y_exp] = false
			wall_grid[x_exp][y_exp + 1] = cells[x][y][1]
			wall_grid[x_exp + 1][y_exp] = cells[x][y][2]

		
func update_tileset_grid():
	# update the tileset_grid using the wall_grid
	tileset_grid = []
	
	var top_left = 0
	var bot_left = 0
	var top_right = 0
	var bot_right = 0
	
	for x in range(len(wall_grid) - 1):
		tileset_grid.push_back([])
		for y in range(len(wall_grid[0]) - 1):
			top_left = int(wall_grid[x][y])
			bot_left = int(wall_grid[x][y + 1]) * 2
			top_right = int(wall_grid[x + 1][y]) * 4
			bot_right = int(wall_grid[x + 1][y + 1]) * 8
			tileset_grid[x].push_back(top_left + bot_left + top_right + bot_right)
			

func update_tiles():
	# update the tiles using the tileset_grid
	for x in range(len(tileset_grid)):
		for y in range(len(tileset_grid[0])):
			$TileMapWalls.set_cell(x, y, tiles[tileset_grid[x][y]])
	

func swiss_cheese():
	# remove random connections in cells. using cells instead of wall_grid
	# guarantees that removing the wall actually creates a new usable connection
	
	for x in range(num_cells_x):
		for y in range(num_cells_y):
			if x < num_cells_x - 1 and cells[x][y][2] \
					and rng.randf() < swiss_cheese_factor:
				cells[x][y][2] = false
			if y < num_cells_y - 1 and cells[x][y][1] \
					and rng.randf() < swiss_cheese_factor:
				cells[x][y][1] = false
				

func change_maze():
	# create a new maze but remove walls where players are standing
	reset_cells()
	iterative_dfs()
	swiss_cheese()
	update_wall_grid()
	
	# calc player position and remove respective tiles
	for grid_vec in get_player_wall_grid_indices():
		remove_wall_from_grid_if_allowed(grid_vec)
			
	update_tileset_grid()
	update_tiles()
	
	
func get_player_wall_grid_indices(smaller_extent=1):
	# calculate cells in the wall_grid that are occupied by the two players
	# Uses a rectangle that is 2 * "smaller_extent" smaller than the actual
	# player hitbox in width and length to allow for small overlaps
	
	var indices = []
	
	var players = $"TileMapWalls".get_children()
	# calc player position
	for player in players:
		var coll = player.get_node("CollisionShape2D")
		var pos = coll.position + player.get_global_position()
		# substract one from extends to account for "near" collisions
		var ext = coll.get_shape().extents - Vector2.ONE * smaller_extent
		var corners = [
			pos - ext,
			pos + ext,
			pos + ext.reflect(Vector2(1, 0)),
			pos + ext.reflect(Vector2(0, 1))
		]
		for corner in corners:
			var grid_vec = global_position_to_wall_grid(corner)
			indices.push_back(grid_vec)
			
	return indices

	
func remove_wall_from_grid_if_allowed(index_vec: Vector2):
	# check if fixed sidewall or no wall. return true if a wall was deleted
	var x = int(index_vec.x)
	var y = int(index_vec.y)
	if x <= 1 or x >= len(wall_grid) - 2 \
			or y <= 1 or y >= len(wall_grid[0]) - 2 \
			or not wall_grid[x][y]:
		return false

	wall_grid[x][y] = false
	return true
		

func add_wall_to_grid_if_allowed(index_vec: Vector2):
	# check if wall present or player on wall. return true if a wall was placed
	var x = int(index_vec.x)
	var y = int(index_vec.y)
	if wall_grid[x][y]:
		return false
	# don't use atm, too restrictive
#	if index_vec in get_player_wall_grid_indices(15):
#		return false
		
	wall_grid[x][y] = true
	return true


func global_position_to_wall_grid(pos: Vector2):
#	print("global: " + str(pos))
	# move global pos vector into TileMap's local space
	pos = pos - $TileMapWalls.get_global_position()
#	print("tilemap: " + str(pos))
	# move local pos into wall grid's local space (half tile offset)
	pos += $TileMapWalls.cell_size * 0.5
#	print("wallgrid: " + str(pos))
	# calculate corresponding grid cell
	pos = (pos / $TileMapWalls.cell_size).floor()
#	print("wall index: " + str(grid_pos))
	
	return pos
	

func wall_grid_to_local_position(grid_vec: Vector2):
	var pos = grid_vec * $TileMapWalls.cell_size
	# pos -= $TileMapWalls.cell_size * 0.5
	pos += $TileMapWalls.get_global_position()
	return pos

	
func remove_wall(x1, y1, x2, y2):
	# assumes both cells are indeed neighbors
	if x1 < x2:
		cells[x1][y1][2] = false
		return
	if x2 < x1:
		cells[x2][y2][2] = false
		return
	if y1 < y2:
		cells[x1][y1][1] = false
		return
	if y2 < y1:
		cells[x2][y2][1] = false
		return


func unvisited_neighbors(x, y):
	var neighbors = []
	# left and right
	for x_n in [x - 1, x + 1]:
		# check for out of bounds
		if x_n < 0 or x_n == num_cells_x:
			continue
		if not cells[x_n][y][0]:
			neighbors.push_back([x_n, y])
	
	# upper and lower
	for y_n in [y - 1, y +1]:
		# check for out of bounds
		if y_n < 0 or y_n == num_cells_y:
			continue
		if not cells[x][y_n][0]:
			neighbors.push_back([x, y_n])
	
	return neighbors


func mark_visited(x, y):
	cells[x][y][0] = true


func print_maze():
	var s = ""
	for y in range(len(wall_grid[0])):
		s = ""
		for x in range(len(wall_grid)):
			s += "x" if wall_grid[x][y] else " "
		print(s)
