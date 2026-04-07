class_name WorldMap
extends RefCounted

var cells: Dictionary = {}


func get_cell(coords: Vector2i) -> MapCell:
	return cells.get(coords, null)


func set_cell(coords: Vector2i, cell: MapCell) -> void:
	cells[coords] = cell


func has_cell(coords: Vector2i) -> bool:
	return cells.has(coords)


func get_entrance_coords() -> Vector2i:
	for coords: Vector2i in cells:
		var cell: MapCell = cells[coords]
		if cell.is_entrance:
			return coords
	return Vector2i.ZERO


func get_exit_coords() -> Vector2i:
	for coords: Vector2i in cells:
		var cell: MapCell = cells[coords]
		if cell.is_exit:
			return coords
	return Vector2i.ZERO
