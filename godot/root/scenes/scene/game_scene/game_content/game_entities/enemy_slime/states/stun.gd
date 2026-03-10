extends SlimeState

@export var stun_duration: float = 1.0
var current_time: float = 0.0


func enter() -> void:
	current_time = 0.0
	slime.stunned = true
	slime.velocity = Vector2.ZERO
	slime.play_animation("Stun")


func physics_process_state(delta: float) -> void:
	slime.velocity = Vector2.ZERO
	slime.move_and_slide()

	current_time += delta

	if current_time >= stun_duration:
		if !try_chase():
			transitioned.emit(self, "idle")


func exit() -> void:
	slime.stunned = false
