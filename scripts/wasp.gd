extends Bug

var enemy: CharacterBody2D
var enemy_found: bool = false
var melee_range: bool = false

func enemy_process(delta):
	if (enemy == null) or (not enemy_found):
		enemy_found = true
		if self == GameManager.enemy_bug:
			enemy = GameManager.player_bug
		elif self == GameManager.player_bug:
			enemy = GameManager.enemy_bug
	elif melee_range and (not spidersnared):
		scale = Vector2(-1.0,-1.0)
		look_at(enemy.global_position)
		
	velocity = direction * speed
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		velocity = velocity.rotated(deg_to_rad(randf_range(-10.0, 10.0)))
		direction = velocity/speed
		look_at(velocity/speed + global_position)

func start_bug_timers():
	$BugTimers/DirectionTimer.start()


func _on_direction_timer_timeout() -> void:
	start_movement()
	pass


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not spidersnared:
		if body != self:
			print("Collision with" + str(body))
			if body.is_in_group("hurtbox"):
				print("Is in group!")
				if "health" in body:
					body.hit(damage, self, body)


func _on_melee_range_body_entered(body: Node2D) -> void:
	if body != self and ("health" in body):
		melee_range=true


func _on_melee_range_body_exited(body: Node2D) -> void:
	if body != self and ("health" in body):
		melee_range=false
