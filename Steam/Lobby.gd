extends "res://Steam/SteamLobby.gd"

var member
signal lobby_member_added()

func _ready() -> void:
	Steam.connect("avatar_loaded", self, "_loaded_Avatar")
	Steam.connect("lobby_joined", self, "_on_lobby_ready")
	Steam.connect("lobby_chat_update", self, "_on_lobby_chat_update")
	$"%LeaveLobbyButton".connect("pressed", self, "leave_lobby")

func _process(delta):
	update_member_data()
	
func _on_lobby_ready(lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("added")
		add_lobby_members()
		refresh_lobby_members()


func add_lobby_members():
	for member in SteamLobby.lobby_members:
		var user = preload("res://Steam/LobbyPlayer.tscn").instance()
		user.member = member
		user.text = member["steam_name"]
		var AVATAR = Image.new()
		user.init()
		$"%GridContainer".add_child(user)
		print(member["steam_name"])
		SteamLobby.lobby_users.append(member)
	for child in $"%GridContainer".get_children():
		child.update_avatar()
		emit_signal("lobby_member_added")
		
func _on_lobby_chat_update(this_lobby_id: int, change_id: int, making_change_id: int, chat_state: int) -> void:
	SteamLobby.get_lobby_members() 
	refresh_lobby_members()

func update_member_data():
	for member in SteamLobby.lobby_members:
		if member_player(member):
			var data = {
				"type": "pos",
				"steam_id": member.steam_id,
				"x": member_player(member).get_pos().x,
				"y": member_player(member).get_pos().y
				}

			send_p2p_packet(0, data)
		

func member_player(member):
	for player in get_parent().get_node("Players").get_children():
		if player.member == member:
			return player
			
func refresh_lobby_members():

	for child in $"%GridContainer".get_children():
		child.free()
	print(SteamLobby.lobby_members)
	add_lobby_members()
	update_member_data()
func leave_lobby() -> void:
	if SteamLobby.lobby_id != 0:
		Steam.leaveLobby(SteamLobby.lobby_id)
		
		for this_member in SteamLobby.lobby_members:
			if this_member['steam_id'] != SteamLobby.steam_id:
				Steam.closeP2PSessionWithUser(this_member['steam_id'])
		
		SteamLobby.lobby_members.clear()    
		SteamLobby.lobby_id = 0  
		get_parent().hide()          
		hide()
		print("Left lobby, ID is now: ", SteamLobby.lobby_id)
