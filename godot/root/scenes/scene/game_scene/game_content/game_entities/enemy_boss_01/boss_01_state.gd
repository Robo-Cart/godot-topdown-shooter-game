class_name BossState
extends State

var player: Node2D:
	get:
		if boss:
			return MultiplayerManager.get_closest_player(boss.global_position)
		return null

@onready var boss: Node2D = owner


func _ready() -> void:
	pass
