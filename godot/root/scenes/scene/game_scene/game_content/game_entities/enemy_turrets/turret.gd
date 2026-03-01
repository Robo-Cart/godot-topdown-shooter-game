class_name Turret
extends CharacterBody2D

@export var animation_tree: AnimationTree

var direction: Vector2
var playback: AnimationNodeStateMachinePlayback
var health: int
var dead: bool = false

@onready var player: Player
@onready var healthbar: ProgressBar = $HealthBar


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")
	playback = animation_tree["parameters/playback"]
	playback.travel("Idle")

	health = 5
	healthbar.init_health(health)


func _physics_process(_delta: float) -> void:
	direction = (player.position - position).normalized()
	#velocity = direction * speed

	move_and_slide()
	update_animation_parameters()


func update_animation_parameters() -> void:
	animation_tree["parameters/Idle/blend_position"] = direction


func _set_health(_value: int) -> void:
	if !dead:
		if health > 0:
			healthbar.health = health
		else:
			dead = true
			$DieParticle.emitting = true
			set_deferred("monitoring", false)
			get_node("Sprite2D").hide()
			$Explode.play()
			$DieTime.start()


func _take_damage(value: int) -> void:
	health += value
	_set_health(health)


func _on_die_time_timeout() -> void:
	queue_free()
