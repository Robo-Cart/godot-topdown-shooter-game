class_name SlimeState
extends State

@onready var slime: EnemySlime = owner as EnemySlime
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	if slime:
		var health_comp: HealthComponent = slime.get_node_or_null("HealthComponent")
		if health_comp:
			health_comp.damaged.connect(on_damaged)
	else:
		push_error("SlimeState could not find EnemySlime owner! Check scene tree.")


func try_chase() -> bool:
	if player and slime:
		var distance = player.global_position.distance_to(slime.global_position)
		if distance <= slime.detection_radius:
			transitioned.emit(self, "chase")
			return true
	return false


func on_damaged(_attack: AttackEntity) -> void:
	transitioned.emit(self, "stun")
