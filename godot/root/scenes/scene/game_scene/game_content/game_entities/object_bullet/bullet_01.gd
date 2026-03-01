extends Sprite2D

@onready var RayCast: RayCast2D = $RayCast2D
@onready var Impact : AudioStreamPlayer2D = $Impact
@onready var HitParticle : CPUParticles2D = $HitParticle

var speed: float = 1000
var hit : bool = false

var enemy: Enemy
var enemy_flash: AnimationPlayer


func _ready() -> void:
	$DistanceTimeout.wait_time = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !hit:
		if RayCast.get_collider() != null and RayCast.is_colliding() and !RayCast.get_collider().is_in_group("player"):
			Impact.play()
			HitParticle.emitting = true
			hit = true
			texture = null
			$DistanceTimeout.start()
			
			
				
			if RayCast.get_collider().is_in_group("enemy"):
				enemy = RayCast.get_collider()
				enemy_flash = enemy.get_node("HitFlashAnim")
				enemy_flash.play("hit")
				enemy._take_damage(-1)
			
			if RayCast.get_collider().get_parent().is_in_group("enemy"):
				enemy = RayCast.get_collider()
				enemy_flash = enemy.get_parent().get_node("HitFlashAnim")
				enemy_flash.play("hit")
				enemy.get_parent()._take_damage(-1)
			
			
		global_position += Vector2(1, 0).rotated(rotation) * speed * delta



func _on_distance_timeout_timeout() -> void:
	queue_free()
