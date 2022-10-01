extends KinematicBody2D

class_name Player

export (int) var player_nr = 0
export (int) var speed = 200

signal collision_with_player

onready var animated_sprite = $AnimatedSprite

var velocity = Vector2()
var direction
var collision_objects = []

func get_class():
	return "Player"
	
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
		if collision_objects:
			_handle_collisions()
	else:
		animated_sprite.set_animation("idle")


func _handle_collisions():
	
	for i in collision_objects.size():
		var collision_obj = collision_objects[i].collider
		if collision_obj.get_class() == "Player":
			emit_signal("collision_with_player")
