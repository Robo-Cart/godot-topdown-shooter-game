extends Powerup

@export var speed_increase: float = 50.0
@export var acceleration_increase: float = 200.0


func _ready() -> void:
	display_name = "Speed Up"
	buff_id = "speed_up"


func apply_effect(target: Node) -> void:
	if target is Player:
		target.MAX_SPEED += speed_increase
		target.ACCELERATION += acceleration_increase
