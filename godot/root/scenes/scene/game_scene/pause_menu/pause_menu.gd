class_name PauseMenu
extends Control
## Original File MIT License Copyright (c) 2024 TinyTakinTeller

@onready var title_label: Label = %TitleLabel

@onready var continue_menu_button: MenuButtonClass = %ContinueMenuButton
@onready var disconnect_menu_button: MenuButtonClass = %DisconnectMenuButton
@onready var options_menu_button: MenuButtonClass = %OptionsMenuButton
@onready var leave_menu_button: MenuButtonClass = %LeaveMenuButton
@onready var quit_menu_button: MenuButtonClass = %QuitMenuButton


func _ready() -> void:
	_connect_signals()
	_refresh_label()

	disconnect_menu_button.visible = false

	if OS.has_feature("web"):
		quit_menu_button.visible = false

	LogWrapper.debug(self, "Ready.")


func setup_for_player(player: Player) -> void:
	# Only show disconnect for players other than player 1
	if player and player.color_index > 0:
		disconnect_menu_button.visible = true
		disconnect_menu_button.label = "MENU_LABEL_DISCONNECT"
		# Set text manually to include player number
		var base_text: String = TranslationServerWrapper.translate("MENU_LABEL_DISCONNECT")
		disconnect_menu_button.text = StringUtils.add_padding(
			"%s (P%d)" % [base_text, player.color_index + 1],
			disconnect_menu_button.padding_spaces
		)
	else:
		disconnect_menu_button.visible = false


func _refresh_label() -> void:
	title_label.text = TranslationServerWrapper.translate("MENU_LABEL_PAUSED")


func _connect_signals() -> void:
	SignalBus.language_changed.connect(_on_language_changed)


func _on_language_changed(_locale: String) -> void:
	_refresh_label()
