extends Node

## Manages zones and level progression.
## Dynamically loads levels based on ZoneData and LevelData resources.

const GENERIC_LEVEL_TEMPLATE_PATH: String = \
		"res://root/scenes/scene/game_scene/game_content/game_levels/generic_level_template.tscn"

@export var zones: Array[ZoneData]


func _ready() -> void:
	LogWrapper.debug(self, "ZoneManager ready.")


## Returns the currently active zone based on save data.
func get_current_zone() -> ZoneData:
	var index: int = Data.game.current_zone_index
	if index >= 0 and index < zones.size():
		return zones[index]
	return null


## Returns the level data for the current index in the active zone.
func get_current_level_data() -> LevelData:
	var zone: ZoneData = get_current_zone()
	if not zone:
		return null
	return zone.get_level_data(Data.game.current_level_index)


## Returns the level template scene path to be instantiated.
func get_current_level_scene() -> PackedScene:
	# Now returns the generic template which will assemble itself in its _ready()
	if not ResourceLoader.exists(GENERIC_LEVEL_TEMPLATE_PATH):
		LogWrapper.error(self, "Generic Level Template not found at %s!" % GENERIC_LEVEL_TEMPLATE_PATH)
		return null
	return load(GENERIC_LEVEL_TEMPLATE_PATH)


## Advances to the next level. Returns true if successful, 
## or false if the zone is completed.
func advance_to_next_level() -> bool:
	var zone: ZoneData = get_current_zone()
	if not zone:
		return false
	
	var next_index: int = Data.game.current_level_index + 1
	if next_index < zone.get_level_count():
		Data.game.current_level_index = next_index
		return true
	
	SignalBus.zone_completed.emit(zone.zone_name)
	return false


## Sets the current zone and resets level index.
func set_zone(index: int) -> void:
	if index >= 0 and index < zones.size():
		Data.game.current_zone_index = index
		Data.game.current_level_index = 0
