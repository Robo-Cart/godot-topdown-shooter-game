extends Node

## Manages zones and level progression.
## Dynamically loads levels based on ZoneData and LevelData resources.

@export var zones: Array[ZoneData]

var _current_world_map: WorldMap


func _ready() -> void:
	LogWrapper.debug(self, "ZoneManager ready.")


## Returns the currently active zone based on save data.
func get_current_zone() -> ZoneData:
	var index: int = Data.game.current_zone_index
	if index >= 0 and index < zones.size():
		return zones[index]
	return null


## Returns the current WorldMap, generating it if necessary.
func get_world_map() -> WorldMap:
	if _current_world_map != null:
		return _current_world_map

	var zone: ZoneData = get_current_zone()
	if not zone:
		return null

	if Data.game.current_zone_seed == 0:
		Data.game.current_zone_seed = randi()
		Data.save_save_file()

	_current_world_map = WorldGenerator.generate_world(zone, Data.game.current_zone_seed)
	return _current_world_map


## Returns the level data for the current coords in the active world map.
func get_current_level_data() -> LevelData:
	var map: WorldMap = get_world_map()
	if map:
		var cell: MapCell = map.get_cell(Data.game.current_level_coords)
		if cell:
			return cell.level_data
	return null


## Returns the level scene (Base Tilemap) to be instantiated.
func get_current_level_scene() -> PackedScene:
	var zone: ZoneData = get_current_zone()
	if not zone:
		return null

	# We load the Base Tilemap directly as the root of the level
	return zone.base_tilemap


## Checks if the door in the given direction leads to a valid, unvisited room.
func is_door_valid(direction_offset: Vector2i) -> bool:
	var target_coords: Vector2i = Data.game.current_level_coords + direction_offset
	var map: WorldMap = get_world_map()

	if map and map.has_cell(target_coords):
		if not Data.game.visited_levels.has(target_coords):
			return true

	return false


## Advances to the next level in the given direction.
## Returns true if successful, or false if the zone is completed (boss killed).
func advance_to_next_level(direction_offset: Vector2i) -> bool:
	var map: WorldMap = get_world_map()
	if not map:
		return false

	var current_coords: Vector2i = Data.game.current_level_coords
	var current_cell: MapCell = map.get_cell(current_coords)

	# Check if we are completing the boss
	if current_cell and current_cell.is_exit:
		var zone: ZoneData = get_current_zone()
		if zone:
			SignalBus.zone_completed.emit(zone.zone_name)
		return false

	# Otherwise, mark current as visited and advance
	if not Data.game.visited_levels.has(current_coords):
		Data.game.visited_levels.append(current_coords)

	Data.game.current_level_coords += direction_offset
	Data.save_save_file()
	return true


## Sets the current zone and resets level coords to the entrance.
func set_zone(index: int) -> void:
	if index >= 0 and index < zones.size():
		Data.game.current_zone_index = index
		Data.game.current_zone_seed = randi()
		Data.game.visited_levels.clear()
		_current_world_map = null

		var map: WorldMap = get_world_map()
		if map:
			Data.game.current_level_coords = map.get_entrance_coords()

		Data.save_save_file()
