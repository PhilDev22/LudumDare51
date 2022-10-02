extends CanvasLayer

onready var ability_shoot_p0 = $IngameUI/AbilityShootPlayer1
onready var ability_build_p0 = $IngameUI/AbilityBuildPlayer1
onready var ability_shoot_p1 = $IngameUI/AbilityShootPlayer2
onready var ability_build_p1 = $IngameUI/AbilityBuildPlayer2

func _ready():
	ability_shoot_p0.get_node("CooldownRect").visible = false
	ability_shoot_p1.get_node("CooldownRect").visible = false
	ability_build_p0.get_node("CooldownRect").visible = false
	ability_build_p1.get_node("CooldownRect").visible = false
	
func connect_signals():
	var players = get_node("/root/LevelBase/Maze/TileMapWalls").get_children()
	
	for i in players.size():
		players[i].connect("action_destroy", self, "on_ability_shoot_used")
		players[i].connect("action_build", self, "on_ability_build_used")
		players[i].get_node("TimerShoot").connect("timeout", self, "on_timer_shoot_timeout_p"+ str(i))
		players[i].get_node("TimerBuild").connect("timeout", self, "on_timer_build_timeout_p"+ str(i))
		

func on_ability_shoot_used(player_nr):
	if player_nr == 0:
		ability_shoot_p0.get_node("CooldownRect").visible = true
	elif player_nr == 1:
		ability_shoot_p1.get_node("CooldownRect").visible = true
	
func on_ability_build_used(player_nr, position, velocity):
	if player_nr == 0:
		ability_build_p0.get_node("CooldownRect").visible = true
	elif player_nr == 1:
		ability_build_p1.get_node("CooldownRect").visible = true
	pass

func on_timer_shoot_timeout_p0():
	ability_shoot_p0.get_node("CooldownRect").visible = false
	
func on_timer_shoot_timeout_p1():
	ability_shoot_p1.get_node("CooldownRect").visible = false	

func on_timer_build_timeout_p0():
	ability_build_p0.get_node("CooldownRect").visible = false
	
func on_timer_build_timeout_p1():
	ability_build_p1.get_node("CooldownRect").visible = false	
