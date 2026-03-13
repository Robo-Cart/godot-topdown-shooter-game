class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died
signal damaged(attack: AttackEntity)

@export var max_health: int = 100

var current_health: int


func _ready() -> void:
	current_health = max_health


func take_damage(attack: AttackEntity) -> void:
	if current_health <= 0:
		return

	var final_damage: int = attack.damage

	# Example: Slimes take double damage from fire!
	#if attack.element == "fire":
	#final_damage *= 2
	#LogWrapper.debug(self, "Critical hit! Fire element used.")

	current_health -= final_damage

	damaged.emit(attack)
	health_changed.emit(current_health, max_health)

	LogWrapper.debug(self, "Took %d damage. HP: %d/%d" % [final_damage, current_health, max_health])

	if current_health <= 0:
		LogWrapper.debug(self, "Health reached 0. Emitting died signal.")
		died.emit()
