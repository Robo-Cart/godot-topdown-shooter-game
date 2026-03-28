class_name MultiplayerScalingComponent
extends Node

@export var scaling_data: MultiplayerScalingData
@export var is_boss: bool = false


func _ready() -> void:
	if not scaling_data:
		LogWrapper.warn(self, "No MultiplayerScalingData assigned.")
		return
	call_deferred("_apply_scaling")


func _apply_scaling() -> void:
	var player_count: int = 1
	if Engine.has_singleton("MultiplayerManager"):
		var mm: Node = get_node("/root/MultiplayerManager")
		if mm and mm.has_method("get_total_player_count"):
			player_count = mm.get_total_player_count()

	if player_count < 1:
		player_count = 1
	var index: int = clamp(player_count - 1, 0, 7)

	var parent: Node = get_parent()
	var health_comp: Node = parent.get_node_or_null("HealthComponent")
	if health_comp and "max_health" in health_comp:
		var mult: float = (
			scaling_data.boss_health_mult[index]
			if is_boss
			else scaling_data.enemy_health_mult[index]
		)
		health_comp.max_health = int(health_comp.max_health * mult)
		if "current_health" in health_comp:
			health_comp.current_health = health_comp.max_health

	var movement_comp: Node = parent.get_node_or_null("MovementComponent")
	if movement_comp and "max_speed" in movement_comp:
		var mult: float = (
			scaling_data.boss_speed_mult[index] if is_boss else scaling_data.enemy_speed_mult[index]
		)
		movement_comp.max_speed = movement_comp.max_speed * mult
	elif "speed" in parent:
		var mult: float = (
			scaling_data.boss_speed_mult[index] if is_boss else scaling_data.enemy_speed_mult[index]
		)
		parent.set("speed", float(parent.get("speed")) * mult)

	var hitbox_comp: Node = parent.get_node_or_null("HitboxComponent")
	if hitbox_comp and "damage" in hitbox_comp:
		var mult: float = (
			scaling_data.boss_damage_mult[index]
			if is_boss
			else scaling_data.enemy_damage_mult[index]
		)
		hitbox_comp.damage = int(hitbox_comp.damage * mult)

	if "knockback_resistance" in parent:
		var mult: float = (
			scaling_data.boss_knockback_mult[index]
			if is_boss
			else scaling_data.enemy_knockback_mult[index]
		)
		parent.set("knockback_resistance", float(parent.get("knockback_resistance")) * mult)
