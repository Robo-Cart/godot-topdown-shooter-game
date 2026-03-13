extends DroneState

@export var speed: float = 100.0


func physics_process_state(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	var direction: Vector2 = (player.global_position - drone.global_position).normalized()

	drone.velocity = direction * speed
	drone.move_and_slide()

	drone.update_animation_parameters(direction)
