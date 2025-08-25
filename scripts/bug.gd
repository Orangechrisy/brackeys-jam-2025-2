extends CharacterBody2D

class_name Bug

func start_movement():
	rotation = randf_range(0, deg_to_rad(360))
	velocity = Vector2(150, 0).rotated(rotation)

func _physics_process(delta: float) -> void:
	
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
