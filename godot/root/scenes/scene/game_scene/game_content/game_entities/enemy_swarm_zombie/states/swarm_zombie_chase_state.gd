extends SwarmZombieState

@export var run_speed: float = 65.0
@export var attack_range: float = 40.0
var current_speed: float


func enter() -> void:
	current_speed = run_speed + randf_range(-15.0, 15.0)

	swarm.play_animation("run")


func physics_process_state(_delta: float) -> void:
	if not is_instance_valid(player):
		swarm.velocity = Vector2.ZERO
		swarm.move_and_slide()
		return

	var target_pos: Vector2 = player.global_position

	var intro_comp: SpawnIntroComponent = swarm.find_child("*SpawnIntroComponent*", true, false)
	if intro_comp:
		target_pos = intro_comp.get_target_position(target_pos)

	var direction: Vector2 = (target_pos - swarm.global_position).normalized()
	var distance: float = player.global_position.distance_to(swarm.global_position)

	if distance < attack_range:
		transitioned.emit(self, "attack")
		return

	# --- Separation Force (to avoid clumping at doorways/corners) ---
	var separation: Vector2 = Vector2.ZERO
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	for enemy: Node in enemies:
		if enemy == swarm or not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var dist_sq: float = swarm.global_position.distance_squared_to(enemy.global_position)
		if dist_sq < 900.0: # 30 pixel detection radius
			var diff: Vector2 = swarm.global_position - enemy.global_position
			separation += diff.normalized() * (1.0 - sqrt(dist_sq) / 30.0)

	var move_dir: Vector2 = (direction + separation * 1.5).normalized()
	swarm.velocity = move_dir * current_speed
	swarm.move_and_slide()

	# --- Anti-Stuck Corner Nudge ---
	if swarm.get_slide_collision_count() > 0 and swarm.velocity.length() < current_speed * 0.5:
		var collision: KinematicCollision2D = swarm.get_slide_collision(0)
		var nudge: Vector2 = collision.get_normal().orthogonal()
		if nudge.dot(direction) < 0:
			nudge = -nudge
		swarm.velocity = nudge * current_speed
		swarm.move_and_slide()

	swarm.update_facing_direction(direction)
