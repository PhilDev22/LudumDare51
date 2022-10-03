extends Control

# onready var button_sound = $AudioButton 


func _ready():
	get_node("/root/UI").visible = false


func _on_Button_pressed():
	$AudioButton.stream.loop = false
	$AudioButton.play()


func _on_Button2_pressed():
	$AudioButton2.stream.loop = false
	$AudioButton2.play()


func _on_AudioButton_finished():
	get_tree().change_scene("res://Scenes/Screens/SelectionUI.tscn")


func _on_AudioButton2_finished():
	get_tree().change_scene("res://Scenes/Screens/Tutorial.tscn")
