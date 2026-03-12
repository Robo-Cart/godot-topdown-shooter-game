class_name SwarmZombieState
extends State

@onready var swarm: EnemySwarmZombie = owner as EnemySwarmZombie
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

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
