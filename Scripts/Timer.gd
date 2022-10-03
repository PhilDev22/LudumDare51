extends Timer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var level_base

# Called when the node enters the scene tree for the first time.
func _ready():
	level_base = get_node("/root/LevelBase")
	level_base.connect("game_over", self, "on_game_over")
	level_base.connect("game_started", self, "on_game_started")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_parent().get_node("LabelCountDown").text = str(get_time_left()).substr(0, 3)


func on_game_started():
	self.wait_time = 10
	self.start()
	
	
func on_game_over(play_time):
	self.stop()
	self.wait_time = 10
	
