
extends "res://Steam/SteamLobby.gd"

var member

signal lobby_member_added


func _ready() -> void:
	Steam.connect("avatar_loaded", self, "_loaded_Avatar")
	Steam.connect("lobby_joined", self, "_on_lobby_ready")
	Steam.connect("lobby_chat_update", self, "_on_lobby_chat_update")

	$"%LeaveLobbyButton".connect("pressed", self, "leave_lobby")


func _process(_delta: float) -> void:
	update_member_data()


func _on_lobby_ready(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:

	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("Added to lobby: ", lobby_id)
		add_lobby_members()
		refresh_lobby_members()


func add_lobby_members() -> void:
	for member_data in SteamLobby.lobby_members:
		var user = preload("res://Steam/LobbyPlayer.tscn").instance()

		user.member = member_data
		user.text = member_data["steam_name"]
		user.init()

		$"%GridContainer".add_child(user)

		print(member_data["steam_name"])
#
#		if not SteamLobby.lobby_users.has(member_data):
		SteamLobby.lobby_users.append(member_data)

	for child in $"%GridContainer".get_children():
		child.update_avatar()
		emit_signal("lobby_member_added")


func _on_lobby_chat_update(
	this_lobby_id: int,
	change_id: int,
	making_change_id: int,
	chat_state: int
) -> void:

	SteamLobby.get_lobby_members()
	refresh_lobby_members()



func update_member_data() -> void:
	var local_player = member_player({"steam_id": SteamLobby.steam_id})

	if local_player == null:
		return

	var pos = local_player.global_position

	var data = {
		"type": "pos",
		"steam_id": SteamLobby.steam_id,
		"x": pos.x,
		"y": pos.y
	}

	send_p2p_packet(0, data)




func member_player(member_data):
	var players_node = get_parent().get_node_or_null("Players")

	if players_node == null:
		return null

	var target_id = int(member_data.get("steam_id", 0))

	for player in players_node.get_children():
		if player.member == null:
			continue

		if typeof(player.member) == TYPE_DICTIONARY:
			if int(player.member.get("steam_id", 0)) == target_id:
				return player
		else:
			if int(player.member) == target_id:
				return player

	return null



func refresh_lobby_members() -> void:
	for child in $"%GridContainer".get_children():
		child.free()

	print(SteamLobby.lobby_members)

	add_lobby_members()
	update_member_data()


func leave_lobby() -> void:
	if SteamLobby.lobby_id != 0:
		Steam.leaveLobby(SteamLobby.lobby_id)

		for this_member in SteamLobby.lobby_members:
			if this_member["steam_id"] != SteamLobby.steam_id:
				Steam.closeP2PSessionWithUser(this_member["steam_id"])

		SteamLobby.lobby_members.clear()
		SteamLobby.lobby_users.clear()
		SteamLobby.lobby_id = 0

		get_parent().hide()
		hide()

		print("Left lobby, ID is now: ", SteamLobby.lobby_id)
