extends BossState

@export var turrets: Array[Sprite2D]
var rotation_speed: float = 5.0


func physics_process_state(_delta: float) -> void:
	if not is_instance_valid(player):
		return

	for turret in turrets:
		if is_instance_valid(turret):
			turret.look_at(player.global_position)
			turret.rotation = clamp(turret.rotation, deg_to_rad(-45), deg_to_rad(45))
