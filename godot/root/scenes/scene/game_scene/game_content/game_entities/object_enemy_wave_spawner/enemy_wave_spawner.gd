extends Node2D

@export var location: SpawnConfig.Location

@onready var _spawn_target: Marker2D = $SpawnTarget


func _ready() -> void:
	if self.location == SpawnConfig.Location.RANDOM_INNER:
		self.add_to_group("enemy_wave_spawner_inner")
	elif self.location == SpawnConfig.Location.MAIN_BOSS:
		self.add_to_group("enemy_wave_spawner_boss")
	else:  # If not any of above it'll be a NESW spawn point
		self.add_to_group("enemy_wave_spawner_edge")


## Returns the global position the enemy should move toward during the intro.
## If the SpawnTarget node has not been moved from its default local position,
## this defaults to the world center (0,0).
func get_target_position() -> Vector2:
	if _spawn_target.position == Vector2.ZERO:
		return Vector2.ZERO
	return _spawn_target.global_position
