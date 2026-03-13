class_name BossState
extends State

var player: Node2D

@onready var boss: Node2D = owner


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
