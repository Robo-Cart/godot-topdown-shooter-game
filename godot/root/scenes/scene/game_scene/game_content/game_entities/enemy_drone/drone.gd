class_name Drone
extends CharacterBody2D

@export var animation_tree: AnimationTree
var playback: AnimationNodeStateMachinePlayback


func _ready() -> void:
	add_to_group("enemy")
	playback = animation_tree["parameters/playback"]
	playback.travel("Idle")


func update_animation_parameters(direction: Vector2) -> void:
	animation_tree["parameters/Idle/blend_position"] = direction
