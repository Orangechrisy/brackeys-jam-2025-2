extends Bug

var charging: bool = false
var enemy: CharacterBody2D
var enemy_found: bool = false
var last_enemy_pos: Vector2

func enemy_process(delta):
	if (enemy == null) or (not enemy_found):
		enemy_found = true
		if self == GameManager.enemy_bug:
			enemy = GameManager.player_bug
		elif self == GameManager.player_bug:
			enemy = GameManager.enemy_bug
	if not charging:
		#look_at(direction)
		velocity = direction * speed
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())
			velocity = velocity.rotated(deg_to_rad(randf_range(-10.0, 10.0)))
			direction = velocity/speed
			look_at(velocity/speed + global_position)
	else:
		look_at(last_enemy_pos)

func start_bug_timers():
	$BugTimers/ChargeTimer.wait_time = randf_range(1.5, 2.5)
	$BugTimers/ChargeTimer.start()

func _on_charge_timer_timeout() -> void:
	last_enemy_pos = enemy.global_position
	#look_at(last_enemy_pos)
	charging=true
	speed = 0
	await get_tree().create_timer(0.2).timeout
	
	#var dist = global_position.distance_to(enemy.global_position)
	#var time = dist / 500.0
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tween.tween_property(self, "global_position", to_global($RayCast2D.target_position), 0.5)
	await tween.finished
	$BugTimers/ChargeTimer.wait_time = randf_range(1.5, 2.5)
	$BugTimers/ChargeTimer.start()
	speed=default_speed
	charging=false
	


func _on_attack_area_body_entered(body: Node2D) -> void:
	if (not spidersnared) and charging:
		if body != self:
			#print("Collision with" + str(body))
			if body.is_in_group("hurtbox"):
				#print("Is in group!")
				if "health" in body:
					body.hit(damage, self, body)
