extends Control


func _on_Button_pressed():
	$AudioButton.stream.loop = false
	$AudioButton.play()


func _on_AudioButton_finished():
	get_tree().change_scene("res://Scenes/Screens/TitleScreen.tscn")
