class_name WeaponComponent
extends Node2D

signal weapon_fired(recoil_force: float, look_vector: Vector2)

@export_group("Nodes")
@export var bullet_scene: PackedScene
@export var shoot_pos: Marker2D
@export var gun_shot_audio: AudioStreamPlayer2D
@export var muzzle_particles: CPUParticles2D

@export_group("Stats")
@export var bullet_speed: float = 1000.0
@export var time_between_shots: float = 0.25
@export var shot_force: float = 50.0  # The recoil pushback

var can_shoot: bool = true
var timer: Timer


func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = time_between_shots
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


func fire(look_vector: Vector2) -> void:
	if not can_shoot or not bullet_scene or not shoot_pos:
		return

	can_shoot = false
	timer.start()

	if gun_shot_audio:
		gun_shot_audio.play()
	if muzzle_particles:
		muzzle_particles.emitting = true

	var new_bullet: Node2D = bullet_scene.instantiate()
	new_bullet.global_position = shoot_pos.global_position
	new_bullet.global_rotation = shoot_pos.global_rotation
	new_bullet.speed = bullet_speed

	get_tree().current_scene.add_child(new_bullet)

	weapon_fired.emit(shot_force, look_vector)


func _on_timer_timeout() -> void:
	can_shoot = true
