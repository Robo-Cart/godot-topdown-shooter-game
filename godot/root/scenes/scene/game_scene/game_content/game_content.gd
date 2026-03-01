# TODO: Consider extending the game options with: [br]
# - https://github.com/godotengine/godot-demo-projects/tree/master/3d/graphics_settings
extends Control

var _new_scene_path: String = "res://root/scenes/scene/game_scene/game_content/game_levels/level_002.tscn"

@onready var _level_content_node: Node = $LevelContent


func _ready() -> void:
	LogWrapper.debug(self, "Scene ready.")
	# Debug / experiment to double check that level scene can be switched
	replace_child_node(_level_content_node, _new_scene_path)


func replace_child_node(_old_node: Node, _new_scene_path_to_load: String) -> void:
	# Disabled for now
	return
	# 1. Load and instantiate the new scene
	# Note: In Godot 4, we use instantiate(), not instance()
	#var scene_resource: PackedScene = load(_new_scene_path_to_load)
	#var new_node: Node2D = scene_resource.instantiate()
#
## 2. Get the parent and the old node's index (its order in the tree)
#var parent: Control = old_node.get_parent()
#var index: int = old_node.get_index()
#
## 3. Add the new node to the parent
#parent.add_child(new_node)
#
## 4. Move the new node to the old node's exact position in the hierarchy
#parent.move_child(new_node, index)
#
## 5. Copy the transform so it appears in the exact same physical spot
#new_node.global_transform = old_node.global_transform
#
## 6. Safely delete the old node at the end of the current frame
#old_node.queue_free()
