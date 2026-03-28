class_name MultiplayerScalingData
extends Resource

@export_group("Enemy Scaling")
## Array length must be 8. Index 0 is 1 player, Index 7 is 8 players.
@export var enemy_health_mult: Array[float] = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5]
@export var enemy_damage_mult: Array[float] = [1.0, 1.2, 1.4, 1.6, 1.8, 2.0, 2.2, 2.4]
@export var enemy_speed_mult: Array[float] = [1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3, 1.35]
@export var enemy_knockback_mult: Array[float] = [1.0, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3]

@export_group("Boss Scaling")
@export var boss_health_mult: Array[float] = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]
@export var boss_damage_mult: Array[float] = [1.0, 1.3, 1.6, 1.9, 2.2, 2.5, 2.8, 3.1]
@export var boss_speed_mult: Array[float] = [1.0, 1.0, 1.05, 1.1, 1.15, 1.2, 1.25, 1.3]
@export var boss_knockback_mult: Array[float] = [1.0, 0.8, 0.6, 0.4, 0.2, 0.1, 0.05, 0.0]

@export_group("Wave Scaling")
@export var wave_size_mult: Array[float] = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 5.0]
@export var powerup_spawn_mult: Array[float] = [1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 3.0]
