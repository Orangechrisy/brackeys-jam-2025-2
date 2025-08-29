extends Node2D

var direction: Vector2
var speed = 10
var damage: int = 5

func _physics_process(_delta: float) -> void:
	global_position += direction * speed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != get_parent():
		if "health" in body:
			body.hit(damage, get_parent(), body)
		queue_free()
