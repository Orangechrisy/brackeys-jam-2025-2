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


func adjust_ray_cast():
	$RayCast2D.target_position -= Vector2(20.0, 0.0)

func fix_if_ray_cast_OoB():
	if to_global($RayCast2D.target_position).x > upper_boundary.x:
		while to_global($RayCast2D.target_position).x > upper_boundary.x:
			adjust_ray_cast()
	elif to_global($RayCast2D.target_position).x < lower_boundary.x:
		while to_global($RayCast2D.target_position).x < lower_boundary.x:
			adjust_ray_cast()
	
	if to_global($RayCast2D.target_position).y > upper_boundary.y:
		while to_global($RayCast2D.target_position).y > upper_boundary.y:
			adjust_ray_cast()
	elif to_global($RayCast2D.target_position).y < lower_boundary.y:
		while to_global($RayCast2D.target_position).y < lower_boundary.y:
			adjust_ray_cast()

func _on_charge_timer_timeout() -> void:
	last_enemy_pos = enemy.global_position
	look_at(last_enemy_pos)
	charging=true
	speed = 0
	
	fix_if_ray_cast_OoB()
	
	await get_tree().create_timer(0.5).timeout
	
	$Sounds/Charge.pitch_scale = randf_range(0.9, 1.1)
	$Sounds/Charge.play()
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tween.tween_property(self, "global_position", to_global($RayCast2D.target_position), 0.5)
	await tween.finished
	$BugTimers/ChargeTimer.wait_time = randf_range(1.5, 2.5)
	$BugTimers/ChargeTimer.start()
	$RayCast2D.target_position = Vector2(300.0, 0.0)
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
