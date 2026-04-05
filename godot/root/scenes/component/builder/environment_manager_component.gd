extends Node
## [EnvironmentManagerComponent]
## Responsible for instantiating the modifier/decoration layer for a level.

var _level_data: LevelData


func setup(data: LevelData) -> void:
	_level_data = data
	_assemble_modifier()


func _assemble_environment() -> void:
	# Note: Base Tilemap assembly is now handled by the scene being the root itself.
	_assemble_modifier()


func _assemble_modifier() -> void:
	if not _level_data or not _level_data.modifier_scene:
		return

	var modifier_instance: Node = _level_data.modifier_scene.instantiate()

	# Add as a child of the current level root (the parent of this component)
	var parent_node: Node = get_parent()
	parent_node.add_child(modifier_instance)

	# Ensure it is moved to an appropriate layer (directly above the base tilemap at index 0)
	if parent_node.get_child_count() > 1:
		parent_node.move_child(modifier_instance, 1)

	LogWrapper.debug(self, "Modifier scene instantiated: %s" %
			_level_data.modifier_scene.resource_path)
