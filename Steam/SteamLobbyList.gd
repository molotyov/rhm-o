extends Control

signal joined_lobby_success()
signal new_player_joined()

func _ready() -> void:
	$"%CreateLobbyButton".connect("pressed", self, "_on_create_lobby_button_pressed")
	Steam.connect("lobby_joined", self, "_on_lobby_joined_confirmed")
	Steam.connect("lobby_match_list", self, "_on_lobby_match_list")

func _on_lobby_joined_confirmed(this_lobby_id: int, _permissions: int, _locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		print("worked!")
		emit_signal("joined_lobby_success") 
		emit_signal("new_player_joined")
		
func _on_lobby_match_list(these_lobbies: Array) -> void:
	for this_lobby in these_lobbies:
		var lobby_num_members: int = Steam.getNumLobbyMembers(this_lobby)
		var lobby_name = Steam.getLobbyData(this_lobby, "host_name")  # ✅ fixed
		var lobby_button: Button = Button.new()
		lobby_button.set_text("%s's Lobby [%s] Player(s)" % [lobby_name, lobby_num_members])
		lobby_button.set_size(Vector2(40, 20))
		lobby_button.set_name("lobby_%s" % this_lobby)
		lobby_button.connect("pressed", self, "_on_join_lobby_pressed", [this_lobby])
		$"%GridContainer".add_child(lobby_button)

func clear_lobby_list():
	for child in $"%GridContainer".get_children():
		child.free()

func _on_join_lobby_pressed(this_lobby: int):
	SteamLobby.join_lobby(this_lobby) 

func _on_create_lobby_button_pressed():
	SteamLobby.create_lobby()
	

func _on_RefreshLobby_pressed():
	clear_lobby_list()
	SteamLobby.request_lobby_list()
	pass
