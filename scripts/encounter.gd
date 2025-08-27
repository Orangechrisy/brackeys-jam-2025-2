extends Node2D

const BODY_PART = preload("res://scenes/body_part.tscn")

func _ready():
	$UI/Player/HealthBar.value = $UI/Player/HealthBar.max_value
	$UI/Enemy/HealthBar.value = $UI/Enemy/HealthBar.max_value
	create_hand()
	set_body()
	var player = load("res://scenes/enemy/cockroach.tscn")
	var enemy = determine_enemy()
	$Battlefield.place_bugs(player, enemy)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if hovered_part != null:
			play_part(hovered_part)

var current_parts = []

func create_hand():
	GameManager.body_parts.shuffle()
	for i in range(min(5, GameManager.body_parts.size())):
		var partID = GameManager.body_parts[i]
		# TODO determine which image to show based on partID instead of just default heart 
		var part = GameManager.create_part(partID)
		#var part = BODY_PART.instantiate()
		$"OrganHolder".add_child(part)
		current_parts.append(part)
		part.position = Vector2(0, get_viewport().size.y - get_viewport().size.y / 6)
		update_part_positions()

# updates the parts so they are in the right positions in the "hand"
func update_part_positions():
	var x_pos = get_viewport().size.x / 2
	var y_pos = get_viewport().size.y - get_viewport().size.y / 6
	for i in range(current_parts.size()):
		calc_and_move_part(i, x_pos, y_pos, 0.1)

# calculates the new position for a part and moves it
func calc_and_move_part(i, x_position, y_position, speed):
	var new_position = Vector2(calculate_part_position(i, x_position), y_position)
	var part = current_parts[i]
	animate_part_to_position(part, new_position, speed)

# for determining where a part in the hand should sit
func calculate_part_position(index, x_position):
	var part = current_parts[index]
	var width = part.get_node("CollisionShape2D").get_shape().radius * 2
	var x_offset = (current_parts.size() - 1) * width
	var new_x_position = x_position + (index * width) - (x_offset / 2)
	return new_x_position

# moves part to a position smoothly
func animate_part_to_position(part, new_position, speed):
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	tween.tween_property(part, "position", new_position, speed)
	await tween.finished

var hovered_part: Area2D = null

# TODO these should probably connect to the body specifically rather than adjusting here so the body can be used in other places
func connect_part_signals(part: Area2D):
	part.connect("part_entered", body_part_part_entered)
	part.connect("part_exited", body_part_part_exited)

func body_part_part_entered(part: Area2D) -> void:
	hovered_part=part
	$"body/Parts".get_child(part.partID).modulate = Color("#ff00ff")

func body_part_part_exited(part: Area2D) -> void:
	if GameManager.body_parts.count(part.partID) == 0:
		$"body/Parts".get_child(part.partID).modulate = Color("#404040")
	else:
		$"body/Parts".get_child(part.partID).modulate = Color("#ffffff")
	if hovered_part==part:
		hovered_part=null
	elif hovered_part and hovered_part.partID == part.partID: # to fix weird issue of entering triggering first on part with same ID
		$"body/Parts".get_child(part.partID).modulate = Color("#ff00ff")

var played_parts = []

func play_part(part: Area2D):
	print(GameManager.body_parts, ", ", current_parts, ", ", played_parts)
	# fades the part away
	var tween = create_tween()
	tween.tween_property(part, "modulate", Color("#ffffff00"), 0.2)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	await tween.finished
	
	# this may need to be different if we want different types of the same part
	# TODO also this should just be in the lose part bit probably... but here for now since thats not set up
	GameManager.body_parts.erase(part.partID)
	update_part_count(part.partID)
	current_parts.erase(part)
	played_parts.append(part)
	part.position = Vector2(-200, -200)
	
	update_part_positions()
	
	activate_part(part.partID)
	print(GameManager.body_parts, ", ", current_parts, ", ", played_parts)
	
func activate_part(partID: int):
	print("activate: ", partID)
	var bug
	# TODO remove this player turn thing and replace it with something like a passed in variable given theres no turns really
	var player_turn = true
	if player_turn:
		bug = $Battlefield.player_bug
	else:
		bug = $Battlefield.enemy_bug
	match partID:
		GameManager.BODYPARTS.HEART:
			# TODO do in a more direct way probs
			bug.hit(-100)
		GameManager.BODYPARTS.BRAIN:
			bug.damage += 10
		GameManager.BODYPARTS.LUNG:
			pass
		GameManager.BODYPARTS.EYES:
			pass
		GameManager.BODYPARTS.LEFTARM:
			pass

# sets the little body at the start of the encounter
func set_body():
	for part in GameManager.body_parts:
		update_part_count(part)

# TODO we may need to change things if we have different types of parts for the same slot, but thats for later
# TODO also dunno if label under the sprite works cause the modulate effects it too, but that should all be different anyways
# updates the part counts on the little body
func update_part_count(partID: int):
	var num = GameManager.body_parts.count(partID)
	if num > 1:
		$"body/Parts".get_child(partID).get_child(0).text = "x" + str(num)
	elif num == 1:
		$"body/Parts".get_child(partID).get_child(0).text = ""
	else:
		$"body/Parts".get_child(partID).modulate = Color("#404040")

func determine_enemy() -> PackedScene:
	var enemy = randi_range(0, GameManager.num_enemies - 1)
	var path = "res://scenes/enemy/" + GameManager.ENEMIES[enemy] + ".tscn"
	var enemy_bug = load(path)
	return enemy_bug

#health bars
func _on_battlefield_update_health_bar(player: bool, health: int) -> void:
	if player:
		$UI/Player/HealthBar.value = health
	else:
		$UI/Enemy/HealthBar.value = health


func _on_battlefield_reset(won: bool) -> void:
	print(GameManager.body_parts, ", ", current_parts, ", ", played_parts)
	for part in played_parts:
		print(part.partID)
		if won:
			GameManager.body_parts.append(part.partID)
			update_part_count(part.partID)
		else:
			GameManager.lose_part(part.partID)
		part.queue_free()
	played_parts.clear()
	for part in current_parts:
		part.queue_free()
	current_parts.clear()
	print(GameManager.body_parts, ", ", current_parts, ", ", played_parts)
	for part in GameManager.body_parts:
		update_part_count(part)
	await get_tree().create_timer(2).timeout
	create_hand()
