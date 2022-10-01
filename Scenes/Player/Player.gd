extends KinematicBody2D

class_name Player

const destroy_path = preload("res://Scenes/Objects/Destroy.tscn")

export (int) var player_nr = 0
export (int) var speed = 200

signal collision_with_player
signal action_destroy
signal action_build

onready var animated_sprite = $AnimatedSprite

var velocity = Vector2()
var direction
var direction_destroy = Vector2(0, 1)
var direction_build = Vector2(0, 1)
var direction_last = Vector2(0,0)
var collision_objects = []

func get_class():
	return "Player"
	
func _ready():
	animated_sprite.set_animation("idle") 
	animated_sprite.set_playing(true)
	
func _physics_process(delta):
	
	velocity = Vector2()
	
	if player_nr == 0:
		direction = InputSystem.input_direction
	elif player_nr == 1:
		direction = InputSystem.input_direction_p2
		
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
		elif direction.y == 1:
			animated_sprite.set_animation("walk_down")
			animated_sprite.flip_h = false
			velocity.y += 1
		elif direction.y == -1:
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
				direction_destroy = InputSystem.input_direction
			destroy(player_nr, direction_destroy)
		if InputSystem.input_build:
			if InputSystem.input_direction != Vector2(0, 0):
				direction_build = InputSystem.input_direction
			build(player_nr, direction_build)
			
	if player_nr == 1:
		if InputSystem.input_destroy_p2:
			if InputSystem.input_direction_p2 != Vector2(0, 0):
				direction_destroy = InputSystem.input_direction_p2
			destroy(player_nr, direction_destroy)
		if InputSystem.input_build_p2:
			if InputSystem.input_direction != Vector2(0, 0):
				direction_build = InputSystem.input_direction
			build(player_nr, direction_build)

func handle_collisions():
	for i in collision_objects.size():
		var collision_obj = collision_objects[i].collider
		if collision_obj.get_class() == "Player":
			emit_signal("collision_with_player")


func destroy(var player_nr = 0, var direction_destroy = Vector2(0, 1)):
	var destroy = destroy_path.instance()
	get_parent().add_child(destroy)
	destroy.position = $Node2D/Position2D.global_position
	if player_nr == 0:
		destroy.velocity = direction_destroy
	elif player_nr == 1:
		destroy.velocity = direction_destroy
	print(destroy.velocity)
	emit_signal("action_destroy", player_nr)
	
	
func build(var player_nr = 0, var direction_destroy = Vector2(0, 1)):
	
	# TODO
	
	print("Player ", player_nr, " is building")
	
	emit_signal("action_build", player_nr)
	
