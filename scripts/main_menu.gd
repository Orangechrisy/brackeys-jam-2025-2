extends Node2D

var fullscreen: bool = false

func _ready() -> void:
	#$CenterContainer/MenuButtons/start.grab_focus()
	# useful for controller support, can do on the other button bits too for when going to each menu/back to main
	# TODO starting value of volume should probably be .5 i think? or maybe make it go up to 2? idk
	$CenterContainer/SettingsMenu/fullscreen.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	$CenterContainer/SettingsMenu/mainvolume.value = db_to_linear(AudioServer.get_bus_index("Master"))
	$CenterContainer/SettingsMenu/mainvolume.value = db_to_linear(AudioServer.get_bus_index("MUSIC"))
	$CenterContainer/SettingsMenu/mainvolume.value = db_to_linear(AudioServer.get_bus_index("SFX"))
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen = true
	else:
		fullscreen = false
	GameManager.stop_other_music(GameManager.shopMusic)
	GameManager.play_audio(GameManager.shopMusic, true)

func _on_start_pressed() -> void:
	GameManager._reset()
	get_tree().change_scene_to_file("res://scenes/char_select.tscn")


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


func _on_fullscreen_pressed() -> void:
	if not fullscreen:
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
