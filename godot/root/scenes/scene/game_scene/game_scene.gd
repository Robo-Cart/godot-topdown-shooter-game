class_name GameScene
extends Node

@export_group("Menu Scene")
@export var scene: SceneManagerEnum.Scene = SceneManagerEnum.Scene.MENU_SCENE
@export var scene_manager_options_id: String = "fade_play"

var is_transitioning: bool = false
var takeover_dialog: ConfirmationDialog

var _transition_rect: ColorRect
var _first_gamepad_handled: bool = false
var _takeover_device_id: int = -1
var _pausing_player: Player = null
var _is_counting_down: bool = false

@onready var game_content: Node = $GameContent
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var options_menu: OptionsMenu = %OptionsMenu
@onready var ui_builder: UiBuilder = %UiBuilder
@onready var hud: HUD = %HUD


# Esc key shortcut toggles pause menu or exits from options via back button
func _input(event: InputEvent) -> void:
	if is_transitioning:
		return

	var device_id: int = -1
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		device_id = event.device

	# Handle Pause (Start button on assigned pads or Escape on keyboard)
	if event.is_action_pressed("game_pause") or (
		event is InputEventJoypadButton
		and event.button_index == JOY_BUTTON_START
		and event.pressed
	):
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		var player_for_device: Player = null
		for p in players:
			if (p as Player).device_id == device_id:
				player_for_device = p as Player
				break

		# If this is a new gamepad
		if device_id != -1 and player_for_device == null:
			if not _first_gamepad_handled:
				_takeover_device_id = device_id
				get_tree().paused = true
				takeover_dialog.popup_centered()
			else:
				_spawn_player(device_id)
			return

		# Toggle pause only if the device is assigned to a player or is keyboard
		if device_id == -1 or player_for_device != null:
			if get_tree().paused:
				if pause_menu.visible:
					_action_continue_menu_button()
				else:
					_action_options_back_menu_button()
			else:
				_pausing_player = player_for_device
				_action_game_pause_menu_button()


func _ready() -> void:
	add_to_group("game_scene")
	_setup_transition_screen()
	_setup_takeover_dialog()
	_load_game_content_scene()

	ui_builder.build()

	_connect_signals()

	SignalBus.is_game_over = false
	_setup_hud()

	SignalBus.game_over.connect(_on_game_over)
	get_tree().node_removed.connect(_on_node_removed)

	LogWrapper.debug(self, "Ready.")


func _on_game_over() -> void:
	SignalBus.is_game_over = true


func _on_node_removed(node: Node) -> void:
	if node.is_in_group("player"):
		hud.remove_player_ui(node as Player)
		_check_player_respawn.call_deferred()


func _check_player_respawn() -> void:
	if _is_counting_down:
		return

	if get_tree().get_nodes_in_group("player").size() == 0 and not SignalBus.is_game_over:
		_start_respawn_countdown()


func _start_respawn_countdown() -> void:
	_is_counting_down = true
	hud.show_countdown(3)

	for i in range(2, -1, -1):
		await get_tree().create_timer(1.0).timeout
		if SignalBus.is_game_over:
			hud.hide_countdown()
			_is_counting_down = false
			return
		if i > 0:
			hud.update_countdown(i)

	hud.hide_countdown()
	_is_counting_down = false

	# Re-check in case a player joined during countdown or game over triggered
	if get_tree().get_nodes_in_group("player").size() == 0 and not SignalBus.is_game_over:
		_spawn_player(-1)


func _setup_takeover_dialog() -> void:
	takeover_dialog = ConfirmationDialog.new()
	takeover_dialog.title = "Gamepad Detected"
	takeover_dialog.dialog_text = (
		"Would you like this gamepad to take over Player 1 (Keyboard) or Join as a new Player?"
	)
	takeover_dialog.ok_button_text = "Take Over P1"
	takeover_dialog.cancel_button_text = "Join as P2"
	takeover_dialog.confirmed.connect(_on_takeover_confirmed)
	takeover_dialog.canceled.connect(_on_takeover_join_new)
	add_child(takeover_dialog)


func _on_takeover_confirmed() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	for p in players:
		var player: Player = p as Player
		if player.device_id == -1:
			player.device_id = _takeover_device_id
			LogWrapper.debug(
				self,
				_get_player_info(_takeover_device_id) + "Gamepad %d took over Player 1" % _takeover_device_id
			)
			break
	_first_gamepad_handled = true
	get_tree().paused = false


func _on_takeover_join_new() -> void:
	_spawn_player(_takeover_device_id)
	_first_gamepad_handled = true
	get_tree().paused = false


func _setup_hud() -> void:
	if not hud:
		return

	var player: Player = null
	if "player" in game_content and game_content.player is Player:
		player = game_content.player
	elif get_tree().get_nodes_in_group("player").size() > 0:
		player = get_tree().get_nodes_in_group("player")[0]

	if player:
		player.device_id = -1
		player.color_index = 0
		player.apply_tint()
		hud.add_player_ui()
		hud.setup_player_ui(0, player)
	elif not SignalBus.is_game_over:
		_spawn_player(-1)


func _spawn_player(device_id: int) -> void:
	var player_scene: PackedScene = load(
		"res://root/scenes/scene/game_scene/game_content/game_entities/player/player.tscn"
	)
	var new_player: Player = player_scene.instantiate() as Player
	new_player.device_id = device_id

	# Spawn in an area close to the centre of the 2d camera viewport
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var camera: Camera2D = get_viewport().get_camera_2d()
	var spawn_center: Vector2 = viewport_rect.size / 2.0
	if camera:
		spawn_center = camera.get_screen_center_position()

	var max_offset: float = viewport_rect.size.x * 0.25

	new_player.global_position = spawn_center + Vector2(
		randf_range(-max_offset, max_offset),
		randf_range(-max_offset, max_offset)
	)

	new_player.color_index = _get_next_available_color_index()

	game_content.add_child(new_player)
	new_player.apply_tint()
	MultiplayerManager.spawn_local_player(device_id)

	hud.add_player_ui()
	hud.setup_player_ui(hud.player_ui_container.get_child_count() - 1, new_player)

	LogWrapper.debug(self, _get_player_info(device_id) + "Spawned player for device %d" % device_id)


func _get_next_available_color_index() -> int:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var used_indices: Array[int] = []
	for p in players:
		used_indices.append((p as Player).color_index)

	for i in range(MultiplayerManager.player_colors.size()):
		if not i in used_indices:
			return i

	return used_indices.size()  # Fallback


func _get_player_info(device_id: int) -> String:
	var steam_id: String = "Local"
	if Engine.has_singleton("Steam"):
		var steam_singleton: Object = Engine.get_singleton("Steam")
		var s_id: int = steam_singleton.getSteamID()
		if s_id > 0:
			steam_id = "Steam%d" % s_id

	var peer_info: String = "Host" if multiplayer.is_server() else "Peer"
	return "[Dev%d|%s|%s] " % [device_id, steam_id, peer_info]


func _setup_transition_screen() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	canvas.layer = 100

	_transition_rect = ColorRect.new()
	_transition_rect.color = Color(0, 0, 0, 0)
	_transition_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	canvas.add_child(_transition_rect)
	add_child(canvas)


func fade_out() -> void:
	is_transitioning = true
	get_tree().paused = true

	var tween: Tween = create_tween()
	tween.tween_property(_transition_rect, "color:a", 1.0, 0.4)
	await tween.finished


func fade_in() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_transition_rect, "color:a", 0.0, 0.4)
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
	pause_menu.setup_for_player(_pausing_player)
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


func _action_disconnect_menu_button() -> void:
	if _pausing_player == null or _pausing_player.color_index == 0:
		return

	var device_id: int = _pausing_player.device_id
	LogWrapper.debug(
		self,
		"Disconnecting player P%d (Dev%d)" % [_pausing_player.color_index + 1, device_id]
	)

	MultiplayerManager.unregister_local_player(device_id)
	hud.remove_player_ui(_pausing_player)
	_pausing_player.queue_free()

	_action_continue_menu_button()


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
	pause_menu.disconnect_menu_button.confirmed.connect(_action_disconnect_menu_button)
	pause_menu.options_menu_button.confirmed.connect(_action_options_menu_button)
	pause_menu.leave_menu_button.confirmed.connect(_action_leave_menu_button)
	pause_menu.quit_menu_button.confirmed.connect(_action_quit_menu_button)

	options_menu.back_menu_button.confirmed.connect(_action_options_back_menu_button)
