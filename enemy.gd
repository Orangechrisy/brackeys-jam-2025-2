extends Node2D

class_name Enemy

@export var health: int = 50
@export var damage: int = 5

signal next_level()

func _process(_delta: float) -> void:
	if health <= 0:
		death()

func death():
	next_level.emit()
