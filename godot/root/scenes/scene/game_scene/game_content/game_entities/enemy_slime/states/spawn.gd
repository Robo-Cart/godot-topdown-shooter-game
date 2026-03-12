extends SlimeState


func enter() -> void:
	slime.velocity = Vector2.ZERO
	slime.play_animation("Spawn")


func physics_process_state(_delta: float) -> void:
	slime.velocity = Vector2.ZERO
	slime.move_and_slide()


func _on_spawn_animation_finished(_anim_name: String = "") -> void:
	transitioned.emit(self, "wander")
