extends CharacterBody2D

class_name Bug

@export var ID: int
@export var health: int = 20
@export var damage: int = 5
@export var speed: int = 200
var direction: Vector2 

signal lose_health(bug: CharacterBody2D, newhealth: int)
signal next_level(bug: CharacterBody2D)

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
	pass
	
func start_timers():
	# Creates timers for given body parts
	for part in GameManager.played_parts:
		match part.partID:
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
	pass

func remove_timers():
	for timer in $Timers.get_children():
		timer.queue_free()
		pass
	
func change_health(amount: int):
	# For damage-changing cases, mostly healing, where no reference to another bug is needed
	health += amount

# TODO fix hitbox and own hurtbox triggering this
func hit(dmg: int, attackingBug: CharacterBody2D, attackedBug: CharacterBody2D):
	
	# handling effects
	print(GameManager.played_parts)
	for part in GameManager.played_parts:
		if attackingBug == GameManager.player_bug:
			match part.partID:
				GameManager.BODYPARTS.TONGUE:
					# Restores a third of the damage dealt as health
					print("Attacker has tongue!")
					attackingBug.health += floor(attackingBug.damage / 3)
		if attackedBug == GameManager.player_bug:
			match part.partID:
				GameManager.BODYPARTS.BRAIN:
					print("Defender has brain!")
					if randi_range(1, 2) == 2:
						dmg = 0
						print("Dodged!")
						
	
	# Handling damage dealt
	health -= dmg
	print("health after hit: ", health, " ", dmg)
	lose_health.emit(self, health)
	#if dmg <= 0:
		#death()
		

# Body part timeout functions
# In a just world this would just be stored in the body part itself but this is not a just world
func _on_timer_leg_timeout(timer: Timer):
	print("Leg timer timeout")
	timer.wait_time = randi_range(1, 5)
	timer.start()
	pass
	
func _on_timer_stomach_timeout(timer: Timer):
	print("Stomach timer timeout")
	timer.wait_time = randi_range(1, 5)
	timer.start()
	pass

func death():
	print(self, " died!")
	next_level.emit(self)
