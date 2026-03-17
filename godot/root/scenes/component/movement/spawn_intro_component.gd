class_name SpawnIntroComponent
extends Node

## How far past the door (in pixels) the enemy should walk before tracking the player.
@export var entrance_offset: float = 40.0 

var is_intro_active: bool = false
var _spawn_location: SpawnConfig.Location
var _target_door: ObjectDoor
var _parent: Node2D

func _ready() -> void:
	_parent = get_parent() as Node2D
	if not _parent:
		LogWrapper.debug(self, "SpawnIntroComponent must be a child of a Node2D!")


## Initializes the intro behavior. Called by Level.gd.
func setup(location: SpawnConfig.Location, door: ObjectDoor) -> void:
	if not door:
		return
		
	_spawn_location = location
	_target_door = door
	is_intro_active = true


## Returns the position the enemy should move toward. 
## If intro is active, returns a point past the door. Otherwise returns the provided player position.
func get_target_position(player_position: Vector2) -> Vector2:
	if not is_intro_active or not _target_door:
		return player_position
	
	# Check if we have passed the door threshold
	if _has_passed_door():
		is_intro_active = false
		return player_position
	
	# Target a point well past the door to ensure we keep moving through it
	var push_vector: Vector2 = Vector2.ZERO
	match _spawn_location:
		SpawnConfig.Location.NORTH: push_vector = Vector2.DOWN
		SpawnConfig.Location.SOUTH: push_vector = Vector2.UP
		SpawnConfig.Location.WEST:  push_vector = Vector2.RIGHT
		SpawnConfig.Location.EAST:  push_vector = Vector2.LEFT
		
	return _target_door.global_position + (push_vector * (entrance_offset + 20.0))


func _has_passed_door() -> bool:
	if not _target_door or not _parent:
		return true
		
	var pos: Vector2 = _parent.global_position
	var door_pos: Vector2 = _target_door.global_position
	
	# We use coordinate thresholds to ensure they are "inside" the play area
	match _spawn_location:
		SpawnConfig.Location.NORTH:
			return pos.y > door_pos.y + entrance_offset
		SpawnConfig.Location.SOUTH:
			return pos.y < door_pos.y - entrance_offset
		SpawnConfig.Location.WEST:
			return pos.x > door_pos.x + entrance_offset
		SpawnConfig.Location.EAST:
			return pos.x < door_pos.x - entrance_offset
			
	return true
