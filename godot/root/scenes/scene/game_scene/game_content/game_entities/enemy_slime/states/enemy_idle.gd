extends EnemyState

var idle_timer: Timer


# Upon moving to this state, initialize the
# timer with a random duration.
func enter() -> void:
	enemy.velocity = Vector2.ZERO

	idle_timer = Timer.new()
	idle_timer.wait_time = randi_range(3, 10)
	idle_timer.timeout.connect(on_timeout)
	idle_timer.autostart = true
	add_child(idle_timer)
	enemy.play_animation("Idle")


func on_timeout() -> void:
	transitioned.emit(self, "wander")


func _physics_process(_delta: float) -> void:
	try_chase()


# When leaving this state (for any reason), stop timer,
# disconnect signals, and free timer
# Technically, just queue_free() would be required, but
# I like showcasing all of the options
func exit() -> void:
	idle_timer.stop()
	idle_timer.timeout.disconnect(on_timeout)
	idle_timer.queue_free()
	idle_timer = null
