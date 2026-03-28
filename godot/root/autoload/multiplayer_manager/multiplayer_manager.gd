extends Node

signal players_updated
signal lobby_created(lobby_id: int)

var players: Dictionary = {}  # Key: int (peer_id), Value: Array[int] (local device ids)
var steam_lobby_id: int = 0
var max_players: int = 8
var player_colors: Array[Color] = [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA,
	Color.ORANGE
]


# Total active players in the game (remote + local)
func get_total_player_count() -> int:
	var count: int = 0
	for p_id: int in players:
		count += players[p_id].size()
	return count


func _ready() -> void:
	if Engine.has_singleton("Steam"):
		var steam_singleton: Object = Engine.get_singleton("Steam")
		var init_result: Dictionary = steam_singleton.steamInit()
		if init_result["status"] == 0:
			LogWrapper.debug(self, "Steam initialized successfully")
			steam_singleton.lobby_created.connect(_on_lobby_created)
			steam_singleton.lobby_joined.connect(_on_lobby_joined)
		else:
			LogWrapper.error(self, "Steam init failed: " + str(init_result))
	else:
		LogWrapper.warn(self, "Steam singleton not found. Running local ENet fallback.")
		host_local_game()


func host_local_game() -> void:
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(8080, max_players)
	if error == OK:
		multiplayer.multiplayer_peer = peer
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		_register_player(multiplayer.get_unique_id(), 0)  # Host P1
		LogWrapper.debug(self, "Local ENet server hosted.")
	else:
		LogWrapper.error(self, "Failed to host ENet: " + str(error))


func host_steam_lobby() -> void:
	if Engine.has_singleton("Steam"):
		var steam_singleton: Object = Engine.get_singleton("Steam")
		steam_singleton.createLobby(steam_singleton.LOBBY_TYPE_PUBLIC, max_players)


func join_steam_lobby(lobby_id: int) -> void:
	if Engine.has_singleton("Steam"):
		var steam_singleton: Object = Engine.get_singleton("Steam")
		steam_singleton.joinLobby(lobby_id)


func _on_lobby_created(connect_res: int, new_lobby_id: int) -> void:
	if connect_res == 1:
		steam_lobby_id = new_lobby_id
		var steam_singleton: Object = Engine.get_singleton("Steam")
		LogWrapper.debug(self, "Created Steam Lobby: " + str(steam_lobby_id))

		var peer: Object = ClassDB.instantiate("SteamMultiplayerPeer")
		if peer:
			var error: Error = peer.create_lobby(steam_singleton.LOBBY_TYPE_PUBLIC, max_players)
			if error == OK:
				multiplayer.multiplayer_peer = peer
				multiplayer.peer_connected.connect(_on_peer_connected)
				multiplayer.peer_disconnected.connect(_on_peer_disconnected)
				_register_player(multiplayer.get_unique_id(), 0)
				lobby_created.emit(steam_lobby_id)


func _on_lobby_joined(new_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == 1:
		steam_lobby_id = new_lobby_id
		var peer: Object = ClassDB.instantiate("SteamMultiplayerPeer")
		if peer:
			var error: Error = peer.connect_lobby(steam_lobby_id)
			if error == OK:
				multiplayer.multiplayer_peer = peer
				LogWrapper.debug(self, "Joined Steam Lobby: " + str(steam_lobby_id))


func _on_peer_connected(id: int) -> void:
	LogWrapper.debug(self, "Peer connected: " + str(id))


func _on_peer_disconnected(id: int) -> void:
	LogWrapper.debug(self, "Peer disconnected: " + str(id))
	if players.has(id):
		players.erase(id)
		players_updated.emit()


func spawn_local_player(device_id: int) -> void:
	var my_id: int = multiplayer.get_unique_id()
	_register_player.rpc_id(1, my_id, device_id)  # Send to server


@rpc("any_peer", "call_local", "reliable")
func _register_player(peer_id: int, device_id: int) -> void:
	if not multiplayer.is_server():
		return
	if not players.has(peer_id):
		players[peer_id] = []
	if not (device_id in players[peer_id]):
		players[peer_id].append(device_id)
	_sync_players.rpc(players)


@rpc("authority", "call_local", "reliable")
func _sync_players(new_players: Dictionary) -> void:
	players = new_players
	players_updated.emit()


func get_closest_player(global_pos: Vector2) -> Node2D:
	var player_nodes: Array[Node] = get_tree().get_nodes_in_group("player")
	var closest: Node2D = null
	var min_dist: float = INF

	for p in player_nodes:
		if is_instance_valid(p):
			var hp: Node = p.get_node_or_null("HealthComponent")
			if hp and hp.current_health <= 0:
				continue

			var dist: float = (p as Node2D).global_position.distance_to(global_pos)
			if dist < min_dist:
				min_dist = dist
				closest = p as Node2D
	return closest
