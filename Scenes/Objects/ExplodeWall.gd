extends Node2D


func _ready():
	get_node("AnimatedSprite/Tween").connect("tween_all_completed", self, "_reset_explode_animation")
	get_node("AnimatedSprite/Tween").interpolate_property(get_node("AnimatedSprite"), "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.8, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("AnimatedSprite/Tween").start()


func play():
	get_node("AudioStreamPlayer").play()
	get_node("AnimatedSprite").show()
	get_node("AnimatedSprite").play("ExplodeWall")


func _reset_explode_animation():
	queue_free()
