extends Node2D

enum Location { NORTH, EAST, SOUTH, WEST, INNER }

@export var location: Location


func _ready() -> void:
	if self.location == Location.INNER:
		self.add_to_group("enemy_wave_spawner_inner")
