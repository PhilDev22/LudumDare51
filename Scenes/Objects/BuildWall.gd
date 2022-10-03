extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimatedSprite/Tween").connect("tween_all_completed", self, "_reset_build_animation")
	get_node("AudioStreamPlayer").play()
	get_node("AnimatedSprite").show()
	get_node("AnimatedSprite").play("BuildWall")
	get_node("AnimatedSprite/Tween").start()
	get_node("AnimatedSprite/Tween").interpolate_property(get_node("AnimatedSprite"), "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.8, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _reset_build_animation():
	print("Hallon Welt!")
	queue_free()
