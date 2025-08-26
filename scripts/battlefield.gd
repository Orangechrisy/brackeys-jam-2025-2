extends Node2D

const COCKROACH = preload("res://scenes/enemy/cockroach.tscn")

signal update_health_bar(player: bool, health: int)
signal reset(won: bool)

var player_bug
var enemy_bug
@export var round = 0
@export var num_rounds = 3

func _ready() -> void:
	player_bug = COCKROACH.instantiate()
	GameManager.player_bug = player_bug
	player_bug.position = Vector2(-150.0, 0.0)
	player_bug.modulate = Color("#00b6ff")
	player_bug.connect("lose_health", health_change)
	player_bug.connect("next_level", round_change)
	$Bugs.add_child(player_bug)
	
	enemy_bug = COCKROACH.instantiate()
	GameManager.enemy_bug = enemy_bug
	enemy_bug.position = Vector2(150.0, 0.0)
	enemy_bug.modulate = Color("#ea003e")
	enemy_bug.connect("lose_health", health_change)
	enemy_bug.connect("next_level", round_change)
	$Bugs.add_child(enemy_bug)
	
	for bug in $Bugs.get_children():
		bug.start_movement()

func health_change(bug: CharacterBody2D, health: int):
	if bug == player_bug:
		update_health_bar.emit(true, health)
	else:
		update_health_bar.emit(false, health)

# if rounds left, reset, otherwise end the encounter
func round_change(bug: CharacterBody2D):
	var won = false
	if bug == player_bug:
		print("enemy win!")
	else:
		print("player win!")
		won = true
	round += 1
	if round < num_rounds:
		print("resetting")
		reset.emit(won) # reset the encounter scene including losing parts
		reset_battlefield()
	else:
		print("fight finished")
		player_bug.queue_free()
		enemy_bug.queue_free()
		reset.emit(won)
		get_tree().change_scene_to_file("res://scenes/shop.tscn")

func reset_battlefield():
	player_bug.queue_free()
	enemy_bug.queue_free()
	await get_tree().create_timer(1).timeout
	_ready()

func _on_button_pressed() -> void:
	$PlayerBug.start_movement()
	$EnemyBug.start_movement()
