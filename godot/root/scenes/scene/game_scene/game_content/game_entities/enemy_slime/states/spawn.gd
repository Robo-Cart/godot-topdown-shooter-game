extends SlimeState

var spawn_duration: float = 0.35  # Slightly longer than the animation to be safe
var current_time: float = 0.0


func enter() -> void:
	current_time = 0.0
	slime.velocity = Vector2.ZERO
	slime.play_animation("Spawn")


func physics_process_state(delta: float) -> void:
	slime.velocity = Vector2.ZERO
	slime.move_and_slide()

	current_time += delta
	if current_time >= spawn_duration:
		transitioned.emit(self, "wander")
