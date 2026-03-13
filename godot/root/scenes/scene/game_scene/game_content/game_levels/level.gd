extends Node2D

@export var level_data: LevelData

@export_group("Spawn Positioning")
@export var spawn_distance_towards_player: float = 20.0
@export var spawn_perpendicular_variance: float = 10.0

var level_timer: float = 0.0
var current_spawn_index: int = 0
var spawn_queue: Array[Dictionary] = []
var is_spawner_paused: bool = false

var cached_scenes: Dictionary = {}


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

		if not cached_scenes.has(wave.enemy_scene_path):
			ResourceLoader.load_threaded_request(wave.enemy_scene_path)
			cached_scenes[wave.enemy_scene_path] = true  # Just mark that we requested it

		for i in range(num_enemies):
			var exact_spawn_time: float = wave.time + (i * time_interval)
			var point: SpawnConfig.Location = wave.spawn_points[i % num_spawn_points]

			spawn_queue.append(
				{
					"time": exact_spawn_time,
					"category": "enemy",
					"enemy_name": wave.enemy_name,
					"scene_path": wave.enemy_scene_path,
					"location": point,
					"wave_stamp": wave.time_stamp
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

		if not cached_scenes.has(powerup.powerup_scene_path):
			ResourceLoader.load_threaded_request(powerup.powerup_scene_path)
			cached_scenes[powerup.powerup_scene_path] = true

		spawn_queue.append(
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
	spawn_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.time < b.time)

	LogWrapper.debug(
		self, "Built unified spawn queue with %d total events scheduled." % spawn_queue.size()
	)


func _process(delta: float) -> void:
	if not is_spawner_paused:
		level_timer += delta
		_check_spawns()


func _check_spawns() -> void:
	while (
		current_spawn_index < spawn_queue.size()
		and level_timer >= spawn_queue[current_spawn_index].time
	):
		var spawn_data: Dictionary = spawn_queue[current_spawn_index]

		if spawn_data.category == "enemy":
			_spawn_enemy(
				spawn_data.scene_path,
				spawn_data.enemy_name,
				spawn_data.location,
				spawn_data.wave_stamp
			)
		elif spawn_data.category == "powerup":
			_spawn_powerup(
				spawn_data.scene_path,
				spawn_data.powerup_name,
				spawn_data.location,
				spawn_data.wave_stamp
			)

		current_spawn_index += 1

		if current_spawn_index >= spawn_queue.size():
			LogWrapper.debug(self, "All scheduled events (enemies and powerups) have been spawned.")


func _get_spawn_position(location: SpawnConfig.Location) -> Vector2:
	var valid_spawners: Array[Node] = []
	var edge_spawners: Array[Node] = get_tree().get_nodes_in_group("enemy_wave_spawner_edge")
	var inner_spawners: Array[Node] = get_tree().get_nodes_in_group("enemy_wave_spawner_inner")

	if location == SpawnConfig.Location.RANDOM_INNER:
		valid_spawners = inner_spawners
	elif location == SpawnConfig.Location.RANDOM_SIDE:
		valid_spawners = edge_spawners
	else:
		for spawner in edge_spawners:
			if spawner.location == location as int:
				valid_spawners.append(spawner)

	if valid_spawners.size() > 0:
		var chosen_spawner: Node = valid_spawners.pick_random()
		var spawner_pos: Vector2 = chosen_spawner.global_position

		var player: Node2D = get_tree().get_first_node_in_group("player")

		if not player:
			return spawner_pos

		var direction_to_player: Vector2 = spawner_pos.direction_to(player.global_position)
		var base_spawn_pos: Vector2 = (
			spawner_pos + (direction_to_player * spawn_distance_towards_player)
		)
		var perpendicular_direction: Vector2 = direction_to_player.orthogonal()
		var random_slide: float = randf_range(
			-spawn_perpendicular_variance, spawn_perpendicular_variance
		)

		return base_spawn_pos + (perpendicular_direction * random_slide)
	else:
		LogWrapper.debug(
			self,
			"WARNING: No valid spawner found for location %s! Defaulting to center." % location
		)
		return Vector2.ZERO


func _spawn_enemy(
	scene_path: String, nice_name: String, location: SpawnConfig.Location, _wave_stamp: String
) -> void:
	if scene_path == "" or scene_path == null:
		LogWrapper.debug(self, "CRITICAL: Cannot spawn '%s'. No scene path assigned!" % nice_name)
		return

	var enemy_scene: PackedScene

	if typeof(cached_scenes.get(scene_path)) == TYPE_BOOL:
		enemy_scene = ResourceLoader.load_threaded_get(scene_path) as PackedScene
		cached_scenes[scene_path] = enemy_scene
	else:
		enemy_scene = cached_scenes.get(scene_path) as PackedScene

	if enemy_scene:
		var enemy_instance: Node2D = enemy_scene.instantiate() as Node2D
		var spawn_pos: Vector2 = _get_spawn_position(location)
		enemy_instance.global_position = spawn_pos
		add_child(enemy_instance)
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

	if typeof(cached_scenes.get(scene_path)) == TYPE_BOOL:
		powerup_scene = ResourceLoader.load_threaded_get(scene_path) as PackedScene
		cached_scenes[scene_path] = powerup_scene
	else:
		powerup_scene = cached_scenes.get(scene_path) as PackedScene

	if powerup_scene:
		var powerup_instance: Node2D = powerup_scene.instantiate() as Node2D
		var spawn_pos: Vector2 = _get_spawn_position(location)
		powerup_instance.global_position = spawn_pos
		add_child(powerup_instance)
	else:
		LogWrapper.debug(
			self, "ERROR: Failed to load %s scene at path: %s" % [nice_name, scene_path]
		)
