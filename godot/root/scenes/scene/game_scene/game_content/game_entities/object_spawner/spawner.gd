class_name Spawner
extends StaticBody2D

@export_group("Spawner Parameters")
@export var active: bool = true
@export var spawns_per_second: float = 0.1
@export var spawn_location_variation_x: float = 10
@export var spawn_location_variation_y: float = 30

@export var enemy_scene = preload(
	"res://root/scenes/scene/game_scene/game_content/game_entities/enemy_slime/enemy_slime.tscn"
)

@onready var spawn_area_location = $SpawnAreaMarker

var spawn_timer: Timer
var number_of_spawned_enemies: int = 0


func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = 1 / spawns_per_second
	spawn_timer.timeout.connect(on_timer_finished)
	spawn_timer.autostart = true
	add_child(spawn_timer)


func _process(delta: float) -> void:
	if !active:
		if spawn_timer.paused == false:
			spawn_timer.paused = true
	else:
		if spawn_timer.paused == true:
			spawn_timer.paused = false


func on_timer_finished():
	var spawned_enemy = enemy_scene.instantiate()
	spawned_enemy.add_to_group("enemies")
	get_tree().root.add_child(spawned_enemy)
	spawned_enemy.global_position.x = (
		spawn_area_location.global_position.x
		+ randf_range(-spawn_location_variation_x, spawn_location_variation_x)
	)
	spawned_enemy.global_position.y = (
		spawn_area_location.global_position.y
		+ randf_range(-spawn_location_variation_y, spawn_location_variation_y)
	)
