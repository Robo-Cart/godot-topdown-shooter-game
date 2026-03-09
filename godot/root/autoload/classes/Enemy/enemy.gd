extends CharacterBody2D
class_name Enemy

signal died(enemy_instance: Enemy)
signal health_changed(new_health: int, max_health: int)

@export var display_name: String = "Enemy"
@export var max_health: int = 100
@export var speed: float = 50.0

var current_health: int
var alive: bool = true
var stunned: bool = false


func _ready() -> void:
	current_health = max_health


func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health, max_health)

	# Add graphical effects here

	if current_health <= 0:
		die()


func die() -> void:
	died.emit(self)
	queue_free()
