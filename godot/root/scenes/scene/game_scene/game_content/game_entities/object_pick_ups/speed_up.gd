extends Area2D

@export var NewSpeed = 400.0
@export var NewAcceleration = 1600
@export var PickUpTime : float = 10
var OldSpeed
var OldAcceleration
var Player

func _ready() -> void:
	$Timer.wait_time = PickUpTime

func _on_body_entered(body):	
	if body.is_in_group("player"):
		Player = body
		$Timer.start()	
		OldSpeed = body.MAX_SPEED
		OldAcceleration = body.ACCELERATION
		body.MAX_SPEED = NewSpeed
		body.ACCELERATION = NewAcceleration
		hide()
		set_deferred("monitoring", false)
	
	#hide from scene


func _on_timer_timeout() -> void:
	Player.MAX_SPEED = OldSpeed
	Player.ACCELERATION = OldAcceleration
	queue_free()
