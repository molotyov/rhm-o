extends Node2D



func show():
	.show()
	$"%Camera".make_current()
	U.is_in_lobby = true

func _ready():
	$"%SteamLobby".connect("lobby_member_added", self, "_on_lobby_member_added")


func _on_lobby_member_added():
	print("Added lobby member!")

	for member in SteamLobby.lobby_members:
		var already_exists = false

		for player in $"%Players".get_children():
			if player.member == null:
				continue

			var player_steam_id = 0

			if typeof(player.member) == TYPE_DICTIONARY:
				player_steam_id = int(player.member.get("steam_id", 0))
			else:
				player_steam_id = int(player.member)

#			if player_steam_id == int(member["steam_id"]):
#				already_exists = true
#				break

		if already_exists:
			continue

		var user = preload("res://Steam/lobbychar/Player.tscn").instance()
		user.member = member

		$"%Players".add_child(user)


		user.update_avatar()
