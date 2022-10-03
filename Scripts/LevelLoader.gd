extends Node2D

signal game_over
signal game_started

var player0
var player1

const knubbel_path = preload("res://Scenes/Animations/Knubbel.tscn")
var knubbel_exists = false

var play_time = 0
var is_playing = false

func _ready():
	start_game()
	
func start_game():
	# TODO handle game start, set inital values, etc.
	print("Game starts")
	
	var spawn_points = $"SpawnPoints".get_children()
	
	# Instantiate player
	player0 = get_node("/root/LevelBase/Maze/TileMapWalls/Player")
	player0.connect("collision_with_player", self, "on_player_collision")
	player0.player_nr = 0
	player0.position = spawn_points[0].position
	
	player1 = get_node("/root/LevelBase/Maze/TileMapWalls/King")
	player1.connect("collision_with_player", self, "on_player_collision")
	player1.player_nr = 1
	player1.position = spawn_points[1].position
	player1.is_ai = false
	
	player0.other_player = player1
	player1.other_player = player0
	
	UI.connect_signals()
	
	play_time = 0
	is_playing = true
	
	emit_signal("game_started")
	
	
func restart_game():
	play_time = 0
	is_playing = true
	emit_signal("game_started")
	
func _process(delta):
	if is_playing:
		play_time += delta
	
	
func handle_game_over():
	
	is_playing = false
	
	# emit game over signal
	emit_signal("game_over", play_time)

	# disable inputs	
	
	# stop timer
	get_node("/root/UI/IngameUI/Timer").stop()
	
	# spawn game over animation
	if not knubbel_exists:
		var pos0 = player0.get_global_position()
		var pos1 = player1.get_global_position()
		var middle = pos0 + 0.5 * (pos1 - pos0)
		var knubbel = knubbel_path.instance()
		knubbel.position = middle
		add_child(knubbel)
		knubbel_exists = true
		
		# remove players
		player0.queue_free()
		player1.queue_free()
		
func on_player_collision():
	handle_game_over()
