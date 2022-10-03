extends Control

signal character_selection_done

onready var label_player1 = $LabelPlayer1
onready var label_player2 = $LabelPlayer2
onready var label_player1ArrowLeft = $LabelPlayer1ArrowLeft
onready var label_player2ArrowLeft = $LabelPlayer2ArrowLeft
onready var label_player1ArrowRight = $LabelPlayer1ArrowRight
onready var label_player2ArrowRight = $LabelPlayer2ArrowRight
onready var audio_horse = $AudioHorse
onready var audio_scream = $AudioScream

var pos_center = 567
var pos_left = 410
var pos_right = 720

var player1_selection = 0 # -1 = Asterius, 1 = Theseus, 0 = none
var player2_selection = 0 # -1 = Asterius, 1 = Theseus, 0 = none

const cloud_path = preload("res://Scenes/Objects/Clouds.tscn")

var starting = false

func _ready():
	init()
	
# call this when screen is shown
func init():
	self.visible = true
	player1_selection = 0
	player2_selection = 0
	label_player1.rect_position.x = pos_center
	label_player2.rect_position.x = pos_center
	label_player1ArrowLeft.text = "<"
	label_player1ArrowRight.text = ">"
	label_player1ArrowLeft.text = "<"
	label_player1ArrowRight.text = ">"
	
func _process(delta):
	
	if starting:
		return
	
	if Input.is_action_just_pressed("ui_left"):
		shift_player1(-1)
	elif Input.is_action_just_pressed("ui_right"):
		shift_player1(1)	
	if Input.is_action_just_pressed("p2_ui_left"):
		shift_player2(-1)
	elif Input.is_action_just_pressed("p2_ui_right"):
		shift_player2(1)	
	if (Input.is_action_just_pressed("ui_accept") 
		or Input.is_action_just_pressed("ui_select")):
		check_start_game()
	
func check_start_game():
	if (player1_selection != 0 and player2_selection != 0
		and player1_selection != player2_selection):
		# player_selection: -1 = Asterius, 1 = Theseus
		emit_signal("character_selection_done", player1_selection, player2_selection)
		starting = true
		start_game()

func shift_player1(direction):
		
	if player1_selection == 0 and direction == -1 and player2_selection != -1:
		label_player1.rect_position.x = pos_left
		label_player1ArrowLeft.text = ">"
		label_player1ArrowRight.text = ""
		player1_selection = -1
		audio_horse.play()
	elif player1_selection == 0 and direction == 1 and player2_selection != 1:
		label_player1.rect_position.x = pos_right
		label_player1ArrowLeft.text = ""
		label_player1ArrowRight.text = "<"
		player1_selection = 1
		audio_scream.play()
	elif ((player1_selection == -1 and direction == 1)
		or (player1_selection == 1 and direction == -1)):
		label_player1.rect_position.x = pos_center
		label_player1ArrowLeft.text = "<"
		label_player1ArrowRight.text = ">"
		player1_selection = 0
	
func shift_player2(direction):
	
	if player2_selection == 0 and direction == -1 and player1_selection != -1:
		label_player2.rect_position.x = pos_left
		label_player2ArrowLeft.text = ">"
		label_player2ArrowRight.text = ""
		player2_selection = -1
		audio_horse.play()
	elif player2_selection == 0 and direction == 1 and player1_selection != 1:
		label_player2.rect_position.x = pos_right
		label_player2ArrowLeft.text = ""
		label_player2ArrowRight.text = "<"
		player2_selection = 1
		audio_scream.play()
	elif ((player2_selection == -1 and direction == 1)
		or (player2_selection == 1 and direction == -1)):
		label_player2.rect_position.x = pos_center
		label_player2ArrowLeft.text = "<"
		label_player2ArrowRight.text = ">"
		player2_selection = 0
	
func start_game():
	var clouds = cloud_path.instance()
	clouds.connect("closed", self, "_on_clouds_closed")
	get_tree().root.add_child(clouds)

func _on_clouds_closed():
	get_tree().change_scene("res://Scenes/Main.tscn")		
