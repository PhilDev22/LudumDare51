extends KinematicBody2D

export (int) var player_nr = 0
export (int) var speed = 200

onready var animated_sprite = $AnimatedSprite

var velocity = Vector2()
var direction
var direction_destroy = Vector2(0, 1)
var collision_objects = []

func _ready():
	animated_sprite.set_animation("idle") 
	animated_sprite.set_playing(true)
	
func _physics_process(delta):
	
	velocity = Vector2()
	
	var direction
	if player_nr == 0:
		direction = InputSystem.input_direction
	elif player_nr == 1:
		direction = InputSystem.input_direction_p2
		
	if direction:
		print("moving player: ", player_nr)
		
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
			
	if velocity:
		velocity = velocity.normalized() * speed
		velocity = move_and_slide(velocity)
		collision_objects.clear()
		for i in get_slide_count():
			collision_objects.push_back(get_slide_collision(i))
	else:
		animated_sprite.set_animation("idle")


func _handle_colllisions():
	return null


func _process(delta):
	if player_nr == 0:
		if InputSystem.input_destroy:
			if InputSystem.input_direction != Vector2(0, 0):
				direction_destroy = InputSystem.input_direction
			destroy(player_nr, direction_destroy)

	if player_nr == 1:
		if InputSystem.input_destroy_p2:
			if InputSystem.input_direction_p2 != Vector2(0, 0):
				direction_destroy = InputSystem.input_direction_p2
			destroy(player_nr, direction_destroy)

const destroy_path = preload("res://Scenes/Objects/Destroy.tscn")


func destroy(var player_nr = 0, var direction_destroy = Vector2(0, 1)):
	var destroy = destroy_path.instance()
	get_parent().add_child(destroy)
	destroy.position = $Node2D/Position2D.global_position
	if player_nr == 0:
		destroy.direction = direction_destroy
	elif player_nr == 1:
		destroy.direction = direction_destroy
	print(destroy.velocity)
