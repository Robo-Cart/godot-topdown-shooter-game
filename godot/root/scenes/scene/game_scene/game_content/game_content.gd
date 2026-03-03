# TODO: Consider extending the game options with: [br]
# - https://github.com/godotengine/godot-demo-projects/tree/master/3d/graphics_settings
extends Control

@onready var level_content_node: Node = $LevelContent
@onready var player: Player = get_tree().get_first_node_in_group("player")

var target_transition_area: String
var position_offset: Vector2


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

	target_transition_area = _target_transition_area
	position_offset = _position_offset

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
				if position_offset != Vector2.ZERO:
					if grandchild.name == target_transition_area:
						player.global_position = grandchild.global_position + position_offset
				grandchild.transition_to_level.connect(_on_level_completed)
				# hacky check to see if this is the first level load (i.e. if it is then position_offset = Vector2.ZERO)
				# in this case if it is then we skip trying to move the player

	await get_tree().process_frame

	get_tree().paused = false

	LogWrapper.debug(self, "Next level loaded: " + scene_path)


func _on_level_completed(
	next_level_path: String, _target_transition_area: String, _position_offset: Vector2
) -> void:
	# Loop back around and load the new path
	load_level_from_path(next_level_path, _target_transition_area, _position_offset)
