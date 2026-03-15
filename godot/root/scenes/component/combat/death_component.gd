class_name DeathComponent
extends Node

@export var health_component: HealthComponent
@export var entity: Node2D
@export var sprite: Sprite2D
@export var death_audio: AudioStreamPlayer2D
@export var death_particles: CPUParticles2D


func _ready() -> void:
	if health_component:
		health_component.died.connect(_on_died)


func _on_died() -> void:
	if entity is CollisionObject2D:
		entity.set_deferred("collision_layer", 0)
		entity.set_deferred("collision_mask", 0)
		_disable_shapes(entity)

	var hurtbox: Area2D = entity.find_child("HurtboxComponent", true, false)
	if not hurtbox and get_parent():
		hurtbox = get_parent().find_child("HurtboxComponent", true, false)

	if hurtbox:
		hurtbox.set_deferred("collision_layer", 0)
		hurtbox.set_deferred("collision_mask", 0)
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
		_disable_shapes(hurtbox)

	if sprite:
		sprite.hide()

	if death_particles:
		death_particles.emitting = true

	if death_audio:
		death_audio.play()
		await death_audio.finished

	entity.queue_free()


func _disable_shapes(node: Node) -> void:
	for child in node.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
			child.set_deferred("visible", false)
		_disable_shapes(child)
