extends Node2D

@export var body_parts = []

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
	RIGHTKIDNEY,
	BLADDER
}
var num_bodyparts: int = BODYPARTS.size()

var partName: Array = []
var partChance: Array = []
var partImages: Array = []
var partTooltip : Array = []

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
	partImages[ID] += json["PATH"]
	partTooltip[ID] = json["BUGDESCR"] +  "\n\n" + json["PLAYERDESCR"]


const ENEMIES = [
	"Cockroach",
	"Spider"
]
var num_enemies: int = ENEMIES.size()
@export var bugs_fought = []


var player_bug: CharacterBody2D
var enemy_bug: CharacterBody2D
var current_parts = []
var played_parts = []

func _ready() -> void:
	_reset()
	
	

func game_over():
	print("game over :(")
	pass

func _input(event):
	if event.is_action_pressed("escape"):
		if get_tree().get_current_scene().get_name() != "MainMenu":
			get_tree().paused = !get_tree().paused

func _reset():
	body_parts.clear()
	
	partName.resize(num_bodyparts)
	partName.fill("null")
	partChance.resize(num_bodyparts)
	partChance.fill(0)
	partImages.resize(num_bodyparts)
	partImages.fill("res://assets/bodyparts/")
	partTooltip.resize(num_bodyparts)
	partTooltip.fill("null")
	
	
	#for i in range(5):
		#body_parts.append(randi_range(0, 1))
	for i in range(num_bodyparts):
		body_parts.append(i)
	
	init_json_data()

func lose_part(partID: int):
	#var partID = body_parts[index]
	#body_parts.remove_at(index)
	match partID:
		BODYPARTS.HEART:
			game_over()
		BODYPARTS.BRAIN:
			#make stupid
			pass
		BODYPARTS.LUNGS:
			#timer
			pass
		BODYPARTS.EYES:
			#obsucre vision
			pass
		BODYPARTS.LEFTARM:
			pass
		BODYPARTS.RIGHTARM:
			pass
		BODYPARTS.LEFTLEG:
			pass
		BODYPARTS.RIGHTLEG:
			pass
		BODYPARTS.STOMACH:
			pass
		BODYPARTS.LIVER:
			pass
		BODYPARTS.LEFTKIDNEY:
			pass
		BODYPARTS.RIGHTKIDNEY:
			pass
		BODYPARTS.BLADDER:
			pass

const BODY_PART = preload("res://scenes/body_part.tscn")

func create_part(partID: int) -> Node2D:
	var part = BODY_PART.instantiate()
	part.partID = partID
	part.get_node("Sprite2D").texture = load(partImages[partID])
	return part
