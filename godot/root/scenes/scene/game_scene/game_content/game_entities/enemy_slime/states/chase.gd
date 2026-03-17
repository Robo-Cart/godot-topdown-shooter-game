extends SlimeState

@export var chase_speed := 75.0


func physics_process_state(_delta: float) -> void:
	var target_pos: Vector2 = player.global_position

	var intro_comp: SpawnIntroComponent = slime.find_child("*SpawnIntroComponent*", true, false)
	if intro_comp:
		target_pos = intro_comp.get_target_position(target_pos)

	var direction: Vector2 = target_pos - slime.global_position
	var distance: float = (player.global_position - slime.global_position).length()

	if distance > slime.detection_radius:
		transitioned.emit(self, "idle")
		return

	if distance < slime.attack_range:
		transitioned.emit(self, "attack")
		return

	# --- Separation Force (to avoid clumping at doorways/corners) ---
	var separation: Vector2 = Vector2.ZERO
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	for enemy: Node in enemies:
		if enemy == slime or not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var dist_sq: float = slime.global_position.distance_squared_to(enemy.global_position)
		if dist_sq < 400.0: # 20 pixel detection radius
			var diff: Vector2 = slime.global_position - enemy.global_position
			separation += diff.normalized() * (1.0 - sqrt(dist_sq) / 20.0)

	var move_dir: Vector2 = (direction.normalized() + separation * 1.5).normalized()
	slime.velocity = move_dir * chase_speed

	slime.play_animation("Run")
	slime.move_and_slide()

	# --- Anti-Stuck Corner Nudge ---
	if slime.get_slide_collision_count() > 0 and slime.velocity.length() < chase_speed * 0.5:
		var collision: KinematicCollision2D = slime.get_slide_collision(0)
		var nudge: Vector2 = collision.get_normal().orthogonal()
		if nudge.dot(direction) < 0:
			nudge = -nudge
		slime.velocity = nudge * chase_speed
		slime.move_and_slide()
