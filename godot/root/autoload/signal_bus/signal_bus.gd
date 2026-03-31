extends Node
## The [SignalBus] can be used to provide global signals.
## Use normal signals for child to parent communication, use global signals otherwise.
## [br][br]
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

# Configuration
signal language_changed(locale: String)
signal number_format_changed(number_format: NumberUtils.NumberFormat)

# Game
var is_game_over: bool = false

signal level_transition_triggered(target_transition_area: String, position_offset: Vector2)
signal zone_completed(zone_name: String)
signal clicks_per_second_updated(cps: int)
signal game_over
