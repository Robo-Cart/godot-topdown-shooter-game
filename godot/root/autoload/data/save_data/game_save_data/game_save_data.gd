class_name GameSaveData
extends SaveData
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal coins_set(value: int)
signal max_clicks_per_second_set(value: int)
signal current_zone_index_set(value: int)
signal current_level_coords_set(value: Vector2i)

var coins: int:
	set(value):
		coins = value
		coins_set.emit(value)

var max_clicks_per_second: int:
	set(value):
		max_clicks_per_second = value
		max_clicks_per_second_set.emit(value)

var current_zone_index: int:
	set(value):
		current_zone_index = value
		current_zone_index_set.emit(value)

var current_zone_seed: int = 0

var current_level_coords: Vector2i:
	set(value):
		current_level_coords = value
		current_level_coords_set.emit(value)

var visited_levels: Array[Vector2i] = []


func clear(_index: int = -1) -> void:
	coins = 0
	max_clicks_per_second = 0
	current_zone_index = 0
	current_zone_seed = 0
	current_level_coords = Vector2i.ZERO
	visited_levels.clear()


func get_as_dict() -> Dictionary:
	var dict: Dictionary = super.get_as_dict()
	dict["current_level_coords"] = var_to_str(current_level_coords)
	var visited: Array[String] = []
	for v: Vector2i in visited_levels:
		visited.append(var_to_str(v))
	dict["visited_levels"] = visited
	return dict


func set_from_dict(dict: Dictionary, index: int = -1) -> void:
	if dict.has("current_level_index"):
		# Old format detected, wipe and reset
		if index != -1:
			Data.delete_save_file_index(index)
		clear(index)
		return

	# Extract custom properties before calling super so we don't trip type checks
	var coords_str: Variant = dict.get("current_level_coords", null)
	var visited_arr: Variant = dict.get("visited_levels", null)

	dict.erase("current_level_coords")
	dict.erase("visited_levels")

	super.set_from_dict(dict, index)

	if typeof(coords_str) == TYPE_STRING:
		current_level_coords = str_to_var(coords_str as String)

	visited_levels.clear()
	if typeof(visited_arr) == TYPE_ARRAY:
		for v: Variant in visited_arr as Array:
			if typeof(v) == TYPE_STRING:
				visited_levels.append(str_to_var(v as String))
