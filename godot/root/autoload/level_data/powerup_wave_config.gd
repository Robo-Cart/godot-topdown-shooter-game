@tool
class_name PowerupWaveConfig
extends Resource

@export var time_stamp: String = "0:00":
	set(value):
		time_stamp = value
		time = _convert_to_seconds(value)
@export_file("*.tscn") var powerup_scene_path: String:
	set(value):
		powerup_scene_path = value
		_update_powerup_name()
@export var display_name: String = "Default Powerup"
@export var random_factor: int = 0
@export var spawn_points: Array[SpawnConfig.Location]

var time: float = 0.0


func _convert_to_seconds(string_time: String) -> float:
	var parts: Array = string_time.split(":")
	if parts.size() == 2:
		var minutes: float = parts[0].to_float()
		var seconds: float = parts[1].to_float()
		return (minutes * 60.0) + seconds
	return string_time.to_float()


func _update_powerup_name() -> void:
	if powerup_scene_path == "" or not ResourceLoader.exists(powerup_scene_path):
		return

	var scene: PackedScene = load(powerup_scene_path)

	if scene:
		var real_file_path: String = scene.resource_path

		display_name = real_file_path.get_file().get_basename().capitalize()
