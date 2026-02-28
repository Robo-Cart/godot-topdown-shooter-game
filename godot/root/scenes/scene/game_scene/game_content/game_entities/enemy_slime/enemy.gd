class_name Enemy
extends CharacterBody2D

#########################################################
# I tend to keep the top level node's functionality
# small. Here, this node is responsible for common state
# variables, passing the damaged signal around, and
# picking a random texture on spawn.
#
# For the most part, other functionality that controls
# the enemy is handled by specific states.
#
# ex. Movement is handled by states setting velocity
# and calling move_and_slide()
########################################################

signal damaged(attack: AttackEntity)

@export var animation_tree: AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback
@onready var sprite: Sprite2D = $Sprite2D

@export_group("Vision Ranges")
@export var detection_radius := 175.0
@export var attack_range := 20.0

var alive := true
var stunned := false

var health = 5


func on_damaged(attack: AttackEntity) -> void:
	damaged.emit(attack)


func _ready():
	add_to_group("enemy")
	animation_tree.active = true

	playback = animation_tree.get("parameters/playback")

	if playback == null:
		push_error("AnimationTree playback is NULL. Check state machine setup.")


func _physics_process(delta: float) -> void:
	# Ensure facing direction of movement and do not revert to default facing when stopped
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


# visual distance for states
func _draw() -> void:
	draw_arc(Vector2.ZERO, detection_radius, 0, 360, 50, Color.DARK_SALMON, 0.5, true)
	draw_arc(Vector2.ZERO, attack_range, 0, 360, 50, Color.CRIMSON, 0.5, true)


func play_animation(name: String):
	if playback:
		playback.travel(name)
	else:
		push_error("Tried to play animation but playback is null.")


func _set_health(value):
	if alive:
		if health < 0:
			alive = false
			#$DieParticle.emitting = true
			set_deferred("monitoring", false)
			get_node("Sprite2D").hide()
			$DeathAudio.play()
			$DieTime.start()


func _take_damage(value):
	health += value
	_set_health(health)


func _on_die_time_timeout() -> void:
	queue_free()  # Replace with function body.
