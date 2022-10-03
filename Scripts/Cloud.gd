extends Node2D


var pos_out = Vector2.ZERO
var pos_in = Vector2.ZERO
var animation_dur_in = 2.0  # duration of animation in sec
var animation_dur_out = 1.5  # duration of animation in sec
var cloud_size = rand_range(0.4, 0.5)
var offset = 200  # offset in px of clouds spanning outside screen

signal closed
signal finished

func _ready():
	# Select cloud sprite randomly
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var cloud_selection = rng.randi_range(0, 4)
	var sprites = [$Cloud1, $Cloud2, $Cloud3, $Cloud4, $Cloud5]
	sprites[cloud_selection].visible = true
	# Select cloud size randomly
	sprites[cloud_selection].scale = Vector2(cloud_size, cloud_size)


func move() -> void:
	var tween = get_node("Tween")

	var window_width = ProjectSettings.get_setting("display/window/size/width")

	var x_in = 0
	if pos_out[0] <= 0:
		x_in = pos_out[0] + window_width/2 + offset
	else:
		x_in = pos_out[0] - window_width/2 - offset
		
	pos_in = Vector2(x_in, pos_out[1])

	tween.interpolate_property(self, "global_position", pos_out, pos_in, animation_dur_in, Tween.TRANS_LINEAR)  # tween_property
	tween.start()


#func _on_Tween_tween_completed(object, key):
#	emit_signal("closed")
#	$Tween2.interpolate_property(self, "global_position", pos_in, pos_out, animation_dur_out, Tween.TRANS_LINEAR)  # tween_property
#	$Tween2.start()

func _on_Tween_tween_completed(object, key):
	emit_signal("closed")
	$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()
	$Tween2.interpolate_property(self, "global_position", pos_in, pos_out, animation_dur_out, Tween.TRANS_LINEAR)  # tween_property
	$Tween2.start()


func _on_Tween2_tween_completed(object, key):
	emit_signal("finished")
	queue_free()
