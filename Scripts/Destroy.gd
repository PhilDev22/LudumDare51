extends KinematicBody2D


var velocity = Vector2(0, 1)  # (1,0)-right, (0,1)-down, (0,-1)-up, ...
var speed = 300

func _physics_process(delta):
	# var collision_info = move_and_collide(velocity.normalized() * delta * speed)
	var collision_info = move_and_collide(velocity.normalized() * speed)


func _process(delta):
	if Input.is_action_just_pressed("build"):
		pass
		
	if Input.is_action_just_pressed("destroy"):
		shoot_destroy()


onready var is_input = "" # reference to player variable
		
	# $Node2D.look_at(get_global_mouse_position())

onready var player_node =  get_node("res://Scenes/Characters/Player.tscn")

const shoot_destroy_path = preload("res://Scenes/Objects/Destroy.tscn")

func shoot_destroy():
	var bullet = shoot_destroy_path.instance()
	get_parent().add_child(bullet)
	bullet.position = $Node2D/Position2D.global_position
	bullet.velocity = get_global_mouse_position() - bullet.position
