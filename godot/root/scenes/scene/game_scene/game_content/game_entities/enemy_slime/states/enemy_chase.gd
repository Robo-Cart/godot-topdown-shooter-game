extends EnemyState


@export var chase_speed := 75.0


func physics_process_state(delta: float):
	
	var direction := player.global_position - enemy.global_position
	
	var distance = direction.length()
	
	if distance > enemy.detection_radius:
		transitioned.emit(self, "idle")
		return
		
	if distance < enemy.attack_range:
		transitioned.emit(self, "attack")
		return
			
	enemy.velocity = direction.normalized()*chase_speed
	
	enemy.play_animation("Run")
	enemy.move_and_slide()
