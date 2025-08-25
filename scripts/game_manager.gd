extends Node2D

@export var body_parts = []

enum {
	HEART,
	BRAIN,
	LUNG,
	EYES,
	LEFTARM,
	RIGHTARM,
	LEFTLEG,
	RIGHTLEG,
	STOMACH,
	LIVER,
	KIDNEY,
	BLADDER
}

const numbodyparts: int = BLADDER+1

func _ready() -> void:
	_reset()

func game_over():
	pass


func _reset():
	body_parts.clear()
	for i in range(numbodyparts):
		body_parts.append(i)

func lose_part(index: int):
	var partID = body_parts[index]
	body_parts.remove_at(index)
	match partID:
		HEART:
			game_over()
		BRAIN:
			#make stupid
			pass
		LUNG:
			#timer
			pass
		EYES:
			#obsucre vision
			pass
		LEFTARM:
			pass
		
