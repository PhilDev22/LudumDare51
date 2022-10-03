extends Control


const cloud_path = preload("res://Scenes/Objects/Clouds.tscn")


func _ready():
	get_node("/root/UI").visible = false

func _on_Button_pressed():
	var clouds = cloud_path.instance()
	clouds.connect("closed", self, "_on_clouds_closed")
	get_tree().root.add_child(clouds)


func _on_clouds_closed():
	get_tree().change_scene("res://Scenes/Main.tscn")


func _on_Button2_pressed():
	print("Button2")
