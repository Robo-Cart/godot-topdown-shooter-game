extends Area2D
class_name HurtboxComponent

@export var health_component: HealthComponent


# Now accepts your custom AttackEntity instead of an integer
func damage(attack: AttackEntity) -> void:
	if health_component:
		health_component.take_damage(attack)
	else:
		LogWrapper.debug(self, "WARNING: Hurtbox took damage but has no HealthComponent assigned!")
