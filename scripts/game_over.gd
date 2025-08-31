extends Node2D

func _ready() -> void:
	get_tree().paused = false
	var labels = get_node("PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2")
	labels.get_node("BillLabel").text = "x" + str(GameManager.rewards[0])
	labels.get_node("BiscuitLabel").text = "x" + str(GameManager.rewards[1])
	labels.get_node("BottlecapLabel").text = "x" + str(GameManager.rewards[2])
	labels.get_node("GumLabel").text = "x" + str(GameManager.rewards[3])
	labels.get_node("PaperclipLabel").text = "x" + str(GameManager.rewards[4])

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_mouse_entered() -> void:
	$MouseOverSound.pitch_scale = randf_range(0.9, 1.4)
	$MouseOverSound.play()
