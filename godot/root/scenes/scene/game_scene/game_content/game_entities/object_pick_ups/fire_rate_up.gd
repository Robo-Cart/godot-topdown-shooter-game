extends Powerup

@export var fire_rate_decrease: float = 0.05
@export var min_fire_rate: float = 0.05  # The absolute maximum speed allowed


func _ready() -> void:
	display_name = "Fire Rate Up"
	buff_id = "fire_rate_up"


func apply_effect(target: Node) -> void:
	if target is Player:
		var shoot_timer: Timer = target.get_node_or_null("ShootTimer")
		if shoot_timer:
			# Subtract the time, but clamp it so it never goes below our minimum
			shoot_timer.wait_time = max(min_fire_rate, shoot_timer.wait_time - fire_rate_decrease)
