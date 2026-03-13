class_name EnemySlime
extends CharacterBody2D

@export var display_name: String = "Enemy"
@export var animation_tree: AnimationTree

@export_group("Vision Ranges")
@export var detection_radius: float = 175.0
@export var attack_range: float = 20.0

var stunned: bool = false
var playback: AnimationNodeStateMachinePlayback

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("enemy")
	animation_tree.active = true
	playback = animation_tree.get("parameters/playback")
	if playback == null:
		push_error("AnimationTree playback is NULL. Check state machine setup.")


func _physics_process(_delta: float) -> void:
	# Ensure facing direction of movement and do not revert to default facing when stopped
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0


# visual distance for states
func _draw() -> void:
	#draw_arc(Vector2.ZERO, detection_radius, 0, 360, 50, Color.DARK_SALMON, 0.5, true)
	#draw_arc(Vector2.ZERO, attack_range, 0, 360, 50, Color.CRIMSON, 0.5, true)
	pass


func play_animation(_name: String) -> void:
	if playback == null:
		if animation_tree == null:
			animation_tree = get_node_or_null("AnimationTree")

		if animation_tree:
			animation_tree.active = true
			playback = animation_tree.get("parameters/playback")

	if playback:
		playback.travel(_name)
	else:
		push_error("Tried to play animation '%s' but playback is still null!" % _name)
