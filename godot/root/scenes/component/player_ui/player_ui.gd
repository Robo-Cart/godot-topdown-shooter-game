class_name PlayerUI
extends PanelContainer

## Player UI component for managing and displaying player stats.

@onready var health_bar: ProgressBar = %HealthBar
@onready var lives_container: HBoxContainer = %LivesContainer
@onready var powerups_container: HBoxContainer = %PowerupsContainer
@onready var player_face: TextureRect = %PlayerFace


func _ready() -> void:
	LogWrapper.debug(self, "PlayerUI ready.")


## Connects the UI to a specific Player instance.
func setup(player: Player) -> void:
	if not player:
		return

	# Connect to health changes
	if player.health_comp:
		player.health_comp.health_changed.connect(_on_player_health_changed)
		_update_health_ui(player.health_comp.current_health, player.health_comp.max_health)

	# Connect to life changes
	player.lives_changed.connect(_on_player_lives_changed)
	_update_lives_ui(player.current_lives, player.max_lives)


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	_update_health_ui(current_health, max_health)


func _on_player_lives_changed(current_lives: int, max_lives: int) -> void:
	_update_lives_ui(current_lives, max_lives)


## Updates the health bar visual.
func _update_health_ui(current: int, total: int) -> void:
	if health_bar:
		health_bar.max_value = total
		health_bar.value = current


## Rebuilds the lives visual indicators.
func _update_lives_ui(current: int, _total: int) -> void:
	if not is_inside_tree():
		return

	# Clear existing life icons
	for child in lives_container.get_children():
		child.queue_free()

	# Add new life icons (squares)
	for i in range(current):
		# Use AspectRatioContainer to force squares
		var aspect_container := AspectRatioContainer.new()
		aspect_container.ratio = 1.0
		aspect_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
		aspect_container.size_flags_vertical = Control.SIZE_FILL
		aspect_container.alignment_horizontal = AspectRatioContainer.ALIGNMENT_BEGIN
		aspect_container.alignment_vertical = AspectRatioContainer.ALIGNMENT_CENTER

		var life_square: ColorRect = ColorRect.new()
		life_square.color = Color.WHITE
		life_square.custom_minimum_size = Vector2(10, 10)

		aspect_container.add_child(life_square)
		lives_container.add_child(aspect_container)
