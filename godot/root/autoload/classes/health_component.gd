extends Node
class_name HealthComponent

signal health_changed(current_health: int, max_health: int)
signal died

@export var max_health: int = 100
var current_health: int


func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	# Prevent taking damage if already dead
	if current_health <= 0:
		return

	current_health -= amount
	health_changed.emit(current_health, max_health)

	LogWrapper.debug(self, "Took %d damage. HP: %d/%d" % [amount, current_health, max_health])

	if current_health <= 0:
		LogWrapper.debug(self, "Health reached 0. Emitting died signal.")
		died.emit()
