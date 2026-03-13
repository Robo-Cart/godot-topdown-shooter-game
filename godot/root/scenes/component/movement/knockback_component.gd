class_name KnockbackComponent
extends Node

@export var target_entity: CharacterBody2D
@export var health_component: HealthComponent


func _ready() -> void:
	if health_component:
		health_component.damaged.connect(_on_damaged)


func _on_damaged(attack: AttackEntity) -> void:
	if target_entity and attack.knockback_force > 0:
		target_entity.velocity = attack.knockback_direction * attack.knockback_force
		target_entity.move_and_slide()
