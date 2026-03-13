extends Sprite2D

var speed: float = 1000.0
var hit: bool = false

@onready var impact: AudioStreamPlayer2D = $Impact
@onready var hit_particle: CPUParticles2D = $HitParticle


func _ready() -> void:
	$DistanceTimeout.wait_time = 1

	var hitbox: Area2D = get_node_or_null("HitboxArea")
	if hitbox:
		hitbox.area_entered.connect(_on_hitbox_area_entered)
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	if !hit:
		global_position += Vector2(1, 0).rotated(rotation) * speed * delta


# --- SIGNAL CALLBACKS ---


func _on_hitbox_area_entered(area: Area2D) -> void:
	if hit:
		return

	if area is HurtboxComponent:
		_process_hit()

		var attack: AttackEntity = AttackEntity.new()
		attack.damage = 1
		attack.knockback_force = 300.0
		attack.knockback_direction = Vector2(1, 0).rotated(rotation).normalized()
		attack.element = "physical"
		attack.attacker = self

		area.damage(attack)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if hit:
		return

	if not body.is_in_group("player"):
		_process_hit()


func _process_hit() -> void:
	hit = true

	impact.play()
	hit_particle.emitting = true

	texture = null

	var hitbox = get_node_or_null("HitboxArea")
	if hitbox:
		hitbox.set_deferred("monitorable", false)
		hitbox.set_deferred("monitoring", false)

	$DistanceTimeout.start()


func _on_distance_timeout_timeout() -> void:
	queue_free()
