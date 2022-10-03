extends Control

onready var tweenLabelGameOver = $TweenLabelGameOver
onready var tweenLabelTime = $TweenLabelTime
onready var tweenLabelTimePlayed = $TweenLabelTimePlayed

onready var LabelGameOver = $LabelGameOver
onready var LabelTime = $LabelTime
onready var LabelTimePlayed = $LabelTimePlayed

var level_base

var time_played = 0

func _ready():
	set_unvisible()
	

func connect_signals():
	level_base = get_node("/root/LevelBase")
	level_base.connect("game_over", self, "on_game_over")


func _process(delta):
	if self.visible and InputSystem.input_proceed:
		set_unvisible()
		# level_base.restart_game()
		get_tree().change_scene("res://Scenes/Screens/SelectionUI.tscn")


func set_unvisible():
	LabelGameOver.visible = false
	LabelTime.visible = false
	LabelTimePlayed.visible = false
	self.visible = false


func on_game_over(play_time):
	time_played = play_time

	
func animate_game_over_label():
	LabelGameOver.visible = true
	tweenLabelGameOver.interpolate_property(LabelGameOver, "margin_top",
			-500, 150, 0.4,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tweenLabelGameOver.start()


func animate_time_played_label(play_time):
	LabelTimePlayed.visible = true
	LabelTimePlayed.margin_top = 1500
	LabelTimePlayed.text =  "%.1f" % play_time
	tweenLabelTimePlayed.interpolate_property(LabelTimePlayed, "margin_top",
			1500, 452, 0.6,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	tweenLabelTimePlayed.start()
	
	
func animate_time_label():
	LabelTime.visible = true
	LabelTime.margin_top = 1500
	tweenLabelTime.interpolate_property(LabelTime, "margin_top",
			1500, 382, 0.6,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5)
	tweenLabelTime.start()
	

func _on_clouds_closed():
	self.visible = true
	animate_game_over_label()
	animate_time_label()
	animate_time_played_label(time_played)
