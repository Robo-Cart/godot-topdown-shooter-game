class_name HUD
extends CanvasLayer

## Global HUD for managing multiple player UI instances.

var countdown_label: Label

@onready var player_ui_container: HBoxContainer = %PlayerUIContainer


func _ready() -> void:
	countdown_label = Label.new()
	countdown_label.name = "CountdownLabel"
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	countdown_label.add_theme_font_size_override("font_size", 128)
	countdown_label.visible = false
	add_child(countdown_label)


func show_countdown(seconds: int) -> void:
	player_ui_container.visible = false
	countdown_label.text = str(seconds)
	countdown_label.visible = true


func update_countdown(seconds: int) -> void:
	countdown_label.text = str(seconds)


func hide_countdown() -> void:
	countdown_label.visible = false
	player_ui_container.visible = true


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


## Removes a player UI instance from the HUD.
func remove_player_ui(player: Player) -> void:
	for child in player_ui_container.get_children():
		var ui: PlayerUI = child as PlayerUI
		if ui and ui.player == player:
			ui.queue_free()
			break
	_update_ui_layout()


func _update_ui_layout() -> void:
	var child_count: int = player_ui_container.get_child_count()
	if child_count == 0:
		return

	# Force layout recalculation of minimum size before we set pivot and scale
	player_ui_container.add_theme_constant_override("separation", 16)
	var target_scale: float = 1.0
	var target_sep: int = 16

	if child_count > 6:
		target_scale = 0.5
		target_sep = 40
	elif child_count > 4:
		target_scale = 0.7
		target_sep = 28
	else:
		target_scale = 1.0
		target_sep = 16

	player_ui_container.add_theme_constant_override("separation", target_sep)

	# Calculate unscaled combined size immediately
	var unscaled_size: Vector2 = player_ui_container.get_combined_minimum_size()
	player_ui_container.pivot_offset = unscaled_size / 2.0
	player_ui_container.scale = Vector2(target_scale, target_scale)

	# We still wait a frame to ensure Godot's internal layout engine catches up
	# and centers the container based on its new size.
	await get_tree().process_frame
	if is_instance_valid(player_ui_container):
		player_ui_container.pivot_offset = player_ui_container.size / 2.0
