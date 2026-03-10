extends Area2D
class_name CollectorComponent

@export var target_entity: Node


func _ready() -> void:
	if not target_entity:
		LogWrapper.debug(self, "WARNING: CollectorComponent has no target_entity assigned!")

	area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if area is Powerup:
		LogWrapper.debug(self, "%s collected %s!" % [target_entity.name, area.display_name])

		area.apply_effect(target_entity)

		if target_entity.has_method("add_buff"):
			target_entity.add_buff(area.buff_id)

		area.queue_free()
