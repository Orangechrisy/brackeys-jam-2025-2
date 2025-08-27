extends Node2D

const BODY_PART = preload("res://scenes/body_part.tscn")
var hovered_part = null

func _ready() -> void:
	var p1 = randi_range(0, GameManager.BODYPARTS.size())
	var p2 = randi_range(0, GameManager.BODYPARTS.size())
	var p3 = randi_range(0, GameManager.BODYPARTS.size())
	var part1 = GameManager.create_part(p1)
	$"OrganHolder".add_child(part1)
	part1.position = $Option1.position
	var part2 = GameManager.create_part(p2)
	$"OrganHolder".add_child(part2)
	part2.position = $Option2.position
	var part3 = GameManager.create_part(p3)
	$"OrganHolder".add_child(part3)
	part3.position = $Option3.position

func connect_part_signals(part: Area2D):
	part.connect("part_entered", body_part_part_entered)
	part.connect("part_exited", body_part_part_exited)

func body_part_part_entered(part: Area2D) -> void:
	hovered_part=part
	part.modulate = Color("#ff00ff")

func body_part_part_exited(part: Area2D) -> void:
	part.modulate = Color("#ffffff")
	if hovered_part==part:
		hovered_part=null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if hovered_part != null:
			buy_part(hovered_part)

func buy_part(part):
	# TODO currency???
	GameManager.body_parts.append(part.partID)
	part.queue_free()
	print(GameManager.body_parts)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/encounter.tscn")
