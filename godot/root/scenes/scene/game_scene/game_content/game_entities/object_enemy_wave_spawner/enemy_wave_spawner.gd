extends Node2D

@export var location: SpawnConfig.Location


func _ready() -> void:
	var funnel: Node2D = get_node_or_null("FunnelWalls")
	if self.location == SpawnConfig.Location.RANDOM_INNER:
		self.add_to_group("enemy_wave_spawner_inner")
		if funnel:
			funnel.queue_free()
	elif self.location == SpawnConfig.Location.MAIN_BOSS:
		self.add_to_group("enemy_wave_spawner_boss")
		if funnel:
			funnel.queue_free()
	else: # If not any of above it'll be a NESW spawn point
		self.add_to_group("enemy_wave_spawner_edge")
		if funnel:
			match self.location:
				SpawnConfig.Location.NORTH:
					funnel.rotation_degrees = 0 # Pointing Down
				SpawnConfig.Location.EAST:
					funnel.rotation_degrees = 90 # Pointing Left
				SpawnConfig.Location.SOUTH:
					funnel.rotation_degrees = 180 # Pointing Up
				SpawnConfig.Location.WEST:
					funnel.rotation_degrees = 270 # Pointing Right
