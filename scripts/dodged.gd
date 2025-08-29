extends Area2D

func _ready() -> void:
	$AnimationPlayer.play("active")
	await get_tree().create_timer(1.5, false).timeout
	queue_free()
