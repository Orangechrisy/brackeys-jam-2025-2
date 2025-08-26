extends Node2D

const COCKROACH = preload("res://scenes/enemy/cockroach.tscn")

signal update_health_bar(player: bool, health: int)

var player_bug
var enemy_bug

func _ready() -> void:
	player_bug = COCKROACH.instantiate()
	GameManager.player_bug = player_bug
	player_bug.position = Vector2(-150.0, 0.0)
	player_bug.modulate = Color("#00b6ff")
	player_bug.connect("lose_health", health_change)
	$Bugs.add_child(player_bug)
	
	enemy_bug = COCKROACH.instantiate()
	GameManager.enemy_bug = enemy_bug
	enemy_bug.position = Vector2(150.0, 0.0)
	enemy_bug.modulate = Color("#ea003e")
	$Bugs.add_child(enemy_bug)
	
	for bug in $Bugs.get_children():
		bug.start_movement()

func health_change(bug: CharacterBody2D, health: int):
	if bug == player_bug:
		update_health_bar.emit(true, health)
	else:
		update_health_bar.emit(false, health)

func _on_button_pressed() -> void:
	$PlayerBug.start_movement()
	$EnemyBug.start_movement()
