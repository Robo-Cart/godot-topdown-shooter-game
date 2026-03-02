extends Node2D

var health: int
var dead: bool = false


func _ready() -> void:
	add_to_group("enemy")
	health = 10


func _set_health(_value: int) -> void:
	if !dead:
		if health <= 0:
			dead = true
			$DieParticle.emitting = true
			set_deferred("monitoring", false)
			get_node("Sprite2D").hide()
			$DieTime.start()


func _take_damage(value: int) -> void:
	health += value
	_set_health(health)
	$HitFlashAnim.play("hit")


func _on_die_time_timeout() -> void:
	self.get_parent().queue_free()
