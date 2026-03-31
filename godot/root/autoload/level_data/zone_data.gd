class_name ZoneData
extends Resource

## A resource representing a themed group of levels (e.g., "Jurassic", "SciFi").

@export var zone_name: String = "ZONE NAME"
@export var levels: Array[PackedScene]
@export var zone_difficulty: int = 1
@export var zone_icon: Texture2D


## Returns the level scene at a given index, if it exists.
func get_level_scene(index: int) -> PackedScene:
	if index >= 0 and index < levels.size():
		return levels[index]
	return null


## Returns the total number of levels in this zone.
func get_level_count() -> int:
	return levels.size()
