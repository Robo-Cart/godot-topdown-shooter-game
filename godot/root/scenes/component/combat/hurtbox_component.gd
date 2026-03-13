class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent


func damage(attack: AttackEntity) -> void:
	if health_component:
		health_component.take_damage(attack)
	else:
		LogWrapper.debug(self, "WARNING: Hurtbox took damage but has no HealthComponent assigned!")
