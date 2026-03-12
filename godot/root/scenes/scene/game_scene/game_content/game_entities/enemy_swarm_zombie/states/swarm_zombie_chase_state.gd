extends SwarmZombieState

@export var run_speed: float = 65.0
@export var attack_range: float = 40.0
var current_speed: float


func enter() -> void:
	current_speed = run_speed + randf_range(-15.0, 15.0)

	swarm.play_animation("run")


func physics_process_state(delta: float) -> void:
	if not is_instance_valid(player):
		swarm.velocity = Vector2.ZERO
		swarm.move_and_slide()
		return

	var direction: Vector2 = (player.global_position - swarm.global_position).normalized()
	var distance: float = player.global_position.distance_to(swarm.global_position)

	if distance < attack_range:
		transitioned.emit(self, "attack")
		return

	swarm.velocity = direction * current_speed
	swarm.move_and_slide()

	swarm.update_facing_direction(direction)
