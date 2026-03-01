extends Sprite2D

@onready var RayCast: RayCast2D = $RayCast2D
@onready var Impact: AudioStreamPlayer2D = $Impact
@onready var HitParticle: CPUParticles2D = $HitParticle

var speed: float = 1000
var hit: bool = false

var enemy_flash: AnimationPlayer


func _ready() -> void:
	$DistanceTimeout.wait_time = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !hit:
		if (
			RayCast.get_collider() != null
			and RayCast.is_colliding()
			and !RayCast.get_collider().is_in_group("player")
		):
			Impact.play()
			HitParticle.emitting = true
			hit = true
			texture = null
			$DistanceTimeout.start()

			if RayCast.get_collider().is_in_group("enemy"):
				# Need to update this to be able to handle multiple node types that might be returned
				# For now I've hard coded the different types along with a check on the returned node type - really clunky and bad practice
				# The repeated code to optionally get the parent also needs refactoring
				if RayCast.get_collider() is CharacterBody2D:
					var enemy: CharacterBody2D = RayCast.get_collider()
					enemy_flash = enemy.get_node("HitFlashAnim")
					enemy_flash.play("hit")
					enemy._take_damage(-1)
				elif RayCast.get_collider() is StaticBody2D:
					var enemy: StaticBody2D = RayCast.get_collider()
					enemy_flash = enemy.get_node("HitFlashAnim")
					enemy_flash.play("hit")
					enemy._take_damage(-1)
				elif RayCast.get_collider() is Node2D:
					var enemy: Node2D = RayCast.get_collider()
					enemy_flash = enemy.get_node("HitFlashAnim")
					enemy_flash.play("hit")
					enemy._take_damage(-1)

			if RayCast.get_collider().get_parent().is_in_group("enemy"):
				if RayCast.get_collider().get_parent() is CharacterBody2D:
					var enemy: CharacterBody2D = RayCast.get_collider().get_parent()
					enemy_flash = enemy.get_node("HitFlashAnim")
					enemy_flash.play("hit")
					enemy._take_damage(-1)
				elif RayCast.get_collider().get_parent() is StaticBody2D:
					var enemy: StaticBody2D = RayCast.get_collider().get_parent()
					enemy_flash = enemy.get_node("HitFlashAnim")
					enemy_flash.play("hit")
					enemy._take_damage(-1)
				elif RayCast.get_collider().get_parent() is Node2D:
					var enemy: Node2D = RayCast.get_collider().get_parent()
					enemy_flash = enemy.get_node("HitFlashAnim")
					enemy_flash.play("hit")
					enemy._take_damage(-1)

		global_position += Vector2(1, 0).rotated(rotation) * speed * delta


func _on_distance_timeout_timeout() -> void:
	queue_free()
