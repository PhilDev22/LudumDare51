extends Node


var tiles_horizontal = 25
var tiles_vertical = 13

var num_cells_x = int(tiles_horizontal / 2)
var num_cells_y = int(tiles_vertical / 2)

var cells = []

var rng = null

export var swiss_cheese_factor = 0.1

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
	print_maze()
	swiss_cheese()
	print_maze()

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
			
func kruskal_fix():
	# determine sets
	pass


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
	var top_row = ""
	for _i in range(num_cells_x * 2 + 1):
		top_row += "x"
	print(top_row)
	
	for i in range(num_cells_y):
		var row = "x"
		var under_row = "x"
		for j in range(num_cells_x):
			if cells[j][i][0]:
				row += "."
			else:
				row += " "
			if cells[j][i][2]:
				row += "x"
			else:
				row += " "
			if cells[j][i][1]:
				under_row += "xx"
			else:
				under_row += " x"
		print(row)
		print(under_row)
