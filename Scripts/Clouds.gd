extends Node2D


const cloud_path = preload("res://Scenes/Objects/Cloud.tscn")

var pos_x = []
var pos_y = []
var positions = get_grid()
var jitter = 15  # add jitter in range [-jitter, jitter] randomly to grid xy-positions


signal closed
signal finished

var disable_ui = true


func _ready():
	get_clouds(positions[0], positions[1])
	

func get_grid():
	var window_width = ProjectSettings.get_setting("display/window/size/width")
	var window_height = ProjectSettings.get_setting("display/window/size/height")
	var offset = 200  # offset in px of clouds spanning outside screen

	var step_size_y = 100  # difference in y positions
	var step_size_x = 120
	
	# get x pos on grid
	# left: 1280 + offset bis 1280 + offset + 640
	# right: 0 - offset - 640 bis 0 - offset
	var min_left = window_width + offset
	var max_left = window_width + offset + window_width/2
	var min_right = 0 - offset - window_width/2
	var max_right = 0 - offset
	
	var pos_x = []
	for x in range(min_right, max_right, step_size_x):
		pos_x.append(x)
	for x in range(min_left, max_left, step_size_x):
		pos_x.append(x)
	
	# get y pos on grid
	var vals_y = []
	var min_y = 0
	var max_y = window_height
	
	for y in range(min_y, max_y, step_size_y):
		pos_y.append(y)

	return [pos_x, pos_y]


func get_clouds(pos_x, pos_y):
	var y_sort = YSort.new()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	get_parent().add_child(y_sort)
	
	var connected = false
	for x in pos_x:
		for y in pos_y:
			var cloud = cloud_path.instance()
			if not connected:
				cloud.connect("closed", self, "_on_clouds_closed")
				cloud.connect("finished", self, "_on_clouds_finished")
				connected = true
			# jitter xy-position of cloud
			var jitter_val = rng.randi_range(-jitter, jitter)
			x += jitter_val
			y += jitter_val
			cloud.pos_out = Vector2(x, y)
			cloud.position = Vector2(x, y)
			y_sort.add_child(cloud)
			cloud.move()
	

func _on_clouds_closed():
	emit_signal("closed")
	if disable_ui:
		get_node("/root/UI").visible = false
	
	
func _on_clouds_finished():
	emit_signal("finished")
	if disable_ui:
		get_node("/root/UI").visible = true
	queue_free()
