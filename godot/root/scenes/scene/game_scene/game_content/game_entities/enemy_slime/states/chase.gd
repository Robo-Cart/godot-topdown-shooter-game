extends SlimeState

@export var chase_speed := 75.0


func physics_process_state(_delta: float) -> void:
	var direction: Vector2 = player.global_position - slime.global_position

	var distance: float = direction.length()

	if distance > slime.detection_radius:
		transitioned.emit(self, "idle")
		return

	if distance < slime.attack_range:
		transitioned.emit(self, "attack")
		return

	slime.velocity = direction.normalized() * chase_speed

	slime.play_animation("Run")
	slime.move_and_slide()
