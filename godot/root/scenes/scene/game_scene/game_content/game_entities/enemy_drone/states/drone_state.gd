class_name DroneState
extends State

var player: Node2D

@onready var drone: Drone = owner as Drone


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

	if drone:
		var health_comp: HealthComponent = drone.get_node_or_null("HealthComponent")
		if health_comp:
			health_comp.damaged.connect(on_damaged)
	else:
		push_error("DroneState could not find Drone owner!")


func on_damaged(_attack: AttackEntity) -> void:
	pass
