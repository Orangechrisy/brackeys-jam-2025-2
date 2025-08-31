extends Control

@onready var ItemLabel: Label = $PanelContainer/MarginContainer/VBoxContainer/ItemLabel
@onready var DescLabel: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel

var on_mouse: bool = true

func _ready() -> void:
	hide()

var popup_active: bool = false
func _physics_process(_delta: float) -> void:
	if GameManager.no_eyes and get_tree().current_scene.name == "shop":
		hide()
	else:
		if on_mouse:
			if popup_active:
				var mouse_pos = Vector2(get_global_mouse_position().x+40.0,get_global_mouse_position().y+40.0)
				if mouse_pos.x > 1350.0:
					mouse_pos.x -= 380.0
				#var mouse_pos = Vector2(500.0, 500.0)
				$PanelContainer.global_position = mouse_pos
		else:
			show()
			$PanelContainer.global_position = Vector2(1300.0,500.0)

func InfoPopup(itemID: int, nextToMouse: bool):
	
	$PanelContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tooltip_pos: Vector2
	if nextToMouse:
		on_mouse=true
		var mouse_pos = Vector2(get_global_mouse_position().x+40.0,get_global_mouse_position().y+40.0)
		if mouse_pos.x > 1350.0:
			mouse_pos.x -= 380.0
		tooltip_pos = mouse_pos
	else:
		on_mouse=false
		tooltip_pos = Vector2(1300.0,500.0)
		
	$PanelContainer.global_position = tooltip_pos
	popup_active=true
	show()
	
	#Rarities
	#var color = ItemLabel.label_settings
	if GameManager.partChance[itemID] == GameManager.common:
		ItemLabel.add_theme_color_override("font_color", "#a3a3a3")
	elif GameManager.partChance[itemID] == GameManager.uncommon:
		ItemLabel.add_theme_color_override("font_color", "#00f102")
	elif GameManager.partChance[itemID] == GameManager.rare:
		ItemLabel.add_theme_color_override("font_color", "#dc28ff")
	else:
		ItemLabel.add_theme_color_override("font_color", "#f4f021")
	
	ItemLabel.text = GameManager.partName[itemID]
	DescLabel.text = GameManager.partTooltip[itemID]
	
func HidePopup():
	popup_active=false
	hide()
