extends CanvasLayer

onready var animation_player = $AnimationPlayer
onready var ability_shoot_p0 = $AbilityShootPlayer1
onready var ability_build_p0 = $AbilityBuildPlayer1
onready var ability_shoot_p1 = $AbilityShootPlayer2
onready var ability_build_p1 = $AbilityBuildPlayer2

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
		
func fade_transition_scene(scene):
	$FadePanel.visible = true
	animation_player.play("FadeOut")
	InputSystem.disable_input_until(animation_player, "animation_finished")
	yield(animation_player, "animation_finished")
	get_tree().change_scene(scene)
	animation_player.play("FadeIn")
	InputSystem.disable_input_until(animation_player, "animation_finished")
	yield(animation_player, "animation_finished")
	$FadePanel.visible = false

func on_ability_shoot_used(player_nr):
	if player_nr == 0:
		ability_shoot_p0.get_node("CooldownRect").visible = true
	elif player_nr == 1:
		ability_shoot_p1.get_node("CooldownRect").visible = true
	
func on_ability_build_used(player_nr):
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
