@tool
class_name LevelTransition extends Area2D

signal transition_to_level(
	next_level_path: String, target_transition_area: String, location_offset: Vector2
)

@onready var player: Player = get_tree().get_first_node_in_group("player")

enum SIDE { NORTH, EAST, SOUTH, WEST }

@export_file("*.tscn") var level: String
@export var target_transition_area: String = "LevelTransition"

@export_category("Collision Area Settings")

@export_range(1, 12, 1, "or_greater") var size: int = 2:
	set(_v):
		size = _v
		_update_area()

@export var pixel_size: int = 32
@export var side: SIDE = SIDE.WEST:
	set(_v):
		side = _v
		_update_area()

@export var snap_to_grid: bool = false:
	set(_v):
		_snap_to_grid()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("level_transition_area")
	_update_area()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_player_entered)


func get_offset() -> Vector2:
	var offset: Vector2 = Vector2.ZERO
	var player_position: Vector2 = player.global_position

	# Create a safe spawn distance that clears the area + player radius
	var safe_distance: float = pixel_size * 2.0

	if side == SIDE.WEST or side == SIDE.EAST:
		offset.y = player_position.y - global_position.y
		offset.x = safe_distance
		if side == SIDE.WEST:
			offset.x *= -1
	else:
		offset.x = player_position.x - global_position.x
		offset.y = safe_distance
		if side == SIDE.NORTH:
			offset.y *= -1

	return offset


func _player_entered(_player: Node2D) -> void:
	if _player != player:
		return
	LogWrapper.debug(self, "Player entered transition area.")
	transition_to_level.emit(level, target_transition_area, get_offset())


func _update_area() -> void:
	var new_rect: Vector2 = Vector2(pixel_size, pixel_size)
	var new_position: Vector2 = Vector2.ZERO

	if side == SIDE.NORTH:
		new_rect.x *= size
		new_position.y -= pixel_size / 2
	elif side == SIDE.SOUTH:
		new_rect.x *= size
		new_position.y += pixel_size / 2
	elif side == SIDE.WEST:
		new_rect.y *= size
		new_position.x -= pixel_size / 2
	elif side == SIDE.EAST:
		new_rect.y *= size
		new_position.x += pixel_size / 2

	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")

	collision_shape.shape.size = new_rect
	collision_shape.position = new_position


func _snap_to_grid() -> void:
	position.x = round(position.x / (pixel_size / 2)) * 16
	position.y = round(position.y / (pixel_size / 2)) * 16
