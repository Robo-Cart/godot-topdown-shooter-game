extends StaticBody2D

var health 
var dead : bool = false

func _ready():	
	add_to_group("enemy")	
	health = 10
	

func _set_health(value):
	if !dead :
		if health <= 0: 
			dead = true
			$DieParticle.emitting = true
			set_deferred("monitoring", false)
			get_node("Sprite2D").hide()
			$DieTime.start()
	
func _take_damage(value):
	health += value
	_set_health(health)


func _on_die_time_timeout() -> void:
	self.get_parent().queue_free()
	
