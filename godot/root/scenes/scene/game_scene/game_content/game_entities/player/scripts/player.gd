class_name Player

extends CharacterBody2D

@export_group("Player Parameters")
@onready var player_man: Node3D = $SubViewportContainer/SubViewport/Player_Man_3D
@onready
var animation_tree: AnimationTree = $SubViewportContainer/SubViewport/Player_Man_3D.get_node(
	"AnimationTree"
)
@onready var weapon_path: Array[Node] = (
	$SubViewportContainer/SubViewport/Player_Man_3D/Armature/Skeleton3D/BoneAttachment3D
	. get_children()
)
@onready var ShootPos: Marker2D = $CentrePoint/ShootPos
@onready var GunShot: AudioStreamPlayer2D = $GunShot
#@onready var Impact: AudioStreamPlayer2D = $Impact
@onready var MuzzleParticles: CPUParticles2D = $CentrePoint/ShootPos/MuzzleParticles
@onready var Camera: Camera2D = $Camera2D

@export var speed: float = 200
@export var physicscontrol: bool = false
@export var bullet_speed: int = 1000
@export var MAX_SPEED: float = 200.0
@export var ACCELERATION: float = 800.0

const FRICTION = 900.0

const IS_PLAYER = true

var input_move: Vector2
var input_aim: Vector2
var playback: AnimationNodeStateMachinePlayback
var anim_pos: Vector2
var look_vector: Vector2
var player_offset_angle: float = 89.5

var bullet_scene: PackedScene = preload(
	"res://root/scenes/scene/game_scene/game_content/game_entities/object_bullet/bullet01.tscn"
)
var time_between_shot: float = 0.25
var can_shoot: bool = true
var shot_force: float = 50


func _ready() -> void:
	add_to_group("player")
	playback = animation_tree["parameters/playback"]
	$ShootTimer.wait_time = time_between_shot


func _physics_process(delta: float) -> void:
	input_move = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	input_aim = Input.get_vector("look_left", "look_right", "look_up", "look_down")

	# Check player control to use physics based control
	if physicscontrol:
		if input_move:
			# Acceleration (Weighty start)
			velocity = velocity.move_toward(input_move * MAX_SPEED, ACCELERATION * delta)
		else:
			# Friction (Weighty stop)
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = input_move * speed

	if input_aim != Vector2.ZERO:
		player_man.rotation.y = -input_aim.angle() + player_offset_angle
		$CentrePoint.global_rotation = input_aim.angle()
		look_vector = input_aim.normalized()
	if input_move != Vector2.ZERO and input_aim == Vector2.ZERO:
		player_man.rotation.y = -input_move.angle() + player_offset_angle
		$CentrePoint.global_rotation = input_move.angle()
		look_vector = input_move.normalized()

	if Input.is_action_pressed("fire") and can_shoot:
		_shoot()
		can_shoot = false
		$ShootTimer.start()
		GunShot.play()
		MuzzleParticles.emitting = true
		#shake camera
		$Camera2D.add_trauma(0.15)
		#apply force to player from front shot_force
		velocity -= look_vector * shot_force

	move_and_slide()
	select_animation()
	update_animation_parameters()


func _shoot() -> void:
	var new_bullet: Node = bullet_scene.instantiate()
	new_bullet.global_position = ShootPos.global_position
	new_bullet.global_rotation = ShootPos.global_rotation
	new_bullet.speed = bullet_speed
	get_parent().add_child(new_bullet)


func _on_shot_timer_timeout() -> void:
	can_shoot = true


func select_animation() -> void:
	if velocity.length() < 130:
		playback.travel("Walk")
	else:
		playback.travel("Run")


func update_animation_parameters() -> void:
	if input_aim != Vector2.ZERO and input_move == Vector2.ZERO:
		input_move = Vector2(0, 0)
	if input_move != Vector2.ZERO and input_aim == Vector2.ZERO:
		input_move = input_move.rotated(player_man.rotation.y)
	if input_move != Vector2.ZERO and input_aim != Vector2.ZERO:
		input_move = input_move.rotated(player_man.rotation.y)

	animation_tree["parameters/Run/blend_position"] = input_move
	animation_tree["parameters/Walk/blend_position"] = input_move
