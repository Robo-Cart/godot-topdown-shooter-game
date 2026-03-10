extends Area2D
class_name HitboxComponent

# We export this so we can link the Hitbox to the Health node in the Inspector!
@export var health_component: HealthComponent


func damage(amount: int) -> void:
	if health_component:
		health_component.take_damage(amount)
	else:
		LogWrapper.debug(self, "WARNING: Hitbox took damage but has no HealthComponent assigned!")
