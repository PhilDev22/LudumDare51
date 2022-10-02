extends Node


var tiles_horizontal = 27
var tiles_vertical = 15

var num_cells_x = int(tiles_horizontal / 2)
var num_cells_y = int(tiles_vertical / 2)

var tiles = [
	null,
	1,
	5,
	3,
	0,
	10,
	null,
	9,
	2,
	null,
	11,
	7,
	4,
	8,
	6,
	null
]

var cells = []
var wall_grid = []
var tileset_grid = []

var rng = null

export var swiss_cheese_factor = 0.15


# Called when the node enters the scene tree for the first time.
func _ready():
	# initialize cells with status (visited, wall_down, wall_right)
	# set to (false, true, true)
	cells = []
	for i in range(num_cells_x):
		cells.append([])
		for _j in range(num_cells_y):
			cells[i].append([false, true, true])
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	iterative_dfs()
	swiss_cheese()
	update_wall_grid()
	update_tileset_grid()
	update_tiles()
	
	get_node("/root/UI/Timer").connect("timeout", self, "change_maze")


func iterative_dfs():
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
	# initialize expanded cells with 100% walls + a ring of no walls
	wall_grid = []
	for i in range(num_cells_x * 2 + 3):
		wall_grid.push_back([])
		for j in range(num_cells_y * 2 + 3):
			if i == 0 or i == num_cells_x * 2 + 2 \
					or j == 0 or j == num_cells_y * 2 + 2:
				wall_grid[i].push_back(false)
			else:
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
	for x in range(len(tileset_grid)):
		for y in range(len(tileset_grid[0])):
			$TileMapWalls.set_cell(x, y, tiles[tileset_grid[x][y]])
	

func swiss_cheese():
	# try with random removal of a percentage of walls first
	for x in range(num_cells_x):
		for y in range(num_cells_y):
			if x < num_cells_x - 1 and cells[x][y][2] \
					and rng.randf() < swiss_cheese_factor:
				cells[x][y][2] = false
			if y < num_cells_y - 1 and cells[x][y][1] \
					and rng.randf() < swiss_cheese_factor:
				cells[x][y][1] = false
				

func change_maze():
	var players = $"TileMapWalls".get_children()
	if len(players) != 2:
		print(len(players))
		print("change maze called without players being present")
		return
	else:
		print("changing maze")

	
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
