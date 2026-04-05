extends Node
## [VictoryManagerComponent]
## Monitors enemies and triggers victory when all waves and enemies are cleared.
## Includes boss detection and spawn acceleration logic.

signal victory_triggered
signal screen_cleared

var _all_spawns_completed: bool = false
var _victory_triggered: bool = false
var _spawned_enemies_tracking: Array[Node2D] = []
var _time_since_last_enemy_clear: float = 0.0


func _process(delta: float) -> void:
	if _victory_triggered:
		return

	_cleanup_spawned_enemies()
	_check_acceleration(delta)

	if _all_spawns_completed:
		_check_victory_condition()


func setup() -> void:
	_all_spawns_completed = false
	_victory_triggered = false
	_spawned_enemies_tracking.clear()
	_time_since_last_enemy_clear = 0.0


func on_all_spawns_completed() -> void:
	_all_spawns_completed = true


func _on_enemy_spawned(enemy: Node2D) -> void:
	_spawned_enemies_tracking.append(enemy)


func _cleanup_spawned_enemies() -> void:
	if Engine.get_process_frames() % 60 == 0:
		# Use untyped lambda parameter to safely handle freed instances
		# and .assign() to update the typed array from the filter result.
		var filtered: Array = _spawned_enemies_tracking.filter(
			func(enemy: Variant) -> bool: return is_instance_valid(enemy)
		)
		_spawned_enemies_tracking.assign(filtered)


func _check_acceleration(delta: float) -> void:
	if _all_spawns_completed:
		return

	if get_tree().get_nodes_in_group("enemy").size() == 0:
		_time_since_last_enemy_clear += delta
		if _time_since_last_enemy_clear >= 3.0:
			screen_cleared.emit()
			_time_since_last_enemy_clear = 0.0
	else:
		_time_since_last_enemy_clear = 0.0


func _check_victory_condition() -> void:
	# 1. Check for bosses specifically
	var bosses: Array[Node] = get_tree().get_nodes_in_group("boss")
	var boss_alive: bool = false
	for boss: Node in bosses:
		if is_instance_valid(boss):
			var hp: HealthComponent = boss.find_child("*HealthComponent*", true, false)
			if not hp or hp.current_health > 0:
				boss_alive = true
				break

	if boss_alive:
		return

	# 2. Check general tracked enemies
	if _spawned_enemies_tracking.size() == 0 and get_tree().get_nodes_in_group("enemy").size() == 0:
		_trigger_victory()


func _trigger_victory() -> void:
	if _victory_triggered:
		return

	_victory_triggered = true
	victory_triggered.emit()
	LogWrapper.debug(self, "Victory detected.")