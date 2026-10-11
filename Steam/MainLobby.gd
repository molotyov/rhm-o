extends Node2D
 
 
func show():
	.show()
	$"%Camera".make_current()
	U.is_in_lobby = true
 
 
func _ready():
	$"%SteamLobby".connect("lobby_member_added", self, "_on_lobby_member_added")
 
 
func _get_player_id(player) -> int:
	if player.member == null:
		return 0
	if typeof(player.member) == TYPE_DICTIONARY:
		return int(player.member.get("steam_id", 0))
	return int(player.member)
 
 
func _on_lobby_member_added():
	var current_ids := []
	for member in SteamLobby.lobby_members:
		current_ids.append(int(member["steam_id"]))
 

	for player in $"%Players".get_children():
		var pid := _get_player_id(player)
		if pid != 0 and not current_ids.has(pid):
			player.queue_free()
 

	for member in SteamLobby.lobby_members:
		var already_exists := false
 
		for player in $"%Players".get_children():
			if player.is_queued_for_deletion():
				continue
			if _get_player_id(player) == int(member["steam_id"]):
				already_exists = true
				break
 
		if already_exists:
			continue
 
		var user = preload("res://Steam/lobbychar/Player.tscn").instance()
		user.member = member
		$"%Players".add_child(user)
		user.update_avatar()
 
