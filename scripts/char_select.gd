extends Node2D

var selected_bug: int = 0
var bug_name: String = "John D. Cockroach"



const COCKROACHICON: Texture2D = preload("res://assets/bugs/cockroachicon.png")
const SPIDERICON: Texture2D = preload("res://assets/bugs/spidericon.png")
const WASPICON: Texture2D = preload("res://assets/bugs/waspicon.png")
const BEETLEICON: Texture2D = preload("res://assets/bugs/beetleicon.png")
const GRASSHOPPERICON = preload("res://assets/bugs/grasshoppericon.png")

#SELECTING BUGS
func show_bug_icon(BugID: int):
	match BugID:
		GameManager.BUGS.COCKROACH:
			$IconBG/Icon.texture = COCKROACHICON
			$Control/Label.text = "COCKROACH"
		GameManager.BUGS.SPIDER:
			$IconBG/Icon.texture = SPIDERICON
			$Control/Label.text = "SPIDER"
		GameManager.BUGS.WASP:
			$IconBG/Icon.texture = WASPICON
			$Control/Label.text = "WASP"
		GameManager.BUGS.BEETLE:
			$IconBG/Icon.texture = BEETLEICON
			$Control/Label.text = "BEETLE"
		GameManager.BUGS.GRASSHOPPER:
			$IconBG/Icon.texture = GRASSHOPPERICON
			$Control/Label.text = "GRASSHOPPER"

func show_selected_icon():
	show_bug_icon(selected_bug)

func toggle_all_off():
	$Control/CockroachButton.button_pressed = false
	$Control/SpiderButton.button_pressed = false
	$Control/WaspButton.button_pressed = false
	$Control/BeetleButton.button_pressed = false
	$Control/GrasshopperButton.button_pressed = false
	
	_on_cockroach_button_mouse_exited()
	_on_spider_button_mouse_exited()
	_on_wasp_button_mouse_exited()
	_on_beetle_button_mouse_exited()
	_on_grasshopper_button_mouse_exited()

func _on_cockroach_button_pressed() -> void:
	toggle_all_off()
	await get_tree().physics_frame
	$Control/CockroachButton.button_pressed = true
	var bug_names = GameManager.default_bug_names[GameManager.BUGS.COCKROACH]
	$Control/BugNameInput.placeholder_text = bug_names[randi_range(0, bug_names.size() - 1)]
	bug_name=$Control/BugNameInput.placeholder_text
	selected_bug=GameManager.BUGS.COCKROACH
	_on_cockroach_button_mouse_entered()

func _on_spider_button_pressed() -> void:
	toggle_all_off()
	await get_tree().physics_frame
	$Control/SpiderButton.button_pressed = true
	var bug_names = GameManager.default_bug_names[GameManager.BUGS.SPIDER]
	$Control/BugNameInput.placeholder_text = bug_names[randi_range(0, bug_names.size() - 1)]
	bug_name=$Control/BugNameInput.placeholder_text
	selected_bug=GameManager.BUGS.SPIDER
	_on_spider_button_mouse_entered()

func _on_wasp_button_pressed() -> void:
	toggle_all_off()
	await get_tree().physics_frame
	$Control/WaspButton.button_pressed = true
	var bug_names = GameManager.default_bug_names[GameManager.BUGS.WASP]
	$Control/BugNameInput.placeholder_text = bug_names[randi_range(0, bug_names.size() - 1)]
	bug_name=$Control/BugNameInput.placeholder_text
	selected_bug=GameManager.BUGS.WASP
	_on_wasp_button_mouse_entered()

func _on_beetle_button_pressed() -> void:
	toggle_all_off()
	await get_tree().physics_frame
	$Control/BeetleButton.button_pressed = true
	var bug_names = GameManager.default_bug_names[GameManager.BUGS.BEETLE]
	$Control/BugNameInput.placeholder_text = bug_names[randi_range(0, bug_names.size() - 1)]
	bug_name=$Control/BugNameInput.placeholder_text
	selected_bug=GameManager.BUGS.BEETLE
	_on_beetle_button_mouse_entered()

func _on_grasshopper_button_pressed() -> void:
	toggle_all_off()
	await get_tree().physics_frame
	$Control/GrasshopperButton.button_pressed = true
	var bug_names = GameManager.default_bug_names[GameManager.BUGS.GRASSHOPPER]
	$Control/BugNameInput.placeholder_text = bug_names[randi_range(0, bug_names.size() - 1)]
	bug_name=$Control/BugNameInput.placeholder_text
	selected_bug=GameManager.BUGS.GRASSHOPPER
	_on_grasshopper_button_mouse_exited()
	$Control/GrasshopperButton/AnimationPlayer.play("hovered") #idk why i did to do this

#STARTING GAME
func _on_start_button_pressed() -> void:
	GameManager.player_bugID = selected_bug
	if bug_name != "":
		GameManager.player_bug_name = bug_name
	else:
		var bug_names = GameManager.default_bug_names[selected_bug]
		GameManager.player_bug_name = bug_names[randi_range(0, bug_names.size() - 1)]
	get_tree().change_scene_to_file("res://scenes/encounter.tscn")


#ANIMATIONS
func _on_cockroach_button_mouse_entered() -> void:
	$Control/CockroachButton/AnimationPlayer.play("hovered")
	play_mouse_over_sound()
	show_bug_icon(GameManager.BUGS.COCKROACH)

func _on_cockroach_button_mouse_exited() -> void:
	show_selected_icon()
	if not $Control/CockroachButton.button_pressed:
		$Control/CockroachButton/AnimationPlayer.play("RESET")

func _on_spider_button_mouse_entered() -> void:
	$Control/SpiderButton/AnimationPlayer.play("hover")
	play_mouse_over_sound()
	show_bug_icon(GameManager.BUGS.SPIDER)

func _on_spider_button_mouse_exited() -> void:
	show_selected_icon()
	if not $Control/SpiderButton.button_pressed:
		$Control/SpiderButton/AnimationPlayer.play("RESET")

func _on_wasp_button_mouse_entered() -> void:
	$Control/WaspButton/AnimationPlayer.play("hover")
	play_mouse_over_sound()
	show_bug_icon(GameManager.BUGS.WASP)

func _on_wasp_button_mouse_exited() -> void:
	show_selected_icon()
	if not $Control/WaspButton.button_pressed:
		$Control/WaspButton/AnimationPlayer.play("RESET")

func _on_beetle_button_mouse_entered() -> void:
	$Control/BeetleButton/AnimationPlayer.play("hover")
	play_mouse_over_sound()
	show_bug_icon(GameManager.BUGS.BEETLE)

func _on_beetle_button_mouse_exited() -> void:
	show_selected_icon()
	if not $Control/BeetleButton.button_pressed:
		$Control/BeetleButton/AnimationPlayer.play("RESET")

func _on_grasshopper_button_mouse_entered() -> void:
	$Control/GrasshopperButton/AnimationPlayer.play("hovered")
	play_mouse_over_sound()
	show_bug_icon(GameManager.BUGS.GRASSHOPPER)

func _on_grasshopper_button_mouse_exited() -> void:
	show_selected_icon()
	if not $Control/GrasshopperButton.button_pressed:
		$Control/GrasshopperButton/AnimationPlayer.play("RESET")

#BUG NAME CHANGING
func _on_bug_name_input_text_changed(new_text: String) -> void:
	bug_name = new_text

#AUDIO
func play_mouse_over_sound():
	$MouseOverSound.pitch_scale = randf_range(0.9, 1.4)
	$MouseOverSound.play()

func _on_start_button_mouse_entered() -> void:
	play_mouse_over_sound()


func _on_how_to_play_pressed() -> void:
	$HowToPlay.show()
	$ChoosebugBg.hide()
	$Control.hide()
	$IconBG.hide()


func _on_how_to_play_back_pressed() -> void:
	$HowToPlay.hide()
	$ChoosebugBg.show()
	$Control.show()
	$IconBG.show()
