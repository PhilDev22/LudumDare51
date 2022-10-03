extends Control


func _ready():
	get_node("/root/UI").visible = false

func _on_Button_pressed():
	get_tree().change_scene("res://Scenes/Screens/SelectionUI.tscn")

func _on_Button2_pressed():
	get_tree().change_scene("res://Scenes/Screens/Tutorial.tscn")
