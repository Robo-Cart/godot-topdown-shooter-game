extends Node2D

enum Side { NORTH, EAST, SOUTH, WEST }

@export_file() var enemy_spawn_config: String
@export var side: Side


func _ready() -> void:
	pass
