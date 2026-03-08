extends Resource
class_name EnemyWaveConfig

enum Direction { NORTH, EAST, SOUTH, WEST, RANDOM_SIDE, RANDOM_INNER }

@export var time_stamp: String = "0:00":
	set(value):
		time_stamp = value
		time = _convert_to_seconds(value)

var time: float = 0.0
@export var type: String
@export var density: int = 1
@export var spawn_points: Array[Direction]


func _convert_to_seconds(string_time: String) -> float:
	var parts: Array = string_time.split(":")
	if parts.size() == 2:
		var minutes: float = parts[0].to_float()
		var seconds: float = parts[1].to_float()
		return (minutes * 60.0) + seconds
	return string_time.to_float()
