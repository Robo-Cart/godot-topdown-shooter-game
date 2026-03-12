extends SwarmZombieState

@export_group("Attack Settings")
@export var attack_duration: float = 0.8  # The total length of the attack animation
@export var damage_point: float = 0.4  # The exact second the zombie physically bites
@export var attack_damage: int = 1

var current_time: float = 0.0
var has_bitten: bool = false


func enter() -> void:
	current_time = 0.0
	has_bitten = false

	swarm.velocity = Vector2.ZERO
	swarm.play_animation("attack")

	if is_instance_valid(player):
		var direction: Vector2 = (player.global_position - swarm.global_position).normalized()
		swarm.update_facing_direction(direction)


func physics_process_state(delta: float) -> void:
	swarm.velocity = Vector2.ZERO
	swarm.move_and_slide()

	current_time += delta

	if current_time >= damage_point and not has_bitten:
		has_bitten = true
		_deliver_bite()

	if current_time >= attack_duration:
		transitioned.emit(self, "chase")


func _deliver_bite() -> void:
	if not is_instance_valid(player):
		return

	var distance: float = player.global_position.distance_to(swarm.global_position)

	if distance <= 75.0:
		var player_hurtbox: HurtboxComponent = player.get_node_or_null("HurtboxComponent")

		if player_hurtbox and player_hurtbox.has_method("damage"):
			var attack: AttackEntity = AttackEntity.new()

			attack.damage = attack_damage

			player_hurtbox.damage(attack)
