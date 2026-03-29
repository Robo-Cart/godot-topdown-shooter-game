class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died
signal damaged(attack: AttackEntity)

@export var max_health: int = 100

var current_health: int


func _ready() -> void:
	current_health = max_health


func take_damage(attack: AttackEntity) -> void:
	if current_health <= 0:
		return

	var final_damage: int = attack.damage

	# Example: Slimes take double damage from fire!
	#if attack.element == "fire":
	#final_damage *= 2
	#LogWrapper.debug(self, "Critical hit! Fire element used.")

	current_health -= final_damage

	damaged.emit(attack)
	health_changed.emit(current_health, max_health)

	LogWrapper.debug(
		self,
		_get_player_log_prefix() + "Took %d damage. HP: %d/%d" % [
			final_damage, current_health, max_health
		]
	)

	if current_health <= 0:
		LogWrapper.debug(self, _get_player_log_prefix() + "Health reached 0. Emitting died signal.")
		died.emit()


func _get_player_log_prefix() -> String:
	var parent: Node = get_parent()
	if not parent or not parent.is_in_group("player"):
		return ""

	var color_index: int = parent.get("color_index") if "color_index" in parent else 0
	var device_id: int = parent.get("device_id") if "device_id" in parent else -1

	var p_id: String = "P%d" % (color_index + 1)
	var d_id: String = "Dev%d" % device_id
	var steam_id: String = "Local"

	if Engine.has_singleton("Steam"):
		var steam_singleton: Object = Engine.get_singleton("Steam")
		var s_id: int = steam_singleton.getSteamID()
		if s_id > 0:
			steam_id = "Steam%d" % s_id

	var network_info: String = "Host" if multiplayer.is_server() else "Peer"
	if steam_id == "Local":
		# Try to find the actual peer ID for this player's device
		var peer_id: int = 1
		for p: int in MultiplayerManager.players:
			if device_id in MultiplayerManager.players[p]:
				peer_id = p
				break

		if peer_id != 1:
			var m_peer: Object = multiplayer.multiplayer_peer
			if m_peer and m_peer.has_method("get_peer_address"):
				var ip: String = m_peer.get_peer_address(peer_id)
				var parts: PackedStringArray = ip.split(".")
				if parts.size() == 4:
					network_info = "IP.*.*.%s" % parts[3]
				else:
					network_info = ip
			else:
				network_info = "Remote"

	return "[%s|%s|%s|%s] " % [p_id, d_id, steam_id, network_info]
