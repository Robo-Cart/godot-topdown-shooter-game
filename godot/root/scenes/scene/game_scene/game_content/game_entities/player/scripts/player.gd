class_name Player
extends CharacterBody2D

signal lives_changed(current_lives: int, max_lives: int)

const FRICTION = 900.0

@export_group("Player Parameters")
@export var speed: float = 200
@export var physicscontrol: bool = false
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var max_lives: int = 5
@export var starting_lives: int = 3

var current_lives: int = starting_lives
var permanent_buffs: Dictionary = {}
var input_move: Vector2
var input_aim: Vector2
var playback: AnimationNodeStateMachinePlayback
var look_vector: Vector2
var player_offset_angle: float = 89.5
var mouse_captured: bool = false
var device_id: int = -1
var color_index: int = 0

@onready var player_man: Node3D = $SubViewportContainer/SubViewport/Player_Man_3D
@onready
var animation_tree: AnimationTree = $SubViewportContainer/SubViewport/Player_Man_3D.get_node(
	"AnimationTree"
)
@onready var camera: Camera2D = $Camera2D
@onready var weapon_comp: WeaponComponent = $WeaponComponent
@onready var health_comp: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group("player")
	playback = animation_tree["parameters/playback"]

	if weapon_comp:
		weapon_comp.weapon_fired.connect(_on_weapon_fired)

	if health_comp:
		health_comp.health_changed.connect(_on_health_changed)
		health_comp.died.connect(_on_died)


func _on_health_changed(current_hp: int, max_hp: int) -> void:
	LogWrapper.debug(self, "Player health: %d/%d" % [current_hp, max_hp])


func _on_died() -> void:
	LogWrapper.debug(self, "Player died! Reducing life.")
	remove_life()
	if current_lives > 0:
		# Reset health for the next life
		health_comp.current_health = health_comp.max_health
		health_comp.health_changed.emit(health_comp.current_health, health_comp.max_health)
	else:
		LogWrapper.debug(self, "GAME OVER - No lives left.")


func _physics_process(delta: float) -> void:
	if device_id == -1:
		# Specifically poll keyboard for Player 1 to avoid gamepad "crosstalk"
		# if the InputMap actions are bound to both.
		var move_vec: Vector2 = Vector2.ZERO
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			move_vec.y -= 1
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			move_vec.y += 1
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			move_vec.x -= 1
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			move_vec.x += 1
		input_move = move_vec.normalized()

		# For aim on keyboard/mouse, we usually use mouse position
		var mouse_pos: Vector2 = get_global_mouse_position()
		input_aim = (mouse_pos - global_position).normalized()
	else:
		var deadzone: float = 0.2
		var move_x: float = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
		var move_y: float = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
		input_move = Vector2(move_x, move_y)
		if input_move.length() < deadzone:
			input_move = Vector2.ZERO

		var aim_x: float = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_X)
		var aim_y: float = Input.get_joy_axis(device_id, JOY_AXIS_RIGHT_Y)
		input_aim = Vector2(aim_x, aim_y)
		if input_aim.length() < deadzone:
			input_aim = Vector2.ZERO

	if physicscontrol:
		if input_move:
			velocity = velocity.move_toward(input_move * max_speed, acceleration * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = input_move * speed

	if input_aim != Vector2.ZERO:
		player_man.rotation.y = -input_aim.angle() + player_offset_angle
		$CentrePoint.global_rotation = input_aim.angle()
		look_vector = input_aim.normalized()
	elif input_move != Vector2.ZERO:
		player_man.rotation.y = -input_move.angle() + player_offset_angle
		$CentrePoint.global_rotation = input_move.angle()
		look_vector = input_move.normalized()

	var is_firing: bool = false
	if device_id == -1:
		is_firing = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_action_pressed("fire")
	else:
		# Use RT/R2 or a joypad button (JOY_BUTTON_A is standard)
		if (
			Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT) > 0.5
			or Input.is_joy_button_pressed(device_id, JOY_BUTTON_A)
		):
			is_firing = true

	if is_firing:
		weapon_comp.fire(look_vector)

	move_and_slide()
	select_animation()
	update_animation_parameters()


func _on_weapon_fired(recoil: float, l_vector: Vector2) -> void:
	camera.add_trauma(0.15)
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


## Updates the number of lives and emits the signal.
func set_lives(count: int) -> void:
	current_lives = clamp(count, 0, max_lives)
	lives_changed.emit(current_lives, max_lives)


func add_life() -> void:
	set_lives(current_lives + 1)


func remove_life() -> void:
	set_lives(current_lives - 1)


func apply_tint() -> void:
	var color: Color = MultiplayerManager.player_colors[
		color_index % MultiplayerManager.player_colors.size()
	]
	var mesh_node: MeshInstance3D = player_man.get_node_or_null(
		"Armature/Skeleton3D/man-pedestrian-rival_Rig"
	)
	if mesh_node:
		for i in mesh_node.get_surface_override_material_count():
			var mat: Material = mesh_node.get_surface_override_material(i)
			if not mat:
				var mesh: Mesh = mesh_node.mesh
				if mesh:
					mat = mesh.surface_get_material(i)

			if mat and mat is StandardMaterial3D:
				var new_mat: StandardMaterial3D = mat.duplicate()
				new_mat.albedo_color = new_mat.albedo_color.lerp(color, 0.4)
				mesh_node.set_surface_override_material(i, new_mat)
