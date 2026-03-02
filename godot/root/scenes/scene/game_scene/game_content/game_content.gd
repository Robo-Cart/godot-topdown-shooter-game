# TODO: Consider extending the game options with: [br]
# - https://github.com/godotengine/godot-demo-projects/tree/master/3d/graphics_settings
extends Control

@onready var level_content_node: Node = $LevelContent
@onready var player: Player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	LogWrapper.debug(self, "Scene ready.")
	# Load first level manually
	load_level_from_path(
		"res://root/scenes/scene/game_scene/game_content/game_levels/level_001.tscn",
		"LevelTransition",
		Vector2.ZERO
	)


func load_level_from_path(
	scene_path: String, _target_transition_area: String, _position_offset: Vector2
) -> void:
	# Safety check in case the path is empty
	if scene_path == "":
		LogWrapper.debug(self, "No next level path provided.")
		return

	get_tree().paused = true

	await get_tree().process_frame  # Level Transition

	for child in level_content_node.get_children():
		child.queue_free()

	await get_tree().process_frame  # Level Transition

	var new_scene_resource: Resource = load(scene_path)
	var new_level: Node2D = new_scene_resource.instantiate()

	level_content_node.add_child(new_level)

	await get_tree().process_frame  # Level Transition

	# LevelTransition nodes must be a child of the top level node in a level
	for child in level_content_node.get_children():
		for grandchild in child.get_children():
			if grandchild.is_in_group("level_transition_area"):
				grandchild.transition_to_level.connect(_on_level_completed)

	get_tree().paused = false

	LogWrapper.debug(self, "Next level loaded: " + scene_path)


func _on_level_completed(
	next_level_path: String, _target_transition_area: String, _position_offset: Vector2
) -> void:
	# Loop back around and load the new path
	load_level_from_path(next_level_path, _target_transition_area, _position_offset)
