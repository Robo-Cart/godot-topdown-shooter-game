extends EnemyState

@onready var anim_player: AnimationPlayer = $"../../AnimationPlayer"


func physics_process_state(_delta: float) -> void:
	enemy.velocity = Vector2.ZERO
	if !anim_player.is_playing():
		enemy.play_animation("Spawn")


func _on_spawn_animation_finished() -> void:
	transitioned.emit(self, "wander")
