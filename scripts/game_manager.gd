extends Node2D

@export var body_parts = []

enum BODYPARTS {
	HEART,
	BRAIN,
	LUNG,
	EYES,
	TONGUE,
	LEFTARM,
	RIGHTARM,
	LEFTLEG,
	RIGHTLEG,
	STOMACH,
	LIVER,
	KIDNEY,
	BLADDER
}

const numbodyparts: int = BODYPARTS.BLADDER+1


var player_bug: CharacterBody2D
var enemy_bug: CharacterBody2D

func _ready() -> void:
	_reset()

func game_over():
	pass

func _input(event):
	if event.is_action_pressed("escape"):
		if get_tree().get_current_scene().get_name() != "MainMenu":
			get_tree().paused = !get_tree().paused

func _reset():
	body_parts.clear()
	for i in range(5):
		body_parts.append(randi_range(0, 1))
	#for i in range(numbodyparts):
		#body_parts.append(i)

func lose_part(index: int):
	var partID = body_parts[index]
	body_parts.remove_at(index)
	match partID:
		BODYPARTS.HEART:
			game_over()
		BODYPARTS.BRAIN:
			#make stupid
			pass
		BODYPARTS.LUNG:
			#timer
			pass
		BODYPARTS.EYES:
			#obsucre vision
			pass
		BODYPARTS.LEFTARM:
			pass

const BODY_PART = preload("res://scenes/body_part.tscn")
var partImages = ["res://assets/heart.png", "res://assets/brain.png"]

func create_part(partID: int) -> Node2D:
	var part = BODY_PART.instantiate()
	part.partID = partID
	part.get_node("Sprite2D").texture = load(partImages[partID])
	return part
