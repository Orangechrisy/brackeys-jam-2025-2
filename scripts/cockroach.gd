extends Bug

func enemy_process(delta):
	velocity = direction * speed
	print("velocity: ", velocity)
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		velocity = velocity.rotated(deg_to_rad(randf_range(-10.0, 10.0)))
		look_at(velocity/speed + global_position)


func _on_direction_timer_timeout() -> void:
	#start_movement()
	pass


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body != self:
		print("Collision with" + str(body))
		if body.is_in_group("hurtbox"):
			print("Is in group!")
			if "health" in body:
				body.hit(damage, self, body)
