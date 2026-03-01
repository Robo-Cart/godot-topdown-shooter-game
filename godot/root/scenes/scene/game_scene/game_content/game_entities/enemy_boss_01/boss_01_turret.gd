extends Sprite2D

var direction: Vector2
@onready var player: Node2D = get_node("../../../../../../Player")  # Update path to player
var rotation_speed = 5.0


func _physics_process(delta: float) -> void:
	look_at(player.global_position)
	rotation = clamp(rotation, deg_to_rad(-45), deg_to_rad(45))
