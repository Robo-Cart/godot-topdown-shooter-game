class_name ObjectDoor
extends Node2D

var is_open: bool = false

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	open_door()

func open_door() -> void:
	if is_open:
		return
	anim_player.play("door_open")
	is_open = true

func close_door() -> void:
	if !is_open:
		return

	anim_player.play("door_close")
	is_open = false