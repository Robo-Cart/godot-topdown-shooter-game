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
		open_door()


func _update_visuals() -> void:
	var h_sprite: Sprite2D = find_child("HorizontalSprite2D", true, false)
	var v_sprite1: Sprite2D = find_child("VerticalSprite2D1", true, false)
	var v_sprite2: Sprite2D = find_child("VerticalSprite2D2", true, false)

	if orientation_setting == ORIENTATION.HORIZONTAL:
		if h_sprite:
			h_sprite.visible = true
		if v_sprite1:
			v_sprite1.visible = false
		if v_sprite2:
			v_sprite2.visible = false
		anim_player = find_child("HorizontalAnimationPlayer", true, false)
		LogWrapper.debug(self, "Horizontal door selected.")
	else:
		if h_sprite:
			h_sprite.visible = false
		if v_sprite1:
			v_sprite1.visible = true
		if v_sprite2:
			v_sprite2.visible = true
		anim_player = find_child("VerticalAnimationPlayer", true, false)
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
