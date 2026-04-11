extends Node
## [WaveManagerComponent]
## Manages the unified spawn queue for enemies and powerups based on LevelData.
## Handles multiplayer scaling, threaded loading, and door management.

signal wave_started(stamp: String)
signal enemy_spawned(enemy: Node2D)
signal all_spawns_completed

const DOOR_CLEARANCE_RADIUS: float = 160.0
const SCALING_DATA_PATH: String = (
	"res://root/scenes/component/multiplayer_scaling/multiplayer_scaling_data.gd"
)

@export_group("Spawn Positioning")
@export var spawn_distance_towards_player: float = 60.0
@export var spawn_perpendicular_variance: float = 10.0

var _level_data: LevelData
var _level_timer: float = 0.0
var _current_spawn_index: int = 0
var _spawn_queue: Array[Dictionary] = []
var _is_paused: bool = false
var _cached_scenes: Dictionary = {}
var _last_indices_for_waves: Dictionary = {}
var _opened_doors_per_wave: Dictionary = {}
var _active_waves_waiting_to_close: Array[String] = []
var _wave_spawners: Dictionary = {}  # wave_stamp -> Array[Vector2]
var _all_spawns_triggered: bool = false
var _last_boss_wave_stamp: String = ""


func _process(delta: float) -> void:
	if _is_paused or not _level_data:
		return

	_process_spawning()
	_update_active_waves_clearance()

	# We only advance the timer if not blocked by a boss wait condition
	if not _is_spawn_blocked():
		_level_timer += delta


func setup(data: LevelData) -> void:
	_level_data = data
	_level_timer = 0.0
	_current_spawn_index = 0
	_all_spawns_triggered = false
	_build_spawn_queue()
	_setup_initial_doors()


func pause_spawner(should_pause: bool) -> void:
	_is_paused = should_pause


func accelerate_spawns(shift_amount: float) -> void:
	if _current_spawn_index >= _spawn_queue.size():
		return

	for i: int in range(_current_spawn_index, _spawn_queue.size()):
		_spawn_queue[i].time -= shift_amount

	LogWrapper.debug(self, "Spawns accelerated by %.2fs" % shift_amount)


func force_close_all_doors() -> void:
	_active_waves_waiting_to_close.clear()
	_wave_spawners.clear()
	_opened_doors_per_wave.clear()
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	for door: Node in doors:
		if door is ObjectDoor:
			while door.get("_spawn_request_count") != null and door.get("_spawn_request_count") > 0:
				door.close_door()
			door.close_door()


func open_all_doors_final() -> void:
	_active_waves_waiting_to_close.clear()
	_wave_spawners.clear()
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	var viewport_center: Vector2 = Vector2(576, 324)

	for door: Node in doors:
		if door is ObjectDoor:
			var dir: Vector2 = door.global_position - viewport_center
			var direction_offset: Vector2i = Vector2i.ZERO

			if abs(dir.x) > abs(dir.y):
				direction_offset = Vector2i(1, 0) if dir.x > 0 else Vector2i(-1, 0)
			else:
				direction_offset = Vector2i(0, 1) if dir.y > 0 else Vector2i(0, -1)

			if ZoneManager.is_door_valid(direction_offset):
				door.open_door_final()


func _build_spawn_queue() -> void:
	_spawn_queue.clear()
	_cached_scenes.clear()

	var player_count: int = 1
	if MultiplayerManager:
		player_count = MultiplayerManager.get_total_player_count()

	var p_index: int = clamp(player_count - 1, 0, 7)
	var scaling_data_script: GDScript = load(SCALING_DATA_PATH)
	var scaling_data: MultiplayerScalingData = scaling_data_script.new()
	var wave_mult: float = scaling_data.wave_size_mult[p_index]
	var powerup_mult: float = scaling_data.powerup_spawn_mult[p_index]

	# 1. Enemy Waves
	for wave: EnemyWaveConfig in _level_data.enemy_wave_config:
		var num_enemies: int = (
			int(wave.number_of_enemies * wave_mult)
			if not wave.is_boss_wave
			else wave.number_of_enemies
		)
		var duration: float = wave.seconds_to_spawn_over
		var num_spawn_points: int = wave.spawn_points.size()

		if num_spawn_points == 0:
			continue

		var time_interval: float = 0.0
		if num_enemies > 1 and duration > 0.0:
			time_interval = duration / float(num_enemies - 1)

		if not _cached_scenes.has(wave.enemy_scene_path):
			ResourceLoader.load_threaded_request(wave.enemy_scene_path)
			_cached_scenes[wave.enemy_scene_path] = true

		for i: int in range(num_enemies):
			var exact_spawn_time: float = wave.time + (i * time_interval)
			_spawn_queue.append(
				{
					"time": exact_spawn_time,
					"category": "enemy",
					"scene_path": wave.enemy_scene_path,
					"location": wave.spawn_points[i % num_spawn_points],
					"wave_stamp": wave.time_stamp,
					"wait_before_spawn": wave.is_boss_wave and i == 0,
					"is_boss_wave": wave.is_boss_wave,
					"nice_name": wave.enemy_name
				}
			)

	# 2. Powerup Waves
	for powerup: PowerupWaveConfig in _level_data.powerup_wave_config:
		var num_powerups: int = int(1.0 * powerup_mult)
		for p_i: int in range(num_powerups):
			var exact_spawn_time: float = powerup.time + (p_i * 0.5)
			var chosen_loc: SpawnConfig.Location = (
				powerup.spawn_points.pick_random()
				if powerup.spawn_points.size() > 0
				else SpawnConfig.Location.RANDOM_INNER
			)
			_spawn_queue.append(
				{
					"time": exact_spawn_time,
					"category": "powerup",
					"scene_path": powerup.powerup_scene_path,
					"location": chosen_loc,
					"wave_stamp": powerup.time_stamp,
					"nice_name": powerup.display_name
				}
			)

	_spawn_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.time < b.time)

	# Map last indices for door handling
	for i: int in range(_spawn_queue.size()):
		_last_indices_for_waves[_spawn_queue[i].wave_stamp] = i
		if _spawn_queue[i].get("is_boss_wave", false):
			_last_boss_wave_stamp = _spawn_queue[i].wave_stamp


func _is_spawn_blocked() -> bool:
	if _current_spawn_index >= _spawn_queue.size():
		return false

	var next_spawn: Dictionary = _spawn_queue[_current_spawn_index]
	if next_spawn.get("wait_before_spawn", false) and _level_timer >= next_spawn.time:
		if get_tree().get_nodes_in_group("enemy").size() > 0:
			return true
	return false


func _process_spawning() -> void:
	while (
		_current_spawn_index < _spawn_queue.size()
		and _level_timer >= _spawn_queue[_current_spawn_index].time
		and not _is_spawn_blocked()
	):
		var spawn_data: Dictionary = _spawn_queue[_current_spawn_index]

		if spawn_data.get("wait_before_spawn", false):
			force_close_all_doors()

		if spawn_data.category == "enemy":
			_spawn_enemy(spawn_data)
		else:
			_spawn_powerup(spawn_data)

		if (
			spawn_data.category == "enemy"
			and _last_indices_for_waves.get(spawn_data.wave_stamp) == _current_spawn_index
		):
			if spawn_data.wave_stamp not in _active_waves_waiting_to_close:
				_active_waves_waiting_to_close.append(spawn_data.wave_stamp)

		_current_spawn_index += 1

	if _current_spawn_index >= _spawn_queue.size() and not _all_spawns_triggered:
		_all_spawns_triggered = true
		all_spawns_completed.emit()


func _spawn_enemy(data: Dictionary) -> void:
	var enemy_scene: PackedScene = _get_scene(data.scene_path)
	if not enemy_scene:
		return

	var enemy: Node2D = enemy_scene.instantiate() as Node2D
	var result: Array = _get_spawn_position(data.location, data.wave_stamp, data.is_boss_wave)
	var spawn_pos: Vector2 = result[0]
	var door: ObjectDoor = result[1]
	var spawner: Node2D = result[2]

	enemy.global_position = spawn_pos
	_add_multiplayer_scaling(enemy, data.is_boss_wave)

	get_parent().add_child(enemy)
	enemy_spawned.emit(enemy)

	if not data.is_boss_wave and door:
		_setup_spawn_intro(enemy, data.location, door, spawner)


func _spawn_powerup(data: Dictionary) -> void:
	var powerup_scene: PackedScene = _get_scene(data.scene_path)
	if not powerup_scene:
		return

	var powerup: Node2D = powerup_scene.instantiate() as Node2D
	var result: Array = _get_spawn_position(data.location, "", false)
	powerup.global_position = result[0]
	get_parent().add_child(powerup)


func _get_scene(path: String) -> PackedScene:
	if typeof(_cached_scenes.get(path)) == TYPE_BOOL:
		var scene: PackedScene = ResourceLoader.load_threaded_get(path) as PackedScene
		_cached_scenes[path] = scene
		return scene
	return _cached_scenes.get(path) as PackedScene


func _get_spawn_position(loc: SpawnConfig.Location, stamp: String, is_boss: bool) -> Array:
	var valid_spawners: Array[Node] = []
	var spawners: Array[Node] = get_tree().get_nodes_in_group("enemy_wave_spawner_edge")

	if loc == SpawnConfig.Location.RANDOM_INNER:
		valid_spawners = get_tree().get_nodes_in_group("enemy_wave_spawner_inner")
	elif loc == SpawnConfig.Location.MAIN_BOSS:
		valid_spawners = get_tree().get_nodes_in_group("enemy_wave_spawner_boss")
	else:
		for s: Node in spawners:
			if s.get("location") == loc as int:
				valid_spawners.append(s)

	if valid_spawners.size() == 0:
		valid_spawners = spawners  # Fallback

	var chosen: Node2D = valid_spawners.pick_random() as Node2D
	var spawner_pos: Vector2 = chosen.global_position
	var door: ObjectDoor = null

	if stamp != "" and not is_boss:
		door = _handle_doors_near_spawner(spawner_pos, stamp)

	var player: Node2D = get_tree().get_first_node_in_group("player")
	if not player:
		return [spawner_pos, door, chosen]

	var dir: Vector2 = spawner_pos.direction_to(player.global_position)
	var pos: Vector2 = spawner_pos + (dir * spawn_distance_towards_player)
	var slide: float = randf_range(-spawn_perpendicular_variance, spawn_perpendicular_variance)

	return [pos + (dir.orthogonal() * slide), door, chosen]


func _handle_doors_near_spawner(spawner_pos: Vector2, stamp: String) -> ObjectDoor:
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	var closest: ObjectDoor = null
	var min_dist: float = 120.0

	for door: Node in doors:
		if door is ObjectDoor:
			var dist: float = door.global_position.distance_to(spawner_pos)
			if dist < min_dist:
				min_dist = dist
				closest = door

	if closest:
		if stamp not in _opened_doors_per_wave:
			_opened_doors_per_wave[stamp] = []
		if closest not in _opened_doors_per_wave[stamp]:
			closest.open_door_for_spawn()
			_opened_doors_per_wave[stamp].append(closest)
			if stamp not in _wave_spawners:
				_wave_spawners[stamp] = []
			_wave_spawners[stamp].append(spawner_pos)

	return closest


func _update_active_waves_clearance() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var waves_to_remove: Array[String] = []

	for stamp: String in _active_waves_waiting_to_close:
		var is_clear: bool = true
		for spawner_pos: Vector2 in _wave_spawners.get(stamp, []):
			for enemy: Node in enemies:
				if (
					enemy is Node2D
					and enemy.global_position.distance_to(spawner_pos) < DOOR_CLEARANCE_RADIUS
				):
					is_clear = false
					break
			if not is_clear:
				break

		if is_clear:
			_close_doors_for_wave(stamp)
			waves_to_remove.append(stamp)

	for stamp: String in waves_to_remove:
		_active_waves_waiting_to_close.erase(stamp)


func _close_doors_for_wave(stamp: String) -> void:
	for door: ObjectDoor in _opened_doors_per_wave.get(stamp, []):
		if is_instance_valid(door):
			door.close_door()
	_opened_doors_per_wave.erase(stamp)
	_wave_spawners.erase(stamp)


func _setup_initial_doors() -> void:
	get_tree().call_group("object_door", "close_door")


func _add_multiplayer_scaling(enemy: Node2D, is_boss: bool) -> void:
	var ScalerScene: PackedScene = preload(
		"res://root/scenes/component/multiplayer_scaling/multiplayer_scaling_component.tscn"
	)
	var scaler: MultiplayerScalingComponent = ScalerScene.instantiate()
	var scaler_data_res: GDScript = load(SCALING_DATA_PATH)
	scaler.scaling_data = scaler_data_res.new()
	scaler.is_boss = is_boss
	enemy.add_child(scaler)


func _setup_spawn_intro(
	enemy: Node2D, loc: SpawnConfig.Location, door: ObjectDoor, spawner: Node2D
) -> void:
	var intro: SpawnIntroComponent = enemy.find_child("*SpawnIntroComponent*", true, false)
	if intro:
		var actual_loc: SpawnConfig.Location = loc
		if loc == SpawnConfig.Location.RANDOM_SIDE:
			var viewport_center: Vector2 = Vector2(576, 324)
			var dir: Vector2 = door.global_position - viewport_center
			if abs(dir.x) > abs(dir.y):
				actual_loc = SpawnConfig.Location.EAST if dir.x > 0 else SpawnConfig.Location.WEST
			else:
				actual_loc = SpawnConfig.Location.SOUTH if dir.y > 0 else SpawnConfig.Location.NORTH

		var target_pos: Vector2 = Vector2.ZERO
		if spawner and spawner.has_method("get_target_position"):
			target_pos = spawner.get_target_position()

		intro.setup(actual_loc, door, target_pos)
