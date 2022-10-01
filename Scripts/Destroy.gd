extends KinematicBody2D


var direction = Vector2(0, 1)  # (1,0)-right, (0,1)-down, (0,-1)-up, ...
var speed = 300


func _physics_process(delta):
	var collision_info = move_and_collide(direction.normalized() * delta * speed)
