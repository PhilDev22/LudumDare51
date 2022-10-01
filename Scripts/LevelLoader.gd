extends Node2D
export var player = "res://Scenes/Player/Player.tscn"


func _ready():
	instantiate_player(0)
	instantiate_player(1)


func instantiate_player(player_nr = 0):
	# This sets the player to appear at the correct area when loading into a new
	# zone
	var spawn_points = $"Non-InteractiveTerrain".get_children()
	var index = player_nr

	# If we somehow don't have that spawn point, fall back to 0
	if not spawn_points[player_nr]:
		index = 0


	# Spawn the player and add to scene
	var player_spawn = load(player).instance()
	player_spawn.player_nr = player_nr
	
	$InteractiveTerrain.add_child(player_spawn)
	# Set player at the correct position (spawn point of zone)
	player_spawn.position = spawn_points[index].position
