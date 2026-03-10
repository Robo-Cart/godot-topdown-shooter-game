extends SlimeState


func physics_process_state(_delta: float) -> void:
	var direction: Vector2 = player.global_position - slime.global_position

	var distance: float = direction.length()

	if distance > slime.attack_range:
		transitioned.emit(self, "idle")
		return

	slime.velocity = Vector2.ZERO

	slime.play_animation("Attack")

	slime.move_and_slide()
