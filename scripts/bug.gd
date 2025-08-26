extends CharacterBody2D

class_name Bug

@export var ID: int
@export var health: int = 50
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

func enemy_process(_delta):
	velocity = direction * speed
	pass

func hit(dmg: int):
	health -= dmg
	print("health after hit: ", health, " ", dmg)
	lose_health.emit(self, health)
	#if dmg <= 0:
		#death()

func death():
	print(self, " died!")
	next_level.emit(self)
