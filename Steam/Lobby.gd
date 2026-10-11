extends Control

 
signal lobby_member_added
 
 
func _ready() -> void:
	SteamLobby.connect("lobby_members_updated", self, "refresh_lobby_members")
	$"%LeaveLobbyButton".connect("pressed", self, "leave_lobby")
 
 
func _process(_delta: float) -> void:
	if SteamLobby.lobby_id > 0:
		send_local_position()
 
 
func send_local_position() -> void:
	var local_player = member_player(SteamLobby.steam_id)
	if local_player == null:
		return
 
	var pos: Vector2 = local_player.global_position
	SteamLobby.send_p2p_packet(0, {
		"type": "pos",
		"steam_id": SteamLobby.steam_id,
		"x": pos.x,
		"y": pos.y
	}, false) 
 
 
func member_player(target_id: int):
	var players_node = get_parent().get_node_or_null("Players")
	if players_node == null:
		return null
 
	for player in players_node.get_children():
		if player.member == null:
			continue
 
		var player_id: int
		if typeof(player.member) == TYPE_DICTIONARY:
			player_id = int(player.member.get("steam_id", 0))
		else:
			player_id = int(player.member)
 
		if player_id == target_id:
			return player
 
	return null
 
 
func refresh_lobby_members() -> void:
	for child in $"%GridContainer".get_children():
		child.free()
 
	for member_data in SteamLobby.lobby_members:
		var user = preload("res://Steam/LobbyPlayer.tscn").instance()
		user.member = member_data
		user.text = member_data["steam_name"]
		user.init()
		$"%GridContainer".add_child(user)
 
		if not SteamLobby.lobby_users.has(member_data):
			SteamLobby.lobby_users.append(member_data)
 
	for child in $"%GridContainer".get_children():
		child.update_avatar()
 

	emit_signal("lobby_member_added")
 
 
func leave_lobby() -> void:
	if SteamLobby.lobby_id == 0:
		return
 
	SteamLobby.leave_lobby()
	get_parent().hide()
	hide()
	print("Left lobby, ID is now: ", SteamLobby.lobby_id)
 
