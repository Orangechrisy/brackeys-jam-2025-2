extends Bug

var jumpattack: bool = false
func enemy_process(delta):
	if jumpattack:
		$AttackArea/Dustcloud.show()
	else:
		$AttackArea/Dustcloud.hide()
	velocity = direction * speed
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		velocity = velocity.rotated(deg_to_rad(randf_range(-10.0, 10.0)))
		direction = velocity/speed
		look_at(velocity/speed + global_position)

func start_bug_timers():
	$BugTimers/JumpTimer.wait_time = randf_range(2.0, 3.0)
	$BugTimers/JumpTimer.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if (not spidersnared) and jumpattack:
		if body != self:
			#print("Collision with" + str(body))
			if body.is_in_group("hurtbox"):
				#print("Is in group!")
				if "health" in body:
					body.hit(damage, self, body)


func _on_jump_timer_timeout() -> void:
	if spidersnared:
		$BugTimers/JumpTimer.wait_time = randf_range(2.0, 3.0)
		$BugTimers/JumpTimer.start()
		return
	$CollisionShape2D.scale = Vector2(0.01, 0.01)
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	$LeftArm/ArmAttackArea.set_collision_layer_value(1, false)
	$RightArm/ArmAttackArea.set_collision_layer_value(1, false)
	$LeftKidney/KidneyDefenseArea.set_collision_layer_value(1, false)
	$RightKidney/KidneyDefenseArea.set_collision_layer_value(1, false)
	
	speed=600
	$Sounds/Jump.pitch_scale = randf_range(0.7, 1.1)
	$Sounds/Jump.play()
	$AnimationPlayer.play("jump")
	$BugTimers/JumpTimer.wait_time = randf_range(4.0, 5.0)
	$BugTimers/JumpTimer.start()
	await $AnimationPlayer.animation_finished
	speed=default_speed
	
	$CollisionShape2D.scale = Vector2(0.4, 0.4)
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	$LeftArm/ArmAttackArea.set_collision_layer_value(1, true)
	$RightArm/ArmAttackArea.set_collision_layer_value(1, true)
	$LeftKidney/KidneyDefenseArea.set_collision_layer_value(1, true)
	$RightKidney/KidneyDefenseArea.set_collision_layer_value(1, true)
	
	$AttackArea.scale = Vector2.ZERO
	jumpattack=true
	$Sounds/Land.pitch_scale = randf_range(0.9, 1.1)
	$Sounds/Land.play()
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tween.tween_property($AttackArea, "scale", Vector2(1.0,1.0), 0.1)
	await get_tree().create_timer(0.2, false).timeout
	jumpattack=false
