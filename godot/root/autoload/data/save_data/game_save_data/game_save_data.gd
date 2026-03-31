class_name GameSaveData
extends SaveData
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

signal coins_set(value: int)
signal max_clicks_per_second_set(value: int)
signal current_zone_index_set(value: int)
signal current_level_index_set(value: int)

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

var current_level_index: int:
	set(value):
		current_level_index = value
		current_level_index_set.emit(value)


func clear(_index: int = -1) -> void:
	coins = 0
	max_clicks_per_second = 0
	current_zone_index = 0
	current_level_index = 0
