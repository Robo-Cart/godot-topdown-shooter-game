extends Node2D

@export var level_data: LevelData

@onready var player: Player = get_tree().get_first_node_in_group("player")

var level_timer: float = 0.0
var current_spawn_index: int = 0
var spawn_queue: Array[Dictionary] = []


func _ready() -> void:
	if not level_data:
		LogWrapper.debug(self, "CRITICAL ERROR: No LevelData assigned to Level!")
		set_process(false)
		return

	debug_print_level_data(level_data)

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

		for i in range(num_enemies):
			var exact_spawn_time: float = wave.time + (i * time_interval)
			var point: EnemyWaveConfig.Location = wave.spawn_points[i % num_spawn_points]

			spawn_queue.append(
				{
					"time": exact_spawn_time,
					"category": "enemy",
					"enemy_scene_path": wave.enemy_scene_path,
					"location": point,
					"wave_stamp": wave.time_stamp
				}
			)

	# --- 2. Process Powerup Waves ---
	for powerup in level_data.powerup_wave_config:
		var exact_spawn_time: float = powerup.time

		# Apply the random factor (deviate by +/- seconds)
		if powerup.random_factor > 0:
			var deviation: float = randf_range(
				-float(powerup.random_factor), float(powerup.random_factor)
			)
			exact_spawn_time = max(0.0, exact_spawn_time + deviation)  # Prevent spawning in negative time

		spawn_queue.append(
			{
				"time": exact_spawn_time,
				"category": "powerup",
				"type": powerup.type,
				"location": -1,  # Powerups don't use this enum, so we pass a dummy value
				"wave_stamp": powerup.time_stamp
			}
		)

	# --- 3. Sort the Unified Timeline ---
	spawn_queue.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.time < b.time)

	LogWrapper.debug(
		self, "Built unified spawn queue with %d total events scheduled." % spawn_queue.size()
	)


func _process(delta: float) -> void:
	level_timer += delta
	_check_spawns()


func _check_spawns() -> void:
	while (
		current_spawn_index < spawn_queue.size()
		and level_timer >= spawn_queue[current_spawn_index].time
	):
		var spawn_data: Dictionary = spawn_queue[current_spawn_index]

		# Route the spawn event to the correct function based on its category
		if spawn_data.category == "enemy":
			_spawn_enemy(spawn_data.enemy_scene_path, spawn_data.location, spawn_data.wave_stamp)
		elif spawn_data.category == "powerup":
			_spawn_powerup(spawn_data.type, spawn_data.wave_stamp)

		current_spawn_index += 1

		if current_spawn_index >= spawn_queue.size():
			LogWrapper.debug(self, "All scheduled events (enemies and powerups) have been spawned.")


func _spawn_enemy(
	scene_path: String, location: EnemyWaveConfig.Location, wave_stamp: String
) -> void:
	var loc_name: String = EnemyWaveConfig.Location.keys()[location]

	# Extract just the scene name from the path (e.g., "res://enemies/Slime.tscn" -> "Slime")
	var scene_name: String = scene_path.get_file().get_basename()

	LogWrapper.debug(
		self, "[Wave %s] -> Spawning 1x ENEMY (%s) at %s" % [wave_stamp, scene_name, loc_name]
	)

	# Load and instantiate the scene
	var enemy_scene: PackedScene = load(scene_path)
	if enemy_scene:
		var enemy_instance: Node = enemy_scene.instantiate()
		add_child(enemy_instance)  # Adds it to the Level node

		# =========================================================
		# TODO: Set enemy_instance.global_position based on 'location'
		# =========================================================
	else:
		LogWrapper.debug(self, "ERROR: Failed to load enemy scene at path: %s" % scene_path)


func _spawn_powerup(powerup_type: String, wave_stamp: String) -> void:
	LogWrapper.debug(self, "[Wave %s] -> Spawning 1x POWERUP (%s)" % [wave_stamp, powerup_type])

	# =========================================================
	# TODO: Instantiate Powerup
	# =========================================================


func debug_print_level_data(level: LevelData) -> void:
	if not level:
		LogWrapper.debug(self, "Debug Error: No LevelData provided!")
		return

	LogWrapper.debug(self, "=========================================")
	LogWrapper.debug(
		self,
		(
			"LEVEL DEBUG: %s (Level %d) | Difficulty: %d"
			% [level.level_name, level.level_number, level.level_difficulty]
		)
	)
	LogWrapper.debug(self, "=========================================")

	# --- 1. ENEMY WAVES ---
	LogWrapper.debug(self, "--- ENEMY WAVES (%d) ---" % level.enemy_wave_config.size())
	for i in range(level.enemy_wave_config.size()):
		var wave: EnemyWaveConfig = level.enemy_wave_config[i]

		# Convert the Enum array to readable string using the new Enum keys
		var points_str: String = ""
		for p in wave.spawn_points:
			points_str += EnemyWaveConfig.Location.keys()[p] + " "

		LogWrapper.debug(
			self,
			(
				"  [%s] (%ss) | Type: %s | Number: %d | SpawnsOver: [%d] | Spawns: [%s]"
				% [
					wave.time_stamp,
					wave.time,
					wave.enemy_scene_path,
					wave.number_of_enemies,
					wave.seconds_to_spawn_over,
					points_str.strip_edges()
				]
			)
		)

	# --- 2. POWERUP WAVES ---
	LogWrapper.debug(self, "--- POWERUP WAVES (%d) ---" % level.powerup_wave_config.size())
	for i in range(level.powerup_wave_config.size()):
		var powerup: PowerupWaveConfig = level.powerup_wave_config[i]

		LogWrapper.debug(
			self,
			(
				"  [%s] (%ss) | Type: %s | Random Factor: %d"
				% [powerup.time_stamp, powerup.time, powerup.type, powerup.random_factor]
			)
		)

	LogWrapper.debug(self, "=========================================")
