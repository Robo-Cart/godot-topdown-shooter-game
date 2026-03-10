extends Node3D

var weapons: Array = []
var selected_weapon: int = 0


func _ready() -> void:
	for w in self.get_children():
		weapons.append(w)
		w.visible = false

	if weapons.size() > 0:
		weapons[selected_weapon].visible = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("next_weapon"):
		if weapons.size() == 0:
			return

		weapons[selected_weapon].visible = false

		selected_weapon = (selected_weapon + 1) % weapons.size()
		weapons[selected_weapon].visible = true
