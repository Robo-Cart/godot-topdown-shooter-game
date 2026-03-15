@tool
class_name ObjectDoor
extends Node2D

enum ORIENTATION {
	HORIZONTAL,
	VERTICAL
}

@export var orientation_setting: ORIENTATION = ORIENTATION.HORIZONTAL:
	set(v):
		orientation_setting = v
		if is_inside_tree():
			_update_visuals()


var is_open: bool = false
var anim_player: AnimationPlayer


func _ready() -> void:
	_update_visuals()
	if not Engine.is_editor_hint():
		self.add_to_group("object_door")

		open_door()


func _update_visuals() -> void:
	var h_sprite: Sprite2D = get_node_or_null("HorizontalSprite2D")
	var v_sprite1: Sprite2D = get_node_or_null("VerticalSprite2D1")
	var v_sprite2: Sprite2D = get_node_or_null("VerticalSprite2D2")

	if orientation_setting == ORIENTATION.HORIZONTAL:
		if h_sprite:
			h_sprite.visible = true
		if v_sprite1:
			v_sprite1.visible = false
		if v_sprite2:
			v_sprite2.visible = false
		anim_player = get_node_or_null("HorizontalAnimationPlayer")
		if not Engine.is_editor_hint():
			LogWrapper.debug(self, "Horizontal door selected.")
	else:
		if h_sprite:
			h_sprite.visible = false
		if v_sprite1:
			v_sprite1.visible = true
		if v_sprite2:
			v_sprite2.visible = true
		anim_player = get_node_or_null("VerticalAnimationPlayer")
		if not Engine.is_editor_hint():
			LogWrapper.debug(self, "Vertical door selected.")


func open_door() -> void:
	if is_open:
		return
	if anim_player:
		anim_player.play("open_door")
	is_open = true


func close_door() -> void:
	if !is_open:
		return
	if anim_player:
		anim_player.play("close_door")
	is_open = false
