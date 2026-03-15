extends Node2D

@onready var health_component: HealthComponent = $ShieldBody/HealthComponent
@onready var hit_flash_anim: AnimationPlayer = $ShieldBody/HitFlashAnim


func _ready() -> void:
	add_to_group("enemy")

	if health_component:
		health_component.damaged.connect(_on_damaged)


func _on_damaged(_attack: AttackEntity) -> void:
	if hit_flash_anim:
		hit_flash_anim.play("hit")
