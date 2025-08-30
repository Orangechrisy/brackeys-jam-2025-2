extends Node2D

@onready var TOOLTIP = $Tooltip
const BODY_PART = preload("res://scenes/body_part.tscn")
var hovered_part = null
var shop_parts = []

func _ready() -> void:
	GameManager.stop_other_music(GameManager.shopMusic)
	GameManager.play_audio(GameManager.shopMusic, false)
	for i in range(3):
		var partID = pick_part()
		var part = GameManager.create_part(partID)
		$OrganHolder.add_child(part)
		part.position = get_node("Option" + str(i+1)).position
		get_node("Option" + str(i+1) + "/Label").text = str(part.cost)
		shop_parts.append(part)
	$Blood/Label.text = str(GameManager.blood)

func pick_part() -> int:
	var totalChance = 0
	var selectedPartID
	for i in range(GameManager.num_bodyparts):
		totalChance += GameManager.partChance[i]
	var randchance: int = randi_range(1, totalChance) 
	totalChance = 0
	for i in range(GameManager.num_bodyparts):
		totalChance += GameManager.partChance[i]
		if randchance <= totalChance:
			selectedPartID = i
			break
	return selectedPartID

func connect_part_signals(part: Area2D):
	part.connect("part_entered", body_part_part_entered)
	part.connect("part_exited", body_part_part_exited)

func body_part_part_entered(part: Area2D) -> void:
	hovered_part=part
	part.modulate = Color("#ff00ff")
	var nextToMouse = true
	$Tooltip.InfoPopup(part.partID, nextToMouse)

func body_part_part_exited(part: Area2D) -> void:
	part.modulate = Color("#ffffff")
	if hovered_part==part:
		hovered_part=null
	$Tooltip.HidePopup()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if hovered_part != null:
			buy_part(hovered_part)
			$Tooltip.HidePopup()

func buy_part(part):
	if GameManager.blood >= part.cost:
		GameManager.blood -= part.cost
		$Blood/Label.text = str(GameManager.blood)
		GameManager.bought_part(part.partID)
		GameManager.body_parts.append(part.partID)
		if part.partID == GameManager.BODYPARTS.EYES and GameManager.no_eyes == false:
			for otherParts in shop_parts:
				otherParts.get_node("Censor").hide()
		shop_parts.erase(part)
		part.queue_free()
	else:
		# do a shake or some sound to indicate cant buy?
		print("cant buy")

func _on_button_pressed() -> void:
	GameManager.match_num += 1 # Updates which match we're on to scale difficulty
	get_tree().change_scene_to_file("res://scenes/encounter.tscn")
