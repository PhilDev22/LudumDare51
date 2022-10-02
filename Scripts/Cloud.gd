extends Node2D

var target_pos = Vector2(0, 0)
var pos_in = Vector2.ZERO
var pos_out = Vector2.ZERO
var animation_dur = 2.0  # duration of animation in sec

func _ready():
#	$Tween.connect("tween_all_completed", $Timer, "start", [2])
#	$Timer.connect("timeout", self, "move_out")
	
	# Select cloud sprite randomly
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var cloud_selection = rng.randi_range(0, 4)
	var sprites = [$Cloud1, $Cloud2, $Cloud3, $Cloud4, $Cloud5]
	sprites[cloud_selection].visible = true
	# Select cloud size randomly
	var cloud_size = rand_range(0.2, 0.25)
	sprites[cloud_selection].scale = Vector2(cloud_size, cloud_size)


func _process(delta):
	if Input.is_action_just_pressed("build"):
		var n_clouds = 50
		get_grid(n_clouds)


func get_grid(var n_clouds):
	var window_width = 1280
	var window_height = 720
	var offset = 20  # offset in px of clouds spanning outside screen
	var jitter = 5  # add jitter in range [-jitter, jitter] randomly to grid xy-positions
	var pos_x = []
	var pos_y = []
	
	# get x pos on grid
	# left: 1280 + offset bis 1280 + offset + 640
	# right: 0 - offset - 640 bis 0 - offset
	var min_left = window_width + offset
	var max_left = window_width + offset + window_width/2
	var min_right = 0 - offset - window_width/2
	var max_right = 0 - offset
	var step_size = ceil(float(max_right - min_right) / (n_clouds/2))
	
	for x in range(min_right, max_right, step_size):
		pos_x.append(x)
	for x in range(min_left, max_left, step_size):
		pos_x.append(x)
	
	var pos_x_jittered = []
	for x in pos_x:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var x_jitter = rng.randi_range(-jitter, jitter)
		pos_x_jittered.append(x + x_jitter)
		
	# get y pos on grid
	var min_y = 0
	var max_y = window_height
	var step_size_y = int(float(max_y - min_y) / (n_clouds))

	for y in range(min_y, max_y, step_size_y):
		pos_y.append(y)
	
	var pos_y_jittered = []
	for y in pos_y:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var y_jitter = rng.randi_range(-jitter, jitter)
		pos_y_jittered.append(y + y_jitter)
	
	# crop xy-positions to number of clouds
	pos_y_jittered = pos_y_jittered.slice(0, n_clouds-1)
	pos_x_jittered = pos_x_jittered.slice(0, n_clouds-1)


func move() -> void:
#	var tween := create_tween()
#	var tween = Tween.new()
#	var tween = $Tween
	var tween = get_node("Tween")
	
	var x_start = 0
	var x_move_in = 0
	var x_move_out = 0
	var y = rand_range(0, 720)
	var window_width = 1280
	var offset = 20  # offset in px of clouds spanning outside screen
	var cloud_stay_dur = 0.2  # duration of still clouds in screen
	
	# choose if cloud enters from left / right
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var cloud_selection = rng.randi_range(0, 1)
	randomize()  # activate random numbers
	if cloud_selection == 0:
		x_start = rand_range(-window_width/2-offset, 0-offset)
	else:
		x_start = rand_range(window_width+offset, window_width+(window_width/2)+offset)

	global_position = Vector2(x_start, y)  # change position of sprite
	pos_out = Vector2(x_start, y)

	# get positions of clouds in screen
	pos_in = Vector2(x_move_in, y)
	if x_start <= 0:
		x_move_in = x_start + window_width/2 + offset
	else:
		x_move_in = x_start - window_width/2 - offset
	pos_in = Vector2(x_move_in, y)

	# Object to animate = self (sprite which the script is attached to), global position of sprite, final value, animation duration
	tween.interpolate_property(self, "global_position", pos_out, pos_in, animation_dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)  # tween_property
	tween.start()
	
#	var tween2 = get_node("Tween2")

	
	# print(global_position, pos_in)

	# tween.interpolate_property(self, "global_position", pos_out, animation_dur, Tween.TRANS_LINEAR, Tween.EASE_IN) 
	
#	tween.connect("tween_all_completed", $Timer, "start", [2])
#


#
#	var timer := create_tween()
#	timer.interpolate_callback(self, 1, "queue_free")
#	timer.start()

#	print("start")
#	yield(get_tree().create_timer(animation_dur+cloud_stay_dur+1), "timeout")
#	print("end")

#	var timer = Timer.new()
#	add_child(timer)
#	timer.autostart = false
#	timer.one_shot = true
#	timer.wait_time = animation_dur+cloud_stay_dur+1

func move_out(pos_out):
	print("move_out")
#	var tween := create_tween()
#	tween.tween_property(self, "global_position", pos_out, animation_dur) 


func _on_Tween_tween_completed(object, key):
	$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()
	get_tree().change_scene("res://Scenes/Main.tscn")
	$Tween2.interpolate_property(self, "global_position", pos_in, pos_out, animation_dur, Tween.TRANS_LINEAR, Tween.EASE_OUT)  # tween_property
	$Tween2.start()
