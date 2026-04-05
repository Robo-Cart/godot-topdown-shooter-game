# TODO: Consider extending the game options with: [br]
# - https://github.com/godotengine/godot-demo-projects/tree/master/3d/graphics_settings
extends Control

var target_transition_area: String
var position_offset: Vector2
var player_characterbody2d_node: CollisionShape2D
var is_transitioning: bool = false

@onready var level_content_node: Node = $LevelContent
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	LogWrapper.debug(self, "Scene ready.")
	SignalBus.level_transition_triggered.connect(_on_level_transition_triggered)
	# Load current level based on ZoneManager state
	await get_tree().process_frame
	load_current_level()


func load_current_level(
	_target_transition_area: String = "LevelTransition", _position_offset: Vector2 = Vector2.ZERO
) -> void:
	var level_scene: PackedScene = ZoneManager.get_current_level_scene()
	if not level_scene:
		LogWrapper.error(self, "No level scene found in current zone!")
		return

	_load_level(level_scene, _target_transition_area, _position_offset)


func _load_level(
	level_scene: PackedScene, _target_transition_area: String, _position_offset: Vector2
) -> void:
	# Safety check in case we are already transitioning
	if is_transitioning:
		LogWrapper.debug(self, "Already transitioning.")
		return

	is_transitioning = true
	get_tree().paused = true

	target_transition_area = _target_transition_area
	position_offset = _position_offset

	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var player_col_shapes: Array[CollisionShape2D] = []

	for p in players:
		for child in p.get_children():
			if child is CollisionShape2D:
				player_col_shapes.append(child)
				child.set_deferred("disabled", true)

	await get_tree().process_frame

	for child in level_content_node.get_children():
		child.queue_free()

	await get_tree().process_frame

	var new_level: Node2D = level_scene.instantiate()
	level_content_node.add_child(new_level)

	await get_tree().process_frame

	# Move the player to the target transition area and apply the offset
	if position_offset != Vector2.ZERO:
		for child in level_content_node.get_children():
			for grandchild in child.get_children():
				if grandchild.is_in_group("level_transition_area"):
					if grandchild.name == target_transition_area:
						# Reposition all players near the target transition area with a spread
						var base_pos: Vector2 = grandchild.global_position + position_offset
						var players_count: int = players.size()

						# Calculate spread grid (e.g., 3x3 for up to 8-9 players)
						var cols: int = ceili(sqrt(players_count))
						var grid_spacing: float = 50.0 # Enough to clear collision shapes

						for i in range(players_count):
							var row: int = i / cols
							var col: int = i % cols

							# Center the grid around the base position
							var row_count: int = ceili(float(players_count) / cols)
							var offset: Vector2 = Vector2(
								(col - (cols - 1) / 2.0) * grid_spacing,
								(row - (row_count - 1) / 2.0) * grid_spacing
							)

							(players[i] as Node2D).global_position = base_pos + offset
	elif Data.game.current_level_index == 0:
		# Reposition all players within 25% of screen width from camera center
		var viewport_rect: Rect2 = get_viewport().get_visible_rect()
		var camera: Camera2D = get_viewport().get_camera_2d()
		var spawn_center: Vector2 = viewport_rect.size / 2.0
		if camera:
			spawn_center = camera.get_screen_center_position()

		var max_offset: float = viewport_rect.size.x * 0.25

		for p in players:
			(p as Node2D).global_position = spawn_center + Vector2(
				randf_range(-max_offset, max_offset),
				randf_range(-max_offset, max_offset)
			)

	await get_tree().process_frame

	LogWrapper.debug(self, "Next level loaded from ZoneManager.")

	get_tree().paused = false

	for col in player_col_shapes:
		col.set_deferred("disabled", false)

	# Wait for the physics engine to tick and clear the "ghost" state
	# We use two physics frames to guarantee a clean state update
	await get_tree().physics_frame
	await get_tree().physics_frame

	is_transitioning = false


func _on_level_transition_triggered(
	_target_transition_area: String, _position_offset: Vector2
) -> void:
	if ZoneManager.advance_to_next_level():
		load_current_level(_target_transition_area, _position_offset)
	else:
		LogWrapper.debug(self, "Zone completed!")
