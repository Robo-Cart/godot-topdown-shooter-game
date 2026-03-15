extends Powerup

@export var speed_increase: float = 50.0
@export var acceleration_increase: float = 200.0


func _ready() -> void:
	display_name = "Speed Up"
	buff_id = "speed_up"


func apply_effect(target: Node) -> void:
	if target is Player:
		target.max_speed += speed_increase
		target.acceleration += acceleration_increase
