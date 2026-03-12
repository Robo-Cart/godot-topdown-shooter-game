class_name AttackEntity
extends RefCounted

var damage: int = 1

var knockback_force: float = 0.0
var knockback_direction: Vector2 = Vector2.ZERO

var element: String = "physical"

var attacker: Node2D = null
