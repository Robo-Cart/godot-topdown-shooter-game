class_name SpawnIntroComponent
extends Node

## How far past the door (in pixels) the enemy should walk before tracking the player.
@export var entrance_offset: float = 40.0

var is_intro_active: bool = false
var _spawn_location: SpawnConfig.Location
var _target_door: ObjectDoor
var _parent: Node2D
var _custom_target: Vector2 = Vector2.ZERO


func _ready() -> void:
	_parent = get_parent() as Node2D
	if not _parent:
		LogWrapper.debug(self, "SpawnIntroComponent must be a child of a Node2D!")


## Initializes the intro behavior. Called by WaveManagerComponent.
func setup(loc: SpawnConfig.Location, door: ObjectDoor, target: Vector2 = Vector2.ZERO) -> void:
	_spawn_location = loc
	_target_door = door
	_custom_target = target
	is_intro_active = true


## Returns the position the enemy should move toward.
## If intro is active, returns a point past the door or the custom target.
# Otherwise returns the provided player position.
func get_target_position(player_position: Vector2) -> Vector2:
	if not is_intro_active:
		return player_position

	# Check if we have passed the intro threshold
	if _has_passed_intro():
		is_intro_active = false
		return player_position

	# If a custom target is provided, use it
	if _custom_target != Vector2.ZERO:
		return _custom_target

	if not _target_door:
		return player_position

	# Fallback: Target a point well past the door to ensure we keep moving through it
	var push_vector: Vector2 = Vector2.ZERO
	match _spawn_location:
		SpawnConfig.Location.NORTH:
			push_vector = Vector2.DOWN
		SpawnConfig.Location.SOUTH:
			push_vector = Vector2.UP
		SpawnConfig.Location.WEST:
			push_vector = Vector2.RIGHT
		SpawnConfig.Location.EAST:
			push_vector = Vector2.LEFT

	return _target_door.global_position + (push_vector * (entrance_offset + 20.0))


func _has_passed_intro() -> bool:
	if not _parent:
		return true

	# Check if we've reached the custom target if one exists
	if _custom_target != Vector2.ZERO:
		return _parent.global_position.distance_to(_custom_target) < 20.0

	if not _target_door:
		return true

	var pos: Vector2 = _parent.global_position
	var door_pos: Vector2 = _target_door.global_position
	var passed: bool = true

	# We use coordinate thresholds to ensure they are "inside" the play area
	match _spawn_location:
		SpawnConfig.Location.NORTH:
			passed = pos.y > door_pos.y + entrance_offset
		SpawnConfig.Location.SOUTH:
			passed = pos.y < door_pos.y - entrance_offset
		SpawnConfig.Location.WEST:
			passed = pos.x > door_pos.x + entrance_offset
		SpawnConfig.Location.EAST:
			passed = pos.x < door_pos.x - entrance_offset

	return passed
