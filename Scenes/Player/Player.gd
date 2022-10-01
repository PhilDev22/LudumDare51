extends KinematicBody2D

export (int) var player_nr = 0
export (int) var speed = 200

onready var animated_sprite = $AnimatedSprite

var velocity = Vector2()
var direction
var collision_objects = []

func _ready():
	animated_sprite.set_animation("idle") 
	animated_sprite.set_playing(true)
	
func _physics_process(delta):
	
	var direction = InputSystem.input_direction if player_nr == 0 else InputSystem.input_direction_p2
	velocity = Vector2()
	
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
		else:
			if direction == Vector2():
				animated_sprite.set_animation("idle") 
		
		velocity = velocity.normalized() * speed
		
		velocity = move_and_slide(velocity)
		for i in get_slide_count():
			collision_objects.push_back(get_slide_collision(i))
