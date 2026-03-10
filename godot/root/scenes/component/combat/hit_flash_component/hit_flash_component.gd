extends Node
class_name HitFlashComponent

@export var health_component: HealthComponent
@export var hit_flash_anim: AnimationPlayer


func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)


func _on_health_changed(_current_health: int, _max_health: int) -> void:
	if hit_flash_anim:
		hit_flash_anim.play("hit")
