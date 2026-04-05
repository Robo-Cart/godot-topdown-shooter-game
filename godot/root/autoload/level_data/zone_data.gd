class_name ZoneData
extends Resource

## A resource representing a themed group of levels (e.g., "Jurassic", "SciFi").
## Each zone defines a shared base environment and a list of levels.

@export var zone_name: String = "ZONE NAME"
## The shared base environment for all levels in this zone.
@export var base_tilemap: PackedScene
## List of level data resources defining each level's content.
@export var levels: Array[LevelData]
@export var zone_difficulty: int = 1
@export var zone_icon: Texture2D


## Returns the level data at a given index, if it exists.
func get_level_data(index: int) -> LevelData:
	if index >= 0 and index < levels.size():
		return levels[index]
	return null


## Returns the total number of levels in this zone.
func get_level_count() -> int:
	return levels.size()
