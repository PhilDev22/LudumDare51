extends KinematicBody2D


var velocity = Vector2(0, 1)  # (1,0)-right, (0,1)-down, (0,-1)-up, ...
var speed = 300


func _physics_process(delta):
	
	var collision_info = move_and_collide(velocity.normalized() * delta * speed)
	
	if not collision_info: return
	
	var collider = collision_info.collider;
	if collider.is_in_group("Walls"):
		# destroy wall
		var target_pos = (position + (velocity * GameData.tile_half_size)) / GameData.tile_size
		#collision_info.collider.destroy_wall_on_cell(target_pos.x, target_pos.y)
		# destroy self
		queue_free()
