class_name GameScene
extends Node

@export_group("Menu Scene")
@export var scene: SceneManagerEnum.Scene = SceneManagerEnum.Scene.MENU_SCENE
@export var scene_manager_options_id: String = "fade_play"

var is_transitioning: bool = false
var transition_rect: ColorRect

@onready var game_content: Node = $GameContent
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var options_menu: OptionsMenu = %OptionsMenu
@onready var ui_builder: UiBuilder = %UiBuilder
@onready var hud: HUD = %HUD


# Esc key shortcut toggles pause menu or exits from options via back button
func _input(_event: InputEvent) -> void:

	if is_transitioning:
		return

	if Input.is_action_just_pressed("game_pause"):
		if get_tree().paused:
			if pause_menu.visible:
				_action_continue_menu_button()
			else:
				_action_options_back_menu_button()
		else:
			_action_game_pause_menu_button()


func _ready() -> void:
	add_to_group("game_scene")
	_setup_transition_screen()
	_load_game_content_scene()

	ui_builder.build()

	_connect_signals()
	_setup_hud()

	LogWrapper.debug(self, "Ready.")


func _setup_hud() -> void:
	if not hud:
		return

	var player: Player = null
	if "player" in game_content and game_content.player is Player:
		player = game_content.player
	elif get_tree().get_nodes_in_group("player").size() > 0:
		player = get_tree().get_nodes_in_group("player")[0]

	if player:
		hud.setup_player_ui(0, player)


func _setup_transition_screen() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100

	transition_rect = ColorRect.new()
	transition_rect.color = Color(0, 0, 0, 0)
	transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	canvas.add_child(transition_rect)
	add_child(canvas)


func fade_out() -> void:
	is_transitioning = true
	get_tree().paused = true

	var tween: Tween = create_tween()
	tween.tween_property(transition_rect, "color:a", 1.0, 0.4)
	await tween.finished


func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(transition_rect, "color:a", 0.0, 0.4)
	await tween.finished

	get_tree().paused = false
	is_transitioning = false


func _after_pause() -> void:
	if "player" in game_content and game_content.player is Player:
		var player: Player = game_content.player
		player.release_mouse()


func _after_unpause() -> void:
	if "control_grab_focus" in game_content and game_content.control_grab_focus is ControlGrabFocus:
		var control_grab_focus: ControlGrabFocus = game_content.control_grab_focus
		control_grab_focus.grab_focus()

	if "player" in game_content and game_content.player is Player:
		var player: Player = game_content.player
		player.capture_mouse()


func _after_leave() -> void:
	pass


# remove this function if you remove "Game Mode" from options
func _load_game_content_scene() -> void:
	game_content.queue_free()

	var game_content_pck: PackedScene = Configuration.get_game_mode_content_scene()
	var game_content_instance: Node = game_content_pck.instantiate()
	NodeUtils.add_child_front(game_content_instance, self)

	game_content = game_content_instance


func _action_game_pause_menu_button() -> void:
	game_content.visible = true
	pause_menu.visible = true
	options_menu.visible = false
	get_tree().paused = true
	_after_pause()
	LogWrapper.debug(name, "Game paused.")


func _action_continue_menu_button() -> void:
	game_content.visible = true
	pause_menu.visible = false
	options_menu.visible = false
	get_tree().paused = false
	_after_unpause()
	LogWrapper.debug(name, "Game unpaused.")


func _action_options_menu_button() -> void:
	game_content.visible = false
	pause_menu.visible = false
	options_menu.visible = true


func _action_options_back_menu_button() -> void:
	game_content.visible = true
	pause_menu.visible = true
	options_menu.visible = false


func _action_leave_menu_button() -> void:
	game_content.process_mode = Node.PROCESS_MODE_DISABLED
	game_content.visible = true
	pause_menu.visible = false
	options_menu.visible = false
	get_tree().paused = false
	LogWrapper.debug(name, "Game leave.")

	self.process_mode = PROCESS_MODE_DISABLED
	Data.exit_save_file()
	_after_leave()
	SceneManagerWrapper.change_scene(scene, scene_manager_options_id)


func _action_quit_menu_button() -> void:
	Data.save_save_file()
	get_tree().quit()


func _connect_signals() -> void:
	if "pause_menu_button" in game_content:
		game_content.pause_menu_button.confirmed.connect(_action_game_pause_menu_button)

	pause_menu.continue_menu_button.confirmed.connect(_action_continue_menu_button)
	pause_menu.options_menu_button.confirmed.connect(_action_options_menu_button)
	pause_menu.leave_menu_button.confirmed.connect(_action_leave_menu_button)
	pause_menu.quit_menu_button.confirmed.connect(_action_quit_menu_button)

	options_menu.back_menu_button.confirmed.connect(_action_options_back_menu_button)
