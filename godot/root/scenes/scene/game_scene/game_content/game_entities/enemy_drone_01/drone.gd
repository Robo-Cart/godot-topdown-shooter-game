class_name Drone
extends CharacterBody2D

@export var animation_tree : AnimationTree

var direction :Vector2
var playback : AnimationNodeStateMachinePlayback

@onready var player: Node2D = get_node("../../Player_Man") # Update path to player

func _ready():
	playback = animation_tree["parameters/playback"]
	playback.travel("Idle")
	

func _process(delta: float) -> void:
	direction = (player.position - position).normalized()
	#velocity = direction * speed

	move_and_slide()
	update_animation_parameters()
	
	
func update_animation_parameters():
	animation_tree["parameters/Idle/blend_position"] = direction
