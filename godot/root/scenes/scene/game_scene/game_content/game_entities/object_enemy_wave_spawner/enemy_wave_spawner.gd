extends Node2D

@export var location: SpawnConfig.Location


func _ready() -> void:
	if self.location == SpawnConfig.Location.RANDOM_INNER:
		self.add_to_group("enemy_wave_spawner_inner")
	elif self.location == SpawnConfig.Location.MAIN_BOSS:
		self.add_to_group("enemy_wave_spawner_boss")
	else: # If not any of above it'll be a NESW spawn point
		self.add_to_group("enemy_wave_spawner_edge")