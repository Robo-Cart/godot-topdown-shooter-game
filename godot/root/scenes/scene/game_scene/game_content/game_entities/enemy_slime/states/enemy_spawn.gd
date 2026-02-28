extends EnemyState

@onready var anim_player = $"../../AnimationPlayer"

func physics_process_state(delta: float):
	enemy.velocity = Vector2.ZERO
	if !anim_player.is_playing():
		enemy.play_animation("Spawn")

func _on_spawn_animation_finished():
	transitioned.emit(self, "wander")
