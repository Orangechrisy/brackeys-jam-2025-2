extends Area2D

class_name Projectile

var direction: Vector2
var origin_bug: CharacterBody2D
@export var speed = 10
@export var damage: int = 5

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	#print(position, position - (direction * speed * delta))
	look_at(global_position + (direction * speed * delta))


func death(_hitenemy: bool):
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if (body != origin_bug) and (body.get_parent().get_parent() != origin_bug):
		var hitenemy: bool = false
		if "health" in body:
			body.hit(damage, origin_bug, body)
			hitenemy=true
		death(hitenemy)

func _on_death_timer_timeout() -> void:
	var hitenemy: bool = false
	death(hitenemy)
