class_name LevelData
extends Resource

## Data resource defining a level's properties, waves, and layout modifiers.

@export var level_name: String = "LEVEL NAME"
@export var level_number: int = 1
@export var icon: Texture2D
@export var level_difficulty: int = 1
@export var enemy_wave_config: Array[EnemyWaveConfig]
@export var powerup_wave_config: Array[PowerupWaveConfig]

@export_group("Layout")
## The level-specific details, decals, and extra collision layers.
@export var modifier_scene: PackedScene
## Optional: Override the zone's base tilemap for this specific level.
@export var base_tilemap_override: PackedScene
