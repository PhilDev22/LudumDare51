extends Control

const cloud_path = preload("res://Scenes/Objects/Cloud.tscn")
var n_clouds = 50


func _ready():
	#yield(get_tree().create_timer(2), "timeout")
	#$Animations.play("Fade")
	#yield(get_tree().create_timer(5), "timeout")
	$Animations.play_backwards("Fade")
	yield(get_tree().create_timer(3), "timeout")
	get_clouds(n_clouds)

	# get_tree().change_scene("res://Scenes/Main.tscn")


func get_clouds(var n_clouds):
	var y_sort = YSort.new()
	get_parent().add_child(y_sort)
	for n in range(n_clouds):
		var cloud = cloud_path.instance()
		y_sort.add_child(cloud)
		cloud.move_out()
