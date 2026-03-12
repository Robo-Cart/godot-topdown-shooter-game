class_name Player
extends CharacterBody2D

@export_group("Player Parameters")
@onready var player_man: Node3D = $SubViewportContainer/SubViewport/Player_Man_3D
@onready
var animation_tree: AnimationTree = $SubViewportContainer/SubViewport/Player_Man_3D.get_node(
	"AnimationTree"
)
@onready var Camera: Camera2D = $Camera2D

@onready var weapon_comp: WeaponComponent = $WeaponComponent
@onready var health_comp = $HealthComponent

@export var speed: float = 200
@export var physicscontrol: bool = false
@export var MAX_SPEED: float = 200.0
@export var ACCELERATION: float = 800.0

var permanent_buffs: Dictionary = {}
const FRICTION = 900.0

var input_move: Vector2
var input_aim: Vector2
var playback: AnimationNodeStateMachinePlayback
var look_vector: Vector2
var player_offset_angle: float = 89.5
var mouse_captured: bool = false


func _ready() -> void:
	add_to_group("player")
	playback = animation_tree["parameters/playback"]

	if weapon_comp:
		weapon_comp.weapon_fired.connect(_on_weapon_fired)

	if health_comp:
		health_comp.health_changed.connect(
			func(current_health: int, _max_health: int):
				print("Ouch! Player health is now: ", current_health)

				if current_health <= 0:
					print("PLAYER IS DEAD!")
				# You can call queue_free() here for now, or trigger a game over!
		)


func _physics_process(delta: float) -> void:
	input_move = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	input_aim = Input.get_vector("look_left", "look_right", "look_up", "look_down")

	if physicscontrol:
		if input_move:
			velocity = velocity.move_toward(input_move * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = input_move * speed

	if input_aim != Vector2.ZERO:
		player_man.rotation.y = -input_aim.angle() + player_offset_angle
		$CentrePoint.global_rotation = input_aim.angle()
		look_vector = input_aim.normalized()
	elif input_move != Vector2.ZERO:  # (Optimized your previous if/else block)
		player_man.rotation.y = -input_move.angle() + player_offset_angle
		$CentrePoint.global_rotation = input_move.angle()
		look_vector = input_move.normalized()

	if Input.is_action_pressed("fire"):
		weapon_comp.fire(look_vector)

	move_and_slide()
	select_animation()
	update_animation_parameters()


func _on_weapon_fired(recoil: float, l_vector: Vector2) -> void:
	Camera.add_trauma(0.15)
	velocity -= l_vector * recoil


func add_buff(buff_name: String) -> void:
	if permanent_buffs.has(buff_name):
		permanent_buffs[buff_name] += 1
	else:
		permanent_buffs[buff_name] = 1
	LogWrapper.debug(self, "Player Buffs Updated: " + str(permanent_buffs))


func select_animation() -> void:
	if velocity.length() < 130:
		playback.travel("Walk")
	else:
		playback.travel("Run")


func update_animation_parameters() -> void:
	var blend_vec: Vector2 = input_move
	if input_move != Vector2.ZERO:
		blend_vec = input_move.rotated(player_man.rotation.y)

	animation_tree["parameters/Run/blend_position"] = blend_vec
	animation_tree["parameters/Walk/blend_position"] = blend_vec


func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
