extends SlimeState

@export var min_wander_time := 2.5
@export var max_wander_time := 10.0
@export var wander_speed := 50.0

var wander_direction: Vector2
var wander_duration: float = 0.0
var current_time: float = 0.0


func enter() -> void:
	wander_direction = Vector2.UP.rotated(deg_to_rad(randf_range(0, 360)))
	slime.play_animation("Walk")

	wander_duration = randf_range(min_wander_time, max_wander_time)
	current_time = 0.0


func physics_process_state(delta: float) -> void:
	if try_chase():
		return

	slime.velocity = wander_direction * wander_speed
	slime.move_and_slide()

	# --- Anti-Stuck Corner Nudge ---
	if slime.get_slide_collision_count() > 0 and slime.velocity.length() < wander_speed * 0.5:
		var collision: KinematicCollision2D = slime.get_slide_collision(0)
		var nudge: Vector2 = collision.get_normal().orthogonal()
		if nudge.dot(wander_direction) < 0:
			nudge = -nudge
		slime.velocity = nudge * wander_speed
		slime.move_and_slide()

	current_time += delta

	if current_time >= wander_duration:
		transitioned.emit(self, "idle")


func exit() -> void:
	pass
