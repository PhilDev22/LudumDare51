extends Tween


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#print("this function is running")
	self.interpolate_property(get_parent(), "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.5, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	self.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
