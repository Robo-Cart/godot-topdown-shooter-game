class_name WorldMapHUD
extends Control

const GRID_WIDTH: int = 7
const GRID_HEIGHT: int = 3
const CELL_GAP: float = 4.0

var _debug_show_all: bool = false
var _world_map: WorldMap = null


func _ready() -> void:
	SignalBus.level_transition_triggered.connect(_on_level_transition_triggered)
	_update_map_data()


func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event is InputEventKey:
		if event.pressed and event.keycode == KEY_F1:
			_debug_show_all = not _debug_show_all
			queue_redraw()


func _on_level_transition_triggered(_target: String, _offset: Vector2, _side: int) -> void:
	call_deferred("_update_map_data")


func _update_map_data() -> void:
	var zm: Node = get_node_or_null("/root/ZoneManager")
	if zm and zm.has_method("get_world_map"):
		_world_map = zm.call("get_world_map") as WorldMap
	queue_redraw()


func _draw() -> void:
	if not _world_map:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var max_width: float = viewport_size.x / 8.0
	var max_height: float = viewport_size.y / 8.0

	var cell_size_x: float = (max_width - (GRID_WIDTH - 1) * CELL_GAP) / GRID_WIDTH
	var cell_size_y: float = (max_height - (GRID_HEIGHT - 1) * CELL_GAP) / GRID_HEIGHT
	var cell_size: float = minf(cell_size_x, cell_size_y)

	var total_width: float = GRID_WIDTH * cell_size + (GRID_WIDTH - 1) * CELL_GAP

	var start_pos: Vector2 = Vector2(size.x - total_width - 16.0, 16.0)

	var current_coords: Vector2i = Data.game.current_level_coords
	var visited: Array[Vector2i] = Data.game.visited_levels

	for y: int in range(GRID_HEIGHT):
		for x: int in range(GRID_WIDTH):
			var coords: Vector2i = Vector2i(x, y)
			if not _world_map.has_cell(coords):
				continue

			var cell: MapCell = _world_map.get_cell(coords)
			var is_current: bool = coords == current_coords
			var is_visited: bool = visited.has(coords)
			var is_adjacent: bool = false

			if not is_visited and not is_current:
				var neighbors: Array[Vector2i] = [
					coords + Vector2i(1, 0),
					coords + Vector2i(-1, 0),
					coords + Vector2i(0, 1),
					coords + Vector2i(0, -1)
				]
				for n: Vector2i in neighbors:
					if n == current_coords or visited.has(n):
						is_adjacent = true
						break

			if not _debug_show_all and not is_visited and not is_current and not is_adjacent:
				continue

			var rect: Rect2 = Rect2(
				start_pos.x + x * (cell_size + CELL_GAP),
				start_pos.y + y * (cell_size + CELL_GAP),
				cell_size,
				cell_size
			)

			var color: Color
			if is_current:
				color = Color.WHITE
			elif cell.is_entrance and is_visited:
				color = Color.GREEN
			elif cell.is_exit and is_visited:
				color = Color.RED
			elif cell.is_entrance and (is_adjacent or _debug_show_all):
				color = Color.GREEN.lerp(Color.TRANSPARENT, 0.5)
			elif cell.is_exit and (is_adjacent or _debug_show_all):
				color = Color.RED.lerp(Color.TRANSPARENT, 0.5)
			elif is_visited:
				color = Color.SLATE_GRAY
			else:
				color = Color.SLATE_GRAY.lerp(Color.TRANSPARENT, 0.7)

			draw_rect(rect, color)

			if not is_visited and not is_current:
				draw_rect(rect, Color.WHITE.lerp(Color.TRANSPARENT, 0.8), false, 1.0)
