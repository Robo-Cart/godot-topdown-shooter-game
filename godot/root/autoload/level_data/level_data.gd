extends Resource
class_name LevelData

@export var level_name: String = "LEVEL NAME"
@export var level_number: int = 1
@export var icon: Texture2D
@export var level_difficuty: int = 1
@export var enemy_wave_config: Array[EnemyWaveConfig]
@export var powerup_wave_config: Array[PowerupWaveConfig]
