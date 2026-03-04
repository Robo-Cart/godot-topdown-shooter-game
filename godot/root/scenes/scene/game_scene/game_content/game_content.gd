# TODO: Consider extending the game options with: [br]
# - https://github.com/godotengine/godot-demo-projects/tree/master/3d/graphics_settings
extends Control

@onready var level_content_node: Node = $LevelContent
@onready var player: Player = get_tree().get_first_node_in_group("player")

var target_transition_area: String
var position_offset: Vector2
var player_characterbody2d_node: CollisionShape2D
var is_transitioning: bool = false


func _ready() -> void:
	LogWrapper.debug(self, "Scene ready.")
	# Load first level manually
	await get_tree().process_frame
	load_level_from_path(
		"res://root/scenes/scene/game_scene/game_content/game_levels/level_001.tscn",
		"LevelTransition",
		Vector2.ZERO
	)


func load_level_from_path(
	scene_path: String, _target_transition_area: String, _position_offset: Vector2
) -> void:
	# Safety check in case the path is empty, OR if we are already transitioning
	if scene_path == "" or is_transitioning:
		LogWrapper.debug(self, "No next level path provided or is already transitioning.")
		return

	is_transitioning = true
	get_tree().paused = true

	target_transition_area = _target_transition_area
	position_offset = _position_offset

	for child in player.get_children():
		if child is CollisionShape2D:
			player_characterbody2d_node = child
			player_characterbody2d_node.set_deferred("disabled", true)

	await get_tree().process_frame

	for child in level_content_node.get_children():
		child.queue_free()

	await get_tree().process_frame

	var new_scene_resource: Resource = load(scene_path)
	var new_level: Node2D = new_scene_resource.instantiate()

	level_content_node.add_child(new_level)

	await get_tree().process_frame

	# LevelTransition nodes must be a child of the top level node in a level
	# Loop through these to connect level transition signals
	# Also move the player to the target transition area and apply the offset
	for child in level_content_node.get_children():
		for grandchild in child.get_children():
			if grandchild.is_in_group("level_transition_area"):
				grandchild.transition_to_level.connect(_on_level_completed)
				if position_offset != Vector2.ZERO:  # first level load passes a zero offset, others will always have a value
					if grandchild.name == target_transition_area:
						player.global_position = grandchild.global_position + position_offset

	await get_tree().process_frame

	LogWrapper.debug(self, "Next level loaded: " + scene_path)

	get_tree().paused = false

	player_characterbody2d_node.set_deferred("disabled", false)

	# Wait for the physics engine to tick and clear the "ghost" state
	# We use two physics frames to guarantee a clean state update
	await get_tree().physics_frame
	await get_tree().physics_frame

	is_transitioning = false


func _on_level_completed(
	next_level_path: String, _target_transition_area: String, _position_offset: Vector2
) -> void:
	# Loop back around and load the new path
	load_level_from_path(next_level_path, _target_transition_area, _position_offset)
