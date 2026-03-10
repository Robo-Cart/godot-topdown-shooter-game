extends Node
class_name DeathComponent

@export var health_component: HealthComponent
@export var entity: Node2D
@export var sprite: Sprite2D
@export var death_audio: AudioStreamPlayer2D
@export var death_particles: CPUParticles2D


func _ready() -> void:
	if health_component:
		health_component.died.connect(_on_died)


func _on_died() -> void:
	entity.set_deferred("collision_layer", 0)
	entity.set_deferred("collision_mask", 0)

	if sprite:
		sprite.hide()

	if death_particles:
		death_particles.emitting = true

	if death_audio:
		death_audio.play()
		await death_audio.finished

	entity.queue_free()
