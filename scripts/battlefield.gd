extends Node2D

signal update_health_bar(player: bool, health: int)
signal reset(won: bool)
signal allow_clicking(allow: bool)

var player_bug
var player_scene
var enemy_bug
var enemy_scene
@export var curr_round = 0
@export var num_rounds = 3
var round_ended = false
	
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
	enemy_bug.position = Vector2(150.0, 0.0)
	#enemy_bug.modulate = Color("#ea003e")
	enemy_bug.connect("change_health", health_change)

	enemy_bug.connect("next_level", round_change)
	$Bugs.add_child(enemy_bug)
	enemy_bug.set_as_enemy()
	
	round_ended = false
	#for bug in $Bugs.get_children():
		#bug.start_movement()

func health_change(bug: CharacterBody2D, health: int):
	print("updating health")
	if bug == player_bug:
		update_health_bar.emit(true, health)
	else:
		update_health_bar.emit(false, health)

# if rounds left, reset, otherwise end the encounter
func round_change(bug: CharacterBody2D):
	if not round_ended:
		round_ended = true
		var won = false
		if bug == player_bug:
			print("enemy win!")
		else:
			print("player win!")
			won = true
		curr_round += 1
		
		# Stopping timers
		player_bug.remove_timers()
		
		if curr_round < num_rounds:
			print("resetting")
			reset.emit(won) # reset the encounter scene including losing parts
			reset_battlefield()
		else:
			print("fight finished")
			player_bug.queue_free()
			enemy_bug.queue_free()
			reset.emit(won)
			GameManager.enemy_body_parts.clear()
			GameManager.enemy_played_parts.clear()
			get_tree().change_scene_to_file("res://scenes/shop.tscn")

func reset_battlefield():
	player_bug.queue_free()
	enemy_bug.queue_free()
	await get_tree().create_timer(1).timeout
	place_bugs(player_scene, enemy_scene)

func _on_button_pressed() -> void:
	if get_parent().can_click == true:
		player_bug.start_movement()
		player_bug.start_timers()
		enemy_bug.start_movement()
		allow_clicking.emit(false)
