class_name WorldGenerator
extends RefCounted

const GRID_WIDTH: int = 7
const GRID_HEIGHT: int = 3


static func generate_world(zone: ZoneData, seed_value: int) -> WorldMap:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value

	var map: WorldMap = WorldMap.new()

	var start_y: int = rng.randi() % GRID_HEIGHT
	var end_y: int = rng.randi() % GRID_HEIGHT
	var start_coords: Vector2i = Vector2i(0, start_y)
	var end_coords: Vector2i = Vector2i(GRID_WIDTH - 1, end_y)

	var active_cells: Array[Vector2i] = []

	# Generate 3 paths to ensure connectivity and no dead ends
	for i: int in range(3):
		var current: Vector2i = start_coords
		var path_cells: Array[Vector2i] = [current]
		var steps_without_east: int = 0

		while current.x < end_coords.x:
			var possible_moves: Array[Vector2i] = []
			# Always allow East
			possible_moves.append(Vector2i(1, 0))

			# Allow North/South if we haven't lingered vertically too long
			if steps_without_east < 2:
				if current.y > 0 and Vector2i(0, -1) not in path_cells:
					possible_moves.append(Vector2i(0, -1))
				if current.y < GRID_HEIGHT - 1 and Vector2i(0, 1) not in path_cells:
					possible_moves.append(Vector2i(0, 1))

			var move: Vector2i = possible_moves[rng.randi() % possible_moves.size()]
			current += move
			path_cells.append(current)

			if move.x > 0:
				steps_without_east = 0
			else:
				steps_without_east += 1

		# Once at x = 6, move vertically to end_coords
		while current.y != end_coords.y:
			var move_y: int = 1 if current.y < end_coords.y else -1
			current += Vector2i(0, move_y)
			path_cells.append(current)

		for pos: Vector2i in path_cells:
			if pos not in active_cells:
				active_cells.append(pos)

	var standard_levels: Array[LevelData] = []
	var boss_level: LevelData = null

	if zone and zone.levels.size() > 0:
		boss_level = zone.levels[zone.levels.size() - 1]
		for i: int in range(zone.levels.size() - 1):
			standard_levels.append(zone.levels[i])
		if standard_levels.size() == 0:
			standard_levels.append(boss_level)  # Fallback

	for coords: Vector2i in active_cells:
		var cell: MapCell = MapCell.new()

		if coords == start_coords:
			cell.is_entrance = true
		if coords == end_coords:
			cell.is_exit = true
			cell.level_data = boss_level
		else:
			if standard_levels.size() > 0:
				cell.level_data = standard_levels[rng.randi() % standard_levels.size()]
			else:
				cell.level_data = boss_level

		map.set_cell(coords, cell)

	return map
