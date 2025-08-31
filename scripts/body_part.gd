extends Area2D

var partID: int = 0
var cost: int = 0

signal part_entered(part: Area2D)
signal part_exited(part: Area2D)

func _ready() -> void:
	get_parent().get_parent().connect_part_signals(self)

func _on_mouse_entered() -> void:
	part_entered.emit(self)
	$Sounds/MouseOverSound.pitch_scale = randf_range(0.9, 1.4)
	$Sounds/MouseOverSound.play()

func _on_mouse_exited() -> void:
	part_exited.emit(self)
