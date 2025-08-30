extends Node2D



signal update_health_bar(player: bool, health: int)
signal reset(won: bool)
signal allow_clicking(allow: bool)

var player_bug
var player_scene
var enemy_bug
var enemy_scene
var round_ended = false

func _ready() -> void:
	GameManager.upper_boundary = to_global(Vector2(275.0, 325.0))
	GameManager.lower_boundary = to_global(Vector2(-300.0, -225.0))

func place_bugs(player: PackedScene, enemy: PackedScene):
	player_scene = player
	player_bug = player.instantiate()
	GameManager.player_bug = player_bug
	player_bug.position = Vector2(-150.0, 0.0)
	#player_bug.modulate = Color("#00b6ff")
	player_bug.connect("change_health", health_change)
	player_bug.connect("next_level", round_change)
	$Bugs.add_child(player_bug)
	
	enemy_scene = enemy
	enemy_bug = enemy.instantiate()
	GameManager.enemy_bug = enemy_bug
	enemy_bug.health += (GameManager.match_num * 2) - 2
	enemy_bug.position = Vector2(150.0, 0.0)
	enemy_bug.rotation = deg_to_rad(180)
	#enemy_bug.modulate = Color("#ea003e")
	enemy_bug.connect("change_health", health_change)
	enemy_bug.connect("next_level", round_change)
	$Bugs.add_child(enemy_bug)
	enemy_bug.set_as_enemy()
	
	round_ended = false

func health_change(bug: CharacterBody2D, health: int):
	if bug == player_bug:
		update_health_bar.emit(true, health)
	else:
		update_health_bar.emit(false, health)

func create_area(area_scene: PackedScene, pos):
	var area = area_scene.instantiate() as Area2D
	area.global_position = pos
	get_parent().call_deferred("add_child", area)

# if rounds left, reset, otherwise end the encounter
func round_change(bug: CharacterBody2D):
	if not round_ended:
		$"../Lungs/LungsTimer".stop()
		round_ended = true
		var won = false
		if bug == player_bug:
			print("enemy win!")
		else:
			print("player win!")
			won = true
		
		player_bug.remove_timers()
		player_bug.queue_free()
		enemy_bug.queue_free()
		await get_tree().create_timer(1).timeout
		reset.emit(won)

func _on_button_pressed() -> void:
	$Button.release_focus()
	if get_parent().can_click == true:
		#$Sounds/MatchBell.pitch_scale = randf_range(0.95, 1.05)
		$Sounds/MatchBell.play()
		player_bug.start_movement()
		player_bug.start_timers()
		enemy_bug.start_movement()
		enemy_bug.start_timers()
		allow_clicking.emit(false)
		if GameManager.no_lungs:
			$"../Lungs/LungsTimer".start()
		$Button.hide()


func _on_button_mouse_entered() -> void:
	$Sounds/MouseOverSound.pitch_scale = randf_range(0.9, 1.4)
	$Sounds/MouseOverSound.play()
