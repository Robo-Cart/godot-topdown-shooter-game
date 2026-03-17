extends Node2D

const DOOR_CLEARANCE_RADIUS: float = 160.0

@export var level_data: LevelData

@export_group("Spawn Positioning")
@export var spawn_distance_towards_player: float = 60.0
@export var spawn_perpendicular_variance: float = 10.0

var _level_timer: float = 0.0
var _current_spawn_index: int = 0
var _spawn_queue: Array[Dictionary] = []
var _is_spawner_paused: bool = false
var _cached_scenes: Dictionary = {}
var _last_indices_for_waves: Dictionary = {}
var _opened_doors_per_wave: Dictionary = {}
var _active_waves_waiting_to_close: Array[String] = []
var _wave_spawners: Dictionary = {} # wave_stamp -> Array[Vector2]
var _all_spawns_completed: bool = false
var _time_since_last_enemy_clear: float = 0.0


func _ready() -> void:
	if not level_data:
		LogWrapper.debug(self, "CRITICAL ERROR: No LevelData assigned to Level!")
		set_process(false)
		return

	LogWrapper.debug(
		self,
		(
			"Initializing Level: %s (Difficulty: %d)"
			% [level_data.level_name, level_data.level_difficulty]
		)
	)

	_build_spawn_queue()
	_setup_initial_doors()


func _process(delta: float) -> void:
	if not _is_spawner_paused:
		_check_spawns()

		if _all_spawns_completed:
			var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
			if enemies.size() == 0:
				_open_all_doors_final()
				_is_spawner_paused = true # Level complete
		else:
			var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
			var is_blocked: bool = false

			# Accelerate spawns if clear for 3 seconds
			if enemies.size() == 0 and _current_spawn_index > 0:
				_time_since_last_enemy_clear += delta
				if _time_since_last_enemy_clear >= 3.0:
					_accelerate_spawns()
					_time_since_last_enemy_clear = 0.0
			else:
				_time_since_last_enemy_clear = 0.0

			if _current_spawn_index < _spawn_queue.size():
				var next_spawn: Dictionary = _spawn_queue[_current_spawn_index]
				if next_spawn.get("wait_before_spawn", false) and _level_timer >= next_spawn.time:
					if enemies.size() > 0:
						is_blocked = true

			if not is_blocked:
				_level_timer += delta

	_update_active_waves_clearance()


func _accelerate_spawns() -> void:
	if _current_spawn_index >= _spawn_queue.size():
		return

	var next_spawn_time: float = _spawn_queue[_current_spawn_index].time
	# We want the next spawn to happen effectively 'now' since 3 seconds have already passed
	var shift_amount: float = next_spawn_time - _level_timer

	if shift_amount > 0:
		LogWrapper.debug(
			self,
			"Level clear! Shifting remaining %d spawns forward by %.2fs"
			% [_spawn_queue.size() - _current_spawn_index, shift_amount]
		)
		for i in range(_current_spawn_index, _spawn_queue.size()):
			_spawn_queue[i].time -= shift_amount


func _setup_initial_doors() -> void:
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	for door in doors:
		if door is ObjectDoor:
			# Use set_deferred or direct internal access if we were the owner,
			# but ObjectDoor manages its own is_open now.
			# To force a close animation, we can just call close_door().
			# If we need to force it, ObjectDoor needs a way.
			# Since we just updated ObjectDoor, we should ensure it handles initial state.
			door.close_door()


func _build_spawn_queue() -> void:
	# --- 1. Process Enemy Waves ---
	for wave in level_data.enemy_wave_config:
		var num_enemies: int = wave.number_of_enemies
		var duration: float = wave.seconds_to_spawn_over
		var num_spawn_points: int = wave.spawn_points.size()

		if num_spawn_points == 0:
			LogWrapper.debug(
				self, "Warning: Enemy wave at %s has no spawn points. Skipping." % wave.time_stamp
			)
			continue

		var time_interval: float = 0.0
		if num_enemies > 1 and duration > 0.0:
			time_interval = duration / float(num_enemies - 1)

		if not _cached_scenes.has(wave.enemy_scene_path):
			ResourceLoader.load_threaded_request(wave.enemy_scene_path)
			_cached_scenes[wave.enemy_scene_path] = true  # Just mark that we requested it

		for i in range(num_enemies):
			var exact_spawn_time: float = wave.time + (i * time_interval)
			var point: SpawnConfig.Location = wave.spawn_points[i % num_spawn_points]

			_spawn_queue.append(
				{
					"time": exact_spawn_time,
					"category": "enemy",
					"enemy_name": wave.enemy_name,
					"scene_path": wave.enemy_scene_path,
					"location": point,
					"wave_stamp": wave.time_stamp,
					"wait_before_spawn": wave.is_boss_wave and i == 0,
					"is_boss_wave": wave.is_boss_wave
				}
			)

	# --- 2. Process Powerup Waves ---
	for powerup in level_data.powerup_wave_config:
		var exact_spawn_time: float = powerup.time

		if powerup.random_factor > 0:
			var deviation: float = randf_range(
				-float(powerup.random_factor), float(powerup.random_factor)
			)
			exact_spawn_time = max(0.0, exact_spawn_time + deviation)

		var chosen_location: SpawnConfig.Location = SpawnConfig.Location.RANDOM_INNER

		if powerup.spawn_points.size() > 0:
			chosen_location = powerup.spawn_points.pick_random()

		if not _cached_scenes.has(powerup.powerup_scene_path):
			ResourceLoader.load_threaded_request(powerup.powerup_scene_path)
			_cached_scenes[powerup.powerup_scene_path] = true

		_spawn_queue.append(
			{
				"time": exact_spawn_time,
				"category": "powerup",
				"powerup_name": powerup.display_name,
				"scene_path": powerup.powerup_scene_path,
				"location": chosen_location,
				"wave_stamp": powerup.time_stamp
			}
		)

	# --- 3. Sort the Unified Timeline ---
	_spawn_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.time < b.time)

	# --- 3b. Map last indices for waves to handle door closing ---
	for i in range(_spawn_queue.size()):
		_last_indices_for_waves[_spawn_queue[i].wave_stamp] = i

	LogWrapper.debug(
		self, "Built unified spawn queue with %d total events scheduled." % _spawn_queue.size()
	)

	# --- 4. Detailed Logging Summary ---
	LogWrapper.debug(self, "--- Level Spawn Schedule Summary ---")

	LogWrapper.debug(self, "[Enemy Waves]")
	for wave in level_data.enemy_wave_config:
		var boss_tag: String = " [BOSS WAVE]" if wave.is_boss_wave else ""
		LogWrapper.debug(
			self,
			(
				"  - %s: %d x %s (over %.1fs)%s"
				% [
					wave.time_stamp,
					wave.number_of_enemies,
					wave.enemy_name,
					wave.seconds_to_spawn_over,
					boss_tag
				]
			)
		)

	if level_data.powerup_wave_config.size() > 0:
		LogWrapper.debug(self, "[Powerup Waves]")
		for powerup in level_data.powerup_wave_config:
			LogWrapper.debug(
				self,
				"  - %s: %s (random factor: %d)"
				% [powerup.time_stamp, powerup.display_name, powerup.random_factor]
			)

	LogWrapper.debug(self, "-----------------------------------")


func _update_active_waves_clearance() -> void:
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
	var waves_to_remove: Array[String] = []

	for wave_stamp in _active_waves_waiting_to_close:
		var is_clear: bool = true
		var spawner_positions: Array = _wave_spawners.get(wave_stamp, [])

		# For each spawner involved in this wave, check if any enemy is nearby
		for spawner_pos: Vector2 in spawner_positions:
			for enemy in enemies:
				if enemy is Node2D:
					if enemy.global_position.distance_to(spawner_pos) < DOOR_CLEARANCE_RADIUS:
						is_clear = false
						break
			if not is_clear:
				break

		if is_clear:
			_close_doors_for_wave(wave_stamp)
			waves_to_remove.append(wave_stamp)
			_wave_spawners.erase(wave_stamp)

	for wave_stamp in waves_to_remove:
		_active_waves_waiting_to_close.erase(wave_stamp)


func _check_spawns() -> void:
	while (
		_current_spawn_index < _spawn_queue.size()
		and _level_timer >= _spawn_queue[_current_spawn_index].time
	):
		var spawn_data: Dictionary = _spawn_queue[_current_spawn_index]

		if spawn_data.get("wait_before_spawn", false):
			var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")
			if enemies.size() > 0:
				break
			# Start of a boss wave and level is clear: close all doors
			_force_close_all_doors()

		if spawn_data.category == "enemy":
			_spawn_enemy(
				spawn_data.scene_path,
				spawn_data.enemy_name,
				spawn_data.location,
				spawn_data.wave_stamp,
				spawn_data.get("is_boss_wave", false)
			)
		elif spawn_data.category == "powerup":
			_spawn_powerup(
				spawn_data.scene_path,
				spawn_data.powerup_name,
				spawn_data.location,
				spawn_data.wave_stamp
			)

		if (spawn_data.category == "enemy"
				and _last_indices_for_waves.get(spawn_data.wave_stamp) == _current_spawn_index):
			# Instead of closing immediately, we add to the clearance queue
			if spawn_data.wave_stamp not in _active_waves_waiting_to_close:
				_active_waves_waiting_to_close.append(spawn_data.wave_stamp)

		_current_spawn_index += 1

		if _current_spawn_index >= _spawn_queue.size():
			LogWrapper.debug(self, "All scheduled events (enemies and powerups) have been spawned.")
			_all_spawns_completed = true


func _close_doors_for_wave(wave_stamp: String) -> void:
	if _opened_doors_per_wave.has(wave_stamp):
		for door: ObjectDoor in _opened_doors_per_wave[wave_stamp]:
			if is_instance_valid(door):
				door.close_door()
		_opened_doors_per_wave.erase(wave_stamp)


func _open_all_doors_final() -> void:
	_active_waves_waiting_to_close.clear()
	_wave_spawners.clear()
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	for door in doors:
		if door is ObjectDoor:
			door.open_door_final()


func _force_close_all_doors() -> void:
	# This clears all active tracking for open doors and shuts them immediately
	_active_waves_waiting_to_close.clear()
	_wave_spawners.clear()
	_opened_doors_per_wave.clear()
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	for door in doors:
		if door is ObjectDoor:
			# Force a single close animation.
			# ObjectDoor already handles is_open/is_final_open checks inside close_door.
			# But we want to ensure any current spawn_request_count is reset.
			# We'll just loop until it's closed since close_door decrements.
			while door._spawn_request_count > 0:
				door.close_door()
			# In case count was already 0 but it was somehow open:
			door.close_door()


func _get_spawn_position(
	location: SpawnConfig.Location, wave_stamp: String = "", is_boss_wave: bool = false
) -> Array:
	var valid_spawners: Array[Node] = []
	var edge_spawners: Array[Node] = get_tree().get_nodes_in_group("enemy_wave_spawner_edge")
	var inner_spawners: Array[Node] = get_tree().get_nodes_in_group("enemy_wave_spawner_inner")
	var boss_spawners: Array[Node] = get_tree().get_nodes_in_group("enemy_wave_spawner_boss")

	if location == SpawnConfig.Location.RANDOM_INNER:
		valid_spawners = inner_spawners
	elif location == SpawnConfig.Location.RANDOM_SIDE:
		valid_spawners = edge_spawners
	elif location == SpawnConfig.Location.MAIN_BOSS:
		valid_spawners = boss_spawners
	else:
		for spawner in edge_spawners:
			if spawner.location == location as int:
				valid_spawners.append(spawner)

	if valid_spawners.size() > 0:
		var chosen_spawner: Node = valid_spawners.pick_random()
		var spawner_pos: Vector2 = chosen_spawner.global_position
		var door: ObjectDoor = null

		# Handle doors near spawner if wave_stamp provided AND not a boss wave
		if wave_stamp != "" and not is_boss_wave:
			door = _handle_doors_near_spawner(spawner_pos, wave_stamp)

		var player: Node2D = get_tree().get_first_node_in_group("player")

		if not player:
			return [spawner_pos, door]

		var direction_to_player: Vector2 = spawner_pos.direction_to(player.global_position)
		var base_spawn_pos: Vector2 = (
			spawner_pos + (direction_to_player * spawn_distance_towards_player)
		)
		var perpendicular_direction: Vector2 = direction_to_player.orthogonal()
		var random_slide: float = randf_range(
			-spawn_perpendicular_variance, spawn_perpendicular_variance
		)

		return [base_spawn_pos + (perpendicular_direction * random_slide), door]

	LogWrapper.debug(
		self, "WARNING: No valid spawner found for location %s! Defaulting to center." % location
	)
	return [Vector2.ZERO, null]


func _handle_doors_near_spawner(spawner_pos: Vector2, wave_stamp: String) -> ObjectDoor:
	var doors: Array[Node] = get_tree().get_nodes_in_group("object_door")
	var closest_door: ObjectDoor = null
	var min_dist: float = 120.0 # Proximity threshold for door association

	for door in doors:
		if door is ObjectDoor:
			var dist: float = door.global_position.distance_to(spawner_pos)
			if dist < min_dist:
				min_dist = dist
				closest_door = door

	if closest_door:
		if not _opened_doors_per_wave.has(wave_stamp):
			_opened_doors_per_wave[wave_stamp] = []

		if closest_door not in _opened_doors_per_wave[wave_stamp]:
			closest_door.open_door_for_spawn()
			_opened_doors_per_wave[wave_stamp].append(closest_door)

			# Record spawner position for clearance check
			if not _wave_spawners.has(wave_stamp):
				_wave_spawners[wave_stamp] = []
			if spawner_pos not in _wave_spawners[wave_stamp]:
				_wave_spawners[wave_stamp].append(spawner_pos)

	return closest_door


func _spawn_enemy(
	scene_path: String,
	nice_name: String,
	location: SpawnConfig.Location,
	wave_stamp: String,
	is_boss_wave: bool = false
) -> void:
	if scene_path == "" or scene_path == null:
		LogWrapper.debug(self, "CRITICAL: Cannot spawn '%s'. No scene path assigned!" % nice_name)
		return

	var enemy_scene: PackedScene

	if typeof(_cached_scenes.get(scene_path)) == TYPE_BOOL:
		enemy_scene = ResourceLoader.load_threaded_get(scene_path) as PackedScene
		_cached_scenes[scene_path] = enemy_scene
	else:
		enemy_scene = _cached_scenes.get(scene_path) as PackedScene

	if enemy_scene:
		var enemy_instance: Node2D = enemy_scene.instantiate() as Node2D
		var result: Array = _get_spawn_position(location, wave_stamp, is_boss_wave)
		var spawn_pos: Vector2 = result[0]
		var door: ObjectDoor = result[1]

		enemy_instance.global_position = spawn_pos
		add_child(enemy_instance)

		# Generic component check for intro logic (skip for boss waves)
		if not is_boss_wave:
			var is_edge: bool = location in [
				SpawnConfig.Location.NORTH, SpawnConfig.Location.EAST,
				SpawnConfig.Location.SOUTH, SpawnConfig.Location.WEST,
				SpawnConfig.Location.RANDOM_SIDE
			]

			if is_edge and door:
				var intro_comp: SpawnIntroComponent = enemy_instance.find_child(
					"*SpawnIntroComponent*", true, false
				) as SpawnIntroComponent
				if intro_comp:
					# For RANDOM_SIDE, we need to know WHICH side was actually chosen
					var actual_location: SpawnConfig.Location = location
					if location == SpawnConfig.Location.RANDOM_SIDE:
						# Infer location from door proximity if possible
						var viewport_center: Vector2 = Vector2(576, 324) # Approximate
						var dir: Vector2 = door.global_position - viewport_center
						if abs(dir.x) > abs(dir.y):
							actual_location = SpawnConfig.Location.EAST if dir.x > 0 \
								else SpawnConfig.Location.WEST
						else:
							actual_location = SpawnConfig.Location.SOUTH if dir.y > 0 \
								else SpawnConfig.Location.NORTH

					intro_comp.setup(actual_location, door)
	else:
		LogWrapper.debug(
			self, "ERROR: Failed to load %s scene at path: %s" % [nice_name, scene_path]
		)


func _spawn_powerup(
	scene_path: String, nice_name: String, location: SpawnConfig.Location, _wave_stamp: String
) -> void:
	if scene_path == "" or scene_path == null:
		LogWrapper.debug(self, "CRITICAL: Cannot spawn '%s'. No scene path assigned!" % nice_name)
		return

	var powerup_scene: PackedScene

	if typeof(_cached_scenes.get(scene_path)) == TYPE_BOOL:
		powerup_scene = ResourceLoader.load_threaded_get(scene_path) as PackedScene
		_cached_scenes[scene_path] = powerup_scene
	else:
		powerup_scene = _cached_scenes.get(scene_path) as PackedScene

	if powerup_scene:
		var powerup_instance: Node2D = powerup_scene.instantiate() as Node2D
		# Do not pass wave_stamp to _get_spawn_position for powerups to avoid opening doors
		var result: Array = _get_spawn_position(location, "")
		var spawn_pos: Vector2 = result[0]
		powerup_instance.global_position = spawn_pos
		add_child(powerup_instance)
	else:
		LogWrapper.debug(
			self, "ERROR: Failed to load %s scene at path: %s" % [nice_name, scene_path]
		)
