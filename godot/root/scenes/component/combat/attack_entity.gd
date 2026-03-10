class_name AttackEntity
extends RefCounted

# The raw damage value
var damage: int = 1

# Knockback properties
var knockback_force: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO

# Elemental properties (e.g., "physical", "fire", "ice")
var element: String = "physical"

# Optional: Store who actually fired the attack!
var attacker: Node2D = null
