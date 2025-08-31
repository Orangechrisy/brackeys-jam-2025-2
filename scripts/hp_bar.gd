extends Control

func _ready() -> void:
	$ProgressBar.max_value = GameManager.player_max_health
	$ProgressBar.value = GameManager.player_health

func _physics_process(_delta: float) -> void:
	$ProgressBar.value = GameManager.player_health


func _on_progress_bar_value_changed(value: float) -> void:
	$ProgressBar/Label.text = str(int(value))
