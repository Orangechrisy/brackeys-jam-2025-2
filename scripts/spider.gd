extends Bug

func enemy_process(delta):
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		look_at(velocity/speed + global_position)


func _on_direction_timer_timeout() -> void:
	start_movement()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("hurtbox"):
		if "health" in body:
			body.hit(damage, self, body)
			# TODO this should totally cause the little portrait to have an effect
