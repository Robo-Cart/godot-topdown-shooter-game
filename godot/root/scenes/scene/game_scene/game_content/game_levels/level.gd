extends Node

@export var level_data: Resource


func _ready() -> void:
	debug_print_level_data(level_data)
	pass


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
			points_str += EnemyWaveConfig.Direction.keys()[p] + " "

		LogWrapper.debug(
			self,
			(
				"  [%s] (%ss) | Type: %s | Density: %d | Spawns: [%s]"
				% [wave.time_stamp, wave.time, wave.type, wave.density, points_str.strip_edges()]
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
