extends KinematicBody2D

export (int) var player_nr = 0
export (int) var speed = 200

onready var animated_sprite = $AnimatedSprite

var velocity = Vector2()
var direction
var direction_last = Vector2(0,0)
var collision_objects = []

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
		animated_sprite.set_animation("idle")

func _handle_colllisions():
	return null
