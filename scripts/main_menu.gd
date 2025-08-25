extends Node2D

func _ready() -> void:
	#$CenterContainer/MenuButtons/start.grab_focus()
	# useful for controller support, can do on the other button bits too for when going to each menu/back to main
	$CenterContainer/SettingsMenu/fullscreen.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	$CenterContainer/SettingsMenu/mainvolume.value = db_to_linear(AudioServer.get_bus_index("Master"))
	$CenterContainer/SettingsMenu/mainvolume.value = db_to_linear(AudioServer.get_bus_index("MUSIC"))
	$CenterContainer/SettingsMenu/mainvolume.value = db_to_linear(AudioServer.get_bus_index("SFX"))

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/encounter.tscn")
	#do this when we have a first level


func _on_settings_pressed() -> void:
	$CenterContainer/MenuButtons.visible = false
	$CenterContainer/SettingsMenu.visible = true


func _on_credits_pressed() -> void:
	$CenterContainer/MenuButtons.visible = false
	$CenterContainer/CreditsMenu.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	$CenterContainer/MenuButtons.visible = true
	$CenterContainer/SettingsMenu.visible = false
	$CenterContainer/CreditsMenu.visible = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_mainvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_musicvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), value)


func _on_sfxvolume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
