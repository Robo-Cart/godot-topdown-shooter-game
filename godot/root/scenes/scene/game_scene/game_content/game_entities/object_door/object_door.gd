@tool
class_name ObjectDoor
extends Node2D

enum DoorOrientation {
	HORIZONTAL,
	VERTICAL
}

@export var orientation_setting: ObjectDoor.DoorOrientation = ObjectDoor.DoorOrientation.HORIZONTAL:
	set(value):
		if orientation_setting == value:
			return
		orientation_setting = value
		if is_inside_tree():
			_update_visuals()

var _is_open: bool = false
var _anim_player: AnimationPlayer
var _static_body: StaticBody2D
var _spawn_request_count: int = 0
var _is_final_open: bool = false


func _ready() -> void:
	_update_visuals()
	_static_body = get_node_or_null("StaticBody2D") as StaticBody2D

	if not Engine.is_editor_hint():
		self.add_to_group("object_door")


## Opens the door visually and updates collision for an enemy spawn.
func open_door_for_spawn() -> void:
	if _is_final_open:
		return

	_spawn_request_count += 1
	if _spawn_request_count == 1:
		_play_open_animation()
	_update_collision()


## Permanently opens the door and disables all collision.
func open_door_final() -> void:
	if _is_final_open:
		return

	_is_final_open = true
	_play_open_animation()
	_update_collision()


## Closes the door if no more spawn requests are active.
func close_door() -> void:
	if _is_final_open:
		return

	if _spawn_request_count > 0:
		_spawn_request_count -= 1

	if _spawn_request_count == 0:
		_play_close_animation()
	_update_collision()


## Generic open door method for backward compatibility.
func open_door() -> void:
	open_door_final()


func _play_open_animation() -> void:
	if _is_open:
		return
	if _anim_player:
		_anim_player.play("open_door")
	_is_open = true


func _play_close_animation() -> void:
	if not _is_open:
		return
	if _anim_player:
		_anim_player.play("close_door")
	_is_open = false


func _update_visuals() -> void:
	var h_sprite: Sprite2D = get_node_or_null("HorizontalSprite2D") as Sprite2D
	var v_sprite1: Sprite2D = get_node_or_null("VerticalSprite2D1") as Sprite2D
	var v_sprite2: Sprite2D = get_node_or_null("VerticalSprite2D2") as Sprite2D

	if orientation_setting == DoorOrientation.HORIZONTAL:
		if h_sprite:
			h_sprite.visible = true
		if v_sprite1:
			v_sprite1.visible = false
		if v_sprite2:
			v_sprite2.visible = false
		_anim_player = get_node_or_null("HorizontalAnimationPlayer") as AnimationPlayer
	else:
		if h_sprite:
			h_sprite.visible = false
		if v_sprite1:
			v_sprite1.visible = true
		if v_sprite2:
			v_sprite2.visible = true
		_anim_player = get_node_or_null("VerticalAnimationPlayer") as AnimationPlayer
	_update_collision()


func _update_collision() -> void:
	if not _static_body:
		return

	var h_shape: CollisionShape2D = get_node_or_null("StaticBody2D/HorizontalShape") \
		as CollisionShape2D
	var v_shape: CollisionShape2D = get_node_or_null("StaticBody2D/VerticalShape") \
		as CollisionShape2D
	var active_shape: CollisionShape2D = h_shape \
		if orientation_setting == DoorOrientation.HORIZONTAL else v_shape
	var inactive_shape: CollisionShape2D = v_shape \
		if orientation_setting == DoorOrientation.HORIZONTAL else h_shape

	if inactive_shape:
		inactive_shape.set_deferred("disabled", true)
		inactive_shape.visible = false

	if active_shape:
		active_shape.set_deferred("disabled", _is_final_open)
		active_shape.visible = not _is_final_open

	if _is_final_open:
		_static_body.collision_layer = 0
	elif _spawn_request_count > 0:
		# Layer 4 (value 8) blocks Player (Mask 27) but not Enemies (Mask 19)
		_static_body.collision_layer = 8
	else:
		# Blocks Player (1/2/4), Enemies (1/2), and Bullets (2)
		_static_body.collision_layer = 1 | 2 | 8
