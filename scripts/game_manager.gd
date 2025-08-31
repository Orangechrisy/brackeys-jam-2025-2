extends Node2D

@export var body_parts = []
@export var enemy_body_parts = []

enum BODYPARTS {
	HEART,
	BRAIN,
	LUNGS,
	EYES,
	TONGUE,
	LEFTARM,
	RIGHTARM,
	LEFTLEG,
	RIGHTLEG,
	STOMACH,
	LIVER,
	LEFTKIDNEY,
	RIGHTKIDNEY
}
var num_bodyparts: int = BODYPARTS.size()

var partName: Array = []
var partChance: Array = []
var partImages: Array = []
var partShadowImages: Array = []
var partTooltip : Array = []
var partCost: Array = []
var partHPLoss: Array = []

#rarities
var common: int = 20
var uncommon: int = 10
var rare: int = 5
var legendary: int = 2

const ITEM_JSON_DATA = "res://data/Body_Parts.json"

#IMPORTING EXCEL DATA TO JSON TO ARRAYS
func load_json(path: String):
	var file = FileAccess.get_file_as_string(path)
	var json
	if file != null:
		json = JSON.parse_string(file)
	else:
		print("error importing file")
	
	return json

func init_json_data() -> void:
	var json = load_json(ITEM_JSON_DATA)
	if json != null:
		for i in range(0, json.size()):
			parse_json(i, json[str(i)])
	else:
		print("error initalizing Items.json")

func parse_json(ID: int, json: Dictionary):
	partName[ID] = json["NAME"]
	match json["RARITY"]:
		"common":
			partChance[ID] = common
		"uncommon":
			partChance[ID] = uncommon
		"rare":
			partChance[ID] = rare
		"legendary":
			partChance[ID] = legendary
		_:
			print("Error: Body Part "+str(ID)+" has unknown rarity.")
	partShadowImages[ID] += json["SHADOWPATH"]
	partImages[ID] += json["PATH"]
	partTooltip[ID] = "Bug: [color=green]"+json["BUGDESCR"] +  "[/color]\n\nPlayer: [color=red]" + json["PLAYERDESCR"]+"[/color]"
	partCost[ID] = json["COST"]
	partHPLoss[ID] = json["HPLOSS"]


enum BUGS {
	COCKROACH,
	SPIDER,
	WASP,
	BEETLE,
	GRASSHOPPER
}

const ENEMIES = [
	"Cockroach",
	"Spider",
	"Wasp",
	"Beetle",
	"Grasshopper"
]
var num_enemies: int = ENEMIES.size()
@export var bugs_fought = []

var default_bug_names = [
	["John D. Cockroach", "The Roach", "Cocktavian", "Roachester", "Floormaster", "John Hancockroach", "Roachefort", "Radroach", "Scuttlebug", "Fallout Fella", "Filthy Fred", "Destroyer of Evil"], 
	["Man-Spider", "Eight-Eyes", "Mrs. Webb", "Herrah the Beast", "Silktune", "Arachned", "Webster", "Webelyn", "Daddy Shortlegs", "Widowmaker", "Vriskan't", "Ariadon't", "Gladys Webface"],
	["White Anglo-Saxon Parasite", "Buzz Buzz", "Hornet", "Beeverly", "Sting King", "Hive Clive", "The Bastard", "Buzz Fightyear", "Yellow Jacked", "Cazador", "Buck Bumble", "Lawrence J. Stingley"],
	["Paul McMandible", "Dung Defender", "Stagley", "Beetle Bailey", "The Maw", "Volkswagen", "Beetlehoven", "The Wall", "Hardtack", "Bretta", "Willoh", "The Nailsmith", "Crunch", "Pincer Pete", "Ringo Stagg"],
	["Jump King", "Grassy", "Hoppenheimer", "Hopper", "Highkix", "Davy Crickett", "Jiminy", "Wayne F. Hopton", "Wyatt Chirp", "Hopkins", "Leaping Larry", "Penelhoppe", "Locust Lord", "The Pestilence"]
]

var player_bugID: int = 0
var player_bug_name: String = "John D. Cockroach"
var player_bug: CharacterBody2D
var enemy_bug: CharacterBody2D
var last_enemy_bugID: int = -2
var current_parts = []
var played_parts = []
var enemy_played_parts = []
var blood = 0
var hand_size = 5
var less_blood = 0
var no_lungs = false
var no_left_leg = false
var no_right_leg = false
var no_eyes = false
var player_max_health = 50
var player_health = 50
var no_liver = false
var no_stomach = false
var no_right_arm = false
var no_left_arm = false
var no_brain = false
var upper_boundary: Vector2
var lower_boundary: Vector2
var match_num = 1
var rewards = [0, 0, 0, 0, 0]

var game_over_bool = false

func game_over():
	game_over_bool = true
	stop_other_music(endMusic)
	get_tree().paused = true
	$Red.show()
	await get_tree().create_timer(0.15).timeout
	$Red.hide()
	await get_tree().create_timer(1).timeout
	var tweenShake = create_tween()
	tweenShake.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	#tween.set_parallel()
	var x = get_viewport().position.x
	tweenShake.tween_property(get_viewport(), "position:x", x - 50, 0.1)
	tweenShake.tween_property(get_viewport(), "position:x", x + 100, 0.1)
	tweenShake.tween_property(get_viewport(), "position:x", x - 50, 0.1)
	tweenShake.tween_property(get_viewport(), "position:x", x + 100, 0.1)
	tweenShake.tween_property(get_viewport(), "position:x", x - 50, 0.1)
	tweenShake.tween_property(get_viewport(), "position:x", x, 0.1)
	await tweenShake.finished
	$Death.play()
	$FadeBlack.show()
	var tweenBlack = create_tween()
	tweenBlack.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenBlack.tween_property($FadeBlack, "modulate", Color("000000ff"), 1)
	await tweenBlack.finished
	await get_tree().create_timer(1).timeout
	play_audio(endMusic, true)
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	var tweenBlack2 = create_tween()
	tweenBlack2.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenBlack2.tween_property($FadeBlack, "modulate", Color("00000000"), 1)
	await tweenBlack2.finished
	$FadeBlack.hide()

func _input(event):
	if event.is_action_pressed("escape"):
		if get_tree().get_current_scene().get_name() != "MainMenu":
			get_tree().paused = !get_tree().paused

func _reset():
	game_over_bool = false
	body_parts.clear()
	enemy_body_parts.clear()
	
	partName.resize(num_bodyparts)
	partName.fill("null")
	partChance.resize(num_bodyparts)
	partChance.fill(0)
	partImages.resize(num_bodyparts)
	partImages.fill("res://assets/bodyparts/")
	partShadowImages.resize(num_bodyparts)
	partShadowImages.fill("res://assets/bodyparts/shadows/")
	partTooltip.resize(num_bodyparts)
	partTooltip.fill("null")
	partCost.resize(num_bodyparts)
	partCost.fill(0)
	partHPLoss.resize(num_bodyparts)
	partHPLoss.fill(0)
	
	for i in range(num_bodyparts):
		body_parts.append(i)
	
	init_json_data()
	
	game_over_bool=false
	last_enemy_bugID=-2
	player_bug = null
	enemy_bug = null
	current_parts.clear()
	played_parts.clear()
	enemy_played_parts.clear()
	blood = 0
	hand_size = 5
	less_blood = 0
	no_lungs = false
	no_left_leg = false
	no_right_leg = false
	no_eyes = false
	player_max_health = 50
	player_health = 50
	no_liver = false
	no_stomach = false
	no_right_arm = false
	no_left_arm = false
	no_brain = false
	match_num = 1
	rewards = [0, 0, 0, 0, 0]
	reset_rarities()

func reset_rarities():
	common = 20
	uncommon = 10
	rare = 5
	legendary = 2

func lose_part(partID: int):
	# to account for playing two of the same part (and ensuring theres no more of the part left)
	if played_parts.count(partID) == 0 and body_parts.count(partID) == 0:
		match partID:
			BODYPARTS.HEART:
				player_health = 0
				game_over()
			BODYPARTS.BRAIN:
				no_brain = true
			BODYPARTS.LUNGS:
				no_lungs = true
			BODYPARTS.EYES:
				no_eyes = true
			BODYPARTS.TONGUE:
				common = 30
				uncommon = 15
				rare = 4
				legendary = 2
			BODYPARTS.LEFTARM:
				no_left_arm = true
				hand_size -= 1
			BODYPARTS.RIGHTARM:
				no_right_arm = true
				hand_size -= 1
			BODYPARTS.LEFTLEG:
				no_left_leg = true
			BODYPARTS.RIGHTLEG:
				no_right_leg = true
			BODYPARTS.STOMACH:
				no_stomach = true
			BODYPARTS.LIVER:
				no_liver = true
			BODYPARTS.LEFTKIDNEY:
				less_blood += 1
			BODYPARTS.RIGHTKIDNEY:
				less_blood += 1
	player_health = max(0, player_health - partHPLoss[partID])
	if player_health == 0:
		game_over()

# for when you have none of the part and you buy one at the shop
func bought_part(partID: int):
	GameManager.player_health += 1
	if body_parts.count(partID) == 0:
		match partID:
			BODYPARTS.HEART:
				pass
			BODYPARTS.BRAIN:
				no_brain = false
			BODYPARTS.LUNGS:
				no_lungs = false
			BODYPARTS.EYES:
				no_eyes = false
			BODYPARTS.TONGUE:
				reset_rarities()
			BODYPARTS.LEFTARM:
				no_left_arm = false
				hand_size += 1
			BODYPARTS.RIGHTARM:
				no_right_arm = false
				hand_size += 1
			BODYPARTS.LEFTLEG:
				no_left_leg = false
			BODYPARTS.RIGHTLEG:
				no_right_leg = false
			BODYPARTS.STOMACH:
				no_stomach = false
			BODYPARTS.LIVER:
				no_liver = false
			BODYPARTS.LEFTKIDNEY:
				less_blood -= 1
			BODYPARTS.RIGHTKIDNEY:
				less_blood -= 1

const BODY_PART = preload("res://scenes/body_part.tscn")

func create_part(partID: int, isShop: bool) -> Node2D:
	var part = BODY_PART.instantiate()
	part.partID = partID
	part.get_node("Sprite2D").texture = load(partImages[partID])
	part.get_node("Shadow").texture = load(partShadowImages[partID])
	if no_eyes and isShop:
		part.get_node("Censor").show()
	part.cost = partCost[partID]
	return part

func liver_check():
	if no_liver:
		player_health -= 1
		if player_health <= 0:
			game_over()

var shopMusic = "ShopMusic"
var battleMusic = "BattleMusic"
var endMusic = "EndMusic"

func play_audio(path: String, fadeIn: bool):
	var audio_to_play
	match path:
		shopMusic:
			if $ShopMusic.playing:
				return
			audio_to_play = $ShopMusic
		battleMusic:
			if $BattleMusic.playing:
				return
			audio_to_play = $BattleMusic
		endMusic:
			if $EndMusic.playing:
				return
			audio_to_play = $EndMusic
	if fadeIn:
		var tween = create_tween()
		tween.parallel()
		tween.tween_property(audio_to_play, "volume_linear", audio_to_play.volume_linear, 3.0).from(0.0)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await get_tree().create_timer(0.05).timeout
		audio_to_play.play(0.0)
	else:
		audio_to_play.play(0.0)

func stop_other_music(path: String):
	var music_to_stop = null
	var musicNodes = [$ShopMusic, $BattleMusic, $EndMusic]
	for music in musicNodes:
		if music.playing:
			music_to_stop = music
	match path:
		shopMusic:
			if $ShopMusic.playing:
				return
		battleMusic:
			if $BattleMusic.playing:
				return
		endMusic:
			if $EndMusic.playing:
				return
	if music_to_stop != null:
		var tween = create_tween()
		tween.tween_property(music_to_stop, "volume_linear", 0.0, 1.0)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await tween.finished
		music_to_stop.stop()
		music_to_stop.volume_linear = 1.0

#DAMAGE NUMBERS
var theme: Theme = preload("res://button_theme.tres")
func display_number(value: int, pos: Vector2, heal: bool):
	if value == 0:
		return
	var number = Label.new()
	number.theme = theme
	number.global_position = pos+Vector2(0,-30)
	number.text = str(value)
	number.z_index = 5
	number.label_settings = LabelSettings.new()
	
	var color = "#FFF"
	if heal:
		color = "#00ff00"
	else:
		color = "#B22"
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 30
	number.label_settings.outline_color = "#000"
	number.label_settings.outline_size = 10
	
	call_deferred("add_child", number)
	
	await number.resized
	number.pivot_offset = Vector2(number.size / 2)
	
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel()
	tween.tween_property(number, "position:y", number.position.y-24, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(number, "position:y", number.position.y, 0.5).set_ease(Tween.EASE_IN).set_delay(0.25)
	tween.tween_property(number, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	await tween.finished
	number.queue_free()
