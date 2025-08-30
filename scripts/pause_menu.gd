extends Control

var fullscreen: bool = false

func _notification(what: int) -> void:
	match what:
		Node.NOTIFICATION_PAUSED:
			hide()
		Node.NOTIFICATION_UNPAUSED:
			show()
			if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
				fullscreen = true
			else:
				fullscreen = false

func _on_resume_pressed() -> void:
	get_tree().paused = !get_tree().paused


func _on_quit_pressed() -> void:
	get_tree().paused = !get_tree().paused
	hide()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_settings_pressed() -> void:
	$CenterContainer/MenuButtons.visible = false
	$CenterContainer/SettingsMenu.visible = true


func _on_fullscreen_pressed() -> void:
	if not fullscreen:
		print("setting fullscreen")
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = false
	$CenterContainer/SettingsMenu/fullscreen.release_focus()


func _on_mainvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_musicvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), value)


func _on_sfxvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)


func _on_back_pressed() -> void:
	$CenterContainer/MenuButtons.visible = true
	$CenterContainer/SettingsMenu.visible = false

func _on_mouse_entered() -> void:
	$MouseOverSound.pitch_scale = randf_range(0.9, 1.4)
	$MouseOverSound.play()
