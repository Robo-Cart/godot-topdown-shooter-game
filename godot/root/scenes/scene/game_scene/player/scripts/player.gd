class_name Player
extends CharacterBody2D

@export var speed : float = 200
@export var animation_tree : AnimationTree
@export var physicscontrol : bool = false

const MAX_SPEED = 300.0
const ACCELERATION = 800.0
const FRICTION = 900.0


var input :Vector2
var playback : AnimationNodeStateMachinePlayback

func _ready():
	add_to_group("player")
	playback = animation_tree["parameters/playback"]

func _process(delta: float) -> void:
	input = Input.get_vector("Left", "Right", "Up", "Down")
	
	# Check player control to use physics based control
	if physicscontrol:
		if input:
			# Acceleration (Weighty start)
			velocity = velocity.move_toward(input * MAX_SPEED, ACCELERATION * delta)
		else:
			# Friction (Weighty stop)
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = input * speed
	
	move_and_slide()
	select_animation()
	update_animation_parameters()
	
func select_animation():
	if velocity == Vector2.ZERO:
		playback.travel("Idle")
	elif velocity.length() < 130:
		playback.travel("Walk")
	else:
		playback.travel("Run")

func update_animation_parameters():
	if input == Vector2.ZERO:
		return
		
	animation_tree["parameters/Idle/blend_position"] = input
	animation_tree["parameters/Run/blend_position"] = input
	animation_tree["parameters/Walk/blend_position"] = input
