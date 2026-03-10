class_name State
extends Node

signal transitioned(state: State, new_state_name: String)


func enter() -> void:
	pass


func exit() -> void:
	pass


func process_state(_delta: float) -> void:
	pass


func physics_process_state(_delta: float) -> void:
	pass
