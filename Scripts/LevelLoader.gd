extends Node2D

signal game_over

var player0
var player1

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
	player1.is_ai = true
	
	player0.other_player = player1
	player1.other_player = player0
	
	UI.connect_signals()

func handle_game_over():
	#TODO handle game over
	
	emit_signal("game_over")
	print("Game Over!")


func on_player_collision():
	handle_game_over()
