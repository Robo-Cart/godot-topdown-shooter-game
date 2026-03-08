extends Node2D

enum Location { NORTH, EAST, SOUTH, WEST, RANDOM_SIDE, RANDOM_INNER }

@export var location: Location


func _ready() -> void:
	# Check for the new RANDOM_INNER enum to assign to the inner pool
	if self.location == Location.RANDOM_INNER:
		self.add_to_group("enemy_wave_spawner_inner")
	else:
		self.add_to_group("enemy_wave_spawner_edge")
