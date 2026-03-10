extends SlimeState

var idle_duration: float = 0.0
var current_time: float = 0.0


func enter() -> void:
	slime.velocity = Vector2.ZERO
	slime.play_animation("Idle")

	idle_duration = randf_range(3.0, 10.0)
	current_time = 0.0


func physics_process_state(delta: float) -> void:
	if try_chase():
		return

	current_time += delta

	if current_time >= idle_duration:
		transitioned.emit(self, "wander")


func exit() -> void:
	pass
