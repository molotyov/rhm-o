extends Control


signal lobby_members_updated

const PACKET_READ_LIMIT: int = 32
const CHANNEL: int = 0

var lobby_id: int = 0
var lobby_members: Array = []
var lobby_users: Array = []
var lobby_members_max: int = 10
var steam_id: int = 0

var _players_node: Node = null


func _ready() -> void:
	steam_id = Steam.getSteamID()

	Steam.connect("p2p_session_request", self, "_on_p2p_session_request")
	Steam.connect("p2p_session_connect_fail", self, "_on_p2p_session_connect_fail")
	Steam.connect("join_requested", self, "_on_lobby_join_requested")
	Steam.connect("lobby_chat_update", self, "_on_lobby_chat_update")
	Steam.connect("lobby_created", self, "_on_lobby_created")
	Steam.connect("lobby_joined", self, "_on_lobby_joined")

	check_command_line()


func check_command_line() -> void:
	var args: Array = OS.get_cmdline_args()
	if args.size() > 1 and args[0] == "+connect_lobby" and int(args[1]) > 0:
		print("Command line lobby ID: %s" % args[1])
		join_lobby(int(args[1]))


func generate_lobby_code(size: int = 6) -> String:
	var code := ""
	var chars := "ABCDEF01234567890"
	randomize()
	for i in range(size):
		code += chars[randi() % len(chars)]
	return code




func _process(_delta: float) -> void:
	if lobby_id > 0:
		read_all_p2p_packets()


func read_all_p2p_packets() -> void:
	var count := 0
	while count < PACKET_READ_LIMIT and Steam.getAvailableP2PPacketSize(CHANNEL) > 0:
		read_p2p_packet()
		count += 1


func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(CHANNEL)
	if packet_size <= 0:
		return

	var packet: Dictionary = Steam.readP2PPacket(packet_size, CHANNEL)
	if packet.empty():
		print("WARNING: Received an empty P2P packet!")
		return

	var sender: int = int(packet["steam_id_remote"])
	var data = bytes2var(packet["data"])

	if typeof(data) != TYPE_DICTIONARY:
		return

	if data.get("type", "") == "pos":
		apply_player_position(sender, Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0))))
	elif data.get("message", "") == "handshake":
		print("Handshake received from: ", sender)


func apply_player_position(sender_id: int, pos: Vector2) -> void:

	if not is_instance_valid(_players_node):
		_players_node = get_tree().get_root().find_node("Players", true, false)
	if _players_node == null:
		return  

	for player in _players_node.get_children():
		if player.member == null:
			continue

		var player_id: int
		if typeof(player.member) == TYPE_DICTIONARY:
			player_id = int(player.member.get("steam_id", 0))
		else:
			player_id = int(player.member)

		if player_id == sender_id:
			player.global_position = pos
			return




func send_p2p_packet(this_target: int, packet_data: Dictionary, reliable: bool = true) -> void:
	var send_type: int = Steam.P2P_SEND_RELIABLE if reliable else Steam.P2P_SEND_UNRELIABLE
	var this_data: PoolByteArray = var2bytes(packet_data)


	if this_target == 0:
		for member in lobby_members:
			var target_id: int = int(member["steam_id"])
			if target_id == steam_id:
				continue
			Steam.sendP2PPacket(target_id, this_data, send_type, CHANNEL)
	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, CHANNEL)


func make_p2p_handshake(target: int = 0) -> void:
	send_p2p_packet(target, {"message": "handshake", "from": steam_id}, true)




func create_lobby() -> void:
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)
	else:
		print("Already in a lobby with ID: ", lobby_id)


func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect != 1:
		return

	lobby_id = this_lobby_id
	print("Created a lobby: %s" % lobby_id)

	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "host_name", Steam.getPersonaName())
	Steam.setLobbyData(lobby_id, "mode", "GodotSteam test")
	Steam.setLobbyData(lobby_id, "game_type", "my_own_lobby")
	Steam.setLobbyData(lobby_id, "version", "1.0.1")
	Steam.allowP2PPacketRelay(true)

	join_lobby(this_lobby_id)


func request_lobby_list() -> void:
	if lobby_id == 0:
		Steam.addRequestLobbyListStringFilter("game_type", "my_own_lobby", Steam.LOBBY_COMPARISON_EQUAL)
		Steam.addRequestLobbyListStringFilter("version", "1.0.1", Steam.LOBBY_COMPARISON_EQUAL)
		Steam.addRequestLobbyListDistanceFilter(3)
		Steam.addRequestLobbyListResultCountFilter(5000)
		Steam.requestLobbyList()


func join_lobby(this_lobby_id: int) -> void:
	print("Attempting to join lobby %s" % this_lobby_id)
	lobby_members.clear()
	Steam.joinLobby(this_lobby_id)


func _on_lobby_joined(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		lobby_id = this_lobby_id
		get_lobby_members()   
		make_p2p_handshake()  
		return

	var fail_reason := "Unknown error"
	match response:
		Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This lobby no longer exists."
		Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this lobby."
		Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The lobby is now full."
		Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "Something unexpected happened!"
		Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this lobby."
		Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
		Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This lobby is locked or disabled."
		Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This lobby is community locked."
		Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the lobby has blocked you from joining."
		Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the lobby."
	print("Failed to join this chat room: %s" % fail_reason)

	request_lobby_list()


func _on_lobby_join_requested(this_lobby_id: int, friend_id: int) -> void:
	print("Joining %s's lobby..." % Steam.getFriendPersonaName(friend_id))
	join_lobby(this_lobby_id)


func _on_lobby_chat_update(this_lobby_id: int, change_id: int, _making_change_id: int, chat_state: int) -> void:
	if this_lobby_id != lobby_id:
		return

	get_lobby_members()

	if chat_state == Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED and change_id != steam_id:
		make_p2p_handshake(change_id)
	elif chat_state != Steam.CHAT_MEMBER_STATE_CHANGE_ENTERED and change_id != steam_id:
		Steam.closeP2PSessionWithUser(change_id)


func get_lobby_members() -> void:
	lobby_members.clear()

	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
	for i in range(num_of_members):
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, i)
		lobby_members.append({
			"steam_id": member_steam_id,
			"steam_name": Steam.getFriendPersonaName(member_steam_id)
		})

	emit_signal("lobby_members_updated")


func leave_lobby() -> void:
	if lobby_id == 0:
		return

	Steam.leaveLobby(lobby_id)
	for member in lobby_members:
		if int(member["steam_id"]) != steam_id:
			Steam.closeP2PSessionWithUser(int(member["steam_id"]))

	lobby_members.clear()
	lobby_users.clear()
	lobby_id = 0
	emit_signal("lobby_members_updated")




func _on_p2p_session_request(remote_id: int) -> void:
	print("%s is requesting a P2P session" % Steam.getFriendPersonaName(remote_id))
	Steam.acceptP2PSessionWithUser(remote_id)
	make_p2p_handshake(remote_id)


func _on_p2p_session_connect_fail(failed_id: int, session_error: int) -> void:
	var reasons := {
		0: "no error given",
		1: "target user not running the same game",
		2: "local user doesn't own app / game",
		3: "target user isn't connected to Steam",
		4: "connection timed out",
		5: "unused",
	}
	print("WARNING: Session failure with %s: %s" % [failed_id, reasons.get(session_error, "unknown error %s" % session_error)])

