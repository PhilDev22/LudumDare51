extends Node

var input_direction
var input_direction_p2
var input_activation
var input_activation_p2

var second_player_input_prefix = "p2_"

func _ready():
	# Do not disable this when game is paused
	set_pause_mode(PAUSE_MODE_PROCESS)

func _process(delta):
	input_direction = get_input_direction(0)
	input_activation = get_input_activation(0)
	input_direction_p2 = get_input_direction(1)
	input_activation_p2 = get_input_activation(1)

func get_input_direction(var player = 0):
	var prefix = second_player_input_prefix if player == 1 else ""
	var horizontal = int(Input.is_action_pressed(prefix + "ui_right")) - int(Input.is_action_pressed(prefix + "ui_left"))
	var vertical = int(Input.is_action_pressed(prefix +"ui_down")) - int(Input.is_action_pressed(prefix + "ui_up"))
	return Vector2(horizontal, vertical if horizontal == 0 else 0)

func get_input_activation(var player = 0):
	var prefix = second_player_input_prefix if player == 1 else ""
	return Input.is_action_just_pressed(prefix + "ui_accept")



# Extremely useful for things like stopping "interact" from looping
# E.G. actor displays dialog, "interact" is the same button that closes dialog
# It would also, on the same frame, trigger interact again
func neutralize_inputs():
	input_direction = null
	input_activation = null
	input_direction_p2 = null
	input_activation_p2 = null

# Give other systems the ability to disable ALL input until a given trigger
# Useful for things like letting menu animations or scene transitions finish
func disable_input_until(wait_for_this_object, to_finish_this):
	neutralize_inputs()
	set_process(false)
	yield(wait_for_this_object, to_finish_this)
	set_process(true)


# Just for "game over"
func disable_input():
	neutralize_inputs()
	set_process(false)
