extends Sprite2D

@onready var RayCast: RayCast2D = $RayCast2D
@onready var Impact: AudioStreamPlayer2D = $Impact
@onready var HitParticle: CPUParticles2D = $HitParticle

var speed: float = 1000
var hit: bool = false

var enemy_flash: AnimationPlayer


func _ready() -> void:
	$DistanceTimeout.wait_time = 1


func _physics_process(delta: float) -> void:
	if !hit:
		var collider: Object = RayCast.get_collider()

		if collider != null and RayCast.is_colliding() and !collider.is_in_group("player"):
			Impact.play()
			HitParticle.emitting = true
			hit = true
			texture = null
			$DistanceTimeout.start()

		if collider is HurtboxComponent:
			var attack: AttackEntity = AttackEntity.new()
			attack.damage = 1

			attack.knockback_force = 300.0
			attack.knockback_direction = Vector2(1, 0).rotated(rotation).normalized()

			attack.element = "physical"
			attack.attacker = self

			collider.damage(attack)

		global_position += Vector2(1, 0).rotated(rotation) * speed * delta


func _on_distance_timeout_timeout() -> void:
	queue_free()
