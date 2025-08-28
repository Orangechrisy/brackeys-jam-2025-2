extends Bug

@onready var knows_enemy: bool = false
var enemy: CharacterBody2D


func enemy_process(delta):
	if not knows_enemy:
		knows_enemy=true
		if self == GameManager.player_bug:
			enemy = GameManager.enemy_bug
		elif self == GameManager.enemy_bug:
			enemy = GameManager.player_bug
	else:
		look_at(enemy.global_position)
	var collision_info = move_and_collide(velocity * delta)
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())


func _on_direction_timer_timeout() -> void:
	start_movement()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if "health" in body:
		body.hit(damage, self, body)
		# TODO this should totally cause the little portrait to have an effect
