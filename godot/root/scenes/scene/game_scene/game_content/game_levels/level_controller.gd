class_name LevelController
extends Node2D

## [LevelController]
## Root orchestrator for a level. Loaded via a Zone's Base Scene.
## Connects and initializes specialized manager components.

@export var level_data: LevelData

var _wave_manager: Node
var _victory_manager: Node
var _environment_manager: Node


func _ready() -> void:
	_identify_components()

	# Prioritize dynamic data from ZoneManager at runtime
	var dynamic_data: LevelData = ZoneManager.get_current_level_data()
	if dynamic_data:
		level_data = dynamic_data

	if not level_data:
		LogWrapper.error(self, "No LevelData found for LevelController!")
		return

	LogWrapper.debug(self, "Initializing Level: %s" % level_data.level_name)

	_setup_components()
	_connect_signals()


func _identify_components() -> void:
	_wave_manager = get_node_or_null("WaveManagerComponent")
	_victory_manager = get_node_or_null("VictoryManagerComponent")
	_environment_manager = get_node_or_null("EnvironmentManagerComponent")


func _setup_components() -> void:
	if _wave_manager and _wave_manager.has_method("setup"):
		_wave_manager.setup(level_data)

	if _victory_manager and _victory_manager.has_method("setup"):
		_victory_manager.setup()

	if _environment_manager and _environment_manager.has_method("setup"):
		_environment_manager.setup(level_data)


func _connect_signals() -> void:
	if _wave_manager and _victory_manager:
		_wave_manager.enemy_spawned.connect(_victory_manager._on_enemy_spawned)
		_wave_manager.all_spawns_completed.connect(_victory_manager.on_all_spawns_completed)
		_victory_manager.screen_cleared.connect(func() -> void:
			var shift: float = 3.0
			_wave_manager.accelerate_spawns(shift)
		)

	if _victory_manager:
		_victory_manager.victory_triggered.connect(_on_victory)


func _on_victory() -> void:
	LogWrapper.debug(self, "Level Victory!")
	if _wave_manager and _wave_manager.has_method("open_all_doors_final"):
		_wave_manager.open_all_doors_final()

	SignalBus.zone_completed.emit(ZoneManager.get_current_zone().zone_name)
