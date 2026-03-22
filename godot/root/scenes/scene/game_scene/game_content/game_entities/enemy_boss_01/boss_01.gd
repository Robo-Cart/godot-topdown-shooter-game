extends CharacterBody2D

@onready var health_component: HealthComponent = $HealthComponent
@onready var hit_flash_anim: AnimationPlayer = $HitFlashAnim


func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")

	if health_component:
		health_component.damaged.connect(_on_damaged)


func _on_damaged(_attack: AttackEntity) -> void:
	if hit_flash_anim:
		hit_flash_anim.play("hit")
