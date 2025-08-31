extends Node2D

func _ready() -> void:
	get_tree().paused = false

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_mouse_entered() -> void:
	$MouseOverSound.pitch_scale = randf_range(0.9, 1.4)
	$MouseOverSound.play()
