extends KinematicBody2D

const speed = 500

var velocity = Vector2(0, 1)  # (1,0)-right, (0,1)-down, (0,-1)-up, ...
var max_distance = GameData.tile_size * 2
var current_distance =  Vector2(0, 0)

func _physics_process(delta):
	
	var move_step = velocity.normalized() * delta * speed
	
	# destroy self when max distance is reached
	current_distance += move_step
	if current_distance.x >= max_distance or current_distance.y >= max_distance:
		queue_free()
	
	var collision_info = move_and_collide(move_step)
	
	if not collision_info: return
	
	var collider = collision_info.collider;
	if collider.is_in_group("Walls"):
		# destroy wall
		var target_pos = (position + (velocity * GameData.tile_half_size)) / GameData.tile_size
		#collision_info.collider.destroy_wall_on_cell(target_pos.x, target_pos.y)
		# destroy self
		queue_free()
