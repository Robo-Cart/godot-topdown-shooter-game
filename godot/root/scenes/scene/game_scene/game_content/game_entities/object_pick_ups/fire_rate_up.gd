extends Area2D

@export var Newtime_between_shot = 0.1
@export var PickUpTime : float = 10
var Oldtime_between_shot
var Player

func _ready() -> void:
	$Timer.wait_time = PickUpTime

func _on_body_entered(body):	
	if body.is_in_group("player"):
		Player = body
		$Timer.start()
		Oldtime_between_shot = body.get_node("ShootTimer").wait_time
		body.get_node("ShootTimer").wait_time = Newtime_between_shot
		hide()
		set_deferred("monitoring", false)
	
	#hide from scene


func _on_timer_timeout() -> void:
	Player.get_node("ShootTimer").wait_time = Oldtime_between_shot
	queue_free()
