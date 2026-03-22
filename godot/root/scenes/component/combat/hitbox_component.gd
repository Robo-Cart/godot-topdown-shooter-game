class_name HitboxComponent
extends Area2D

## Component for dealing damage to HurtboxComponents on contact.

@export var damage: int = 1
@export var element: String = "physical"
@export var knockback_force: float = 0.0

@export var damage_cooldown: float = 0.5

var attacker: Node2D
var _cooldown_timer: float = 0.0
var _current_hurtbox: HurtboxComponent


func _ready() -> void:
	attacker = get_parent() as Node2D
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta

	if _cooldown_timer <= 0 and _current_hurtbox:
		_deal_damage(_current_hurtbox)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		_current_hurtbox = area as HurtboxComponent
		if _cooldown_timer <= 0:
			_deal_damage(_current_hurtbox)


func _on_area_exited(area: Area2D) -> void:
	if area == _current_hurtbox:
		_current_hurtbox = null


func _deal_damage(hurtbox: HurtboxComponent) -> void:
	var attack := AttackEntity.new()
	attack.damage = damage
	attack.element = element
	attack.knockback_force = knockback_force
	attack.attacker = attacker

	if attacker:
		attack.knockback_direction = (hurtbox.global_position - attacker.global_position).normalized()

	hurtbox.damage(attack)
	_cooldown_timer = damage_cooldown
