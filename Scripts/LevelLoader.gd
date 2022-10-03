extends Node2D

signal game_over
signal game_started

var player0
var player1
var ingame_ui

const clouds_path = preload("res://Scenes/Objects/Clouds.tscn")

const knubbel_path = preload("res://Scenes/Animations/Knubbel.tscn")
var knubbel_exists = false
var knubbel
var spawn_points

var play_time = 0
var is_playing = false

func _ready():
	start_game()
	
func start_game():
	# TODO handle game start, set inital values, etc.
	print("Game starts")
	
	spawn_points = $"SpawnPoints".get_children()
	ingame_ui = get_node("/root/UI/IngameUI")
	
	# Instantiate player
	player0 = get_node("/root/LevelBase/Maze/TileMapWalls/Player")
	player0.connect("collision_with_player", self, "on_player_collision")
	player0.player_nr = get_node("/root/GameData").asterius_player_nr
	
	player1 = get_node("/root/LevelBase/Maze/TileMapWalls/King")
	player1.connect("collision_with_player", self, "on_player_collision")
	player1.player_nr = get_node("/root/GameData").theseus_player_nr
	player1.is_ai = false
	
	player0.other_player = player1
	player1.other_player = player0
	
	UI.connect_signals()
	
	restart_game()
	
func restart_game():
	if knubbel_exists:
		knubbel.queue_free()
	knubbel_exists = false
	player0.visible = true
	player1.visible = true
	player0.position = spawn_points[0].position
	player1.position = spawn_points[1].position
	play_time = 0
	is_playing = true
	ingame_ui.visible = true
	emit_signal("game_started")
	
func _process(delta):
	if is_playing:
		play_time += delta
	
	
func handle_game_over():
	
	is_playing = false
	
	# emit game over signal
	emit_signal("game_over", play_time)

	# stop timer
	get_node("Timer").stop()
	
	# spawn game over animation
	var pos0 = player0.get_global_position()
	var pos1 = player1.get_global_position()
	var middle = pos0 + 0.5 * (pos1 - pos0)
	knubbel = knubbel_path.instance()
	knubbel.position = middle
	add_child(knubbel)
	knubbel_exists = true
	
	# spawn clouds
	var clouds = clouds_path.instance()
	clouds.disable_ui = false
	clouds.connect("closed", get_node("/root/UI/GameOverUI"), "_on_clouds_closed")
	clouds.connect("closed", self, "_on_clouds_closed")
	get_node("/root/UI").add_child(clouds)
	
	# remove players
	player0.visible = false
	player1.visible = false
	
	ingame_ui.visible = false


func _on_clouds_closed():
	knubbel.get_node("AnimatedSprite").playing = false
	knubbel.queue_free()
	knubbel_exists = false


func on_player_collision():
	handle_game_over()
