extends Bug

var web_area_active: bool = false

var spider: bool = true
var melee_state: bool = false
var enemy: CharacterBody2D
var enemy_found: bool = false

var tween_started: bool = false
func enemy_process(delta):
	if (enemy == null) or (not enemy_found):
		enemy_found = true
		if self == GameManager.enemy_bug:
			enemy = GameManager.player_bug
		elif self == GameManager.player_bug:
			enemy = GameManager.enemy_bug
	else:
		look_at(enemy.global_position)
	
	if not web_area_active:
		speed=default_speed
		var collision_info = move_and_collide(velocity * delta)
		if collision_info:
			velocity = velocity.bounce(collision_info.get_normal())
			velocity = velocity.rotated(deg_to_rad(randf_range(-10.0, 10.0)))
	elif not tween_started:
		tween_started=true
		invincible=true
		var dist = global_position.distance_to(enemy.global_position)
		var time = dist / 350.0
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
		var attack_pos = enemy.global_position
		if enemy.global_position.y > global_position.y:
			attack_pos -= Vector2(0.0, 50.0)
		else:
			attack_pos -= Vector2(0.0, -50.0)
		if enemy.global_position.x > global_position.x:
			attack_pos -= Vector2(50.0, 0.0)
		else:
			attack_pos -= Vector2(-50.0, 0.0)
		
		tween.tween_property(self, "global_position", attack_pos, time)
		await tween.finished
		invincible=false
		web_area_active=false
		tween_started=false

#I DONT KNOW WHY THIS DOESNT WORK 😢😢😢😢😢😢😢
#JUST MAKING IT AUTOSTART FOR NOW YES I KNOW THE SPIDER CAN ATTACK EARLY
func start_bug_timers():
	$BugTimers/ShootTimer.start()

func _on_attack_area_body_entered(body: Node2D) -> void:
	if web_area_active:
		if body.is_in_group("hurtbox"):
			if "health" in body:
				body.hit(7, self, body)
				web_area_active=false
				# TODO this should totally cause the little portrait to have an effect


const WEB_SHOT = preload("res://scenes/web_shot.tscn")
func _on_shoot_timer_timeout() -> void:
	var webshot = WEB_SHOT.instantiate()
	webshot.origin_bug = self
	get_parent().add_child(webshot)
	webshot.global_position = global_position
	webshot.direction = (to_global(Vector2.RIGHT)-global_position).normalized()


func _on_melee_timer_timeout() -> void:
	web_area_active=false
