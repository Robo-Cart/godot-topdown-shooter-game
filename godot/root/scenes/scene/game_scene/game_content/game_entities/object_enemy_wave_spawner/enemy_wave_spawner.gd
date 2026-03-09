extends Node2D

@export var location: SpawnConfig.Location


func _ready() -> void:
	if self.location == SpawnConfig.Location.RANDOM_INNER:
		self.add_to_group("enemy_wave_spawner_inner")
	else:
		self.add_to_group("enemy_wave_spawner_edge")
