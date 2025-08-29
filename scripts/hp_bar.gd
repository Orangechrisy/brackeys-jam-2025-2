extends Control

func _ready() -> void:
	$ProgressBar.max_value = GameManager.player_max_health
	$ProgressBar.value = GameManager.player_health

func _physics_process(_delta: float) -> void:
	$ProgressBar.value = GameManager.player_health
