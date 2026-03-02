extends Sprite2D

var direction: Vector2
@onready var player: Player = get_tree().get_first_node_in_group("player")
var rotation_speed: float = 5.0


func _physics_process(_delta: float) -> void:
	look_at(player.global_position)
	rotation = clamp(rotation, deg_to_rad(-45), deg_to_rad(45))
