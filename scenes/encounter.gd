extends Node2D


func _ready():
	create_enemy()
	create_hand()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if hovered_part != null:
			play_part(hovered_part)

const FROG = preload("res://scenes/enemy/frog.tscn")

func create_enemy():
	var enemy = FROG.instantiate()
	enemy.position = Vector2(960.0, 270.0)
	add_child(enemy)

func create_hand():
	#$"Organ holder/BodyPart".connect("mouse_entered", hover_part)
	pass

var hovered_part: Area2D = null


@onready var turn: int = 1
@onready var player_turn: bool = true

func next_turn():
	turn+=1
	if player_turn:
		player_turn=false
	else:
		player_turn=true


func _on_body_part_part_entered(part: Area2D) -> void:
	hovered_part=part

func _on_body_part_part_exited(part: Area2D) -> void:
	if hovered_part==part:
		hovered_part=null

func play_part(part: Area2D):
	var tween = create_tween()
	
	tween.tween_property(part, "modulate", Color("#ffffff00"), 0.2)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	await tween.finished
	
	part.position = Vector2(960.0, 540.0)
	
	var tween2 = create_tween()
	tween2.tween_property(part, "modulate", Color("#ffffff"), 0.2)
	tween2.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	await tween2.finished
	
	activate_part(part.partID)
	
func activate_part(partID: int):
	pass
