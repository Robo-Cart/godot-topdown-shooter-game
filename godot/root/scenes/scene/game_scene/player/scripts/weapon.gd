extends Node3D

var weapons = []
var selected_weapon = 0


func _ready() -> void:
	for w in self.get_children():
		weapons.append(w)
		w.visible = false
	weapons[selected_weapon].visible = true
	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Next Weapon"):
		weapons[selected_weapon].visible = false
		if (selected_weapon >= weapons.size()-1):
			selected_weapon = 0
			weapons[selected_weapon].visible = true
		else:
			selected_weapon += 1
			weapons[selected_weapon].visible = true
		print(weapons[selected_weapon])
		
