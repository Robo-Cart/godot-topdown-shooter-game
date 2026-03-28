class_name SwarmZombieState
extends State

var player: Node2D:
	get:
		if swarm:
			return MultiplayerManager.get_closest_player(swarm.global_position)
		return null

@onready var swarm: EnemySwarmZombie = owner as EnemySwarmZombie


func _ready() -> void:
	if swarm:
		var health_comp: HealthComponent = swarm.get_node_or_null("HealthComponent")
		if health_comp:
			health_comp.damaged.connect(on_damaged)
	else:
		push_error("EnemySwarmZombie could not find EnemySwarmZombie owner!")


func on_damaged(_attack: AttackEntity) -> void:
	var health_comp: HealthComponent = swarm.get_node_or_null("HealthComponent")
	if health_comp and health_comp.current_health <= 0:
		transitioned.emit(self, "death")
