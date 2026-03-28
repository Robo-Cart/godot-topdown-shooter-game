extends Node3D

var weapons: Array = []
var selected_weapon: int = 0
var device_id: int = -1
var _last_wants_next: bool = false


func _ready() -> void:
	for w in self.get_children():
		weapons.append(w)
		w.visible = false

	if weapons.size() > 0:
		weapons[selected_weapon].visible = true


func _process(_delta: float) -> void:
	var wants_next: bool = false
	if device_id == -1:
		# Use action check for keyboard/mouse
		wants_next = Input.is_action_just_pressed("next_weapon")
	else:
		# Use joypad specific button for gamepads (e.g., Y or Triangle is common for switching)
		# JOY_BUTTON_Y is index 3
		# We need a manual "just pressed" for joy buttons
		var pressed: bool = Input.is_joy_button_pressed(device_id, JOY_BUTTON_Y)
		if pressed and not _last_wants_next:
			wants_next = true
		_last_wants_next = pressed

	if wants_next:
		if weapons.size() == 0:
			return

		weapons[selected_weapon].visible = false

		selected_weapon = (selected_weapon + 1) % weapons.size()
		weapons[selected_weapon].visible = true
