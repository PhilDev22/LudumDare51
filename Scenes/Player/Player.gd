extends KinematicBody2D

class_name Player

const destroy_path = preload("res://Scenes/Objects/Destroy.tscn")

export (int) var player_nr = 0
export (int) var speed = 200
export (bool) var is_ai = false

signal collision_with_player
signal action_destroy
signal action_build

onready var animated_sprite = $AnimatedSprite
onready var timer_shoot = $TimerShoot
onready var timer_build = $TimerBuild
onready var build_wall = $BuildWall

var velocity = Vector2()
var direction
var direction_action = Vector2(0, 1)
var direction_last = Vector2(0,1)
var collision_objects = []

#ai
var direction_ai = Vector2(1, 0)
var other_player
var ai_stuck_timer = 0
var ai_stuck_timer_max = 0.05
var ai_stuck_vector = Vector2()
var ai_stuck_threshold = 3
var ai_player_influence_distance = 250
var ai_ability_timer = -5
var ai_ability_timer_max = 2

func get_class():
	return "Player"
	
func _ready():
	animated_sprite.set_animation("idle_down") 
	animated_sprite.set_playing(true)
	build_wall.get_node("AnimatedSprite").hide()
	build_wall.get_node("AnimatedSprite/Tween").connect("tween_all_completed", self, "_reset_build_animation")
	self.connect("action_build", get_parent().get_parent(), "_on_build")
	
	if (player_nr == 1):
		is_ai = true
	
	
func _physics_process(delta):
	
	velocity = Vector2()
	
	if player_nr == 0:
		direction = InputSystem.input_direction
	elif player_nr == 1:
		direction = InputSystem.input_direction_p2
		
	if is_ai:
		direction = direction_ai
		
	if direction:
		direction_last = direction

		if direction.x == 1:
			animated_sprite.set_animation("walk_horizontal")
			animated_sprite.flip_h = false
			velocity.x += 1
		elif direction.x == -1:
			animated_sprite.set_animation("walk_horizontal")
			animated_sprite.flip_h = true
			velocity.x -= 1
			
		if direction.y == 1:
			if direction.x == 0:
				animated_sprite.set_animation("walk_down")
				animated_sprite.flip_h = false
			velocity.y += 1
		elif direction.y == -1:
			if direction.x == 0:
				animated_sprite.set_animation("walk_up")
				animated_sprite.flip_h = false
			velocity.y -= 1

	if not velocity:
		if direction_last.x == 1:
			animated_sprite.set_animation("idle_horizontal")
			animated_sprite.flip_h = false
		elif direction_last.x == -1:
			animated_sprite.set_animation("idle_horizontal")
			animated_sprite.flip_h = true
		elif direction_last.y == 1:
			animated_sprite.set_animation("idle_down")
			animated_sprite.flip_h = false
		elif direction_last.y == -1:
			animated_sprite.set_animation("idle_up")
			animated_sprite.flip_h = false
	else:
		velocity = velocity.normalized() * speed
		velocity = move_and_slide(velocity)
		collision_objects.clear()
		for i in get_slide_count():
			collision_objects.push_back(get_slide_collision(i))
		if collision_objects:
			handle_collisions()


func _process(delta):
	
	if player_nr == 0:
		if InputSystem.input_destroy:
			if InputSystem.input_direction != Vector2(0, 0):
				direction_action = InputSystem.input_direction
			else:
				direction_action = direction_last
			destroy(player_nr, direction_action)
		if InputSystem.input_build:
			if InputSystem.input_direction != Vector2(0, 0):
				direction_action = InputSystem.input_direction
			else:
				direction_action = direction_last
			build(player_nr, direction_action)

	if player_nr == 1:
		if InputSystem.input_destroy_p2:
			if InputSystem.input_direction_p2 != Vector2(0, 0):
				direction_action = InputSystem.input_direction_p2
			else:
				direction_action = direction_last
			destroy(player_nr, direction_action)
		if InputSystem.input_build_p2:
			if InputSystem.input_direction != Vector2(0, 0):
				direction_action = InputSystem.input_direction_p2
			else:
				direction_action = direction_last
			build(player_nr, direction_action)
			
	if is_ai: 
		if not velocity:
			update_ai_direction()
		ai_stuck_timer += delta
		if (ai_stuck_timer >= ai_stuck_timer_max):
			ai_stuck_timer = 0
			if (ai_stuck_vector.x > ai_stuck_threshold 
				or ai_stuck_vector.x < -ai_stuck_threshold
				or ai_stuck_vector.y > ai_stuck_threshold
				or ai_stuck_vector.y < -ai_stuck_threshold):
					
				direction_ai = -ai_stuck_vector.normalized()
				destroy(player_nr, direction_ai)
				
			ai_stuck_vector = Vector2()
		
		ai_ability_timer += delta
		if ai_ability_timer >= ai_ability_timer_max:
			ai_ability_timer = 0
			var r = randi() % 2
			if r == 0:
				destroy(player_nr, direction_ai)
			elif r == 1:
				build(player_nr, direction_ai)

func handle_collisions():
	for i in collision_objects.size():
		var collision_obj = collision_objects[i].collider
		if collision_obj.get_class() == "Player":
			emit_signal("collision_with_player")
		elif is_ai and collision_obj.is_in_group("Walls"):
			update_ai_direction(collision_obj)


func destroy(var player_nr = 0, var direction_destroy = Vector2(0, 1)):
	# no diagonal shooting
	if direction_destroy.x != 0 and direction_destroy.y != 0:
		direction_destroy.y = 0
	
	if not timer_shoot.is_stopped():
		return
		
	var destroy = destroy_path.instance()
	destroy.connect("collision_with_wall", get_parent().get_parent(), "_on_destroy")
	#destroy.position = $WeaponPosition2D.global_position - get_parent().position
	destroy.position = global_position - get_parent().position
	destroy.velocity = direction_destroy
	get_parent().add_child(destroy)
	print("Player ", player_nr, ": shooting")
	emit_signal("action_destroy", player_nr)
	timer_shoot.start()
	
	
func build(var player_nr = 0, var direction_player = Vector2(0, 1)):
	# no diagonal building
	if direction_player.x != 0 and direction_player.y != 0:
		direction_player.y = 0
	
	if not timer_build.is_stopped():
		return
		
	var interactive_terrain = get_tree().get_nodes_in_group ("Walls")[0]
	#interactive_terrain.add_wall_behind_player(position.x, position.y, direction_player)
	print("Player ", player_nr, ": building wall")
	emit_signal("action_build", player_nr, global_position, direction_player)
	timer_build.start()
	
	#build_wall.show()
	build_wall.get_node("AudioStreamPlayer").play()
	build_wall.get_node("AnimatedSprite").show()
	build_wall.get_node("AnimatedSprite").play("BuildWall")
	build_wall.get_node("AnimatedSprite/Tween").interpolate_property(build_wall.get_node("AnimatedSprite"), "modulate", 
	  Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.8, 
	  Tween.TRANS_LINEAR, Tween.EASE_IN)
	build_wall.get_node("AnimatedSprite/Tween").start()
	
	
func update_ai_direction(collision_obj = null):
	
	# prevent direction change if the collided wall was not in direction of player
	if collision_obj:
		var cell_id = collision_obj.get_cellv(position + (direction_last * GameData.tile_size))
		if (cell_id == -1):
			return
	
	# get random value (-1,0,1)
	var rand_x = randi() % 3 - 1
	var rand_y = randi() % 3 - 1
	
	# influence next movement direction dependent on other players position
	var distance_to_player = position.distance_to(other_player.position) 
	if distance_to_player < ai_player_influence_distance:
		if direction_last.y != 0:
			if position.x > other_player.position.x:
				rand_x	= 1
			elif position.x < other_player.position.x:
				rand_x	= -1
		elif direction_last.x != 0:
			if position.y > other_player.position.y:
				rand_y	= 1
			elif position.y < other_player.position.y:
				rand_y	= -1
		
			
	if direction_last.x != 0:
		direction_ai.x = 0
		direction_ai.y = rand_y
	elif direction_last.y != 0:
		direction_ai.x = rand_x
		direction_ai.y = 0
	
	ai_stuck_vector += direction_ai


func _on_TimerShoot_timeout():
	pass

func _on_TimerBuild_timeout():
	pass # Replace with function body.


func _reset_build_animation():
	build_wall.get_node("AnimatedSprite").hide()
	build_wall.get_node("AnimatedSprite").modulate = Color(1, 1, 1, 1)
	build_wall.get_node("AnimatedSprite/Tween").reset_all()
	build_wall.get_node("AudioStreamPlayer").stop()
		
