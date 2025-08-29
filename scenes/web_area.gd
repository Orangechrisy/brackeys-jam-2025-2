extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if (not ("spider" in body)) and ("health" in body):
		body.spidersnared=true
		queue_free()


func _on_death_timer_timeout() -> void:
	queue_free()
