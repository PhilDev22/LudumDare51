extends Node2D
export var player = "res://Scenes/Player/Player.tscn"

signal game_over

var player0
var player1

func _ready():
	start_game()
	
func start_game():
	# TODO handle game start, set inital values, etc.
	print("Game starts")
	
	# Instantiate player
	player0 = instantiate_player(0)
	player1 = instantiate_player(1)
	player0.connect("collision_with_player", self, "on_player_collision")
	player1.connect("collision_with_player", self, "on_player_collision")
	
	UI.connect_signals()

func instantiate_player(player_nr = 0):
	# This sets the player to appear at the correct area when loading into a new
	# zone
	var spawn_points = $"SpawnPoints".get_children()
	var index = player_nr

	# If we somehow don't have that spawn point, fall back to 0
	if not spawn_points[player_nr]:
		index = 0


	# Spawn the player and add to scene
	var player_spawn = load(player).instance()
	player_spawn.player_nr = player_nr
	
	$"Maze/TileMapWalls".add_child(player_spawn)
	# Set player at the correct position (spawn point of zone)
	player_spawn.position = spawn_points[index].position
	
	return player_spawn


func handle_game_over():
	#TODO handle game over
	
	emit_signal("game_over")
	print("Game Over!")


func on_player_collision():
	handle_game_over()
