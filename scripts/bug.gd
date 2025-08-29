extends CharacterBody2D

class_name Bug

@export var ID: int
@export var health: int = 20
@export var damage: int = 5
@export var speed: int = 200
var direction: Vector2 
var played_parts = GameManager.played_parts

signal change_health(bug: CharacterBody2D, newhealth: int)
signal next_level(bug: CharacterBody2D)

const STOMACH_ACID = preload("res://scenes/stomach_acid.tscn")

func set_as_enemy():
	played_parts = GameManager.enemy_played_parts

func start_movement():
	rotation = randf_range(0, deg_to_rad(360))
	direction = Vector2(1,0).rotated(rotation)
	velocity = direction*speed

func _physics_process(delta: float) -> void:
	enemy_process(delta)
	
	if health <= 0:
		death()

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
				$Timers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_leg_timeout.bind(timer))
				timer.start()
			GameManager.BODYPARTS.RIGHTLEG:
				print("Right leg found!")
				var timer = Timer.new()
				$Timers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_leg_timeout.bind(timer))
				timer.start()
			GameManager.BODYPARTS.STOMACH:
				print("Stomach found!")
				var timer = Timer.new()
				$Timers.add_child(timer)
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_stomach_timeout.bind(timer))
				timer.start()
			GameManager.BODYPARTS.LIVER:
				print("Liver found!")
				var timer = Timer.new()
				timer.wait_time = randi_range(1, 5)
				timer.one_shot = true
				timer.timeout.connect(_on_timer_liver_timeout.bind(timer))
				timer.start()

func remove_timers():
	for timer in $Timers.get_children():
		timer.queue_free()

func hit(dmg: int, attackingBug: CharacterBody2D, attackedBug: CharacterBody2D):
	#print("hit: ", attackingBug, " | ", attackedBug)
	if attackingBug != attackedBug:
		# TODO this should totally cause the little portrait to have an effect
		# handling effects
		#print(played_parts)
		for part in played_parts:
			if attackingBug == GameManager.player_bug:
				match part:
					GameManager.BODYPARTS.TONGUE:
						# Restores a third of the damage dealt as health
						print("Attacker has tongue!")
						attackingBug.health += floor(attackingBug.damage / 3)
						change_health.emit(attackingBug, attackingBug.health)
			if attackedBug == GameManager.player_bug:
				match part:
					GameManager.BODYPARTS.BRAIN:
						print("Defender has brain!")
						if randi_range(1, 2) == 2:
							dmg = 0
							print("Dodged!")
					#GameManager.BODYPARTS.LEFTKIDNEY:
						#print("checking areas: ", $LeftKidney/KidneyDefenseArea.get_overlapping_areas())
					#GameManager.BODYPARTS.RIGHTKIDNEY:
						#print("checking areas: ", $RightKidney/KidneyDefenseArea.get_overlapping_areas())
		
		# Handling damage dealt
		health -= dmg
		print("health after hit: ", health, " ", dmg)
		change_health.emit(self, health)
	

func _on_arm_attack_area_body_entered(body: Node2D) -> void:
	if "health" in body:
		body.hit(damage, self, body)

# Body part timeout functions
# In a just world this would just be stored in the body part itself but this is not a just world
func _on_timer_leg_timeout(timer: Timer):
	print("Leg timer timeout")
	#var timer2 = Timer.new()
	#timer2.wait_time = 1
	#timer2.one_shot = true
	#timer2.timeout.connect(_on_timer2_leg2_timeout.bind(timer2))
	#timer2.start()
	speed += 100
	await get_tree().create_timer(1).timeout
	speed -= 100
	#print("timer2 started")
	timer.wait_time = randi_range(2, 5)
	timer.start()

#func _on_timer2_leg2_timeout(timer: Timer):
	#print("timer2 ended")
	#speed -= 50
	
func _on_timer_stomach_timeout(timer: Timer):
	print("Stomach timer timeout")
	var acid = STOMACH_ACID.instantiate()
	add_child(acid)
	acid.position = global_position
	acid.direction = velocity / speed
	timer.wait_time = 0.5 #randi_range(1, 5)
	timer.start()

func _on_timer_liver_timeout(timer: Timer):
	print("Liver timer timeout")
	health += 2
	change_health.emit(self, health)
	timer.wait_time = randi_range(1, 5)
	timer.start()

func death():
	print(self, " died!")
	next_level.emit(self)
