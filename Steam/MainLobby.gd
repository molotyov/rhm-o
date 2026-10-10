extends Node2D



func show():
	.show()
	$"%Camera".make_current()
	U.is_in_lobby = true

func _ready():
	$"%SteamLobby".connect("lobby_member_added", self, "_on_lobby_member_added")

func _on_lobby_member_added():
	print("added lobby member!")
	for member in SteamLobby.lobby_members:
		var user = preload("res://Steam/lobbychar/Player.tscn").instance()
		user.member = member
		var AVATAR = Image.new()
		$"%Players".add_child(user)
		print(member["steam_name"])
		SteamLobby.lobby_users.append(member)
	for child in $"%Players".get_children():
		child.update_avatar()
		emit_signal("lobby_member_added")
