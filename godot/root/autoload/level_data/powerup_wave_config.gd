extends Resource
class_name PowerupWaveConfig

# This is just a placeholder for now - need to think more about how powerup spawns work

@export var time_stamp: String = "0:00":
	set(value):
		time_stamp = value
		time = _convert_to_seconds(value)

var time: float = 0.0

@export var type: String  # update this to use a proper resource at some point
@export var random_factor: int = 0  # if more than zero then chance of deviating from schedule is higher


func _convert_to_seconds(string_time: String) -> float:
	var parts: Array = string_time.split(":")
	if parts.size() == 2:
		var minutes: float = parts[0].to_float()
		var seconds: float = parts[1].to_float()
		return (minutes * 60.0) + seconds
	return string_time.to_float()
