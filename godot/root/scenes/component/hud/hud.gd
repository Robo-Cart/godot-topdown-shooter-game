class_name HUD
extends CanvasLayer

## Global HUD for managing multiple player UI instances.

@onready var player_ui_container: HBoxContainer = %PlayerUIContainer


## Gets the player UI instance for a specific player index.
func get_player_ui(index: int) -> PlayerUI:
	if index >= 0 and index < player_ui_container.get_child_count():
		return player_ui_container.get_child(index) as PlayerUI
	return null


## Adds a new player UI instance to the HUD.
func add_player_ui() -> PlayerUI:
	var PlayerUiScene: PackedScene = preload("res://root/scenes/component/player_ui/player_ui.tscn")
	var new_player_ui: PlayerUI = PlayerUiScene.instantiate() as PlayerUI
	player_ui_container.add_child(new_player_ui)
	_update_ui_layout()
	return new_player_ui


## Sets up a specific player UI with a player instance.
func setup_player_ui(index: int, player: Player) -> void:
	var ui: PlayerUI = get_player_ui(index)
	if ui:
		ui.setup(player)


func _update_ui_layout() -> void:
	var child_count: int = player_ui_container.get_child_count()
	player_ui_container.alignment = BoxContainer.ALIGNMENT_CENTER

	if child_count > 4:
		player_ui_container.scale = Vector2(0.5, 0.5)
		# Adjust separation for smaller scale
		player_ui_container.add_theme_constant_override("separation", 40)
	else:
		player_ui_container.scale = Vector2(1.0, 1.0)
		player_ui_container.add_theme_constant_override("separation", 10)
