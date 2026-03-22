extends SlimeState

@export var damage: int = 1
@export var damage_cooldown: float = 0.4

var _cooldown_timer: float = 0.0


func physics_process_state(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	var direction: Vector2 = player.global_position - slime.global_position

	var distance: float = direction.length()

	if distance > slime.attack_range:
		transitioned.emit(self, "idle")
		return

	slime.velocity = Vector2.ZERO

	slime.play_animation("Attack")

	if _cooldown_timer <= 0:
		_deliver_hit()

	slime.move_and_slide()


func _deliver_hit() -> void:
	if not is_instance_valid(player):
		return

	var distance: float = player.global_position.distance_to(slime.global_position)

	# Range for the "Attack" animation hit
	if distance <= slime.attack_range:
		var player_hurtbox: HurtboxComponent = player.get_node_or_null("HurtboxComponent")

		if player_hurtbox:
			var attack: AttackEntity = AttackEntity.new()
			attack.damage = damage
			attack.attacker = slime
			attack.knockback_force = 200.0
			attack.knockback_direction = (player.global_position - slime.global_position).normalized()

			player_hurtbox.damage(attack)
			_cooldown_timer = damage_cooldown
