extends Projectile

const WEB_AREA = preload("res://scenes/web_area.tscn")

@onready var battlefield = origin_bug.get_parent().get_parent()

func death(hitenemy: bool):
	if not hitenemy:
		battlefield.create_area(WEB_AREA, global_position, origin_bug)
	queue_free()
