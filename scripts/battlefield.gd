extends Node2D


func _on_button_pressed() -> void:
	$PlayerBug.start_movement()
	$EnemyBug.start_movement()
