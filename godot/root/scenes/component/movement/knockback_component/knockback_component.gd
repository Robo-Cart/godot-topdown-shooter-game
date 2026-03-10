extends Node
class_name KnockbackComponent

@export var target_entity: CharacterBody2D
@export var health_component: HealthComponent


func _ready() -> void:
	if health_component:
		health_component.damaged.connect(_on_damaged)


func _on_damaged(attack: AttackEntity) -> void:
	if target_entity and attack.knockback_force > 0:
		# Apply the velocity!
		# You might need to adjust this depending on how your State Machine overrides velocity,
		# but pushing it directly to the CharacterBody2D is the standard approach.
		target_entity.velocity = attack.knockback_direction * attack.knockback_force
		target_entity.move_and_slide()
