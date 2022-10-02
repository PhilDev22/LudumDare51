extends Node2D


func _ready():
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
		move_out()


func move_out() -> void:
	var tween := create_tween()
	
	randomize()  # activate random numbers
	var start_x = rand_range(0, 1280)
	var start_y = rand_range(0, 720)
	global_position = Vector2(start_x, start_y)  # change position of sprite

	var final_x = 0	
	var final_pos = Vector2(final_x, start_y)
	if start_x > 640:
		final_x = 1500
	else:
		final_x = -200
	final_pos = Vector2(final_x, start_y)

	var animation_dur = 3.0  # duration of animation in sec
	# Object to animate = self (sprite which the script is attached to), global position of sprite, final value, animation duration
	tween.tween_property(self, "global_position", final_pos, animation_dur) 
