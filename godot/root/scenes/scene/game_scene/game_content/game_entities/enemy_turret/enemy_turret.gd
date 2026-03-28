class_name Turret
extends CharacterBody2D

@export var animation_tree: AnimationTree

var direction: Vector2
var playback: AnimationNodeStateMachinePlayback

var player: Node2D:
	get:
		if Engine.has_singleton("MultiplayerManager"):
			return get_node("/root/MultiplayerManager").get_closest_player(global_position)
		return null

@onready var healthbar: ProgressBar = $HealthBar
@onready var health_comp: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group("enemy")
	playback = animation_tree["parameters/playback"]
	playback.travel("Idle")

	if health_comp and healthbar:
		healthbar.init_health(health_comp.max_health)
		health_comp.health_changed.connect(_on_health_changed)


func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		direction = (player.position - position).normalized()

		move_and_slide()
		update_animation_parameters()


func update_animation_parameters() -> void:
	animation_tree["parameters/Idle/blend_position"] = direction


func _on_health_changed(current_health: int, _max_health: int) -> void:
	healthbar.health = current_health

	if current_health <= 0:
		healthbar.hide()
