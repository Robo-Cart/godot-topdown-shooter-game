extends SwarmZombieState

@export var fade_duration: float = 1.0


func enter() -> void:
	swarm.velocity = Vector2.ZERO
	swarm.play_animation("death")

	var death_audio: AudioStreamPlayer2D = swarm.get_node_or_null("DeathAudio")
	if death_audio:
		death_audio.pitch_scale = randf_range(0.8, 1.2)
		death_audio.play()

	swarm.set_deferred("collision_layer", 0)
	swarm.set_deferred("collision_mask", 0)

	# Disable and hide main collision shape
	if "collision_shape" in swarm and swarm.collision_shape:
		swarm.collision_shape.set_deferred("disabled", true)
		swarm.collision_shape.set_deferred("visible", false)

	# Disable and hide hurtbox collision shapes
	var hurtbox: HurtboxComponent = swarm.find_child("HurtboxComponent", true, false)
	if hurtbox:
		hurtbox.set_deferred("collision_layer", 0)
		hurtbox.set_deferred("collision_mask", 0)
		for child in hurtbox.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)
				child.set_deferred("visible", false)

	var tween: Tween = swarm.create_tween()

	tween.tween_property(swarm, "modulate:a", 0.0, fade_duration)


func physics_process_state(_delta: float) -> void:
	swarm.velocity = Vector2.ZERO
	swarm.move_and_slide()

	if not swarm.anim_sprite.is_playing() or swarm.anim_sprite.animation != "death":
		swarm.queue_free()
