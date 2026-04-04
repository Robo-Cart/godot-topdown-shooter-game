@tool
extends Node2D

## [level_variant.gd]
## This script is used for level variant/decoration scenes.
## It provides an editor-only preview of the zone's base tilemap to assist with alignment.
## At runtime, this script remains passive and does not instantiate the preview.

@export_group("Editor Only")
## The base scene (e.g., scifi_zone_base.tscn) to display behind this variant in the editor.
@export var editor_preview_base: PackedScene:
	set(value):
		editor_preview_base = value
		if Engine.is_editor_hint():
			_update_preview()

## Toggle to show or hide the base preview in the editor.
@export var show_preview: bool = true:
	set(value):
		show_preview = value
		if Engine.is_editor_hint():
			_update_preview()

var _preview_node: Node = null


func _ready() -> void:
	if Engine.is_editor_hint():
		_update_preview()
	else:
		# Safety: Ensure no editor preview nodes exist at runtime
		for child in get_children():
			if child.name == "_EditorPreviewBase":
				child.queue_free()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_preview_node):
			_preview_node.queue_free()


func _update_preview() -> void:
	# 1. Clean up existing preview
	if is_instance_valid(_preview_node):
		_preview_node.queue_free()
		_preview_node = null

	# 2. Instantiate new preview ONLY in editor
	if Engine.is_editor_hint() and show_preview and editor_preview_base:
		var instance: Node = editor_preview_base.instantiate()
		instance.name = "_EditorPreviewBase"

		# Ensure it's not saved into the variant scene
		instance.owner = null

		add_child(instance)
		move_child(instance, 0)

		_preview_node = instance