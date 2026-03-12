class_name EnemySwarmZombie
extends CharacterBody2D

@export var display_name: String = "Zombie"

@export var zombie_variants: Array[SpriteFrames] = []

@onready var pivot: Node2D = $Pivot
@onready var anim_sprite: AnimatedSprite2D = $Pivot/AnimatedSprite2D
@onready var hit_audio: AudioStreamPlayer2D = $HitAudio


func _ready() -> void:
	add_to_group("enemy")

	if zombie_variants.size() > 0:
		if anim_sprite == null:
			anim_sprite = $Pivot/AnimatedSprite2D
		anim_sprite.sprite_frames = zombie_variants.pick_random()

	play_animation("run")

	var health_comp = $HealthComponent
	if health_comp:
		health_comp.damaged.connect(_on_damaged)


func update_facing_direction(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return

	if pivot == null:
		pivot = $Pivot
	if anim_sprite == null:
		anim_sprite = $Pivot/AnimatedSprite2D

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			pivot.rotation_degrees = 0  # Facing Right
		else:
			pivot.rotation_degrees = 180  # Facing Left
	else:
		if direction.y > 0:
			pivot.rotation_degrees = 90  # Facing Down
		else:
			pivot.rotation_degrees = -90  # Facing Up


func play_animation(anim_name: String) -> void:
	if anim_sprite == null:
		anim_sprite = $Pivot/AnimatedSprite2D
	anim_sprite.play(anim_name)


func _on_damaged(_attack) -> void:
	if hit_audio:
		hit_audio.pitch_scale = randf_range(0.8, 1.2)
		hit_audio.play()
