@tool  # <-- REQUIRED: Allows this script to run inside the Godot Editor
extends Resource
class_name EnemyWaveConfig

enum Location { NORTH, EAST, SOUTH, WEST, RANDOM_SIDE, RANDOM_INNER }

@export var time_stamp: String = "0:00":
	set(value):
		time_stamp = value
		time = _convert_to_seconds(value)

var time: float = 0.0

@export var enemy_name: String = "Default Enemy"

# Added a setter here so it triggers when you assign a file in the Inspector
@export_file("*.tscn") var enemy_scene_path: String:
	set(value):
		enemy_scene_path = value
		_update_enemy_name()

@export var number_of_enemies: int = 1
@export var seconds_to_spawn_over: float = 0.0
@export var spawn_points: Array[Location]


func _convert_to_seconds(string_time: String) -> float:
	var parts: Array = string_time.split(":")
	if parts.size() == 2:
		var minutes: float = parts[0].to_float()
		var seconds: float = parts[1].to_float()
		return (minutes * 60.0) + seconds
	return string_time.to_float()


func _update_enemy_name() -> void:
	if enemy_scene_path == "" or not ResourceLoader.exists(enemy_scene_path):
		return

	var scene: PackedScene = load(enemy_scene_path)
	if scene:
		var temp_instance: Node = scene.instantiate()
		if "display_name" in temp_instance:
			enemy_name = temp_instance.get("display_name")

		else:
			enemy_name = enemy_scene_path.get_file().get_basename().capitalize()

		temp_instance.free()
