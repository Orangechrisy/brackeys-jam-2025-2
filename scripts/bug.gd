extends CharacterBody2D

class_name Bug

@export var ID: int
@export var health: int = 20:
	set(value):
		if max_health != null:
			if health > value:
				GameManager.display_number(health-value,global_position,false)
			else:
				GameManager.display_number(value-health,global_position,true)
			if value > max_health:
				health = max_health
			else:
				health = max(0, value)
			change_health.emit(self, health)
		else:
			health = value
@export var damage: int = 5
@export var speed: int = 200

@onready var default_speed: int = speed
@onready var max_health = health
 
@onready var battlefield = get_parent().get_parent()
@onready var upper_boundary: Vector2 = GameManager.upper_boundary
@onready var lower_boundary: Vector2 = GameManager.lower_boundary

var direction: Vector2 
var played_parts = GameManager.played_parts
var enemy_played_parts = GameManager.enemy_played_parts

signal change_health(bug: CharacterBody2D, newhealth: int)
signal next_level(bug: CharacterBody2D)

const STOMACH_ACID = preload("res://scenes/stomach_acid.tscn")

func set_as_enemy():
	played_parts = GameManager.enemy_played_parts
	enemy_played_parts = GameManager.played_parts

func start_movement():
	#speed=default_speed
	rotation = randf_range(0, deg_to_rad(360))
	direction = Vector2(1,0).rotated(rotation)
	velocity = direction*speed

func _ready() -> void:
	#speed=0
	$IdleAnim.play("idle")

func _physics_process(delta: float) -> void:
	if health <= 0:
		$GlobalAnimationPlayer.play("death")
		await get_tree().create_timer(0.5, false).timeout
		death()
	
	#THEY CANNOT ESCAPE
	if global_position.x > upper_boundary.x:
		global_position.x = (upper_boundary.x - 50.0)
	elif global_position.x < lower_boundary.x:
		global_position.x = (lower_boundary.x + 50.0)
	if global_position.y > upper_boundary.y:
		global_position.y = (upper_boundary.y - 50.0)
	elif global_position.y < lower_boundary.y:
		global_position.y = (lower_boundary.y + 50.0)
	

	if not spidersnared:
		enemy_process(delta)

# define the ai of the bug by overwriting this function with movement and other things
func enemy_process(_delta):
	velocity = direction * speed

func start_timers():
	# Creates timers for given body parts
	for part in played_parts:
		match part:
			GameManager.BODYPARTS.LEFTLEG:
				# Instantiate a timer
				print("Left leg found!")
				var timer = Timer.new()
				$BodyPartTimers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_leg_timeout.bind(timer))
				timer.start()
			GameManager.BODYPARTS.RIGHTLEG:
				print("Right leg found!")
				var timer = Timer.new()
				$BodyPartTimers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_leg_timeout.bind(timer))
				timer.start()
			GameManager.BODYPARTS.STOMACH:
				print("Stomach found!")
				var timer = Timer.new()
				$BodyPartTimers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_stomach_timeout.bind(timer))
				timer.start()
			GameManager.BODYPARTS.LIVER:
				print("Liver found!")
				var timer = Timer.new()
				$BodyPartTimers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_liver_timeout.bind(timer))
				timer.start()
	if self == GameManager.player_bug:
		if GameManager.no_left_leg and GameManager.no_right_leg:
			speed = 0
			var timer = Timer.new()
			$BodyPartTimers.add_child(timer)
			timer.wait_time = randi_range(6, 12)
			timer.one_shot = true
			timer.timeout.connect(_on_timer_leg_lost_timeout.bind(timer))
			timer.start()
		elif GameManager.no_left_leg or GameManager.no_right_leg:
			print("no leg?")
			speed = 0
			var timer = Timer.new()
			$BodyPartTimers.add_child(timer)
			timer.wait_time = randi_range(1, 1)
			timer.one_shot = true
			timer.timeout.connect(_on_timer_leg_lost_timeout.bind(timer))
			timer.start()
	
	start_bug_timers()

func start_bug_timers():
	pass

func remove_timers():
	for timer in $BodyPartTimers.get_children():
		timer.queue_free()

const DODGED = preload("res://scenes/dodged.tscn")

# this bug got attacked
func hit(dmg: int, attackingBug: CharacterBody2D, attackedBug: CharacterBody2D):
	if not invincible:
		# make sure different bodies
		if attackingBug != attackedBug:
			# player bug attacked and doesnt have a stomach
			if attackedBug == GameManager.player_bug:
				if GameManager.no_stomach:
					dmg += 1
					
			# attacked bug has a brain
			for part in played_parts:
				if part == GameManager.BODYPARTS.BRAIN:
					print("Defender has brain!")
					if randi_range(1, 2) == 2:
						dmg = 0
						battlefield.create_area(DODGED, global_position)
						print("Dodged!")
						
			# attacking bug has a tongue
			if dmg > 0:
				for part in enemy_played_parts:
					if part == GameManager.BODYPARTS.TONGUE:
						# Restores a third of the damage dealt as health
						print("Attacker has tongue!")
						attackingBug.health += floor(attackingBug.damage / 3)
			
			# Handling damage dealt
			health -= dmg
			print("health after hit: ", health, " ", dmg)
			if dmg > 0:
				#Taking Damage: play animation and get 0.3s of i-frames
				invincible=true
				$BugTimers/InvincibilityTimer.start()
				if not $GlobalAnimationPlayer.animation_started:
					$GlobalAnimationPlayer.play("damage")
	

func _on_arm_attack_area_body_entered(body: Node2D) -> void:
	if body != self:
		if "health" in body:
			body.hit(damage, self, body)

# Body part timeout functions
# In a just world this would just be stored in the body part itself but this is not a just world
func _on_timer_leg_timeout(timer: Timer):
	print("Leg timer timeout")
	speed += 100
	await get_tree().create_timer(1).timeout
	speed -= 100
	timer.wait_time = randi_range(2, 5)
	timer.start()

func _on_timer_leg_lost_timeout(_timer: Timer):
	print("Leg lost timer timeout")
	speed = default_speed
	
func _on_timer_stomach_timeout(timer: Timer):
	print("Stomach timer timeout")
	var acid = STOMACH_ACID.instantiate()
	acid.origin_bug = self
	get_parent().add_child(acid)
	acid.global_position = global_position
	acid.direction = (to_global(Vector2.RIGHT)-global_position).normalized()
	timer.wait_time = randi_range(2, 4)
	timer.start()

func _on_timer_liver_timeout(timer: Timer):
	print("Liver timer timeout")
	health += 2
	timer.wait_time = randi_range(1, 5)
	timer.start()

func death():
	print(self, " died!")
	next_level.emit(self)

var invincible: bool 
func _on_invincibility_timer_timeout() -> void:
	invincible = false

#SPIDER:
var spidersnared: bool = false:
	set(value):
		if value == true:
			print("snared")
			speed=0
			$BugTimers/SnaredTimer.start()
			if GameManager.enemy_bug == self:
				GameManager.player_bug.web_area_active = true 
			elif GameManager.player_bug == self:
				GameManager.enemy_bug.web_area_active = true 
		spidersnared = value


func _on_snared_timer_timeout() -> void:
	speed=default_speed
	spidersnared=false
