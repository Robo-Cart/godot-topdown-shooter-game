class_name BossState
extends State

@onready var boss: Node2D = owner
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
