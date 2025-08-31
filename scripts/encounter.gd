extends Node2D

const BODY_PART = preload("res://scenes/body_part.tscn")
var can_click = true
var wins = 0
var lungs_timer_ended = false

func _ready():
	GameManager.stop_other_music(GameManager.battleMusic)
	await start_of_battle()
	GameManager.play_audio(GameManager.battleMusic, false)
	create_hand()
	set_body()
	set_enemy_body()
	
	check_hand_sprite()
	
	var enemy = determine_enemy()
	var player = determine_player()
	#var enemy = load("res://scenes/enemy/spider.tscn")
	$Battlefield.place_bugs(player, enemy)
	enemy_play_parts()
	set_health_bars()
	$Blood/Label.text = str(GameManager.blood)

func _process(_delta: float) -> void:
	if can_click and Input.is_action_just_pressed("left_click"):
		if hovered_part != null:
			play_part(hovered_part)
	var mouse_pos = get_global_mouse_position()
	# can maybe instead do this by viewport size instead of hardcoded...
	if not brain_move_tween:
		$Hand.position = Vector2(clamp(mouse_pos.x, 440, 1440), clamp(mouse_pos.y, 830, 1080))
	if GameManager.no_lungs:
		$Lungs.show()
		$Lungs/ColorRect.show()
		if not $Lungs/LungsTimer.is_stopped():
			var out_of_time = 1 - ($Lungs/LungsTimer.time_left / $Lungs/LungsTimer.wait_time)
			$Lungs/ColorRect.modulate = Color(1, 1, 1, out_of_time)
		elif not lungs_timer_ended:
			$Lungs/ColorRect.hide()
		if lungs_timer_ended:
			$Lungs/Label.text = "0.00"
			$Lungs/ColorRect.modulate = Color(1, 1, 1, 1)
		elif $Lungs/LungsTimer.is_stopped():
			$Lungs/Label.text = "%0.2f" % $Lungs/LungsTimer.wait_time
		else:
			$Lungs/Label.text = "%0.2f" % $Lungs/LungsTimer.time_left
	else:
		$Lungs.hide()
	if hovered_part == null:
		$Tooltip.hide()

var reward: int
var rewards = [
	"A Wet $5 Bill!",
	"A Partially Eaten Biscuit!",
	"A Shiny Bottle Cap!",
	"Half A Pack Of Gum!",
	"A Paperclip!"
]
var reward_images = [
	"res://assets/rewards/reward_bill.png",
	"res://assets/rewards/reward_biscuit.png",
	"res://assets/rewards/reward_bottlecap.png",
	"res://assets/rewards/reward_gum.png",
	"res://assets/rewards/reward_paperclip.png"
]

func start_of_battle():
	$StartingReward.show()
	$Sounds/Drumroll.play()
	reward = randi_range(0, rewards.size() - 1)
	await get_tree().create_timer(2.0).timeout
	$StartingReward/LabelReward.text = rewards[reward]
	$StartingReward/LabelReward.show()
	$StartingReward/Rays.show()
	$StartingReward/Reward.texture = load(reward_images[reward])
	$StartingReward/Reward.show()
	$StartingReward/Label2.show()
	$StartingReward/Label3.show()
	await get_tree().create_timer(4.0).timeout
	$StartingReward.hide()

func end_of_battle():
	$EndingReward.show()
	$EndingReward/Reward.texture = load(reward_images[reward])
	if wins == 3:
		$EndingReward/Label.text = "You Won " + rewards[reward]
		$EndingReward/Label2.show()
		$EndingReward/Reward.show()
		GameManager.blood += 1
	elif wins == 2:
		$EndingReward/Label.text = "You Won " + rewards[reward]
		$EndingReward/Reward.show()
	else:
		$EndingReward/Label.text = "You Didn't Win " + rewards[reward]
	await get_tree().create_timer(4.0).timeout

func set_health_bars():
	$UI/Player/HealthBar.max_value = GameManager.player_bug.max_health
	$UI/Enemy/HealthBar.max_value = GameManager.enemy_bug.max_health
	$UI/Player/HealthBar.value = $UI/Player/HealthBar.max_value
	$UI/Player/HealthBar/Label.text = str(int($UI/Player/HealthBar.value))
	$UI/Enemy/HealthBar.value = $UI/Enemy/HealthBar.max_value
	$UI/Enemy/HealthBar/Label.text = str(int($UI/Enemy/HealthBar.value))

func create_hand():
	GameManager.body_parts.shuffle()
	for i in range(min(GameManager.hand_size, GameManager.body_parts.size())):
		var partID = GameManager.body_parts[i]
		# TODO determine which image to show based on partID instead of just default heart 
		var part = GameManager.create_part(partID, false)
		#var part = BODY_PART.instantiate()
		$"OrganHolder".add_child(part)
		GameManager.current_parts.append(part)
		part.position = $body.position
		update_part_positions()

# updates the parts so they are in the right positions in the "hand"
func update_part_positions():
	var x_pos = get_viewport().size.x / 2
	var y_pos = get_viewport().size.y - get_viewport().size.y / 6
	for i in range(GameManager.current_parts.size()):
		calc_and_move_part(i, x_pos, y_pos, 0.1)

# calculates the new position for a part and moves it
func calc_and_move_part(i, x_position, y_position, speed):
	var new_position = Vector2(calculate_part_position(i, x_position), y_position)
	var part = GameManager.current_parts[i]
	animate_part_to_position(part, new_position, speed)

# for determining where a part in the hand should sit
func calculate_part_position(index, x_position):
	var part = GameManager.current_parts[index]
	var width = part.get_node("CollisionShape2D").get_shape().radius * 2
	var x_offset = (GameManager.current_parts.size() - 1) * width
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
	$"body/Parts".get_child(part.partID).get_node("Sprite2D").modulate = Color("#b00000")
	var nextToMouse = false
	$Tooltip.InfoPopup(part.partID, nextToMouse)

func body_part_part_exited(part: Area2D) -> void:
	update_part_count(part.partID, true)
	if hovered_part==part:
		hovered_part=null
	elif hovered_part and hovered_part.partID == part.partID: # to fix weird issue of entering triggering first on part with same ID
		$"body/Parts".get_child(part.partID).get_node("Sprite2D").modulate = Color("#b00000")
	$Tooltip.HidePopup()

func check_hand_sprite():
	if GameManager.no_right_arm:
		if GameManager.no_left_arm:
			$Hand/AnimatedSprite2D.animation = &"ghost"
		else:
			$Hand/AnimatedSprite2D.animation = &"left"
	else:
		$Hand/AnimatedSprite2D.animation = &"default"

var playing_part: bool = false
var brain_move_tween = false

func play_part(part: Area2D):
	if not playing_part:
		playing_part = true
		
		# no brain so play a random part
		if GameManager.no_brain:
			var rng = randi_range(0, GameManager.current_parts.size() - 1)
			if part != GameManager.current_parts[rng]:
				part = GameManager.current_parts[rng]
				get_viewport().warp_mouse(part.global_position)
				var handtween = create_tween()
				handtween.tween_property($Hand, "position", part.global_position, 0.3)
				brain_move_tween = true
				await handtween.finished
				brain_move_tween = false
		
		# grab animation
		$"Hand/AnimatedSprite2D".frame = 1
		$Tooltip.HidePopup()
		
		$Sounds/PlayBodyPart.pitch_scale = randf_range(0.9, 1.1)
		$Sounds/PlayBodyPart.play()
		
		# fades the part away
		var tween = create_tween()
		tween.tween_property(part, "modulate", Color("#ffffff00"), 0.2)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_STOP)
		await tween.finished
		
		# this may need to be different if we want different types of the same part
		var partID = part.partID
		GameManager.body_parts.erase(partID)
		GameManager.current_parts.erase(part)
		GameManager.played_parts.append(partID)
		update_part_count(partID, true)
		part.queue_free()
		update_part_positions()
		
		activate_part(partID, true)
		$"Hand/AnimatedSprite2D".frame = 0
		if not $Battlefield/Button.visible:
			$Battlefield/Button.show()
		playing_part = false
	
func activate_part(partID: int, isPlayer: bool):
	var bug
	#var player_turn = true
	if isPlayer:
		bug = $Battlefield.player_bug
	else:
		bug = $Battlefield.enemy_bug
	match partID:
		GameManager.BODYPARTS.HEART:
			var health = 25
			$UI/Player/HealthBar.max_value += health
			bug.max_health += health
			bug.health += 25
		GameManager.BODYPARTS.BRAIN:
			# in bug script
			pass
		GameManager.BODYPARTS.LUNGS:
			bug.speed += 100
			bug.default_speed += 100
		GameManager.BODYPARTS.EYES:
			bug.get_node("AttackArea/CollisionShape2D").scale = Vector2(1.2, 1.2)
		GameManager.BODYPARTS.LEFTARM:
			bug.get_node("LeftArm").show()
			bug.get_node("LeftArm/ArmAttackArea/CollisionShape2D").disabled = false
		GameManager.BODYPARTS.RIGHTARM:
			bug.get_node("RightArm").show()
			bug.get_node("RightArm/ArmAttackArea/CollisionShape2D").disabled = false
		GameManager.BODYPARTS.LEFTLEG:
			# in bug script
			pass
		GameManager.BODYPARTS.RIGHTLEG:
			# in bug script
			pass
		GameManager.BODYPARTS.STOMACH:
			# in bug script
			pass
		GameManager.BODYPARTS.LIVER:
			# in bug script
			pass
		GameManager.BODYPARTS.LEFTKIDNEY:
			bug.get_node("LeftKidney").show()
			bug.get_node("LeftKidney/KidneyDefenseArea/CollisionShape2D").disabled = false
		GameManager.BODYPARTS.RIGHTKIDNEY:
			bug.get_node("RightKidney").show()
			bug.get_node("RightKidney/KidneyDefenseArea/CollisionShape2D").disabled = false

# sets the little body at the start of the encounter
func set_body():
	for part in range(GameManager.num_bodyparts):
		update_part_count(part, true)

func set_enemy_body():
	for part in range(GameManager.num_bodyparts):
		GameManager.enemy_body_parts.append(part)
		update_part_count(part, false)
	var extra_body_parts = 2 + GameManager.match_num
	for i in range(extra_body_parts):
		var partID = randi_range(0, GameManager.num_bodyparts - 1)
		GameManager.enemy_body_parts.append(partID)
		update_part_count(partID, false)
		

func enemy_play_parts():
	GameManager.enemy_body_parts.shuffle()
	@warning_ignore("integer_division")
	var part_play_count = min(1 + floor(GameManager.match_num / 2), 8)
	for i in range(min(part_play_count, GameManager.enemy_body_parts.size())):
		var partID = GameManager.enemy_body_parts.pop_back()
		GameManager.enemy_played_parts.append(partID)
		activate_part(partID, false)
		update_part_count(partID, false)
	

# updates the part counts on the little body
func update_part_count(partID: int, isPlayer: bool):
	var amount
	var played_parts
	var parts_node
	if isPlayer:
		amount = GameManager.body_parts.count(partID)
		played_parts = GameManager.played_parts
		parts_node = $body/Parts
	else:
		amount = GameManager.enemy_body_parts.count(partID)
		played_parts = GameManager.enemy_played_parts
		parts_node = $enemybody/Parts
	if played_parts.has(partID):
		parts_node.get_child(partID).get_node("Sprite2D").modulate = Color("#ffeb00")
	elif amount > 1:
		parts_node.get_child(partID).get_node("Sprite2D").modulate = Color("#ff0000")
	elif amount == 1:
		parts_node.get_child(partID).get_node("Sprite2D").modulate = Color("#ff8877")
	else:
		parts_node.get_child(partID).get_node("Sprite2D").modulate = Color("#404040")

const COCKROACHICON: Texture2D = preload("res://assets/bugs/cockroachicon.png")
const SPIDERICON: Texture2D = preload("res://assets/bugs/spidericon.png")
const WASPICON: Texture2D = preload("res://assets/bugs/waspicon.png")
const BEETLEICON: Texture2D = preload("res://assets/bugs/beetleicon.png")

func determine_player() -> PackedScene:
	var path = "res://scenes/enemy/" + GameManager.ENEMIES[GameManager.player_bugID] + ".tscn"
	var player_bug = load(path)
	$UI/Player/NameLabel.text = GameManager.player_bug_name
	match GameManager.player_bugID:
		GameManager.BUGS.COCKROACH:
			$UI/Player/IconBG/Icon.texture = COCKROACHICON
		GameManager.BUGS.SPIDER:
			$UI/Player/IconBG/Icon.texture = SPIDERICON
		GameManager.BUGS.WASP:
			$UI/Player/IconBG/Icon.texture = WASPICON
		GameManager.BUGS.BEETLE:
			$UI/Player/IconBG/Icon.texture = BEETLEICON
	
	return player_bug


@onready var enemyID: int = -1
func determine_enemy() -> PackedScene:
	if enemyID == -1:
		enemyID = randi_range(0, GameManager.num_enemies - 1)
	var path = "res://scenes/enemy/" + GameManager.ENEMIES[enemyID] + ".tscn"
	var enemy_bug = load(path)
	var enemy_names = GameManager.default_bug_names[enemyID]
	var rng = randi_range(0, enemy_names.size() - 1)
	while GameManager.player_bug_name == enemy_names[rng]:
		rng = randi_range(0, enemy_names.size() - 1)
	$UI/Enemy/NameLabel.text = enemy_names[rng]
	match enemyID:
		GameManager.BUGS.COCKROACH:
			$UI/Enemy/IconBG/Icon.texture = COCKROACHICON
		GameManager.BUGS.SPIDER:
			$UI/Enemy/IconBG/Icon.texture = SPIDERICON
		GameManager.BUGS.WASP:
			$UI/Enemy/IconBG/Icon.texture = WASPICON
		GameManager.BUGS.BEETLE:
			$UI/Enemy/IconBG/Icon.texture = BEETLEICON
	return enemy_bug

#health bars
func _on_battlefield_update_health_bar(player: bool, health: int) -> void:
	if player:
		if $UI/Player/HealthBar.value > health:
			$UI/Player/AnimationPlayer.play("damage")
		$UI/Player/HealthBar.value = health
		$UI/Player/HealthBar/Label.text = str(health)
	else:
		if $UI/Enemy/HealthBar.value > health:
			$UI/Enemy/AnimationPlayer.play("damage")
		$UI/Enemy/HealthBar.value = health
		$UI/Enemy/HealthBar/Label.text = str(health)


@export var curr_round = 0
@export var num_rounds = 3

func _on_battlefield_reset(won: bool) -> void:
	curr_round += 1
	if won:
		wins += 1
	else:
		$Sounds/PlayerHit.play()
	#for part in GameManager.played_parts:
	for i in range(GameManager.played_parts.size()):
		var part = GameManager.played_parts.pop_back()
		if won:
			GameManager.body_parts.append(part)
		else:
			GameManager.lose_part(part)
		update_part_count(part, true)
	for part in GameManager.current_parts:
		part.queue_free()
	GameManager.current_parts.clear()
	for part in GameManager.body_parts:
		update_part_count(part, true)
	reset_enemy_parts(won)
	
	GameManager.liver_check()
	check_hand_sprite()
	
	if curr_round < num_rounds:
		await get_tree().create_timer(2.0).timeout
		# these two temp
		var player = determine_player()
		var enemy
		if enemyID == -1:
			enemy = determine_enemy()
		else:
			var path = "res://scenes/enemy/" + GameManager.ENEMIES[enemyID] + ".tscn"
			enemy = load(path)
		$Battlefield.place_bugs(player, enemy)
		create_hand()
		enemy_play_parts()
		set_health_bars()
	else:
		GameManager.enemy_body_parts.clear()
		GameManager.enemy_played_parts.clear()
		#GameManager.stop_other_music(GameManager.shopMusic)
		await get_tree().create_timer(2.0).timeout
		await end_of_battle()
		get_tree().change_scene_to_file("res://scenes/shop.tscn")
	can_click = true

func reset_enemy_parts(won: bool):
	if won:
		var blood_gain = 0
		for i in range(GameManager.enemy_played_parts.size()):
			var part = GameManager.enemy_played_parts.pop_back()
			update_part_count(part, false)
			blood_gain += 1
		GameManager.blood += max(0, blood_gain - GameManager.less_blood)
		$Blood/Label.text = str(GameManager.blood)
	else:
		# put the parts back into enemy's body parts pool since they didnt lose any
		for i in range(GameManager.enemy_played_parts.size()):
			var part = GameManager.enemy_played_parts.pop_back()
			GameManager.enemy_body_parts.append(part)
			update_part_count(part, false)

func _on_battlefield_allow_clicking(allow: bool) -> void:
	can_click = allow


func _on_lungs_timer_timeout() -> void:
	lungs_timer_ended = true
	$Lungs/Label.text = "0.00"
	GameManager.game_over()
