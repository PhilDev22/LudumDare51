extends Control

const cloud_path = preload("res://Scenes/Objects/Cloud.tscn")
var n_clouds = 50


func _on_Button_pressed():
	get_clouds(n_clouds)
#	get_tree().change_scene("res://Scenes/Main.tscn")


func get_clouds(var n_clouds):
	var y_sort = YSort.new()
	get_parent().add_child(y_sort)
	for n in range(n_clouds):
		var cloud = cloud_path.instance()
		cloud.target_pos = Vector2(0, 0)
		y_sort.add_child(cloud)
		cloud.move()
