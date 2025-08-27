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
	#for i in range(5):
		#body_parts.append(randi_range(0, 1))
	for i in range(num_bodyparts):
		body_parts.append(i)

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

# yeah im ignoring the better way to do this rn...
var partImages = [
	"res://assets/bodyparts/heart.png",
	"res://assets/bodyparts/brain.png",
	"res://assets/bodyparts/lungs.png",
	"res://assets/bodyparts/eyes.png",
	"res://assets/bodyparts/tongue.png",
	"res://assets/bodyparts/left_arm.png",
	"res://assets/bodyparts/right_arm.png",
	"res://assets/bodyparts/left_leg.png",
	"res://assets/bodyparts/right_leg.png",
	"res://assets/bodyparts/stomach.png",
	"res://assets/bodyparts/liver.png",
	"res://assets/bodyparts/left_kidney.png",
	"res://assets/bodyparts/right_kidney.png",
	"res://assets/bodyparts/bladder.png",
]

func create_part(partID: int) -> Node2D:
	var part = BODY_PART.instantiate()
	part.partID = partID
	part.get_node("Sprite2D").texture = load(partImages[partID])
	return part
